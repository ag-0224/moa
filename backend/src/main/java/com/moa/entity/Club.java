package com.moa.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * schema.sql의 clubs 테이블과 매핑되는 Entity. 메인 페이지(홈 피드)/검색 화면에
 * 표시되는 동아리 한 건.
 *
 * memberCount는 club_members(가입 관계) 테이블을 매번 COUNT해서 구하지 않고
 * clubs 테이블에 그대로 저장된 값을 쓴다. 아직 실제 "동아리 가입" 기능(가입/탈퇴
 * API)이 없어서(이번 작업 범위 밖) club_members에는 개발용 목데이터만 들어있고,
 * 실제 가입 인원을 반영하지 못하기 때문이다. 가입/탈퇴 기능이 생기면 그때
 * club_members 기준 COUNT로 바꾸는 게 맞다.
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
     * leaderName은 별도 입력칸이 없다 — 동아리를 만든 사용자가 곧 회장이므로
     * User.getName()을 그대로 쓴다. category도 등록 화면에는 입력칸이 없어서
     * ClubService.DEFAULT_CATEGORY 상수로 고정한다(카테고리 선택 UI는 이번
     * 작업 범위 밖). memberCount는 생성 직후 ClubService가 만드는 사람을
     * club_members에 바로 가입시키므로 1로 시작한다 — 이 값은 클래스 상단에
     * 문서화된 것처럼 club_members를 실시간으로 세지 않는 저장된 값이라,
     * 이후 실제 가입/탈퇴가 있어도 자동으로 갱신되지 않는다는 점은 동일하다.
     */
    public static Club create(String name, String leaderName, String category, String thumbnailUrl, String description) {
        Club club = new Club();
        club.name = name;
        club.leaderName = leaderName;
        club.category = category;
        club.memberCount = 1;
        club.thumbnailUrl = thumbnailUrl;
        club.description = description;
        return club;
    }
}
