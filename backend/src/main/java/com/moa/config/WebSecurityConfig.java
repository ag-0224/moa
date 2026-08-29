package com.moa.config;

import com.moa.config.jwt.JwtAuthenticationFilter;
import com.moa.config.jwt.TokenProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * 베이스라인 Security 설정.
 *
 * 무상태(stateless) API + MOA 자체 JWT 인증(config.jwt.JwtAuthenticationFilter)을 사용한다.
 * 로그인은 이메일/비밀번호가 아닌 Firebase(구글/애플)로만 이루어지므로(ADR 002),
 * 별도의 폼 로그인/PasswordEncoder는 두지 않는다.
 */
@Configuration
@EnableWebSecurity
public class WebSecurityConfig {

    private static final String[] PUBLIC_ENDPOINTS = {
            "/api/v1/health",
            "/api/v1/auth/login",
            "/swagger-ui/**",
            "/v3/api-docs/**",
            "/h2-console/**",
            // FileStorageService가 저장한 스터디 사진 등을 서빙하는 경로(WebMvcConfig).
            // Image.network(thumbnailUrl)는 Authorization 헤더를 붙이지 않으므로 인증 없이
            // 접근 가능해야 한다.
            "/uploads/**"
    };

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, TokenProvider tokenProvider) throws Exception {
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
                .headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()))
                .addFilterBefore(new JwtAuthenticationFilter(tokenProvider), UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}
