package com.moa.filter.exception;

/**
 * 이미 가입한(club_members에 행이 있는) 동아리에 다시 지원하려고 할 때 발생한다.
 */
public class ClubAlreadyJoinedException extends RuntimeException {
    public ClubAlreadyJoinedException(String message) {
        super(message);
    }
}
