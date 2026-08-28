package com.moa.service;

import com.moa.dto.response.ClubResponse;
import com.moa.entity.Club;
import com.moa.entity.ClubMember;
import com.moa.filter.exception.ClubMembershipNotFoundException;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClubService {

    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;

    /**
     * 내가 가입한 동아리 목록('마이페이지' 등에서 사용). 전부 joined=true다.
     */
    public List<ClubResponse> getMyClubs(Long userId) {
        List<ClubMember> memberships = clubMemberRepository.findByUserId(userId);
        return memberships.stream()
                .map(membership -> ClubResponse.of(membership.getClub(), true, membership.isFavorite()))
                .toList();
    }

    /**
     * 전체 동아리 목록('메인 페이지' 홈 피드에서 사용). 로그인한 사용자의 가입/즐겨찾기
     * 여부를 함께 표시하기 위해 club_members를 clubId 기준으로 미리 맵으로 만들어 조회한다.
     */
    public List<ClubResponse> getAllClubs(Long userId) {
        List<Club> clubs = clubRepository.findAll();
        Map<Long, ClubMember> membershipByClubId = clubMemberRepository.findByUserId(userId).stream()
                .collect(Collectors.toMap(membership -> membership.getClub().getId(), Function.identity()));

        return clubs.stream()
                .map(club -> {
                    ClubMember membership = membershipByClubId.get(club.getId());
                    boolean joined = membership != null;
                    boolean favorite = joined && membership.isFavorite();
                    return ClubResponse.of(club, joined, favorite);
                })
                .toList();
    }

    /**
     * 가입한 동아리만 즐겨찾기할 수 있다. 가입 여부는 club_members에 (clubId, userId) 행이
     * 있는지로 판단하므로, 없으면 ClubMembershipNotFoundException을 던진다.
     */
    @Transactional
    public ClubResponse setFavorite(Long userId, Long clubId, boolean favorite) {
        ClubMember membership = clubMemberRepository.findByClubIdAndUserId(clubId, userId)
                .orElseThrow(() -> new ClubMembershipNotFoundException("가입한 동아리만 즐겨찾기할 수 있어요."));

        membership.changeFavorite(favorite);
        return ClubResponse.of(membership.getClub(), true, membership.isFavorite());
    }
}
