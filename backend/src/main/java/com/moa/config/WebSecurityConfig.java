package com.moa.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * 베이스라인 Security 설정.
 *
 * 현재 openapi.yaml에는 인증이 필요한 엔드포인트가 정의되어 있지 않으므로,
 * 여기서는 무상태(stateless) API 기본값과 공개 엔드포인트(Health check, API 문서)만
 * 구성한다. JWT 인증 필터(config.jwt 패키지) 및 로그인/회원가입 계약이 확정되면
 * 계약 변경 절차(AGENTS.md §4)에 따라 이 설정을 확장한다.
 */
@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

    private static final String[] PUBLIC_ENDPOINTS = {
            "/api/v1/health",
            "/swagger-ui/**",
            "/v3/api-docs/**",
            "/h2-console/**"
    };

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(PUBLIC_ENDPOINTS).permitAll()
                        .anyRequest().authenticated()
                )
                // H2 콘솔(local 프로필 전용)은 내부적으로 HTML frame을 사용하므로
                // 동일 출처 프레임을 허용한다. local 프로필에서만 실제로 등록되는
                // 엔드포인트라 다른 프로필에는 영향이 없다.
                .headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()));
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
