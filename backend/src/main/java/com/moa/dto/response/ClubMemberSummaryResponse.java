package com.moa.dto.response;

import com.moa.entity.ClubMember;

/**
 * 동아리 멤버 목록(GET /clubs/{clubId}/members) 한 행. 관리자 권한 넘기기
 * 화면에서 넘겨줄 대상을 고르는 데 쓴다.
 *
 * leader는 Club 자체가 아니라 "그 동아리의 leader_id와 이 멤버의 user_id가
 * 같은지"로 계산되는 값이라(ClubResponse.joined/favorite와 같은 이유),
 * ClubMember 엔티티가 아니라 ClubService가 채워서 넘긴다.
 */
public record ClubMemberSummaryResponse(
        Long userId,
        String name,
        boolean leader
) {

    public static ClubMemberSummaryResponse of(ClubMember member, boolean leader) {
        return new ClubMemberSummaryResponse(
                member.getUser().getId(),
                member.getUser().getName(),
                leader
        );
    }
}
