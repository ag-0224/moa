package com.moa.filter.exception;

/**
 * 이미 APPROVED/REJECTED로 처리된 신청서를 다시 승인/거절하려 할 때 발생한다.
 * 특히 승인을 중복 처리하면 club_members가 두 번 생기거나 memberCount가
 * 두 번 늘어날 수 있어서 반드시 막아야 한다.
 */
public class ClubApplicationNotPendingException extends RuntimeException {
    public ClubApplicationNotPendingException(String message) {
        super(message);
    }
}
