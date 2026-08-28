package com.moa.controller;

import com.moa.dto.response.HealthResponse;
import com.moa.service.HealthService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * openapi.yaml의 GET /health 계약을 구현한다.
 */
@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class HealthController {

    private final HealthService healthService;

    @GetMapping("/health")
    public HealthResponse checkHealth() {
        return healthService.getHealth();
    }
}
