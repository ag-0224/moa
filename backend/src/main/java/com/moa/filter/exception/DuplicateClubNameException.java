package com.moa.filter.exception;

/**
 * "스터디 등록" 화면에서 이미 존재하는 동아리(스터디) 이름으로 등록을
 * 시도했을 때 던진다.
 */
public class DuplicateClubNameException extends RuntimeException {
    public DuplicateClubNameException(String message) {
        super(message);
    }
}
