package com.moa.filter.exception;

/**
 * 이번 학기 휴가를 이미 다 쓴 상태(vacationDaysUsed >= vacationDaysTotal)에서
 * 휴가를 또 사용하려고 할 때 발생한다. 프론트엔드(CheckInButton)는 이 상황을
 * 먼저 클라이언트에서 걸러서 확인 대신 안내 다이얼로그를 보여주므로, 이
 * 예외는 그 방어를 우회한 경우(동시 요청 등)를 위한 서버 측 안전장치다.
 */
public class VacationLimitExceededException extends RuntimeException {
    public VacationLimitExceededException(String message) {
        super(message);
    }
}
