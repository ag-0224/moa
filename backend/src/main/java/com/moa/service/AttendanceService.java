package com.moa.service;

import com.moa.constant.AttendanceMark;
import com.moa.constant.AttendanceStatus;
import com.moa.dto.response.AttendanceCodeResponse;
import com.moa.dto.response.AttendanceOverviewResponse;
import com.moa.dto.response.MemberAttendanceResponse;
import com.moa.dto.response.MyStudyInfoResponse;
import com.moa.entity.AttendanceCode;
import com.moa.entity.AttendanceRecord;
import com.moa.entity.Club;
import com.moa.entity.ClubMember;
import com.moa.entity.User;
import com.moa.filter.exception.AttendanceCodeNotIssuedException;
import com.moa.filter.exception.ClubMembershipNotFoundException;
import com.moa.filter.exception.ClubNotFoundException;
import com.moa.filter.exception.InvalidAttendanceCodeException;
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.filter.exception.NotClubLeaderException;
import com.moa.filter.exception.VacationLimitExceededException;
import com.moa.repository.AttendanceCodeRepository;
import com.moa.repository.AttendanceRecordRepository;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
import com.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.IntStream;

/**
 * 스터디 출석 현황 탭 / "내 정보" 탭이 쓰는 출석·휴가 관리.
 *
 * 결석은 attendance_records에 저장하지 않고 "지나간 날짜인데 행이 없음"으로
 * 계산한다(entity/AttendanceRecord.java, schema.sql 주석 참고). 그래서 이
 * 서비스의 조회 메서드들은 항상 "오늘이 며칠인지"를 기준으로 과거/오늘/미래를
 * 나눠서 AttendanceMark를 채운다.
 *
 * 결석 계산은 스터디(Club)가 실제로 만들어진 날짜(Club.getCreatedAt())보다
 * 이전 날짜는 절대 포함하지 않는다 — 스터디가 존재하지도 않았던 날을
 * 결석으로 세는 건 말이 안 되기 때문이다. 그 이전 날짜는 미래 날짜와 똑같이
 * AttendanceMark.UPCOMING(빈 칸)으로 표시한다.
 */
@Service
@RequiredArgsConstructor
public class AttendanceService {

    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final UserRepository userRepository;
    private final AttendanceRecordRepository attendanceRecordRepository;
    private final AttendanceCodeRepository attendanceCodeRepository;

    private final SecureRandom secureRandom = new SecureRandom();

    /**
     * 출석 현황 탭. 이번 주(월~일) 전체 인원의 출석 도장과, 로그인한 사용자
     * 본인의 이번 학기 누적 휴가 사용/총 일수를 함께 내려준다.
     */
    public AttendanceOverviewResponse getOverview(Long clubId, Long userId) {
        Club club = findClubOrThrow(clubId);
        ClubMember myMembership = findMembershipOrThrow(clubId, userId);
        LocalDate studyCreatedAt = club.getCreatedAt().toLocalDate();

        List<ClubMember> memberships = clubMemberRepository.findByClubId(clubId);

        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - DayOfWeek.MONDAY.getValue());
        LocalDate weekEnd = weekStart.plusDays(6);

        List<AttendanceRecord> weekRecords =
                attendanceRecordRepository.findByClubIdAndAttendanceDateBetween(clubId, weekStart, weekEnd);
        Map<Long, Map<LocalDate, AttendanceStatus>> recordsByUserId = new HashMap<>();
        for (AttendanceRecord record : weekRecords) {
            recordsByUserId
                    .computeIfAbsent(record.getUser().getId(), key -> new HashMap<>())
                    .put(record.getAttendanceDate(), record.getStatus());
        }

        List<ClubMember> ordered = memberships.stream()
                .sorted(Comparator.comparing((ClubMember member) -> !member.getUser().getId().equals(userId))
                        .thenComparing(member -> member.getUser().getId()))
                .toList();

        List<MemberAttendanceResponse> members = ordered.stream()
                .map(member -> toMemberAttendanceResponse(member, userId, weekStart, today, studyCreatedAt, recordsByUserId))
                .toList();

        long myVacationDaysUsed =
                attendanceRecordRepository.countByClubIdAndUserIdAndStatus(clubId, userId, AttendanceStatus.VACATION);

