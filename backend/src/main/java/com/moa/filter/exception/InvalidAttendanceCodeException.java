package com.moa.filter.exception;

/**
 * "출석 하기" 버튼에서 입력한 출석번호가 오늘의 정답과 다를 때 발생한다.
 */
public class InvalidAttendanceCodeException extends RuntimeException {
    public InvalidAttendanceCodeException(String message) {
        super(message);
    }
}
