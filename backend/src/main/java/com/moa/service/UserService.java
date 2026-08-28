package com.moa.service;

import com.moa.dto.request.CompleteProfileRequest;
import com.moa.dto.response.UserResponse;
import com.moa.entity.User;
import com.moa.filter.exception.DuplicateNicknameException;
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.repository.ClubApplicationRepository;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final ClubApplicationRepository clubApplicationRepository;

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

    /**
     * 마이페이지('내 정보')의 '회원 탈퇴' 버튼이 호출한다. 계정을 완전히
     * 삭제한다(soft delete 없음 — 이번 범위에서는 정말로 행을 지운다).
     *
     * users.id를 참조하는 club_members/club_applications에는 ON DELETE CASCADE가
     * 걸려있지 않아서(schema.sql), 사용자 행을 지우기 전에 그 두 테이블의 관련
     * 행을 먼저 지워야 FK 제약 위반이 나지 않는다. Club.memberCount는 이
     * 삭제로 갱신되지 않는데, 이미 문서화된 대로(Club 엔티티 Javadoc)
     * memberCount는 club_members를 실시간으로 세지 않고 저장된 값을 그대로
     * 쓰는 의도적인 단순화라 이 메서드의 새로운 문제는 아니다.
     */
    @Transactional
    public void deleteAccount(Long userId) {
        User user = findUserOrThrow(userId);
        clubApplicationRepository.deleteByUserId(userId);
        clubMemberRepository.deleteByUserId(userId);
        userRepository.delete(user);
    }

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new InvalidAuthTokenException("사용자를 찾을 수 없습니다."));
    }
}
