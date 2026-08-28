package com.moa.filter.exception;

/**
 * 가입하지 않은 동아리를 즐겨찾기하려고 할 때 발생한다. 즐겨찾기는 가입한
 * 동아리에 대해서만 의미가 있다(프론트엔드 검색 화면도 가입하지 않은 동아리는
 * 즐겨찾기 롱프레스 메뉴 자체를 띄우지 않는다).
 */
public class ClubMembershipNotFoundException extends RuntimeException {
    public ClubMembershipNotFoundException(String message) {
        super(message);
    }
}
