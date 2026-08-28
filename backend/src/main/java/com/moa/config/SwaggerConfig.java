package com.moa.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * springdoc-openapi 문서 메타데이터 설정.
 * API 계약의 단일 진실 출처는 저장소 루트의 openapi.yaml이며,
 * 이 설정은 로컬 개발 중 Swagger UI(/swagger-ui.html)로 확인하기 위한 보조 수단이다.
 */
@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI moaOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("MOA API Contract")
                        .description("Single Source of Truth for MOA Spring Boot 3 Backend & Flutter Frontend REST API")
                        .version("1.0.0"));
    }
}
