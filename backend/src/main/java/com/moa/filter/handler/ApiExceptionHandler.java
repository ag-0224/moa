package com.moa.filter.handler;

import com.moa.dto.response.ApiError;
import com.moa.dto.response.ApiResponse;
import com.moa.filter.exception.ClubAlreadyJoinedException;
import com.moa.filter.exception.ClubApplicationAlreadyPendingException;
import com.moa.filter.exception.ClubMembershipNotFoundException;
import com.moa.filter.exception.ClubNotFoundException;
import com.moa.filter.exception.DuplicateEmailException;
import com.moa.filter.exception.DuplicateNicknameException;
import com.moa.filter.exception.FirebaseNotConfiguredException;
import com.moa.filter.exception.InvalidAuthTokenException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

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

    @ExceptionHandler(DuplicateEmailException.class)
    public ResponseEntity<ApiResponse<Void>> handleDuplicateEmail(DuplicateEmailException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiResponse.failure(new ApiError("DUPLICATE_EMAIL", e.getMessage(), List.of())));
    }

    @ExceptionHandler(DuplicateNicknameException.class)
    public ResponseEntity<ApiResponse<Void>> handleDuplicateNickname(DuplicateNicknameException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiResponse.failure(new ApiError("DUPLICATE_NICKNAME", e.getMessage(), List.of())));
    }

    @ExceptionHandler(ClubNotFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleClubNotFound(ClubNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.failure(new ApiError("CLUB_NOT_FOUND", e.getMessage(), List.of())));
    }

    @ExceptionHandler(ClubMembershipNotFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleClubMembershipNotFound(ClubMembershipNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.failure(new ApiError("CLUB_MEMBERSHIP_NOT_FOUND", e.getMessage(), List.of())));
    }

    @ExceptionHandler(ClubAlreadyJoinedException.class)
    public ResponseEntity<ApiResponse<Void>> handleClubAlreadyJoined(ClubAlreadyJoinedException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiResponse.failure(new ApiError("CLUB_ALREADY_JOINED", e.getMessage(), List.of())));
    }

    @ExceptionHandler(ClubApplicationAlreadyPendingException.class)
    public ResponseEntity<ApiResponse<Void>> handleClubApplicationAlreadyPending(ClubApplicationAlreadyPendingException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(ApiResponse.failure(new ApiError("CLUB_APPLICATION_ALREADY_PENDING", e.getMessage(), List.of())));
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
        // 주의: 이전에는 여기서 원본 예외를 그냥 버렸다. 그래서 로그인 500 오류의
        // 실제 원인(예: DB 유니크 제약 위반)이 콘솔에 전혀 남지 않아 디버깅이
        // 불가능했다. 반드시 로그로 남긴다.
        log.error("예상하지 못한 서버 오류가 발생했습니다.", e);
        return ResponseEntity.internalServerError()
                .body(ApiResponse.failure(new ApiError("INTERNAL_ERROR", "예상하지 못한 오류가 발생했습니다.", List.of())));
    }
}
