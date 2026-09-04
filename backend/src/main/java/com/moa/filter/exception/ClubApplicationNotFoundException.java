package com.moa.filter.exception;

/**
 * 승인/거절하려는 가입 신청서가 존재하지 않거나, 존재하더라도 그 동아리
 * (clubId) 소속이 아닐 때 발생한다.
 */
public class ClubApplicationNotFoundException extends RuntimeException {
    public ClubApplicationNotFoundException(String message) {
        super(message);
    }
}
