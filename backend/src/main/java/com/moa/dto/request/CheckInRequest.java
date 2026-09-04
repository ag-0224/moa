package com.moa.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

/**
 * "출석 하기" 버튼의 출석번호 입력 다이얼로그가 제출하는 요청 본문.
 */
public record CheckInRequest(
        @NotBlank(message = "출석번호를 입력해주세요.")
        @Pattern(regexp = "\\d{4}", message = "출석번호는 숫자 4자리예요.")
        String code
) {
}
