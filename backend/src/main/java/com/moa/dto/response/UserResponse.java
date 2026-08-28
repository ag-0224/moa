package com.moa.dto.response;

import com.moa.entity.User;

/**
 * openapi.yaml의 User 스키마(GET /users/me 등)와 매핑되는 응답 DTO.
 */
public record UserResponse(Long id, String email, String name, String role) {

    public static UserResponse from(User user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getName(), user.getRole().name());
    }
}