        return new AttendanceOverviewResponse(
                weekStart,
                members,
                (int) myVacationDaysUsed,
                myMembership.getVacationDaysTotal()
        );
    }

    private MemberAttendanceResponse toMemberAttendanceResponse(
            ClubMember member,
            Long requestingUserId,
            LocalDate weekStart,
            LocalDate today,
            LocalDate studyCreatedAt,
            Map<Long, Map<LocalDate, AttendanceStatus>> recordsByUserId
    ) {
        Long memberUserId = member.getUser().getId();
        Map<LocalDate, AttendanceStatus> byDate = recordsByUserId.getOrDefault(memberUserId, Map.of());

        List<AttendanceMark> weeklyMarks = IntStream.range(0, 7)
                .mapToObj(dayIndex -> markFor(weekStart.plusDays(dayIndex), today, studyCreatedAt, byDate))
                .toList();

        long vacationDaysUsed = attendanceRecordRepository.countByClubIdAndUserIdAndStatus(
                member.getClub().getId(), memberUserId, AttendanceStatus.VACATION);

        int todayIndex = (int) ChronoUnit.DAYS.between(weekStart, today);
        AttendanceMark todayMark = (todayIndex >= 0 && todayIndex < 7) ? weeklyMarks.get(todayIndex) : AttendanceMark.UPCOMING;

        return new MemberAttendanceResponse(
                memberUserId,
                member.getUser().getName(),
                memberUserId.equals(requestingUserId),
                todayMark,
                weeklyMarks,
                (int) vacationDaysUsed
        );
    }

    private AttendanceMark markFor(LocalDate date, LocalDate today, LocalDate studyCreatedAt, Map<LocalDate, AttendanceStatus> byDate) {
        if (date.isAfter(today)) {
            return AttendanceMark.UPCOMING;
        }
        AttendanceStatus status = byDate.get(date);
        if (status != null) {
            return status == AttendanceStatus.VACATION ? AttendanceMark.VACATION : AttendanceMark.PRESENT;
        }
        if (date.isEqual(today)) {
            return AttendanceMark.UPCOMING;
        }
        // 스터디가 만들어지기 전 날짜는 결석이 아니라 "해당 사항 없음"이다 —
        // UPCOMING(빈 칸)을 그대로 재사용한다(화면에는 아직 지나지 않은 날과
        // 똑같이 빈 회색 칸/점으로 보인다).
        return date.isBefore(studyCreatedAt) ? AttendanceMark.UPCOMING : AttendanceMark.ABSENT;
    }

    /**
     * "출석 하기" 버튼의 출석번호 입력. 오늘 발급된 코드와 다르면
     * InvalidAttendanceCodeException, 아직 코드 자체가 없으면
     * AttendanceCodeNotIssuedException을 던진다.
     */
    @Transactional
    public void checkIn(Long clubId, Long userId, String code) {
        Club club = findClubOrThrow(clubId);
        User user = findUserOrThrow(userId);
        findMembershipOrThrow(clubId, userId);

        LocalDate today = LocalDate.now();
        AttendanceCode todayCode = attendanceCodeRepository.findByClubIdAndAttendanceDate(clubId, today)
                .orElseThrow(() -> new AttendanceCodeNotIssuedException("오늘의 출석번호가 아직 발급되지 않았어요."));

        if (!todayCode.getCode().equals(code)) {
            throw new InvalidAttendanceCodeException("출석번호가 올바르지 않아요.");
        }

        upsertAttendanceRecord(club, user, clubId, userId, today, AttendanceStatus.PRESENT);
    }

    /**
     * "출석 하기" 버튼의 휴가 사용. 이번 학기 휴가를 이미 다 썼으면
     * VacationLimitExceededException을 던진다(프론트엔드가 먼저 걸러주지만,
     * 동시 요청 등에 대비한 서버 측 방어).
     */
    @Transactional
    public void useVacation(Long clubId, Long userId) {
        Club club = findClubOrThrow(clubId);
        User user = findUserOrThrow(userId);
        ClubMember membership = findMembershipOrThrow(clubId, userId);

        LocalDate today = LocalDate.now();
        var existing = attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDate(clubId, userId, today);

        boolean alreadyOnVacationToday = existing.isPresent() && existing.get().getStatus() == AttendanceStatus.VACATION;
        if (!alreadyOnVacationToday) {
            long vacationDaysUsed = attendanceRecordRepository.countByClubIdAndUserIdAndStatus(
                    clubId, userId, AttendanceStatus.VACATION);
            if (vacationDaysUsed >= membership.getVacationDaysTotal()) {
                throw new VacationLimitExceededException("이번 학기 휴가를 모두 사용했어요.");
            }
        }

        upsertAttendanceRecord(club, user, clubId, userId, today, AttendanceStatus.VACATION);
    }

    private void upsertAttendanceRecord(
            Club club, User user, Long clubId, Long userId, LocalDate date, AttendanceStatus status
    ) {
        attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDate(clubId, userId, date)
                .ifPresentOrElse(
                        record -> record.changeStatus(status),
                        () -> attendanceRecordRepository.save(AttendanceRecord.of(club, user, date, status))
                );
    }

    /**
     * 스터디 관리 페이지의 "출석번호 확인". 동아리장만 호출할 수 있다(아니면
     * NotClubLeaderException). 오늘 날짜로 이미 발급된 코드가 있으면 그대로
     * 재사용하고, 없으면 4자리 숫자를 새로 발급해서 저장한다 — 같은 날 여러
     * 번 호출해도 매번 같은 번호가 내려온다(멱등).
     */
    @Transactional
    public AttendanceCodeResponse getOrIssueTodayCode(Long clubId, Long userId) {
        Club club = findClubOrThrow(clubId);
        if (!club.isLedBy(userId)) {
            throw new NotClubLeaderException("동아리장만 할 수 있어요.");
        }

        LocalDate today = LocalDate.now();
        AttendanceCode todayCode = attendanceCodeRepository.findByClubIdAndAttendanceDate(clubId, today)
                .orElseGet(() -> attendanceCodeRepository.save(AttendanceCode.issue(club, generateCode(), today)));

        return AttendanceCodeResponse.of(todayCode);
    }

    private String generateCode() {
        return String.format("%04d", secureRandom.nextInt(10000));
    }

    /**
     * "내 정보" 탭의 월별 출석 달력 + 휴가/출석 통계. year/month로 지정한
     * 달의 아무 날짜나 상관없이 그 달 전체를 본다. 미래 달은 아직 아무
     * 기록도 있을 수 없으므로 전부 빈 상태로 내려준다.
     */
    public MyStudyInfoResponse getMyMonthlyInfo(Long clubId, Long userId, int year, int month) {
        Club club = findClubOrThrow(clubId);
        ClubMember membership = findMembershipOrThrow(clubId, userId);
        LocalDate studyCreatedAt = club.getCreatedAt().toLocalDate();

        YearMonth requestedMonth = YearMonth.of(year, month);
        LocalDate today = LocalDate.now();
        YearMonth currentMonth = YearMonth.from(today);
        YearMonth creationMonth = YearMonth.from(studyCreatedAt);

        // 스터디가 생기기 전 달이나 아직 오지 않은 달은 둘 다 출석을 셀 수
        // 없는 달이라 똑같이 빈 상태로 내려준다.
        if (requestedMonth.isAfter(currentMonth) || requestedMonth.isBefore(creationMonth)) {
            return new MyStudyInfoResponse(
                    year, month, Map.of(), 0, 0, 0, membership.getVacationDaysTotal(), studyCreatedAt);
        }

        LocalDate monthStart = requestedMonth.atDay(1);
        // 조회한 달이 스터디가 만들어진 바로 그 달이면, 만들어지기 전 날짜는
        // 건너뛰고 생성일부터만 센다(그 전 날짜는 결석이 될 수 없다).
        LocalDate effectiveStart = monthStart.isBefore(studyCreatedAt) ? studyCreatedAt : monthStart;
        int firstPastDay = effectiveStart.getDayOfMonth();
        int lastPastDay = requestedMonth.equals(currentMonth) ? today.getDayOfMonth() - 1 : requestedMonth.lengthOfMonth();

        Map<Integer, AttendanceMark> dailyMarks = new LinkedHashMap<>();
        int presentCount = 0;
        int absentCount = 0;

        if (lastPastDay >= firstPastDay) {
            List<AttendanceRecord> records = attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDateBetween(
                    clubId, userId, monthStart.plusDays(firstPastDay - 1), monthStart.plusDays(lastPastDay - 1));
            Map<LocalDate, AttendanceStatus> byDate = new HashMap<>();
            for (AttendanceRecord record : records) {
                byDate.put(record.getAttendanceDate(), record.getStatus());
            }

            for (int day = firstPastDay; day <= lastPastDay; day++) {
                AttendanceStatus status = byDate.get(monthStart.plusDays(day - 1));
                if (status == null) {
                    dailyMarks.put(day, AttendanceMark.ABSENT);
                    absentCount++;
                } else if (status == AttendanceStatus.PRESENT) {
                    dailyMarks.put(day, AttendanceMark.PRESENT);
                    presentCount++;
                } else {
                    dailyMarks.put(day, AttendanceMark.VACATION);
                }
            }
        }

        if (requestedMonth.equals(currentMonth)) {
            var todayRecord = attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDate(clubId, userId, today);
            if (todayRecord.isPresent()) {
                AttendanceStatus status = todayRecord.get().getStatus();
                if (status == AttendanceStatus.PRESENT) {
                    dailyMarks.put(today.getDayOfMonth(), AttendanceMark.PRESENT);
                    presentCount++;
                } else {
                    dailyMarks.put(today.getDayOfMonth(), AttendanceMark.VACATION);
                }
            }
        }

        long vacationDaysUsed =
                attendanceRecordRepository.countByClubIdAndUserIdAndStatus(clubId, userId, AttendanceStatus.VACATION);

        return new MyStudyInfoResponse(
                year, month, dailyMarks, presentCount, absentCount, (int) vacationDaysUsed,
                membership.getVacationDaysTotal(), studyCreatedAt
        );
    }

    private Club findClubOrThrow(Long clubId) {
        return clubRepository.findById(clubId)
                .orElseThrow(() -> new ClubNotFoundException("존재하지 않는 동아리예요."));
    }

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new InvalidAuthTokenException("사용자를 찾을 수 없습니다."));
    }

    private ClubMember findMembershipOrThrow(Long clubId, Long userId) {
        return clubMemberRepository.findByClubIdAndUserId(clubId, userId)
                .orElseThrow(() -> new ClubMembershipNotFoundException("가입한 스터디만 출석 정보를 볼 수 있어요."));
    }
}
