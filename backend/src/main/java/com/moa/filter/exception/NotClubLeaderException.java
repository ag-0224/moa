package com.moa.filter.exception;

/**
 * 동아리장(관리자)만 호출할 수 있는 API를 다른 멤버가 호출했을 때 발생한다.
 * 관리자 권한 넘기기, 가입 신청 승인/거절이 여기 해당한다.
 */
public class NotClubLeaderException extends RuntimeException {
    public NotClubLeaderException(String message) {
        super(message);
    }
}
