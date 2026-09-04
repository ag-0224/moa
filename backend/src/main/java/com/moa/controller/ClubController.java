package com.moa.controller;

import com.moa.dto.request.ApplyClubRequest;
import com.moa.dto.request.SetClubFavoriteRequest;
import com.moa.dto.request.TransferClubLeaderRequest;
import com.moa.dto.response.ApiResponse;
import com.moa.dto.response.ClubApplicationResponse;
import com.moa.dto.response.ClubDetailResponse;
import com.moa.dto.response.ClubMemberSummaryResponse;
import com.moa.dto.response.ClubResponse;
import com.moa.service.ClubService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * openapi.yaml의 GET /clubs/me, GET /clubs, PATCH /clubs/{clubId}/favorite,
 * PATCH /clubs/{clubId}/leader, GET /clubs/{clubId}/members, GET/POST
 * /clubs/{clubId}/applications... 계약을 구현한다. 전부
 * Authorization: Bearer <accessToken>이 필요하다.
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

    /**
     * 동아리 상세(가입 전 소개/지원) 화면.
     */
    @GetMapping("/{clubId}")
    public ApiResponse<ClubDetailResponse> getClubDetail(Authentication authentication, @PathVariable Long clubId) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.getClubDetail(userId, clubId));
    }

    /**
     * 스터디 관리 페이지의 "스터디 정보 수정". 동아리장만 호출할 수 있다.
     * createClub과 같은 이유로 multipart/form-data이며, thumbnail 파트를
     * 보내지 않으면 기존 사진을 그대로 유지한다.
     */
    @PatchMapping(value = "/{clubId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<ClubDetailResponse> updateClub(
            Authentication authentication,
            @PathVariable Long clubId,
            @RequestParam("name") String name,
            @RequestParam("description") String description,
            @RequestParam(value = "thumbnail", required = false) MultipartFile thumbnail
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.updateClub(userId, clubId, name, description, thumbnail));
    }

    /**
     * 스터디 관리 페이지의 "스터디 삭제". 동아리장만 호출할 수 있다.
     */
    @DeleteMapping("/{clubId}")
    public ApiResponse<Void> deleteClub(Authentication authentication, @PathVariable Long clubId) {
        Long userId = (Long) authentication.getPrincipal();
        clubService.deleteClub(userId, clubId);
        return ApiResponse.success(null);
    }

    /**
     * 동아리 상세 화면의 "지원 하기" 버튼이 호출하는 가입 신청.
     */
    @PostMapping("/{clubId}/apply")
    public ApiResponse<ClubDetailResponse> applyToClub(
            Authentication authentication,
            @PathVariable Long clubId,
            @Valid @RequestBody ApplyClubRequest request
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.applyToClub(userId, clubId, request.selfIntroduction()));
    }

    /**
     * 메인 페이지 "스터디 등록" 버튼 → 등록 화면의 "작성완료" 제출.
     * JSON이 아니라 multipart/form-data인 이유는 사진(thumbnail) 파일을 같이
     * 받기 위해서다 — name/description은 같은 요청의 일반 폼 필드로 온다.
     */
    @PostMapping(value = "", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<ClubDetailResponse> createClub(
            Authentication authentication,
            @RequestParam("name") String name,
            @RequestParam("description") String description,
            @RequestParam(value = "thumbnail", required = false) MultipartFile thumbnail
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.createClub(userId, name, description, thumbnail));
    }

    /**
     * 관리자 권한 넘기기 화면(멤버 선택)이 쓰는 동아리 멤버 목록.
     */
    @GetMapping("/{clubId}/members")
    public ApiResponse<List<ClubMemberSummaryResponse>> getClubMembers(
            Authentication authentication,
            @PathVariable Long clubId
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.getClubMembers(userId, clubId));
    }

    /**
     * 관리자(동아리장) 권한 넘기기. 현재 동아리장만 호출할 수 있다.
     */
    @PatchMapping("/{clubId}/leader")
    public ApiResponse<ClubDetailResponse> transferClubLeader(
            Authentication authentication,
            @PathVariable Long clubId,
            @Valid @RequestBody TransferClubLeaderRequest request
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.transferLeadership(userId, clubId, request.newLeaderId()));
    }

    /**
     * 가입 신청 관리 화면의 대기 중인 신청서 목록(관리자 전용).
     */
    @GetMapping("/{clubId}/applications")
    public ApiResponse<List<ClubApplicationResponse>> getPendingClubApplications(
            Authentication authentication,
            @PathVariable Long clubId
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.getPendingApplications(userId, clubId));
    }

    /**
     * 가입 신청 승인(관리자 전용).
     */
    @PostMapping("/{clubId}/applications/{applicationId}/approve")
    public ApiResponse<ClubApplicationResponse> approveClubApplication(
            Authentication authentication,
            @PathVariable Long clubId,
            @PathVariable Long applicationId
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.approveApplication(userId, clubId, applicationId));
    }

    /**
     * 가입 신청 거절(관리자 전용).
     */
    @PostMapping("/{clubId}/applications/{applicationId}/reject")
    public ApiResponse<ClubApplicationResponse> rejectClubApplication(
            Authentication authentication,
            @PathVariable Long clubId,
            @PathVariable Long applicationId
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(clubService.rejectApplication(userId, clubId, applicationId));
    }
}
