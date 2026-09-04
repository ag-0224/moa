package com.moa.dto.response;

import com.moa.constant.ClubApplicationStatus;
import com.moa.entity.ClubApplication;

import java.time.OffsetDateTime;

/**
 * 가입 신청 목록/승인/거절(GET·POST /clubs/{clubId}/applications...) 응답
 * 한 건. 관리자(동아리장) 전용 API에서만 쓰인다.
 */
public record ClubApplicationResponse(
        Long id,
        Long userId,
        String applicantName,
        String selfIntroduction,
        ClubApplicationStatus status,
        OffsetDateTime appliedAt
) {

    public static ClubApplicationResponse of(ClubApplication application) {
        return new ClubApplicationResponse(
                application.getId(),
                application.getUser().getId(),
                application.getUser().getName(),
                application.getSelfIntroduction(),
                application.getStatus(),
                application.getCreatedAt()
        );
    }
}
