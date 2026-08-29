package com.moa.filter.exception;

/**
 * "스터디 등록" 화면에서 스터디 이름이 비어있거나 길이 제한을 넘는 등,
 * 형식 자체가 사용 불가능할 때 던진다. 이미 존재하는 이름과 겹치는 경우는
 * 이 예외가 아니라 DuplicateClubNameException을 쓴다.
 */
public class InvalidClubNameException extends RuntimeException {
    public InvalidClubNameException(String message) {
        super(message);
    }
}
