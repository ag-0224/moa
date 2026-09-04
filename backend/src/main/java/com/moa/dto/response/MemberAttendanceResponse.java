package com.moa.dto.response;

import com.moa.constant.AttendanceMark;

import java.util.List;

/**
 * 스터디 출석 현황 탭의 인원 목록 한 행.
 */
public record MemberAttendanceResponse(
        Long memberId,
        String name,
        boolean isMe,
        AttendanceMark todayMark,
        List<AttendanceMark> weeklyMarks,
        int vacationDaysUsed
) {
}
