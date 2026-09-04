package com.moa.constant;

/**
 * 하루치 출석을 화면에 표시할 때 쓰는 상태. AttendanceOverviewResponse/
 * MyStudyInfoResponse가 이 값을 내려준다.
 *
 * AttendanceStatus(실제 저장되는 값: PRESENT/VACATION)와 달리 ABSENT/UPCOMING을
 * 포함한다 — 이 둘은 attendance_records에 저장되지 않고 AttendanceService가
 * "그 날짜에 행이 있는지 + 오늘/미래인지"를 보고 계산해서 채운다.
 */
public enum AttendanceMark {
    /** 출석. */
    PRESENT,

    /** 결석(그 날짜에 attendance_records 행이 없음, 지나간 날짜). */
    ABSENT,

    /** 휴가 처리됨(결석으로 집계하지 않음). */
    VACATION,

    /** 아직 오지 않은 날, 또는 오늘인데 아직 출석/휴가를 정하지 않음. */
    UPCOMING
}
