package com.moa.controller;

import com.moa.dto.response.ApiResponse;
import com.moa.dto.response.UserResponse;
import com.moa.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * openapi.yaml의 GET /users/me 계약을 구현한다. Authorization: Bearer <accessToken>이 필요하다.
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
}
