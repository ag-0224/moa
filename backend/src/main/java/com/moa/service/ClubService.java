package com.moa.service;

import com.moa.constant.ClubApplicationStatus;
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
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.repository.ClubApplicationRepository;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
import com.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClubService {

    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final ClubApplicationRepository clubApplicationRepository;
    private final UserRepository userRepository;

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

    /**
     * 동아리 상세(가입 전 소개/지원) 화면. 가입했으면 applicationStatus는 항상 null이고,
     * 안 했으면 신청서 유무/상태(PENDING/REJECTED)를 함께 내려준다.
     */
    public ClubDetailResponse getClubDetail(Long userId, Long clubId) {
        Club club = findClubOrThrow(clubId);
        Optional<ClubMember> membership = clubMemberRepository.findByClubIdAndUserId(clubId, userId);

        if (membership.isPresent()) {
            return ClubDetailResponse.of(club, true, membership.get().isFavorite(), null);
        }

        ClubApplicationStatus applicationStatus = clubApplicationRepository.findByClubIdAndUserId(clubId, userId)
                .map(ClubApplication::getStatus)
                .orElse(null);
        return ClubDetailResponse.of(club, false, false, applicationStatus);
    }

    /**
     * "지원 하기" 버튼이 호출하는 가입 신청. 이미 가입돼 있으면 CLUB_ALREADY_JOINED,
     * 이미 PENDING 신청서가 있으면 CLUB_APPLICATION_ALREADY_PENDING을 던진다.
     * REJECTED 신청서가 있으면 새로 만들지 않고 그 행을 재사용해 다시 PENDING으로 돌린다.
     */
    @Transactional
    public ClubDetailResponse applyToClub(Long userId, Long clubId, String selfIntroduction) {
        Club club = findClubOrThrow(clubId);

        if (clubMemberRepository.findByClubIdAndUserId(clubId, userId).isPresent()) {
            throw new ClubAlreadyJoinedException("이미 가입한 동아리예요.");
        }

        Optional<ClubApplication> existing = clubApplicationRepository.findByClubIdAndUserId(clubId, userId);
        if (existing.isPresent()) {
            ClubApplication application = existing.get();
            if (application.getStatus() == ClubApplicationStatus.PENDING) {
                throw new ClubApplicationAlreadyPendingException("이미 승인 대기 중인 신청서가 있어요.");
            }
            application.resubmit(selfIntroduction);
            return ClubDetailResponse.of(club, false, false, application.getStatus());
        }

        User user = findUserOrThrow(userId);
        ClubApplication application = clubApplicationRepository.save(ClubApplication.apply(club, user, selfIntroduction));
        return ClubDetailResponse.of(club, false, false, application.getStatus());
    }

    private Club findClubOrThrow(Long clubId) {
        return clubRepository.findById(clubId)
                .orElseThrow(() -> new ClubNotFoundException("존재하지 않는 동아리예요."));
    }

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new InvalidAuthTokenException("사용자를 찾을 수 없습니다."));
    }
}
