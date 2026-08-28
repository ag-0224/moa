package com.moa.dto.request;

import jakarta.validation.constraints.NotBlank;

/**
 * openapi.yaml POST /auth/login 요청 스키마와 매핑되는 요청 DTO.
 */
public record LoginRequest(@NotBlank String idToken) {
}
