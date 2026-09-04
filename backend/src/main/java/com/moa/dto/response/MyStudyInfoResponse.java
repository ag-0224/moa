package com.moa.dto.response;

import com.moa.constant.AttendanceMark;

import java.time.LocalDate;
import java.util.Map;

/**
 * "내 정보" 탭의 월별 출석 달력 + 휴가/출석 통계 응답. year/month는 조회한
 * 달을 그대로 돌려준다(요청과 같은 값이지만, 클라이언트가 응답만 보고도
 * 어느 달인지 알 수 있도록 포함한다).
 *
 * dailyMarks는 "그 달의 day-of-month(1~31) -> 출석 표시" 맵이다. JSON
 * 객체 키는 항상 문자열이라 실제로는 {"1": "PRESENT", "3": "ABSENT", ...}
 * 형태로 내려간다 — 프론트엔드가 키를 int로 파싱해서 쓴다. 지나지 않은
 * 날(오늘 중 아직 정하지 않은 경우 포함)과 스터디가 아직 만들어지기 전
 * 날짜(studyCreatedAt 이전)는 둘 다 이 맵에 없다 — 결석으로 셀 수 있는
 * 날이 아니기 때문이다.
 *
 * studyCreatedAt은 조회한 달과 무관하게 항상 그 스터디(clubId)의 생성일을
 * 그대로 돌려준다. 프론트엔드가 월 이동 화살표/달력 선택의 하한선으로 쓴다
 * (스터디가 만들어지기 전 달을 봐도 항상 빈 상태이므로 갈 필요가 없다).
 */
public record MyStudyInfoResponse(
        int year,
        int month,
        Map<Integer, AttendanceMark> dailyMarks,
        int presentCount,
        int absentCount,
        int vacationDaysUsed,
        int vacationDaysTotal,
        LocalDate studyCreatedAt
) {
}
