package com.moa.service;

import com.moa.constant.ClubApplicationStatus;
import com.moa.constant.Provider;
import com.moa.dto.response.ClubApplicationResponse;
import com.moa.dto.response.ClubDetailResponse;
import com.moa.dto.response.ClubMemberSummaryResponse;
import com.moa.dto.response.ClubResponse;
import com.moa.entity.Club;
import com.moa.entity.ClubApplication;
import com.moa.entity.ClubMember;
import com.moa.entity.User;
import com.moa.filter.exception.ClubAlreadyJoinedException;
import com.moa.filter.exception.ClubApplicationAlreadyPendingException;
import com.moa.filter.exception.ClubApplicationNotFoundException;
import com.moa.filter.exception.ClubApplicationNotPendingException;
import com.moa.filter.exception.ClubMembershipNotFoundException;
import com.moa.filter.exception.ClubNotFoundException;
import com.moa.filter.exception.DuplicateClubNameException;
import com.moa.filter.exception.InvalidClubNameException;
import com.moa.filter.exception.InvalidLeaderTransferException;
import com.moa.filter.exception.NotClubLeaderException;
import com.moa.repository.ClubApplicationRepository;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
import com.moa.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
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

    @Mock
    private FileStorageService fileStorageService;

    @Test
    void getMyClubsReturnsOnlyJoinedClubsWithTheirFavoriteFlag() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);

        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clubService.setFavorite(1L, 1L, true))
                .isInstanceOf(ClubMembershipNotFoundException.class);
    }

    @Test
    void getClubDetailReturnsJoinedWithNullApplicationStatus() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User user = newUser(1L);
        Club club = newClub(1L, "알고리즘 스터디", "박승찬", "학술", 24, user);
        ClubMember membership = ClubMember.join(club, user);
        membership.changeFavorite(true);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(membership));

        ClubDetailResponse response = clubService.getClubDetail(1L, 1L);

        assertThat(response.joined()).isTrue();
        assertThat(response.favorite()).isTrue();
        assertThat(response.leader()).isTrue();
        assertThat(response.applicationStatus()).isNull();
    }

    @Test
    void getClubDetailReturnsApplicationStatusWhenNotJoined() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);

        when(clubRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clubService.getClubDetail(1L, 1L))
                .isInstanceOf(ClubNotFoundException.class);
    }

    @Test
    void applyToClubCreatesPendingApplicationWhenNoneExists() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
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

    @Test
    void createClubSavesNewClubAndJoinsCreatorAsMember() {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);

        when(userRepository.findById(1L)).thenReturn(Optional.of(leader));
        when(clubRepository.existsByName("알고리즘 스터디")).thenReturn(false);
        when(clubRepository.save(any(Club.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ClubDetailResponse response =
                clubService.createClub(1L, "알고리즘 스터디", "매주 알고리즘 문제를 풉니다.", null);

        assertThat(response.name()).isEqualTo("알고리즘 스터디");
        assertThat(response.joined()).isTrue();
        assertThat(response.leader()).isTrue();
        assertThat(response.memberCount()).isEqualTo(1);
        verify(clubMemberRepository).save(any(ClubMember.class));
        verify(fileStorageService, org.mockito.Mockito.never()).storeClubThumbnail(any());
    }

    @Test
    void createClubStoresThumbnailWhenFileProvided() {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        MockMultipartFile thumbnail = new MockMultipartFile("thumbnail", "photo.png", "image/png", new byte[]{1, 2, 3});

        when(userRepository.findById(1L)).thenReturn(Optional.of(leader));
        when(clubRepository.existsByName("사진 동아리")).thenReturn(false);
        when(fileStorageService.storeClubThumbnail(thumbnail)).thenReturn("http://localhost:8080/uploads/clubs/abc.png");
        when(clubRepository.save(any(Club.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ClubDetailResponse response = clubService.createClub(1L, "사진 동아리", "설명", thumbnail);

        assertThat(response.thumbnailUrl()).isEqualTo("http://localhost:8080/uploads/clubs/abc.png");
    }

    @Test
    void createClubThrowsWhenNameIsBlank() {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(leader));

        assertThatThrownBy(() -> clubService.createClub(1L, "   ", "설명", null))
                .isInstanceOf(InvalidClubNameException.class);
        verify(clubRepository, never()).save(any());
    }

    @Test
    void createClubThrowsWhenNameAlreadyExists() {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(leader));
        when(clubRepository.existsByName("알고리즘 스터디")).thenReturn(true);

        assertThatThrownBy(() -> clubService.createClub(1L, "알고리즘 스터디", "설명", null))
                .isInstanceOf(DuplicateClubNameException.class);
        verify(clubRepository, never()).save(any());
        verify(clubMemberRepository, never()).save(any());
    }

    @Test
    void getClubMembersReturnsAllMembersWithLeaderFlag() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        User other = newUser(2L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);
        ClubMember leaderMembership = ClubMember.join(club, leader);
        ClubMember otherMembership = ClubMember.join(club, other);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(leaderMembership));
        when(clubMemberRepository.findByClubId(1L)).thenReturn(List.of(leaderMembership, otherMembership));

        List<ClubMemberSummaryResponse> responses = clubService.getClubMembers(1L, 1L);

        assertThat(responses).hasSize(2);
        ClubMemberSummaryResponse leaderSummary = responses.stream().filter(r -> r.userId().equals(1L)).findFirst().orElseThrow();
        ClubMemberSummaryResponse otherSummary = responses.stream().filter(r -> r.userId().equals(2L)).findFirst().orElseThrow();
        assertThat(leaderSummary.leader()).isTrue();
        assertThat(otherSummary.leader()).isFalse();
    }

    @Test
    void getClubMembersThrowsWhenCallerNotMember() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clubService.getClubMembers(1L, 1L))
                .isInstanceOf(ClubMembershipNotFoundException.class);
    }

    @Test
    void transferLeadershipUpdatesLeaderAndLeaderNameAndReturnsLeaderFalseForCaller() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User currentLeader = newUser(1L);
        User newLeader = newUser(2L, "새 회장");
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, currentLeader);
        ClubMember callerMembership = ClubMember.join(club, currentLeader);
        ClubMember newLeaderMembership = ClubMember.join(club, newLeader);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 2L)).thenReturn(Optional.of(newLeaderMembership));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.of(callerMembership));

        ClubDetailResponse response = clubService.transferLeadership(1L, 1L, 2L);

        assertThat(response.leader()).isFalse();
        assertThat(response.leaderName()).isEqualTo("새 회장");
        assertThat(club.isLedBy(2L)).isTrue();
        assertThat(club.isLedBy(1L)).isFalse();
    }

    @Test
    void transferLeadershipThrowsWhenCallerNotLeader() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User actualLeader = newUser(1L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, actualLeader);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));

        assertThatThrownBy(() -> clubService.transferLeadership(2L, 1L, 3L))
                .isInstanceOf(NotClubLeaderException.class);
    }

    @Test
    void transferLeadershipThrowsWhenTargetIsSelf() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));

        assertThatThrownBy(() -> clubService.transferLeadership(1L, 1L, 1L))
                .isInstanceOf(InvalidLeaderTransferException.class);
    }

    @Test
    void transferLeadershipThrowsWhenTargetNotMember() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubMemberRepository.findByClubIdAndUserId(1L, 2L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clubService.transferLeadership(1L, 1L, 2L))
                .isInstanceOf(ClubMembershipNotFoundException.class);
    }

    @Test
    void getPendingApplicationsReturnsOnlyPendingOnes() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        User applicant = newUser(2L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);
        ClubApplication application = ClubApplication.apply(club, applicant, "자기소개".repeat(5));

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubApplicationRepository.findByClubIdAndStatus(1L, ClubApplicationStatus.PENDING))
                .thenReturn(List.of(application));

        List<ClubApplicationResponse> responses = clubService.getPendingApplications(1L, 1L);

        assertThat(responses).hasSize(1);
        assertThat(responses.get(0).status()).isEqualTo(ClubApplicationStatus.PENDING);
        assertThat(responses.get(0).applicantName()).isEqualTo(applicant.getName());
    }

    @Test
    void getPendingApplicationsThrowsWhenCallerNotLeader() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));

        assertThatThrownBy(() -> clubService.getPendingApplications(2L, 1L))
                .isInstanceOf(NotClubLeaderException.class);
    }

    @Test
    void approveApplicationCreatesMembershipAndIncrementsMemberCount() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        User applicant = newUser(2L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);
        ClubApplication application = ClubApplication.apply(club, applicant, "자기소개".repeat(5));
        setField(application, "id", 10L);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubApplicationRepository.findById(10L)).thenReturn(Optional.of(application));

        ClubApplicationResponse response = clubService.approveApplication(1L, 1L, 10L);

        assertThat(response.status()).isEqualTo(ClubApplicationStatus.APPROVED);
        assertThat(application.getStatus()).isEqualTo(ClubApplicationStatus.APPROVED);
        assertThat(club.getMemberCount()).isEqualTo(25);
        verify(clubMemberRepository).save(any(ClubMember.class));
    }

    @Test
    void approveApplicationThrowsWhenAlreadyProcessed() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        User applicant = newUser(2L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);
        ClubApplication application = ClubApplication.apply(club, applicant, "자기소개".repeat(5));
        application.approve();
        setField(application, "id", 10L);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubApplicationRepository.findById(10L)).thenReturn(Optional.of(application));

        assertThatThrownBy(() -> clubService.approveApplication(1L, 1L, 10L))
                .isInstanceOf(ClubApplicationNotPendingException.class);
        verify(clubMemberRepository, never()).save(any());
    }

    @Test
    void approveApplicationThrowsWhenApplicationBelongsToDifferentClub() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        User applicant = newUser(2L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);
        Club otherClub = newClub(2L, "등산 동아리", "리더2", "체육", 12, leader);
        ClubApplication application = ClubApplication.apply(otherClub, applicant, "자기소개".repeat(5));
        setField(application, "id", 10L);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubApplicationRepository.findById(10L)).thenReturn(Optional.of(application));

        assertThatThrownBy(() -> clubService.approveApplication(1L, 1L, 10L))
                .isInstanceOf(ClubApplicationNotFoundException.class);
    }

    @Test
    void rejectApplicationMarksRejectedWithoutCreatingMembership() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        User applicant = newUser(2L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);
        ClubApplication application = ClubApplication.apply(club, applicant, "자기소개".repeat(5));
        setField(application, "id", 10L);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));
        when(clubApplicationRepository.findById(10L)).thenReturn(Optional.of(application));

        ClubApplicationResponse response = clubService.rejectApplication(1L, 1L, 10L);

        assertThat(response.status()).isEqualTo(ClubApplicationStatus.REJECTED);
        assertThat(club.getMemberCount()).isEqualTo(24);
        verify(clubMemberRepository, never()).save(any());
    }

    @Test
    void rejectApplicationThrowsWhenCallerNotLeader() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository, clubApplicationRepository, userRepository, fileStorageService);
        User leader = newUser(1L);
        User applicant = newUser(2L);
        Club club = newClub(1L, "알고리즘 스터디", "리더", "학술", 24, leader);
        ClubApplication application = ClubApplication.apply(club, applicant, "자기소개".repeat(5));
        setField(application, "id", 10L);

        when(clubRepository.findById(1L)).thenReturn(Optional.of(club));

        assertThatThrownBy(() -> clubService.rejectApplication(2L, 1L, 10L))
                .isInstanceOf(NotClubLeaderException.class);
    }

    // Club/User는 @GeneratedValue id라 public 생성자/setter가 없다. schema.sql/data.sql로
    // 시딩되는 엔티티라 애플리케이션 코드에도 별도 생성 로직이 없으므로, 단위 테스트에서는
    // UserServiceTest의 setId() 패턴과 마찬가지로 리플렉션으로 직접 구성한다.
    //
    // leader는 Club.isLedBy(userId)가 null을 역참조하지 않도록 항상 채워야 한다.
    // 관리자 권한 자체를 테스트하지 않는 대다수 테스트는 이 오버로드로 아무
    // 관계없는 사용자(ID=999)를 회장으로 넣어두고, 권한 관련 테스트만 명시적으로
    // leader를 지정하는 오버로드를 쓴다.
    private static Club newClub(Long id, String name, String leaderName, String category, int memberCount)
            throws Exception {
        return newClub(id, name, leaderName, category, memberCount, newUser(999L));
    }

    private static Club newClub(Long id, String name, String leaderName, String category, int memberCount, User leader)
            throws Exception {
        Constructor<Club> constructor = Club.class.getDeclaredConstructor();
        constructor.setAccessible(true);
        Club club = constructor.newInstance();
        setField(club, "id", id);
        setField(club, "name", name);
        setField(club, "leaderName", leaderName);
        setField(club, "leader", leader);
        setField(club, "category", category);
        setField(club, "memberCount", memberCount);
        return club;
    }

    private static User newUser(Long id) throws Exception {
        return newUser(id, "Test User");
    }

    private static User newUser(Long id, String name) throws Exception {
        User user = User.createOAuthUser("user@example.com", name, Provider.GOOGLE, "uid-" + id);
        setField(user, "id", id);
        return user;
    }

    private static void setField(Object target, String fieldName, Object value) throws Exception {
        Field field = target.getClass().getDeclaredField(fieldName);
        field.setAccessible(true);
        field.set(target, value);
    }
}
