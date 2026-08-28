package com.moa.filter.exception;

/**
 * Firebase ID Token 또는 MOA 자체 JWT가 유효하지 않을 때 발생한다.
 */
public class InvalidAuthTokenException extends RuntimeException {

    public InvalidAuthTokenException(String message) {
        super(message);
    }

    public InvalidAuthTokenException(String message, Throwable cause) {
        super(message, cause);
    }
}
