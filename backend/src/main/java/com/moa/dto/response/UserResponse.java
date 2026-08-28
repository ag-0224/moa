package com.moa.dto.response;

import com.moa.entity.User;

/**
 * openapi.yaml의 User 스키마(GET /users/me, PATCH /users/me 등)와 매핑되는 응답 DTO.
 * nickname/major/studentId는 회원가입(추가 정보 입력)을 완료하기 전까지 null이다.
 * profileCompleted는 nickname != null과 동치이며, 클라이언트가 메인 화면으로 보낼지
 * 회원가입 화면으로 보낼지 판단하는 데 그대로 사용한다.
 */
public record UserResponse(
        Long id,
        String email,
        String name,
        String role,
        String nickname,
        String major,
        String studentId,
        boolean profileCompleted
) {

    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getName(),
                user.getRole().name(),
                user.getNickname(),
                user.getMajor(),
                user.getStudentId(),
                user.isProfileCompleted()
        );
    }
}
