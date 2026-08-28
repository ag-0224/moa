package com.moa;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class MoaApplication {

    public static void main(String[] args) {
        SpringApplication.run(MoaApplication.class, args);
    }
}
