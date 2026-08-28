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
import com.moa.filter.exception.DuplicateClubNameException;
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.filter.exception.InvalidClubNameException;
import com.moa.repository.ClubApplicationRepository;
import com.moa.repository.ClubMemberRepository;
import com.moa.repository.ClubRepository;
import com.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

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
    private final FileStorageService fileStorageService;

    private static final int MAX_NAME_LENGTH = 100;

    /**
     * "스터디 등록" 화면에는 카테고리를 고르는 입력칸이 없다. 그렇다고 clubs.category를
     * NULL로 둘 수는 없어서(schema.sql NOT NULL) 고정값을 쓴다 — 카테고리별 분류/필터가
     * 필요해지면 그때 등록 화면에 선택 UI를 추가하고 이 상수를 걷어내면 된다.
     */
    private static final String DEFAULT_CATEGORY = "스터디";

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

    /**
     * 메인 페이지 "스터디 등록" 플로팅 버튼 → 등록 화면에서 호출하는 스터디(동아리)
     * 생성. 만든 사람이 곧바로 그 스터디의 회장 겸 첫 멤버가 되도록, 저장과 함께
     * club_members 행도 하나 만든다(가입 신청 승인 절차 없이 즉시 가입).
     *
     * 이름은 (1) 공백만 있거나 비어있으면 InvalidClubNameException, (2) 100자를
     * 넘으면 InvalidClubNameException, (3) 이미 존재하면 DuplicateClubNameException을
     * 던진다 — 프론트(ClubRegisterPage)는 이 셋을 구분하지 않고 전부 "이름" 입력칸
     * 아래 빨간 글씨 에러로 보여준다.
     */
    @Transactional
    public ClubDetailResponse createClub(Long userId, String name, String description, MultipartFile thumbnail) {
        User leader = findUserOrThrow(userId);
        String trimmedName = validateName(name);

        String thumbnailUrl = (thumbnail == null || thumbnail.isEmpty())
                ? null
                : fileStorageService.storeClubThumbnail(thumbnail);

        Club club = clubRepository.save(
                Club.create(trimmedName, leader.getName(), DEFAULT_CATEGORY, thumbnailUrl, description)
        );
        clubMemberRepository.save(ClubMember.join(club, leader));

        return ClubDetailResponse.of(club, true, false, null);
    }

    private String validateName(String name) {
        String trimmed = name == null ? "" : name.trim();
        if (trimmed.isEmpty()) {
            throw new InvalidClubNameException("스터디 이름을 입력해주세요.");
        }
        if (trimmed.length() > MAX_NAME_LENGTH) {
            throw new InvalidClubNameException("스터디 이름은 " + MAX_NAME_LENGTH + "자 이하로 입력해주세요.");
        }
        if (clubRepository.existsByName(trimmed)) {
            throw new DuplicateClubNameException("이미 사용 중인 스터디 이름이에요: " + trimmed);
        }
        return trimmed;
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
