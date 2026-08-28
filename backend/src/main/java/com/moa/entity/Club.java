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
}
