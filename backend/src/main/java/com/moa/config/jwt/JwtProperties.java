package com.moa.config.jwt;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * jwt.secret / jwt.expiration-ms (application.yml, 실제 값은 JWT_SECRET / JWT_EXPIRATION_MS
 * 환경변수)를 감싸는 설정 값 객체. secret이 비어 있어도 애플리케이션 기동은 막지 않고,
 * 실제로 토큰을 만들거나 검증할 때(TokenProvider)만 예외를 던진다.
 */
@Component
public class JwtProperties {

    private final String secret;
    private final long expirationMs;

    public JwtProperties(
            @Value("${jwt.secret:}") String secret,
            @Value("${jwt.expiration-ms:86400000}") long expirationMs) {
        this.secret = secret;
        this.expirationMs = expirationMs;
    }

    public String getSecret() {
        return secret;
    }

    public long getExpirationMs() {
        return expirationMs;
    }
}
