package com.moa.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.moa.config.jwt.TokenProvider;
import com.moa.constant.Provider;
import com.moa.dto.response.LoginResponse;
import com.moa.dto.response.UserResponse;
import com.moa.entity.User;
import com.moa.filter.exception.DuplicateEmailException;
import com.moa.filter.exception.FirebaseNotConfiguredException;
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.Optional;

/**
 * Firebase Authentication(구글/애플)으로 발급된 ID Token을 검증하고,
 * 최초 로그인이면 사용자를 생성한 뒤 MOA 자체 액세스 토큰(JWT)을 발급한다.
 */
@Service
public class AuthService {

    private final Optional<FirebaseAuth> firebaseAuth;
    private final UserRepository userRepository;
    private final TokenProvider tokenProvider;
    private final String activeProfile;

    @org.springframework.beans.factory.annotation.Autowired
    public AuthService(
            Optional<FirebaseAuth> firebaseAuth,
            UserRepository userRepository,
            TokenProvider tokenProvider,
            @Value("${spring.profiles.active:local}") String activeProfile
    ) {
        this.firebaseAuth = firebaseAuth;
        this.userRepository = userRepository;
        this.tokenProvider = tokenProvider;
        this.activeProfile = activeProfile;
    }

    public AuthService(
            Optional<FirebaseAuth> firebaseAuth,
            UserRepository userRepository,
            TokenProvider tokenProvider
    ) {
        this(firebaseAuth, userRepository, tokenProvider, "prod");
    }

    @Transactional
    public LoginResponse login(String idToken) {
        if (firebaseAuth.isEmpty()) {
            if ("local".equalsIgnoreCase(activeProfile)) {
                String devEmail = "user@moa.com";
                String devName = "MOA 개발 사용자";
                String devProviderUid = "dev_provider_uid_12345";
                User user = findOrCreateUser(devEmail, devName, Provider.GOOGLE, devProviderUid);

                String accessToken = tokenProvider.createToken(user.getId(), user.getRole());
                return new LoginResponse(accessToken, tokenProvider.getExpirationSeconds(), UserResponse.from(user));
            }
            throw new FirebaseNotConfiguredException();
        }

        FirebaseAuth auth = firebaseAuth.get();
        FirebaseToken decoded = verify(auth, idToken);

        Provider provider = resolveProvider(decoded);
        String providerUid = decoded.getUid();
        String email = requireNonBlank(decoded.getEmail(), "Firebase 토큰에 이메일 정보가 없습니다.");
        String name = resolveName(decoded, email);

        User user = findOrCreateUser(email, name, provider, providerUid);

        String accessToken = tokenProvider.createToken(user.getId(), user.getRole());
        return new LoginResponse(accessToken, tokenProvider.getExpirationSeconds(), UserResponse.from(user));
    }

    /**
     * (provider, providerUid)로 기존 사용자를 찾고, 없으면 새로 만든다.
     *
     * 주의 1: 같은 이메일이 다른 provider로 이미 가입돼 있으면(예: 구글로 가입한
     * 이메일과 같은 이메일로 애플 로그인 시도) users.email UNIQUE 제약을 위반하므로,
     * 저장을 시도하기 전에 먼저 email로 조회해 명확한 에러로 처리한다.
     *
     * 주의 2: 같은 사용자가 동시에 두 번 로그인 요청을 보내는 경쟁 상태(race condition)에서는
     * 두 요청 모두 "존재하지 않음"을 보고 둘 다 저장을 시도할 수 있다. 이 경우 users.provider/
     * provider_uid UNIQUE 제약을 위반하는 쪽에서 DataIntegrityViolationException이 발생하는데,
     * 이미 다른 요청이 만든 행을 다시 조회해서 반환한다(로그인 자체는 실패로 취급하지 않는다).
     */
    private User findOrCreateUser(String email, String name, Provider provider, String providerUid) {
        Optional<User> existing = userRepository.findByProviderAndProviderUid(provider, providerUid);
        if (existing.isPresent()) {
            return existing.get();
        }

        if (userRepository.findByEmail(email).isPresent()) {
            throw new DuplicateEmailException("이미 다른 로그인 방식으로 가입된 이메일입니다: " + email);
        }

        try {
            return userRepository.save(User.createOAuthUser(email, name, provider, providerUid));
        } catch (DataIntegrityViolationException e) {
            return userRepository.findByProviderAndProviderUid(provider, providerUid)
                    .orElseThrow(() -> new DuplicateEmailException(
                            "이미 다른 로그인 방식으로 가입된 이메일입니다: " + email));
        }
    }

    private FirebaseToken verify(FirebaseAuth auth, String idToken) {
        try {
            return auth.verifyIdToken(idToken);
        } catch (FirebaseAuthException e) {
            throw new InvalidAuthTokenException("Firebase ID 토큰 검증에 실패했습니다.", e);
        }
    }

    private Provider resolveProvider(FirebaseToken decoded) {
        Object firebaseClaim = decoded.getClaims().get("firebase");
        String signInProvider = null;
        if (firebaseClaim instanceof Map<?, ?> claims) {
            Object value = claims.get("sign_in_provider");
            signInProvider = value != null ? value.toString() : null;
        }
        if (signInProvider == null) {
            throw new InvalidAuthTokenException("Firebase 토큰에서 로그인 제공자 정보를 확인할 수 없습니다.");
        }
        try {
            return Provider.fromFirebaseSignInProvider(signInProvider);
        } catch (IllegalArgumentException e) {
            throw new InvalidAuthTokenException(e.getMessage());
        }
    }

    private String resolveName(FirebaseToken decoded, String email) {
        String name = decoded.getName();
        if (name != null && !name.isBlank()) {
            return name;
        }
        int atIndex = email.indexOf('@');
        return atIndex > 0 ? email.substring(0, atIndex) : email;
    }

    private String requireNonBlank(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new InvalidAuthTokenException(message);
        }
        return value;
    }
}
