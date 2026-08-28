package com.moa.repository;

import com.moa.entity.Club;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClubRepository extends JpaRepository<Club, Long> {

    /**
     * "스터디 등록" 화면에서 이름 중복 여부를 확인하는 데 쓴다
     * (ClubService.createClub). 대소문자는 구분한다 — 한글 이름이 대부분이라
     * 대소문자 구분이 실질적인 문제가 되지 않는다.
     */
    boolean existsByName(String name);
}
