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

    /**
     * 스터디 정보 수정(ClubService.updateClub)에서 이름 중복 여부를 확인하는
     * 데 쓴다. 자기 자신(clubId)은 비교 대상에서 제외해야, 이름을 바꾸지
     * 않고 그대로 재제출해도 중복으로 걸리지 않는다.
     */
    boolean existsByNameAndIdNot(String name, Long id);
}
