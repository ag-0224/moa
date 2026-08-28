package com.moa.dto.response;

/**
 * docs/API_CONTRACT.md에 정의된 표준 응답 포맷({success, data, error}).
 * 주의: GET /health는 이 포맷이 정해지기 전에 만들어진 예외라 감싸지 않는다.
 * 새 엔드포인트는 모두 이 래퍼를 사용한다.
 */
public record ApiResponse<T>(boolean success, T data, ApiError error) {

    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, data, null);
    }

    public static <T> ApiResponse<T> failure(ApiError error) {
        return new ApiResponse<>(false, null, error);
    }
}
