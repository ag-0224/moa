package com.moa.repository;

import com.moa.constant.AttendanceStatus;
import com.moa.entity.AttendanceRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AttendanceRecordRepository extends JpaRepository<AttendanceRecord, Long> {

    /**
     * 출석현황 탭의 이번 주 출석 도장(요일별 칸)을 만들 때, 스터디 전체
     * 인원의 이번 주 기록을 한 번에 가져오는 데 쓴다.
     */
    List<AttendanceRecord> findByClubIdAndAttendanceDateBetween(Long clubId, LocalDate startDate, LocalDate endDate);

    /**
     * "내 정보" 탭의 월별 출석 달력을 만들 때, 로그인한 사용자 한 명의 그 달
     * 기록만 가져오는 데 쓴다.
     */
    List<AttendanceRecord> findByClubIdAndUserIdAndAttendanceDateBetween(
            Long clubId, Long userId, LocalDate startDate, LocalDate endDate);

    /**
     * 출석번호 입력/휴가 사용 시, 오늘 이미 기록이 있는지(있으면 상태만 바꿔야
     * 하는지) 확인하는 데 쓴다.
     */
    Optional<AttendanceRecord> findByClubIdAndUserIdAndAttendanceDate(Long clubId, Long userId, LocalDate date);

    /**
     * 이번 학기 누적 휴가 사용 일수. 특정 달에 국한하지 않고 전체 기록을 센다
     * — 휴가 총 한도(ClubMember.vacationDaysTotal)와 같은 기준(누적)으로
     * 비교해야 하기 때문이다.
     */
    long countByClubIdAndUserIdAndStatus(Long clubId, Long userId, AttendanceStatus status);
}
