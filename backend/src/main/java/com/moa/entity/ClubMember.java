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
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * schema.sql의 club_members 테이블과 매핑되는 Entity. 사용자 한 명이 동아리
 * 하나에 가입돼 있다는 관계이자, 그 동아리를 즐겨찾기했는지 여부를 담는다.
 *
 * 이 행이 존재하는 것 자체가 "가입됨"을 뜻한다(별도의 boolean 컬럼 없음).
 * 아직 실제 가입/탈퇴 API는 없어서(이번 작업 범위 밖) 지금은 개발용 목데이터로만
 * 채워진다 — schema.sql 옆의 dummy_data.sql 참고.
 */
@Entity
@Table(name = "club_members", uniqueConstraints = {
        @UniqueConstraint(name = "uq_club_members_club_user", columnNames = {"club_id", "user_id"})
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ClubMember extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id", nullable = false)
    private Club club;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "is_favorite", nullable = false)
    private boolean favorite;

    /**
     * 이번 학기 휴가 총 일수. schema.sql의 DB 기본값(3)과 반드시 같은 값으로
     * 맞춰둔다 — Hibernate가 INSERT 시 이 필드의 자바 기본값(초기화하지
     * 않으면 0)을 그대로 내려보내 DB DEFAULT를 덮어써 버리기 때문이다
     * (User.role = Role.USER 필드 초기화와 같은 이유).
     */
    @Column(name = "vacation_days_total", nullable = false)
    private int vacationDaysTotal = 3;

    public static ClubMember join(Club club, User user) {
        return join(club, user, false);
    }

    public static ClubMember join(Club club, User user, boolean favorite) {
        ClubMember member = new ClubMember();
        member.club = club;
        member.user = user;
        member.favorite = favorite;
        return member;
    }

    public void changeFavorite(boolean favorite) {
        this.favorite = favorite;
    }
}
