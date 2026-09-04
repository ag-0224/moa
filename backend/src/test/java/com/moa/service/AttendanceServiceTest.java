package com.moa.service;

import com.moa.constant.AttendanceMark;
import com.moa.constant.AttendanceStatus;
import com.moa.constant.Provider;
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
import com.moa.filter.exception.InvalidAttendanceCodeException;
import com.moa.filter.exception.VacationLimitExceededException;
import com.moa.repository.AttendanceCodeRepository;
import com.moa.repository.AttendanceRecordRepository;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
import com.moa.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AttendanceServiceTest {

    @Mock
    private ClubRepository clubRepository;

    @Mock
    private ClubMemberRepository clubMemberRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private AttendanceRecordRepository attendanceRecordRepository;

    @Mock
    private AttendanceCodeRepository attendanceCodeRepository;

    private AttendanceService newService() {
        return new AttendanceService(
                clubRepository, clubMemberRepository, userRepository, attendanceRecordRepository, attendanceCodeRepository);
    }

    @Test
    void getOverviewThrowsWhenNotAMember() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.getOverview(1L, 1L))
                .isInstanceOf(ClubMembershipNotFoundException.class);
    }

    @Test
    void getOverviewPutsRequestingUserFirstAndMarksPastDaysWithoutRecordsAsAbsent() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User me = newUser(1L);
        User other = newUser(2L);
        ClubMember myMembership = newMembership(club, me, 3);
        ClubMember otherMembership = newMembership(club, other, 3);

        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - DayOfWeek.MONDAY.getValue());

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(myMembership));
        // 나중에(2번) 등록됐지만 응답에서는 로그인한 사용자(1번)가 항상 먼저 와야 한다.
        when(clubMemberRepository.findByClubId(1L)).thenReturn(List.of(otherMembership, myMembership));
        when(attendanceRecordRepository.findByClubIdAndAttendanceDateBetween(1L, weekStart, weekStart.plusDays(6)))
                .thenReturn(List.of());
        when(attendanceRecordRepository.countByClubIdAndUserIdAndStatus(1L, 1L, AttendanceStatus.VACATION))
                .thenReturn(0L);
        when(attendanceRecordRepository.countByClubIdAndUserIdAndStatus(1L, 2L, AttendanceStatus.VACATION))
                .thenReturn(0L);

        AttendanceOverviewResponse response = service.getOverview(1L, 1L);

        assertThat(response.weekStart()).isEqualTo(weekStart);
        assertThat(response.members()).hasSize(2);
        MemberAttendanceResponse first = response.members().get(0);
        assertThat(first.memberId()).isEqualTo(1L);
        assertThat(first.isMe()).isTrue();

        // 어제까지는 기록이 없으면 결석으로 계산되고, 오늘은 아직 정하지 않았으니 예정(UPCOMING)이어야 한다.
        int todayIndex = today.getDayOfWeek().getValue() - DayOfWeek.MONDAY.getValue();
        assertThat(first.weeklyMarks().get(todayIndex)).isEqualTo(AttendanceMark.UPCOMING);
        if (todayIndex > 0) {
            assertThat(first.weeklyMarks().get(todayIndex - 1)).isEqualTo(AttendanceMark.ABSENT);
        }
        assertThat(first.todayMark()).isEqualTo(AttendanceMark.UPCOMING);
        assertThat(response.myVacationDaysTotal()).isEqualTo(3);
    }

    @Test
    void checkInThrowsWhenCodeNotIssuedForToday() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceCodeRepository.findByClubIdAndAttendanceDate(1L, LocalDate.now())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.checkIn(1L, 1L, "1234"))
                .isInstanceOf(AttendanceCodeNotIssuedException.class);
        verify(attendanceRecordRepository, never()).save(any());
    }

    @Test
    void checkInThrowsWhenCodeDoesNotMatch() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);
        AttendanceCode todayCode = newAttendanceCode(club, "1234", LocalDate.now());

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceCodeRepository.findByClubIdAndAttendanceDate(1L, LocalDate.now())).thenReturn(Optional.of(todayCode));

        assertThatThrownBy(() -> service.checkIn(1L, 1L, "0000"))
                .isInstanceOf(InvalidAttendanceCodeException.class);
        verify(attendanceRecordRepository, never()).save(any());
    }

    @Test
    void checkInSavesPresentRecordWhenCodeMatchesAndNoExistingRecordToday() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);
        AttendanceCode todayCode = newAttendanceCode(club, "1234", LocalDate.now());

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceCodeRepository.findByClubIdAndAttendanceDate(1L, LocalDate.now())).thenReturn(Optional.of(todayCode));
        when(attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDate(1L, 1L, LocalDate.now()))
                .thenReturn(Optional.empty());

        service.checkIn(1L, 1L, "1234");

        verify(attendanceRecordRepository).save(any(AttendanceRecord.class));
    }

    @Test
    void checkInUpdatesExistingVacationRecordToPresentInsteadOfCreatingNewOne() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);
        AttendanceCode todayCode = newAttendanceCode(club, "1234", LocalDate.now());
        AttendanceRecord existing = AttendanceRecord.of(club, user, LocalDate.now(), AttendanceStatus.VACATION);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceCodeRepository.findByClubIdAndAttendanceDate(1L, LocalDate.now())).thenReturn(Optional.of(todayCode));
        when(attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDate(1L, 1L, LocalDate.now()))
                .thenReturn(Optional.of(existing));

        service.checkIn(1L, 1L, "1234");

        assertThat(existing.getStatus()).isEqualTo(AttendanceStatus.PRESENT);
        verify(attendanceRecordRepository, never()).save(any());
    }

    @Test
    void useVacationThrowsWhenAlreadyUsedAllVacationDays() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDate(1L, 1L, LocalDate.now()))
                .thenReturn(Optional.empty());
        when(attendanceRecordRepository.countByClubIdAndUserIdAndStatus(1L, 1L, AttendanceStatus.VACATION))
                .thenReturn(3L);

        assertThatThrownBy(() -> service.useVacation(1L, 1L))
                .isInstanceOf(VacationLimitExceededException.class);
        verify(attendanceRecordRepository, never()).save(any());
    }

    @Test
    void useVacationSavesVacationRecordWhenUnderLimit() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDate(1L, 1L, LocalDate.now()))
                .thenReturn(Optional.empty());
        when(attendanceRecordRepository.countByClubIdAndUserIdAndStatus(1L, 1L, AttendanceStatus.VACATION))
                .thenReturn(1L);

        service.useVacation(1L, 1L);

        verify(attendanceRecordRepository).save(any(AttendanceRecord.class));
    }

    @Test
    void getMyMonthlyInfoReturnsAllZerosForFutureMonth() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);
        YearMonth nextMonth = YearMonth.now().plusMonths(1);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));

        MyStudyInfoResponse response = service.getMyMonthlyInfo(1L, 1L, nextMonth.getYear(), nextMonth.getMonthValue());

        assertThat(response.dailyMarks()).isEmpty();
        assertThat(response.presentCount()).isZero();
        assertThat(response.absentCount()).isZero();
        assertThat(response.vacationDaysUsed()).isZero();
        assertThat(response.vacationDaysTotal()).isEqualTo(3);
        verify(attendanceRecordRepository, never())
                .findByClubIdAndUserIdAndAttendanceDateBetween(any(), any(), any(), any());
    }

    @Test
    void getMyMonthlyInfoComputesPresentAndAbsentCountsForPastMonth() throws Exception {
        AttendanceService service = newService();
        Club club = newClub(1L);
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);
        YearMonth lastMonth = YearMonth.now().minusMonths(1);
        LocalDate day1 = lastMonth.atDay(1);
        LocalDate day2 = lastMonth.atDay(2);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDateBetween(
                1L, 1L, day1, lastMonth.atEndOfMonth()))
                .thenReturn(List.of(AttendanceRecord.of(club, user, day1, AttendanceStatus.PRESENT)));
        when(attendanceRecordRepository.countByClubIdAndUserIdAndStatus(1L, 1L, AttendanceStatus.VACATION))
                .thenReturn(0L);

        MyStudyInfoResponse response =
                service.getMyMonthlyInfo(1L, 1L, lastMonth.getYear(), lastMonth.getMonthValue());

        assertThat(response.dailyMarks().get(1)).isEqualTo(AttendanceMark.PRESENT);
        assertThat(response.dailyMarks().get(2)).isEqualTo(AttendanceMark.ABSENT);
        assertThat(response.presentCount()).isEqualTo(1);
        assertThat(response.absentCount()).isEqualTo(lastMonth.lengthOfMonth() - 1);
    }

    @Test
    void getOverviewMarksDaysBeforeStudyCreationAsUpcomingNotAbsent() throws Exception {
        AttendanceService service = newService();
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.minusDays(today.getDayOfWeek().getValue() - DayOfWeek.MONDAY.getValue());
        if (weekStart.isEqual(today)) {
            // 오늘이 월요일이면 "이번 주 안에 스터디 생성일 이전 날짜"를 만들 수 없어
            // 이 케이스를 검증할 수 없다(다른 날 다시 돌리면 검증된다).
            return;
        }
        LocalDate studyCreatedAt = weekStart.plusDays(1);

        Club club = newClub(1L, studyCreatedAt.atStartOfDay().atOffset(ZoneOffset.UTC));
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(clubMemberRepository.findByClubId(1L)).thenReturn(List.of(membership));
        when(attendanceRecordRepository.findByClubIdAndAttendanceDateBetween(1L, weekStart, weekStart.plusDays(6)))
                .thenReturn(List.of());
        when(attendanceRecordRepository.countByClubIdAndUserIdAndStatus(1L, 1L, AttendanceStatus.VACATION))
                .thenReturn(0L);

        AttendanceOverviewResponse response = service.getOverview(1L, 1L);

        // weekStart(월요일)는 스터디가 생기기 전날이라 결석이 아니라 UPCOMING(빈 칸)이어야 한다.
        assertThat(response.members().get(0).weeklyMarks().get(0)).isEqualTo(AttendanceMark.UPCOMING);
    }

    @Test
    void getMyMonthlyInfoReturnsEmptyForMonthBeforeStudyWasCreated() throws Exception {
        AttendanceService service = newService();
        YearMonth creationMonth = YearMonth.now().minusMonths(1);
        LocalDate creationDate = creationMonth.atDay(5);
        Club club = newClub(1L, creationDate.atStartOfDay().atOffset(ZoneOffset.UTC));
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);
        YearMonth monthBeforeCreation = creationMonth.minusMonths(1);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));

        MyStudyInfoResponse response = service.getMyMonthlyInfo(
                1L, 1L, monthBeforeCreation.getYear(), monthBeforeCreation.getMonthValue());

        assertThat(response.dailyMarks()).isEmpty();
        assertThat(response.presentCount()).isZero();
        assertThat(response.absentCount()).isZero();
        assertThat(response.studyCreatedAt()).isEqualTo(creationDate);
        verify(attendanceRecordRepository, never())
                .findByClubIdAndUserIdAndAttendanceDateBetween(any(), any(), any(), any());
    }

    @Test
    void getMyMonthlyInfoSkipsDaysBeforeCreationWithinCreationMonth() throws Exception {
        AttendanceService service = newService();
        YearMonth creationMonth = YearMonth.now().minusMonths(2);
        LocalDate creationDate = creationMonth.atDay(10);
        Club club = newClub(1L, creationDate.atStartOfDay().atOffset(ZoneOffset.UTC));
        User user = newUser(1L);
        ClubMember membership = newMembership(club, user, 3);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));
        when(attendanceRecordRepository.findByClubIdAndUserIdAndAttendanceDateBetween(
                1L, 1L, creationDate, creationMonth.atEndOfMonth()))
                .thenReturn(List.of());
        when(attendanceRecordRepository.countByClubIdAndUserIdAndStatus(1L, 1L, AttendanceStatus.VACATION))
                .thenReturn(0L);

        MyStudyInfoResponse response =
                service.getMyMonthlyInfo(1L, 1L, creationMonth.getYear(), creationMonth.getMonthValue());

        // 생성일(10일) 전날들은 결석으로 세지 않고 아예 맵에 없어야 한다.
        assertThat(response.dailyMarks()).doesNotContainKey(9);
        assertThat(response.dailyMarks().get(10)).isEqualTo(AttendanceMark.ABSENT);
        assertThat(response.absentCount()).isEqualTo(creationMonth.lengthOfMonth() - 9);
    }

    private static Club newClub(Long id) throws Exception {
        // 대부분의 테스트는 생성일 자체를 검증하지 않으므로, 다른 날짜 계산과
        // 절대 겹치지 않도록 충분히 오래전(1년 전)으로 기본값을 둔다.
        return newClub(id, OffsetDateTime.now().minusYears(1));
    }

    private static Club newClub(Long id, OffsetDateTime createdAt) throws Exception {
        Constructor<Club> constructor = Club.class.getDeclaredConstructor();
        constructor.setAccessible(true);
        Club club = constructor.newInstance();
        setField(club, "id", id);
        setField(club, "name", "알고리즘 스터디");
        setField(club, "leaderName", "박승찬");
        setField(club, "category", "학술");
        setField(club, "memberCount", 2);
        setField(club, "createdAt", createdAt);
        return club;
    }

    private static User newUser(Long id) throws Exception {
        User user = User.createOAuthUser("user" + id + "@example.com", "Test User " + id, Provider.GOOGLE, "uid-" + id);
        setField(user, "id", id);
        return user;
    }

    private static ClubMember newMembership(Club club, User user, int vacationDaysTotal) throws Exception {
        ClubMember membership = ClubMember.join(club, user);
        setField(membership, "vacationDaysTotal", vacationDaysTotal);
        return membership;
    }

    private static AttendanceCode newAttendanceCode(Club club, String code, LocalDate date) throws Exception {
        Constructor<AttendanceCode> constructor = AttendanceCode.class.getDeclaredConstructor();
        constructor.setAccessible(true);
        AttendanceCode attendanceCode = constructor.newInstance();
        setField(attendanceCode, "club", club);
        setField(attendanceCode, "code", code);
        setField(attendanceCode, "attendanceDate", date);
        return attendanceCode;
    }

    // BaseEntity(createdAt/updatedAt)처럼 상위 클래스가 선언한 필드도 설정할 수
    // 있도록, 대상 클래스부터 시작해 필드를 찾을 때까지 상위 클래스로 올라간다.
    private static void setField(Object target, String fieldName, Object value) throws Exception {
        Class<?> type = target.getClass();
        while (type != null) {
            try {
                Field field = type.getDeclaredField(fieldName);
                field.setAccessible(true);
                field.set(target, value);
                return;
            } catch (NoSuchFieldException e) {
                type = type.getSuperclass();
            }
        }
        throw new NoSuchFieldException(fieldName);
    }
}
