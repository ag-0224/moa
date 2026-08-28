package com.moa.repository;

import com.moa.entity.ClubApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ClubApplicationRepository extends JpaRepository<ClubApplication, Long> {

    Optional<ClubApplication> findByClubIdAndUserId(Long clubId, Long userId);
}
