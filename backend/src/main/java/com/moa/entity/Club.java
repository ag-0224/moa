package com.moa.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * schema.sql의 clubs 테이블과 매핑되는 Entity. 메인 페이지(홈 피드)/검색 화면에
 * 표시되는 동아리 한 건.
 *
 * memberCount는 club_members(가입 관계) 테이블을 매번 COUNT해서 구하지 않고
 * clubs 테이블에 그대로 저장된 값을 쓴다. 가입 신청이 승인될 때만
 * incrementMemberCount()로 +1 하고, 그 외에는(생성 시 1로 시작하는 것 포함)
 * 실시간으로 다시 세지 않는다 — 아직 "탈퇴" 기능이 없어서 감소 경로는 없다.
 *
 * leader는 이 동아리의 관리자(동아리장)다. 동아리를 만든 사용자로 시작하고
 * (create), changeLeader로 다른 가입 멤버에게 넘길 수 있다
 * (ClubService.transferLeadership). leaderName은 항상 leader와 같은
 * 사용자의 이름을 표시용으로 저장해둔 값이라, 응답을 만들 때마다 User를
 * 조인해서 이름을 다시 조회하지 않아도 된다 — changeLeader가 둘을 항상 함께
 * 갱신하므로 서로 어긋날 일이 없다.
 */
@Entity
@Table(name = "clubs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Club extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(name = "leader_name", nullable = false, length = 50)
    private String leaderName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "leader_id", nullable = false)
    private User leader;

    @Column(nullable = false, length = 50)
    private String category;

    @Column(name = "member_count", nullable = false)
    private int memberCount;

    @Column(name = "thumbnail_url")
    private String thumbnailUrl;

    /**
     * 동아리 상세(가입 전 소개) 화면에 보여줄 한두 문장짜리 소개 글.
     * 목록 화면(ClubListItem/ClubResponse)에는 쓰이지 않고, 상세 화면
     * (ClubDetailResponse)에서만 노출한다.
     */
    @Column(columnDefinition = "TEXT")
    private String description;

    /**
     * "스터디 등록" 화면(ClubService.createClub)에서 새 동아리를 만들 때 쓰는 팩토리.
     *
     * 동아리를 만든 사용자가 곧 회장이므로 leader로 그대로 저장하고,
     * leaderName도 그 사용자의 이름(User.getName())으로 채운다. category도
     * 등록 화면에는 입력칸이 없어서 ClubService.DEFAULT_CATEGORY 상수로
     * 고정한다(카테고리 선택 UI는 이번 작업 범위 밖). memberCount는 생성
     * 직후 ClubService가 만드는 사람을 club_members에 바로 가입시키므로
     * 1로 시작한다.
     */
    public static Club create(String name, User leader, String category, String thumbnailUrl, String description) {
        Club club = new Club();
        club.name = name;
        club.leader = leader;
        club.leaderName = leader.getName();
        club.category = category;
        club.memberCount = 1;
        club.thumbnailUrl = thumbnailUrl;
        club.description = description;
        return club;
    }

    /**
     * 관리자 권한 넘기기(PATCH /clubs/{clubId}/leader). leader와 leaderName을
     * 항상 함께 바꿔서 둘이 어긋나지 않게 한다.
     */
    public void changeLeader(User newLeader) {
        this.leader = newLeader;
        this.leaderName = newLeader.getName();
    }

    /**
     * 로그인한 사용자가 이 동아리의 관리자(동아리장)인지. ClubResponse/
     * ClubDetailResponse의 leader 필드와 각종 관리자 전용 API의 인가 검사
     * (ClubService.requireLeader)가 이 메서드로 판단한다.
     */
    public boolean isLedBy(Long userId) {
        return leader.getId().equals(userId);
    }

    /**
     * 가입 신청이 승인될 때(ClubService.approveApplication)만 호출된다 —
     * club_members에 새 행이 하나 생겼다는 뜻이라 저장된 카운트를 맞춰준다.
     */
    public void incrementMemberCount() {
        this.memberCount++;
    }
}
