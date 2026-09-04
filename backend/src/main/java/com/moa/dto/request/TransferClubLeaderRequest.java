package com.moa.dto.request;

import jakarta.validation.constraints.NotNull;

/**
 * openapi.yaml PATCH /clubs/{clubId}/leader 요청 스키마와 매핑되는 요청 DTO.
 * newLeaderId는 반드시 그 동아리의 기존 가입 멤버여야 한다(ClubService.transferLeadership).
 */
public record TransferClubLeaderRequest(
        @NotNull(message = "관리자 권한을 넘겨받을 사용자를 선택해주세요.")
        Long newLeaderId
) {
}
