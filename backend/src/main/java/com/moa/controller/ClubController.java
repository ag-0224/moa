package com.moa.controller;

import com.moa.dto.request.SetClubFavoriteRequest;
import com.moa.dto.response.ApiResponse;
import com.moa.dto.response.ClubResponse;
import com.moa.service.ClubService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * openapi.yaml의 GET /clubs/me, GET /clubs, PATCH /clubs/{clubId}/favorite 계약을 구현한다.
 * 전부 Authorization: Bearer <accessToken>이 필요하다.
 */
@RestController
@RequestMapping("/api/v1/clubs")
@RequiredArgsConstructor
public class ClubController {

    private final ClubService clubService;

    /**
     * 내가 가입한 동아리 목록.
     */
    @GetMapping("/me")
    public ApiResponse<List<ClubResponse>> getMyClubs(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.getMyClubs(userId));
    }

    /**
     * 메인 페이지 홈 피드에서 보여줄 전체 동아리 목록.
     */
    @GetMapping
    public ApiResponse<List<ClubResponse>> getAllClubs(Authentication authentication) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.getAllClubs(userId));
    }

    @PatchMapping("/{clubId}/favorite")
    public ApiResponse<ClubResponse> setFavorite(
            Authentication authentication,
            @PathVariable Long clubId,
            @Valid @RequestBody SetClubFavoriteRequest request
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.setFavorite(userId, clubId, request.favorite()));
    }
}
