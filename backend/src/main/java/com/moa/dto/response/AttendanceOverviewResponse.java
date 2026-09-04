package com.moa.dto.response;

import java.time.LocalDate;
import java.util.List;

/**
 * 스터디 출석 현황 탭 전체 응답. weekStart는 이번 주 월요일이다.
 */
public record AttendanceOverviewResponse(
        LocalDate weekStart,
        List<MemberAttendanceResponse> members,
        int myVacationDaysUsed,
        int myVacationDaysTotal
) {
}
