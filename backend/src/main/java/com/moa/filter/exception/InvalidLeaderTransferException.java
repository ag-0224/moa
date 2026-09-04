package com.moa.filter.exception;

/**
 * 관리자 권한을 이미 관리자인 사용자(자기 자신)에게 넘기려고 할 때 발생한다.
 */
public class InvalidLeaderTransferException extends RuntimeException {
    public InvalidLeaderTransferException(String message) {
        super(message);
    }
}
