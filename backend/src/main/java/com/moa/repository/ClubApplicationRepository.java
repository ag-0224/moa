package com.moa.repository;

import com.moa.entity.ClubApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClubApplicationRepository extends JpaRepository<ClubApplication, Long> {

    Optional<ClubApplication> findByClubIdAndUserId(Long clubId, Long userId);

    /**
     * 회원 탈퇴(UserService.deleteAccount) 시 club_applications에 남아있는 신청
     * 행을 먼저 정리하기 위해 쓴다. ClubMemberRepository.deleteByUserId와 같은
     * 이유(FK 제약)로 필요하다.
     */
    void deleteByUserId(Long userId);
}
