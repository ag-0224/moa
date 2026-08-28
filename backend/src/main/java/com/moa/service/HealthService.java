package com.moa.service;

import com.moa.dto.response.HealthResponse;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;

@Service
public class HealthService {

    public HealthResponse getHealth() {
        return new HealthResponse("UP", OffsetDateTime.now());
    }
}
