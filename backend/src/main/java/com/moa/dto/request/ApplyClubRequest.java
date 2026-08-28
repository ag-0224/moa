package com.moa.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 동아리 상세 화면의 "지원 하기" 흐름에서 제출하는 가입 신청서 본문.
 * Moarium 참고 프로젝트는 최소 100자를 요구했지만, MOA는 아직 커스텀 질문
 * 없이 자기소개 하나만 받는 단순한 형태라 20자로 완화했다.
 */
public record ApplyClubRequest(
        @NotBlank(message = "자기소개를 입력해주세요.")
        @Size(min = 20, max = 1000, message = "자기소개는 20자 이상 1000자 이하로 입력해주세요.")
        String selfIntroduction
) {
}
