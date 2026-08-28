package com.moa.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.moa.config.jwt.JwtProperties;
import com.moa.config.jwt.TokenProvider;
import com.moa.constant.Provider;
import com.moa.dto.response.LoginResponse;
import com.moa.entity.User;
import com.moa.filter.exception.DuplicateEmailException;
import com.moa.filter.exception.FirebaseNotConfiguredException;
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;

import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    private static final String TEST_SECRET = "test-secret-key-must-be-at-least-32-bytes-long!";

    @Mock
    private FirebaseAuth firebaseAuth;

    @Mock
    private UserRepository userRepository;

    @Mock
    private FirebaseToken firebaseToken;

    private TokenProvider tokenProvider;

    @BeforeEach
    void setUp() {
        tokenProvider = new TokenProvider(new JwtProperties(TEST_SECRET, 60_000L));
    }

    @Test
    void loginCreatesNewUserWhenNotFound() throws FirebaseAuthException {
        AuthService authService = new AuthService(Optional.of(firebaseAuth), userRepository, tokenProvider);

        when(firebaseAuth.verifyIdToken(anyString())).thenReturn(firebaseToken);
        when(firebaseToken.getUid()).thenReturn("firebase-uid-1");
        when(firebaseToken.getEmail()).thenReturn("user@example.com");
        when(firebaseToken.getName()).thenReturn("Test User");
        when(firebaseToken.getClaims()).thenReturn(Map.of(
                "firebase", Map.of("sign_in_provider", "google.com")
        ));
        when(userRepository.findByProviderAndProviderUid(Provider.GOOGLE, "firebase-uid-1"))
                .thenReturn(Optional.empty());
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        LoginResponse response = authService.login("valid-token");

        assertThat(response.user().email()).isEqualTo("user@example.com");
        assertThat(response.user().role()).isEqualTo("USER");
        assertThat(response.accessToken()).isNotBlank();
    }

    @Test
    void loginReturnsExistingUserWithoutCreatingDuplicate() throws FirebaseAuthException {
        AuthService authService = new AuthService(Optional.of(firebaseAuth), userRepository, tokenProvider);
        User existing = User.createOAuthUser("existing@example.com", "Existing User", Provider.APPLE, "apple-uid-1");

        when(firebaseAuth.verifyIdToken(anyString())).thenReturn(firebaseToken);
        when(firebaseToken.getUid()).thenReturn("apple-uid-1");
        when(firebaseToken.getEmail()).thenReturn("existing@example.com");
        when(firebaseToken.getClaims()).thenReturn(Map.of(
                "firebase", Map.of("sign_in_provider", "apple.com")
        ));
        when(userRepository.findByProviderAndProviderUid(Provider.APPLE, "apple-uid-1"))
                .thenReturn(Optional.of(existing));

        LoginResponse response = authService.login("valid-token");

        assertThat(response.user().email()).isEqualTo("existing@example.com");
    }

    @Test
    void loginThrowsWhenFirebaseNotConfigured() {
        AuthService authService = new AuthService(Optional.empty(), userRepository, tokenProvider);

        assertThatThrownBy(() -> authService.login("any-token"))
                .isInstanceOf(FirebaseNotConfiguredException.class);
    }

    @Test
    void loginThrowsWhenTokenInvalid() throws FirebaseAuthException {
        AuthService authService = new AuthService(Optional.of(firebaseAuth), userRepository, tokenProvider);
        when(firebaseAuth.verifyIdToken(anyString())).thenThrow(mock(FirebaseAuthException.class));

        assertThatThrownBy(() -> authService.login("bad-token"))
                .isInstanceOf(InvalidAuthTokenException.class);
    }

    @Test
    void loginThrowsDuplicateEmailWhenEmailTakenByDifferentProvider() throws FirebaseAuthException {
        AuthService authService = new AuthService(Optional.of(firebaseAuth), userRepository, tokenProvider);
        User existingWithSameEmail =
                User.createOAuthUser("shared@example.com", "Existing User", Provider.GOOGLE, "google-uid-1");

        when(firebaseAuth.verifyIdToken(anyString())).thenReturn(firebaseToken);
        when(firebaseToken.getUid()).thenReturn("apple-uid-2");
        when(firebaseToken.getEmail()).thenReturn("shared@example.com");
        when(firebaseToken.getClaims()).thenReturn(Map.of(
                "firebase", Map.of("sign_in_provider", "apple.com")
        ));
        when(userRepository.findByProviderAndProviderUid(Provider.APPLE, "apple-uid-2"))
                .thenReturn(Optional.empty());
        when(userRepository.findByEmail("shared@example.com"))
                .thenReturn(Optional.of(existingWithSameEmail));

        assertThatThrownBy(() -> authService.login("valid-token"))
                .isInstanceOf(DuplicateEmailException.class);
    }

    @Test
    void loginRecoversFromRaceConditionOnConcurrentFirstLogin() throws FirebaseAuthException {
        AuthService authService = new AuthService(Optional.of(firebaseAuth), userRepository, tokenProvider);
        User createdByConcurrentRequest =
                User.createOAuthUser("racer@example.com", "Racer", Provider.GOOGLE, "racer-uid");

        when(firebaseAuth.verifyIdToken(anyString())).thenReturn(firebaseToken);
        when(firebaseToken.getUid()).thenReturn("racer-uid");
        when(firebaseToken.getEmail()).thenReturn("racer@example.com");
        when(firebaseToken.getName()).thenReturn("Racer");
        when(firebaseToken.getClaims()).thenReturn(Map.of(
                "firebase", Map.of("sign_in_provider", "google.com")
        ));
        // 첫 조회는 없음 -> save 시도 -> 유니크 제약 위반(동시 요청이 먼저 저장) -> 재조회 시 발견
        when(userRepository.findByProviderAndProviderUid(Provider.GOOGLE, "racer-uid"))
                .thenReturn(Optional.empty())
                .thenReturn(Optional.of(createdByConcurrentRequest));
        when(userRepository.findByEmail("racer@example.com")).thenReturn(Optional.empty());
        when(userRepository.save(any(User.class))).thenThrow(new DataIntegrityViolationException("dup"));

        LoginResponse response = authService.login("valid-token");

        assertThat(response.user().email()).isEqualTo("racer@example.com");
    }
}
