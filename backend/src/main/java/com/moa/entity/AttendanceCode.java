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
 * clubs.leader_id 기준으로 동아리장만 호출할 수 있는
 * GET /clubs/{clubId}/attendance/code(AttendanceService.getOrIssueTodayCode)가
 * 이 코드를 발급/조회한다. 같은 (club_id, attendance_date)에 대해 이미
 * 발급된 코드가 있으면 그대로 재사용하고, 없으면 issue()로 새로 만든다.
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

    /**
     * 출석번호 발급(GET /clubs/{clubId}/attendance/code)에서 그날 코드가
     * 아직 없을 때 새로 만드는 팩토리.
     */
    public static AttendanceCode issue(Club club, String code, LocalDate attendanceDate) {
        AttendanceCode attendanceCode = new AttendanceCode();
        attendanceCode.club = club;
        attendanceCode.code = code;
        attendanceCode.attendanceDate = attendanceDate;
        return attendanceCode;
    }
}
