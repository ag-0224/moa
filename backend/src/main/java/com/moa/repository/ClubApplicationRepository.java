package com.moa.repository;

import com.moa.constant.ClubApplicationStatus;
import com.moa.entity.ClubApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ClubApplicationRepository extends JpaRepository<ClubApplication, Long> {

    Optional<ClubApplication> findByClubIdAndUserId(Long clubId, Long userId);

    /**
     * 가입 신청 관리 화면(GET /clubs/{clubId}/applications)이 아직 처리하지
     * 않은 신청서만 보여주는 데 쓴다.
     */
    List<ClubApplication> findByClubIdAndStatus(Long clubId, ClubApplicationStatus status);

    /**
     * 회원 탈퇴(UserService.deleteAccount) 시 club_applications에 남아있는 신청
     * 행을 먼저 정리하기 위해 쓴다. ClubMemberRepository.deleteByUserId와 같은
     * 이유(FK 제약)로 필요하다.
     */
    void deleteByUserId(Long userId);

    /**
     * 스터디 삭제(ClubService.deleteClub) 시 club_applications에 남아있는
     * 신청 행을 먼저 정리하기 위해 쓴다. FK 제약 때문에 club_members와
     * 마찬가지로 clubs 행보다 먼저 지워야 한다.
     */
    void deleteByClubId(Long clubId);
}
