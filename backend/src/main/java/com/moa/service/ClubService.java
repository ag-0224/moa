package com.moa.service;

import com.moa.constant.ClubApplicationStatus;
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
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.filter.exception.InvalidClubNameException;
import com.moa.filter.exception.InvalidLeaderTransferException;
import com.moa.filter.exception.NotClubLeaderException;
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
                .map(membership -> {
                    Club club = membership.getClub();
                    return ClubResponse.of(club, true, membership.isFavorite(), club.isLedBy(userId));
                })
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
                    return ClubResponse.of(club, joined, favorite, club.isLedBy(userId));
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
        Club club = membership.getClub();
        return ClubResponse.of(club, true, membership.isFavorite(), club.isLedBy(userId));
    }

    /**
     * 동아리 상세(가입 전 소개/지원) 화면. 가입했으면 applicationStatus는 항상 null이고,
     * 안 했으면 신청서 유무/상태(PENDING/REJECTED)를 함께 내려준다.
     */
    public ClubDetailResponse getClubDetail(Long userId, Long clubId) {
        Club club = findClubOrThrow(clubId);
        Optional<ClubMember> membership = clubMemberRepository.findByClubIdAndUserId(clubId, userId);

        if (membership.isPresent()) {
            return ClubDetailResponse.of(club, true, membership.get().isFavorite(), club.isLedBy(userId), null);
        }

        ClubApplicationStatus applicationStatus = clubApplicationRepository.findByClubIdAndUserId(clubId, userId)
                .map(ClubApplication::getStatus)
                .orElse(null);
        return ClubDetailResponse.of(club, false, false, false, applicationStatus);
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
            return ClubDetailResponse.of(club, false, false, false, application.getStatus());
        }

        User user = findUserOrThrow(userId);
        ClubApplication application = clubApplicationRepository.save(ClubApplication.apply(club, user, selfIntroduction));
        return ClubDetailResponse.of(club, false, false, false, application.getStatus());
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
                Club.create(trimmedName, leader, DEFAULT_CATEGORY, thumbnailUrl, description)
        );
        clubMemberRepository.save(ClubMember.join(club, leader));

        return ClubDetailResponse.of(club, true, false, true, null);
    }

    /**
     * 관리자 권한 넘기기 화면(멤버 선택)에서 쓰는 동아리 멤버 목록. 가입한
     * 사용자만 조회할 수 있다 — 가입하지 않았으면 CLUB_MEMBERSHIP_NOT_FOUND.
     */
    public List<ClubMemberSummaryResponse> getClubMembers(Long userId, Long clubId) {
        Club club = findClubOrThrow(clubId);
        clubMemberRepository.findByClubIdAndUserId(clubId, userId)
                .orElseThrow(() -> new ClubMembershipNotFoundException("가입한 동아리만 멤버 목록을 볼 수 있어요."));

        return clubMemberRepository.findByClubId(clubId).stream()
                .map(member -> ClubMemberSummaryResponse.of(member, club.isLedBy(member.getUser().getId())))
                .toList();
    }

    /**
     * 관리자(동아리장) 권한 넘기기. 현재 동아리장만 호출할 수 있고(아니면
     * NotClubLeaderException), 대상은 반드시 이 동아리의 기존 가입 멤버여야
     * 한다(아니면 ClubMembershipNotFoundException). 자기 자신에게 넘기려
     * 하면 InvalidLeaderTransferException을 던진다.
     */
    @Transactional
    public ClubDetailResponse transferLeadership(Long userId, Long clubId, Long newLeaderId) {
        Club club = findClubOrThrow(clubId);
        requireLeader(club, userId);

        if (newLeaderId.equals(userId)) {
            throw new InvalidLeaderTransferException("이미 관리자인 사용자예요.");
        }

        ClubMember newLeaderMembership = clubMemberRepository.findByClubIdAndUserId(clubId, newLeaderId)
                .orElseThrow(() -> new ClubMembershipNotFoundException("이 동아리의 가입 멤버에게만 권한을 넘길 수 있어요."));
        ClubMember callerMembership = clubMemberRepository.findByClubIdAndUserId(clubId, userId)
                .orElseThrow(() -> new ClubMembershipNotFoundException("가입한 동아리가 아니에요."));

        club.changeLeader(newLeaderMembership.getUser());

        // 넘긴 직후 호출한 사용자는 더 이상 동아리장이 아니므로 leader=false로 내려준다.
        return ClubDetailResponse.of(club, true, callerMembership.isFavorite(), false, null);
    }

    /**
     * 가입 신청 목록(관리자 전용). 아직 처리하지 않은 PENDING 신청서만
     * 내려준다 — APPROVED는 멤버 목록에서 이미 보이고, REJECTED는 더 조치할
     * 게 없다.
     */
    public List<ClubApplicationResponse> getPendingApplications(Long userId, Long clubId) {
        Club club = findClubOrThrow(clubId);
        requireLeader(club, userId);

        return clubApplicationRepository.findByClubIdAndStatus(clubId, ClubApplicationStatus.PENDING).stream()
                .map(ClubApplicationResponse::of)
                .toList();
    }

    /**
     * 가입 신청 승인(관리자 전용). club_members에 새 행을 만들어 실제로
     * 가입 처리하고 memberCount를 +1 한다. 이미 APPROVED/REJECTED로 처리된
     * 신청서를 다시 승인하려 하면 CLUB_APPLICATION_NOT_PENDING을 던진다
     * (memberCount 중복 증가를 막기 위해서다).
     */
    @Transactional
    public ClubApplicationResponse approveApplication(Long userId, Long clubId, Long applicationId) {
        Club club = findClubOrThrow(clubId);
        requireLeader(club, userId);
        ClubApplication application = findPendingApplicationOrThrow(clubId, applicationId);

        application.approve();
        clubMemberRepository.save(ClubMember.join(club, application.getUser()));
        club.incrementMemberCount();

        return ClubApplicationResponse.of(application);
    }

    /**
     * 가입 신청 거절(관리자 전용). 신청서 상태만 REJECTED로 바꾸고
     * club_members에는 변화가 없다. 지원자는 이후 POST /clubs/{clubId}/apply로
     * 재신청할 수 있다.
     */
    @Transactional
    public ClubApplicationResponse rejectApplication(Long userId, Long clubId, Long applicationId) {
        Club club = findClubOrThrow(clubId);
        requireLeader(club, userId);
        ClubApplication application = findPendingApplicationOrThrow(clubId, applicationId);

        application.reject();

        return ClubApplicationResponse.of(application);
    }

    private ClubApplication findPendingApplicationOrThrow(Long clubId, Long applicationId) {
        ClubApplication application = clubApplicationRepository.findById(applicationId)
                .filter(candidate -> candidate.getClub().getId().equals(clubId))
                .orElseThrow(() -> new ClubApplicationNotFoundException("존재하지 않는 신청서예요."));
        if (application.getStatus() != ClubApplicationStatus.PENDING) {
            throw new ClubApplicationNotPendingException("이미 처리된 신청서예요.");
        }
        return application;
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

    /**
     * 관리자 권한 넘기기/가입 신청 승인·거절 등 동아리장 전용 액션의 공통
     * 인가 검사. leaderName(표시용 문자열) 비교가 아니라 실제 leader_id FK
     * 기준이라 동명이인에 안전하다.
     */
    private void requireLeader(Club club, Long userId) {
        if (!club.isLedBy(userId)) {
            throw new NotClubLeaderException("동아리장만 할 수 있어요.");
        }
    }
}
