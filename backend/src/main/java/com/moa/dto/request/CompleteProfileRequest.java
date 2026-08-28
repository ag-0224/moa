package com.moa.dto.request;

import jakarta.validation.constraints.NotBlank;

/**
 * openapi.yaml PATCH /users/me 요청 스키마와 매핑되는 요청 DTO.
 * 회원가입 화면('회원 정보 입력')에서 제출하는 추가 정보. 이메일은 이미 Firebase
 * 로그인 시점에 확정되어 있으므로 여기서 다시 받지 않는다.
 */
public record CompleteProfileRequest(
        @NotBlank(message = "이름은 필수 입력 사항이에요.") String name,
        @NotBlank(message = "닉네임은 필수 입력 사항이에요.") String nickname,
        @NotBlank(message = "전공은 필수 입력 사항이에요.") String major,
        @NotBlank(message = "학번은 필수 입력 사항이에요.") String studentId
) {
}
