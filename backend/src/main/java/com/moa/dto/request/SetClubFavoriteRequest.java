package com.moa.dto.request;

/**
 * openapi.yaml PATCH /clubs/{clubId}/favorite 요청 스키마와 매핑되는 요청 DTO.
 */
public record SetClubFavoriteRequest(boolean favorite) {
}
