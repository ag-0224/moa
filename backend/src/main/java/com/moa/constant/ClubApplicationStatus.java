package com.moa.constant;

/**
 * club_applications.status 컬럼과 매핑되는 동아리 가입 신청 상태.
 *
 * PENDING으로 생성되며, 동아리장이 승인/거절하면 APPROVED/REJECTED로 바뀐다.
 * TODO(leader-approval): 아직 APPROVED/REJECTED로 바꿔주는 승인/거절
 * 엔드포인트가 없다(동아리장 기능은 이번 범위 밖). 지금은 신청서를 내면
 * PENDING 상태로 남아있고, REJECTED일 때만 재신청(resubmit)이 가능하다.
 */
public enum ClubApplicationStatus {
    PENDING,
    APPROVED,
    REJECTED
}
