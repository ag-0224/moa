package com.moa.repository;

import com.moa.entity.ClubMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ClubMemberRepository extends JpaRepository<ClubMember, Long> {

    List<ClubMember> findByUserId(Long userId);

    Optional<ClubMember> findByClubIdAndUserId(Long clubId, Long userId);
}
