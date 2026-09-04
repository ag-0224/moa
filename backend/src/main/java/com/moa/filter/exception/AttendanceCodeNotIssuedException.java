package com.moa.filter.exception;

/**
 * 오늘 그 스터디의 출석번호가 아직 발급(시딩)되지 않았을 때 발생한다.
 *
 * 아직 동아리장이 매일 번호를 발급하는 화면/API가 없어서(attendance_codes
 * 테이블 주석 참고 — clubs.leader_id는 생겼지만 발급 API 자체는 별도 이슈)
 * 로컬 개발 데이터(data.sql)로 시딩된 스터디가 아니면 이 예외가 난다.
 */
public class AttendanceCodeNotIssuedException extends RuntimeException {
    public AttendanceCodeNotIssuedException(String message) {
        super(message);
    }
}
