package com.moa.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

/**
 * FileStorageService가 로컬 디스크(app.upload.dir)에 저장한 파일(스터디 사진 등)을
 * "/uploads/**" 경로로 정적 서빙한다. WebSecurityConfig의 PUBLIC_ENDPOINTS에도
 * 같은 경로가 등록돼 있어야 인증 없이 접근할 수 있다(Image.network가 토큰을
 * 붙이지 않으므로).
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final String uploadDir;

    public WebMvcConfig(@Value("${app.upload.dir:uploads}") String uploadDir) {
        this.uploadDir = uploadDir;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String location = Paths.get(uploadDir).toAbsolutePath().normalize().toUri().toString();
        registry.addResourceHandler("/uploads/**").addResourceLocations(location);
    }
}
