package com.moa.controller;

import com.moa.dto.request.CompleteProfileRequest;
import com.moa.dto.response.ApiResponse;
import com.moa.dto.response.UserResponse;
import com.moa.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * openapi.yaml의 GET/PATCH /users/me 계약을 구현한다. Authorization: Bearer <accessToken>이 필요하다.
 */
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ApiResponse<UserResponse> getMyInfo(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(userService.getMyInfo(userId));
    }

    /**
     * 회원가입 화면('회원 정보 입력')의 '작성 완료' 버튼이 호출하는 엔드포인트.
     */
    @PatchMapping("/me")
    public ApiResponse<UserResponse> completeProfile(
            Authentication authentication,
            @Valid @RequestBody CompleteProfileRequest request
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(userService.completeProfile(userId, request));
    }

    /**
     * 마이페이지('내 정보')의 '회원 탈퇴' 버튼이 호출하는 엔드포인트.
     */
    @DeleteMapping("/me")
    public ApiResponse<Void> deleteAccount(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        userService.deleteAccount(userId);
        return ApiResponse.success(null);
    }
}
