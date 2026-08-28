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

    public static User createOAuthUser(String email, String name, Provider provider, String providerUid) {
        User user = new User();
        user.email = email;
        user.name = name;
        user.role = Role.USER;
        user.provider = provider;
        user.providerUid = providerUid;
        return user;
    }
}
