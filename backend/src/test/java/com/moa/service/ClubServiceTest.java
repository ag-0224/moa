package com.moa.service;

import com.moa.constant.ClubApplicationStatus;
import com.moa.constant.Provider;
import com.moa.dto.response.ClubDetailResponse;
import com.moa.dto.response.ClubResponse;
import com.moa.entity.Club;
import com.moa.entity.ClubApplication;
import com.moa.entity.ClubMember;
import com.moa.entity.User;
import com.moa.filter.exception.ClubAlreadyJoinedException;
import com.moa.filter.exception.ClubApplicationAlreadyPendingException;
import com.moa.filter.exception.ClubMembershipNotFoundException;
import com.moa.filter.exception.ClubNotFoundException;
import com.moa.repository.ClubApplicationRepository;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
import com.moa.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ClubServiceTest {

    @Mock
    private ClubRepository clubRepository;

    @Mock
    private ClubMemberRepository clubMemberRepository;

    @Mock
    private ClubApplicationRepository clubApplicationRepository;

    @Mock
    private UserRepository userRepository;

    @Test
    void getMyClubsReturnsOnlyJoinedClubsWithTheirFavoriteFlag() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);
        ClubMember membership = ClubMember.join(club, user);
        membership.changeFavorite(true);

        when(clubMemberRepository.findByUserId(1L)).thenReturn(List.of(membership));

        List<ClubResponse> responses = clubService.getMyClubs(1L);

        assertThat(responses).hasSize(1);
        ClubResponse response = responses.get(0);
        assertThat(response.id()).isEqualTo(1L);
        assertThat(response.joined()).isTrue();
        assertThat(response.favorite()).isTrue();
    }

    @Test
    void getAllClubsMarksOnlyJoinedClubsAsJoined() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club joinedClub = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        Club notJoinedClub = newClub(2L, "등산 동아리", "박승찬", "체육", 12);
        User user = newUser(1L);
        ClubMember membership = ClubMember.join(joinedClub, user);

        when(clubRepository.findAll()).thenReturn(List.of(joinedClub, notJoinedClub));
        when(clubMemberRepository.findByUserId(1L)).thenReturn(List.of(membership));

        List<ClubResponse> responses = clubService.getAllClubs(1L);

        assertThat(responses).hasSize(2);
        ClubResponse joined = responses.stream().filter(r -> r.id().equals(1L)).findFirst().orElseThrow();
        ClubResponse notJoined = responses.stream().filter(r -> r.id().equals(2L)).findFirst().orElseThrow();
        assertThat(joined.joined()).isTrue();
        assertThat(joined.favorite()).isFalse();
        assertThat(notJoined.joined()).isFalse();
        assertThat(notJoined.favorite()).isFalse();
    }

    @Test
    void setFavoriteUpdatesMembershipWhenJoined() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);
        ClubMember membership = ClubMember.join(club, user);

        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));

        ClubResponse response = clubService.setFavorite(1L, 1L, true);

        assertThat(response.favorite()).isTrue();
        assertThat(membership.isFavorite()).isTrue();
    }

    @Test
    void setFavoriteThrowsWhenNotJoined() {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);

        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clubService.setFavorite(1L, 1L, true))
                .isInstanceOf(ClubMembershipNotFoundException.class);
    }

    @Test
    void getClubDetailReturnsJoinedWithNullApplicationStatus() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);
        ClubMember membership = ClubMember.join(club, user);
        membership.changeFavorite(true);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));

        ClubDetailResponse response = clubService.getClubDetail(1L, 1L);

        assertThat(response.joined()).isTrue();
        assertThat(response.favorite()).isTrue();
        assertThat(response.applicationStatus()).isNull();
    }

    @Test
    void getClubDetailReturnsApplicationStatusWhenNotJoined() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);
        ClubApplication application = ClubApplication.apply(club, user, "자기소개".repeat(5));

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());
        when(clubApplicationRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(application));

        ClubDetailResponse response = clubService.getClubDetail(1L, 1L);

        assertThat(response.joined()).isFalse();
        assertThat(response.applicationStatus()).isEqualTo(ClubApplicationStatus.PENDING);
    }

    @Test
    void getClubDetailThrowsWhenClubNotFound() {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);

        when(clubRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clubService.getClubDetail(1L, 1L))
                .isInstanceOf(ClubNotFoundException.class);
    }

    @Test
    void applyToClubCreatesPendingApplicationWhenNoneExists() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());
        when(clubApplicationRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(clubApplicationRepository.save(org.mockito.ArgumentMatchers.any(ClubApplication.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ClubDetailResponse response = clubService.applyToClub(1L, 1L, "자기소개".repeat(5));

        assertThat(response.applicationStatus()).isEqualTo(ClubApplicationStatus.PENDING);
        assertThat(response.joined()).isFalse();
    }

    @Test
    void applyToClubThrowsWhenAlreadyJoined() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);
        ClubMember membership = ClubMember.join(club, user);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));

        assertThatThrownBy(() -> clubService.applyToClub(1L, 1L, "자기소개".repeat(5)))
                .isInstanceOf(ClubAlreadyJoinedException.class);
    }

    @Test
    void applyToClubThrowsWhenApplicationAlreadyPending() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);
        ClubApplication application = ClubApplication.apply(club, user, "자기소개".repeat(5));

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());
        when(clubApplicationRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(application));

        assertThatThrownBy(() -> clubService.applyToClub(1L, 1L, "자기소개".repeat(5)))
                .isInstanceOf(ClubApplicationAlreadyPendingException.class);
    }

    @Test
    void applyToClubResubmitsRejectedApplication() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24);
        User user = newUser(1L);
        ClubApplication application = ClubApplication.apply(club, user, "이전 자기소개".repeat(5));
        application.reject();

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());
        when(clubApplicationRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(application));

        ClubDetailResponse response = clubService.applyToClub(1L, 1L, "새로운 자기소개".repeat(5));

        assertThat(response.applicationStatus()).isEqualTo(ClubApplicationStatus.PENDING);
        assertThat(application.getStatus()).isEqualTo(ClubApplicationStatus.PENDING);
        assertThat(application.getSelfIntroduction()).isEqualTo("새로운 자기소개".repeat(5));
    }

    // Club/User는 @GeneratedValue id라 public 생성자/setter가 없다. schema.sql/data.sql로
    // 시딩되는 엔티티라 애플리케이션 코드에도 별도 생성 로직이 없으므로, 단위 테스트에서는
    // UserServiceTest의 setId() 패턴과 마찬가지로 리플렉션으로 직접 구성한다.
    private static Club newClub(Long id, String name, String leaderName, String category, int memberCount)
            throws Exception {
        Constructor<Club> constructor = Club.class.getDeclaredConstructor();
        constructor.setAccessible(true);
        Club club = constructor.newInstance();
        setField(club, "id", id);
        setField(club, "name", name);
        setField(club, "leaderName", leaderName);
        setField(club, "category", category);
        setField(club, "memberCount", memberCount);
        return club;
    }

    private static User newUser(Long id) throws Exception {
        User user = User.createOAuthUser("user@example.com", "Test User", Provider.GOOGLE, "uid-" + id);
        setField(user, "id", id);
        return user;
    }

    private static void setField(Object target, String fieldName, Object value) throws Exception {
        Field field = target.getClass().getDeclaredField(fieldName);
        field.setAccessible(true);
        field.set(target, value);
    }
}
