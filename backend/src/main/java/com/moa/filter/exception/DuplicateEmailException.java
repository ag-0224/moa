package com.moa.filter.exception;

/**
 * 다른 로그인 제공자(Provider)로 이미 가입된 이메일로 로그인을 시도할 때 발생한다.
 * 예: 구글로 가입한 이메일과 같은 이메일로 애플 로그인을 시도하는 경우.
 */
public class DuplicateEmailException extends RuntimeException {

    public DuplicateEmailException(String message) {
        super(message);
    }
}
