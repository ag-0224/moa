package com.moa.repository;

import com.moa.entity.AttendanceCode;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;

public interface AttendanceCodeRepository extends JpaRepository<AttendanceCode, Long> {

    /**
     * "출석 하기" 버튼이 입력받은 코드를 검증할 때, 오늘 그 스터디의 정답
     * 코드를 조회하는 데 쓴다.
     */
    Optional<AttendanceCode> findByClubIdAndAttendanceDate(Long clubId, LocalDate attendanceDate);

    /**
     * 스터디 삭제(ClubService.deleteClub) 시 attendance_codes에 남아있는
     * 발급 기록을 먼저 정리하기 위해 쓴다. FK 제약상 clubs 행보다 먼저
     * 지워야 한다.
     */
    void deleteByClubId(Long clubId);
}
