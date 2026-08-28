package com.moa.dto.response;

import com.moa.constant.ClubApplicationStatus;
import com.moa.entity.Club;

/**
 * 동아리 상세(가입 전 소개/지원) 화면 전용 응답. 목록용 ClubResponse와 달리
 * description을 포함하고, 가입 여부 대신(가입했으면 굳이 지원 상태가 필요 없어서)
 * applicationStatus로 신청 진행 상태를 함께 내려준다.
 *
 * applicationStatus는 joined가 true면 항상 null이다. joined가 false일 때만
 * null(아직 신청 안 함)/PENDING(승인 대기 중)/REJECTED(거절됨, 재신청 가능)
 * 셋 중 하나가 온다.
 */
public record ClubDetailResponse(
        Long id,
        String name,
        String leaderName,
        String category,
        int memberCount,
        String description,
        String thumbnailUrl,
        boolean joined,
        boolean favorite,
        ClubApplicationStatus applicationStatus
) {

    public static ClubDetailResponse of(
            Club club,
            boolean joined,
            boolean favorite,
            ClubApplicationStatus applicationStatus
    ) {
        return new ClubDetailResponse(
                club.getId(),
                club.getName(),
                club.getLeaderName(),
                club.getCategory(),
                club.getMemberCount(),
                club.getDescription(),
                club.getThumbnailUrl(),
                joined,
                favorite,
                joined ? null : applicationStatus
        );
    }
}
