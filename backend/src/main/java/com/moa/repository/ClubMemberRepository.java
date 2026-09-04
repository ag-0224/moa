package com.moa.repository;

import com.moa.entity.ClubMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ClubMemberRepository extends JpaRepository<ClubMember, Long> {

    List<ClubMember> findByUserId(Long userId);

    Optional<ClubMember> findByClubIdAndUserId(Long clubId, Long userId);

    /**
     * 스터디 출석 현황 탭(AttendanceService.getOverview)이 그 스터디에 가입한
     * 인원 전체를 나열하는 데 쓴다.
     */
    List<ClubMember> findByClubId(Long clubId);

    /**
     * 회원 탈퇴(UserService.deleteAccount) 시 club_members에 남아있는 가입 행을
     * 먼저 정리하기 위해 쓴다. users.id -> club_members.user_id에 ON DELETE
     * CASCADE가 걸려있지 않아서(schema.sql), 사용자 행을 지우기 전에 이 메서드로
     * 먼저 지워야 FK 제약 위반 없이 삭제할 수 있다.
     */
    void deleteByUserId(Long userId);
}
