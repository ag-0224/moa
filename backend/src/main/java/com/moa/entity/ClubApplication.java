package com.moa.entity;

import com.moa.constant.ClubApplicationStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
 * 가입하지 않은 동아리에 "지원하기"를 눌러 제출한 가입 신청서. club_members와는
 * 별개의 테이블이다 — 신청은 아직 가입이 아니고(joined는 여전히 club_members
 * 행의 존재로만 판단한다), 동아리장이 승인해야 비로소 가입이 된다.
 *
 * (club_id, user_id)에 유니크 제약을 둬서 사용자당 동아리 하나에 신청서 하나만
 * 존재하게 한다. REJECTED 상태에서 재신청하면 새 행을 만드는 대신 이 행을
 * {@link #resubmit(String)}으로 재사용한다.
 */
@Entity
@Table(name = "club_applications", uniqueConstraints = {
        @UniqueConstraint(name = "uq_club_applications_club_user", columnNames = {"club_id", "user_id"})
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ClubApplication extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id", nullable = false)
    private Club club;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "self_introduction", nullable = false, length = 1000)
    private String selfIntroduction;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ClubApplicationStatus status;

    public static ClubApplication apply(Club club, User user, String selfIntroduction) {
        ClubApplication application = new ClubApplication();
        application.club = club;
        application.user = user;
        application.selfIntroduction = selfIntroduction;
        application.status = ClubApplicationStatus.PENDING;
        return application;
    }

    /**
     * 거절(REJECTED)된 신청서를 새 자기소개로 다시 제출한다. PENDING인 신청서에는
     * 호출하지 않는다(ClubService가 먼저 상태를 확인해서 막는다).
     */
    public void resubmit(String selfIntroduction) {
        this.selfIntroduction = selfIntroduction;
        this.status = ClubApplicationStatus.PENDING;
    }

    // TODO(leader-approval): 동아리장 승인/거절 엔드포인트가 생기면 사용할 메서드.
    // 지금은 어디서도 호출되지 않는다.
    public void approve() {
        this.status = ClubApplicationStatus.APPROVED;
    }

    public void reject() {
        this.status = ClubApplicationStatus.REJECTED;
    }
}
