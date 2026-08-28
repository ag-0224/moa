package com.moa.filter.exception;

/**
 * 이미 승인 대기(PENDING) 중인 신청서가 있는 동아리에 또 지원하려고 할 때 발생한다.
 * REJECTED 상태에서는 재신청이 허용되므로 이 예외를 던지지 않는다.
 */
public class ClubApplicationAlreadyPendingException extends RuntimeException {
    public ClubApplicationAlreadyPendingException(String message) {
        super(message);
    }
}
