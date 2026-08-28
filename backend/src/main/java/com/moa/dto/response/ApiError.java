package com.moa.dto.response;

import java.util.List;

/**
 * docs/API_CONTRACT.md 표준 에러 응답의 error 필드.
 */
public record ApiError(String code, String message, List<String> details) {
}
