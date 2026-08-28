package com.moa.dto.response;

import com.moa.entity.Club;

/**
 * openapi.yaml의 Club 스키마(GET /clubs, GET /clubs/me, PATCH /clubs/{clubId}/favorite)와
 * 매핑되는 응답 DTO.
 *
 * joined/favorite는 Club 자체가 아니라 "요청한 사용자 기준"으로 계산되는 값이라
 * Club 엔티티가 아니라 ClubService가 채워서 넘긴다(User.profileCompleted처럼
 * 엔티티 안에서 계산할 수 있는 값이 아님에 주의).
 *
 * 필드 이름을 isJoined/isFavorite가 아니라 joined/favorite로 지은 이유는
 * UserResponse.profileCompleted와 같은 규칙("is" 접두사 없이 그냥 형용사)을
 * 따르기 위해서다 — record의 boolean 컴포넌트에 is 접두사를 붙이면 Jackson이
 * JavaBean 스타일 getter(isJoined())로 오인해 "joined"로 벗겨서 직렬화할 수도
 * 있다는 모호함 자체를 피한다.
 */
public record ClubResponse(
        Long id,
        String name,
        String leaderName,
        String category,
        int memberCount,
        String thumbnailUrl,
        boolean joined,
        boolean favorite
) {

    public static ClubResponse of(Club club, boolean joined, boolean favorite) {
        return new ClubResponse(
                club.getId(),
                club.getName(),
                club.getLeaderName(),
                club.getCategory(),
                club.getMemberCount(),
                club.getThumbnailUrl(),
                joined,
                favorite
        );
    }
}
