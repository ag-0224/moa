package com.moa.entity;

import com.moa.constant.Provider;
import com.moa.constant.Role;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * schema.sql의 users 테이블과 매핑되는 Entity.
 * MOA는 이메일/비밀번호 가입을 지원하지 않으므로(ADR 002), 생성은 항상
 * {@link #createOAuthUser}를 통해 구글/애플(Firebase) 로그인 정보로만 이루어진다.
 */
@Entity
@Table(name = "users", uniqueConstraints = {
        @UniqueConstraint(name = "uq_users_email", columnNames = "email"),
        @UniqueConstraint(name = "uq_users_provider_provider_uid", columnNames = {"provider", "provider_uid"})
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String email;

    @Column(name = "password_hash")
    private String passwordHash;

    @Column(nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role = Role.USER;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Provider provider;

    @Column(name = "provider_uid", nullable = false)
    private String providerUid;

    // 아래 세 필드는 최초 OAuth 로그인 시점에는 비어 있다(NULL). 회원가입 화면에서
    // completeProfile()로 채워지기 전까지는 isProfileCompleted()가 false를 반환한다.
    @Column(length = 50, unique = true)
    private String nickname;

    @Column(length = 100)
    private String major;

    @Column(name = "student_id", length = 20)
    private String studentId;

    public static User createOAuthUser(String email, String name, Provider provider, String providerUid) {
        User user = new User();
        user.email = email;
        user.name = name;
        user.role = Role.USER;
        user.provider = provider;
        user.providerUid = providerUid;
        return user;
    }

    /**
     * 회원가입 화면('회원 정보 입력')에서 제출한 추가 정보를 채운다.
     * 이 호출 이후로 {@link #isProfileCompleted()}가 true가 된다.
     */
    public void completeProfile(String name, String nickname, String major, String studentId) {
        this.name = name;
        this.nickname = nickname;
        this.major = major;
        this.studentId = studentId;
    }

    /**
     * 회원가입(추가 정보 입력)을 완료했는지 여부. nickname은 completeProfile() 전에는
     * 항상 NULL이므로, 이 값 하나로 '메인 화면으로 보낼지 회원가입 화면으로 보낼지'를
     * 판단할 수 있다(로그인 응답과 GET /users/me 응답 양쪽 모두에서 동일하게 동작).
     */
    public boolean isProfileCompleted() {
        return nickname != null;
    }
}
