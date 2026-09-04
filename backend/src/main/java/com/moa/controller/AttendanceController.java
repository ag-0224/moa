package com.moa.controller;

import com.moa.dto.request.CheckInRequest;
import com.moa.dto.response.ApiResponse;
import com.moa.dto.response.AttendanceOverviewResponse;
import com.moa.dto.response.MyStudyInfoResponse;
import com.moa.service.AttendanceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 스터디 홈 화면의 출석현황/내 정보 탭이 쓰는 출석·휴가 API. 전부
 * Authorization: Bearer <accessToken>이 필요하고, 가입하지 않은 스터디에
 * 대해 호출하면 404 CLUB_MEMBERSHIP_NOT_FOUND를 반환한다(AttendanceService).
 */
@RestController
@RequestMapping("/api/v1/clubs/{clubId}/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    /**
     * 출석현황 탭: 이번 주 전체 인원의 출석 도장 + 내 휴가 사용/총 일수.
     */
    @GetMapping("/overview")
    public ApiResponse<AttendanceOverviewResponse> getOverview(Authentication authentication, @PathVariable Long clubId) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(attendanceService.getOverview(clubId, userId));
    }

    /**
     * "출석 하기" 버튼의 출석번호 입력 제출.
     */
    @PostMapping("/check-in")
    public ApiResponse<Void> checkIn(
            Authentication authentication,
            @PathVariable Long clubId,
            @Valid @RequestBody CheckInRequest request
    ) {
        Long userId = (Long) authentication.getPrincipal();
        attendanceService.checkIn(clubId, userId, request.code());
        return ApiResponse.success(null);
    }

    /**
     * "출석 하기" 버튼의 휴가 사용 제출.
     */
    @PostMapping("/vacation")
    public ApiResponse<Void> useVacation(Authentication authentication, @PathVariable Long clubId) {
        Long userId = (Long) authentication.getPrincipal();
        attendanceService.useVacation(clubId, userId);
        return ApiResponse.success(null);
    }

    /**
     * "내 정보" 탭: year/month로 지정한 달의 출석 달력 + 휴가/출석 통계.
     */
    @GetMapping("/me")
    public ApiResponse<MyStudyInfoResponse> getMyMonthlyInfo(
            Authentication authentication,
            @PathVariable Long clubId,
            @RequestParam int year,
            @RequestParam int month
    ) {
        Long userId = (Long) authentication.getPrincipal();
        return ApiResponse.success(attendanceService.getMyMonthlyInfo(clubId, userId, year, month));
    }
}
