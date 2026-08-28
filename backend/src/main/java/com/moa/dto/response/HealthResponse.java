package com.moa.dto.response;

import java.time.OffsetDateTime;

/**
 * openapi.yaml GET /health 응답 스키마(status, timestamp)와 매핑되는 응답 DTO.
 */
public record HealthResponse(String status, OffsetDateTime timestamp) {
}
