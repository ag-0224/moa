package com.moa.service;

import com.moa.constant.Provider;
import com.moa.dto.response.ClubResponse;
import com.moa.entity.Club;
import com.moa.entity.ClubMember;
import com.moa.entity.User;
import com.moa.filter.exception.ClubMembershipNotFoundException;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
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

    @Test
    void getMyClubsReturnsOnlyJoinedClubsWithTheirFavoriteFlag() throws Exception {
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository);
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
        ClubService clubService = new ClubService(clubRepository, clubMemberRepository);

        when(clubMemberRepository.findByClubIdAndUserId(1L, 1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clubService.setFavorite(1L, 1L, true))
                .isInstanceOf(ClubMembershipNotFoundException.class);
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
