package com.moa.constant;

/**
 * attendance_records.status 컬럼과 매핑되는, 실제로 저장되는 출석 상태.
 *
 * 결석(ABSENT)은 여기 없다 — "그 날짜에 행이 없다"가 곧 결석이라는 뜻이라
 * 별도로 저장하지 않는다(schema.sql의 attendance_records 테이블 주석 참고).
 * 화면에 보여줄 때 쓰는 ABSENT/UPCOMING까지 포함한 4가지 표시 상태는
 * {@link AttendanceMark}를 쓴다.
 */
public enum AttendanceStatus {
    PRESENT,
    VACATION
}
