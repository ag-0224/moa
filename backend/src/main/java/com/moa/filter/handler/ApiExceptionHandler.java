package com.moa.filter.handler;

import com.moa.dto.response.ApiError;
import com.moa.dto.response.ApiResponse;
import com.moa.filter.exception.FirebaseNotConfiguredException;
import com.moa.filter.exception.InvalidAuthTokenException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.List;

/**
 * docs/API_CONTRACT.md의 표준 에러 응답 포맷으로 예외를 변환하는 전역 핸들러.
 */
@RestControllerAdvice
public class ApiExceptionHandler {

    @ExceptionHandler(InvalidAuthTokenException.class)
    public ResponseEntity<ApiResponse<Void>> handleInvalidAuthToken(InvalidAuthTokenException e) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.failure(new ApiError("INVALID_AUTH_TOKEN", e.getMessage(), List.of())));
    }

    @ExceptionHandler(FirebaseNotConfiguredException.class)
    public ResponseEntity<ApiResponse<Void>> handleFirebaseNotConfigured(FirebaseNotConfiguredException e) {
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(ApiResponse.failure(new ApiError("FIREBASE_NOT_CONFIGURED", e.getMessage(), List.of())));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException e) {
        List<String> details = e.getBindingResult().getFieldErrors().stream()
                .map(fieldError -> fieldError.getField() + ": " + fieldError.getDefaultMessage())
                .toList();
        return ResponseEntity.badRequest()
                .body(ApiResponse.failure(new ApiError("INVALID_REQUEST", "요청 값이 올바르지 않습니다.", details)));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleUnexpected(Exception e) {
        return ResponseEntity.internalServerError()
                .body(ApiResponse.failure(new ApiError("INTERNAL_ERROR", "예상하지 못한 오류가 발생했습니다.", List.of())));
    }
}
