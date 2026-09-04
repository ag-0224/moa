package com.moa.entity;

import com.moa.constant.AttendanceStatus;
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

import java.time.LocalDate;

/**
 * schema.sql의 attendance_records 테이블과 매핑되는 Entity. 스터디 인원 한
 * 명이 특정 날짜에 출석했는지(PRESENT) 휴가를 썼는지(VACATION) 하나를 담는다.
 *
 * 결석은 이 행이 아예 없는 것으로 표현한다 — AttendanceService가 "지나간
 * 날짜인데 행이 없음"을 결석으로 계산한다. (club, user, attendanceDate)
 * 조합마다 최대 한 행만 존재하므로, 출석/휴가를 다시 선택하면 새로 만들지
 * 않고 {@link #changeStatus}로 기존 행을 갱신한다.
 */
@Entity
@Table(name = "attendance_records", uniqueConstraints = {
        @UniqueConstraint(
                name = "uq_attendance_records_club_user_date",
                columnNames = {"club_id", "user_id", "attendance_date"}
        )
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AttendanceRecord extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id", nullable = false)
    private Club club;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "attendance_date", nullable = false)
    private LocalDate attendanceDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AttendanceStatus status;

    public static AttendanceRecord of(Club club, User user, LocalDate attendanceDate, AttendanceStatus status) {
        AttendanceRecord record = new AttendanceRecord();
        record.club = club;
        record.user = user;
        record.attendanceDate = attendanceDate;
        record.status = status;
        return record;
    }

    /**
     * 출석번호 입력/휴가 사용을 오늘 중에 다시 선택했을 때, 새 행을 만들지
     * 않고 기존 행의 상태만 바꾼다(하루에 출석과 휴가를 동시에 가질 수 없음).
     */
    public void changeStatus(AttendanceStatus status) {
        this.status = status;
    }
}
