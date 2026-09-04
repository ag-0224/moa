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

import java.time.LocalDate;

/**
 * schema.sql의 attendance_codes 테이블과 매핑되는 Entity. 스터디 하루치
 * 출석번호(4자리) 한 건.
 *
 * clubs.leader_id가 생겨서 서버가 동아리장을 구분할 수는 있게 됐지만, 이
 * 코드를 발급/재발급하는 서비스 로직은 아직 별도 이슈로 남아있다 — 로컬
 * 개발에서는 data.sql 시드 데이터로만 채워진다(schema.sql 테이블 주석 참고).
 * 그래서 이 클래스에는 지금 당장 애플리케이션 코드가 쓰는 팩토리 메서드가
 * 없고, AttendanceCodeRepository로 조회만 한다 — 발급 API를 만들 때 함께
 * 팩토리 메서드를 추가하면 된다.
 */
@Entity
@Table(name = "attendance_codes", uniqueConstraints = {
        @UniqueConstraint(name = "uq_attendance_codes_club_date", columnNames = {"club_id", "attendance_date"})
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AttendanceCode extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id", nullable = false)
    private Club club;

    @Column(nullable = false, length = 4)
    private String code;

    @Column(name = "attendance_date", nullable = false)
    private LocalDate attendanceDate;
}
