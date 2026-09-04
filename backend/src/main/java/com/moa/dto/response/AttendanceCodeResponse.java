package com.moa.dto.response;

import com.moa.entity.AttendanceCode;

import java.time.LocalDate;

/**
 * openapi.yaml의 AttendanceCode 스키마(GET /clubs/{clubId}/attendance/code)와
 * 매핑되는 응답 DTO. 스터디 관리 페이지의 "출석번호 확인" 화면이 오늘 발급된
 * (또는 방금 새로 발급한) 4자리 코드를 그대로 보여주는 데 쓴다.
 */
public record AttendanceCodeResponse(
        String code,
        LocalDate date
) {

    public static AttendanceCodeResponse of(AttendanceCode attendanceCode) {
        return new AttendanceCodeResponse(
                attendanceCode.getCode(),
                attendanceCode.getAttendanceDate()
        );
    }
}
