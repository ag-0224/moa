package com.moa.dto.response;

/**
 * openapi.yaml POST /auth/login 응답 스키마와 매핑되는 응답 DTO.
 */
public record LoginResponse(String accessToken, long expiresInSeconds, UserResponse user) {
}
