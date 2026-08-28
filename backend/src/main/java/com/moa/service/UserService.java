package com.moa.service;

import com.moa.dto.request.CompleteProfileRequest;
import com.moa.dto.response.UserResponse;
import com.moa.entity.User;
import com.moa.filter.exception.DuplicateNicknameException;
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserResponse getMyInfo(Long userId) {
        User user = findUserOrThrow(userId);
        return UserResponse.from(user);
    }

    /**
     * 회원가입 화면('회원 정보 입력')에서 제출한 추가 정보를 저장한다.
     * 저장에 성공하면 User.isProfileCompleted()가 true가 되어, 이후 로그인/세션
     * 복원 시 클라이언트가 메인 화면으로 보낼 수 있게 된다.
     */
    @Transactional
    public UserResponse completeProfile(Long userId, CompleteProfileRequest request) {
        User user = findUserOrThrow(userId);

        userRepository.findByNickname(request.nickname())
                .filter(other -> !other.getId().equals(userId))
                .ifPresent(other -> {
                    throw new DuplicateNicknameException("이미 사용 중인 닉네임이에요: " + request.nickname());
                });

        user.completeProfile(request.name(), request.nickname(), request.major(), request.studentId());
        User saved = userRepository.save(user);
        return UserResponse.from(saved);
    }

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new InvalidAuthTokenException("사용자를 찾을 수 없습니다."));
    }
}
