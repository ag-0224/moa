-- 이 파일은 로컬(H2) 개발용 스키마 초기화 스크립트다.
-- 단일 진실 출처는 저장소 루트의 schema.sql이며, 그 파일이 바뀌면 이 파일도 함께 동기화한다.

-- MOA Database Schema Definition (PostgreSQL / MySQL compatible)

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    provider VARCHAR(20) NOT NULL,
    provider_uid VARCHAR(255) NOT NULL,
    -- 최초 OAuth 로그인 시점에는 비어 있다가(NULL), 회원가입 화면(추가 정보 입력)
    -- 제출 후 채워진다. nickname이 NULL이면 '아직 회원가입을 완료하지 않은 사용자'라는
    -- 뜻이며, 이 값 하나로 로그인 시/앱 재시작 시 모두 메인 화면행/회원가입 화면행을 판단한다.
    nickname VARCHAR(50),
    major VARCHAR(100),
    student_id VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_provider_provider_uid UNIQUE (provider, provider_uid),
    CONSTRAINT uq_users_nickname UNIQUE (nickname)
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE TABLE IF NOT EXISTS clubs (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    leader_name VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    member_count INTEGER NOT NULL DEFAULT 0,
    thumbnail_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- club_members는 (club_id, user_id) 행의 존재 자체가 '가입했다'는 뜻이다. 별도의
-- is_joined 컬럼은 없고, 가입한 동아리에 한해서만 의미가 있는 is_favorite만 저장한다.
CREATE TABLE IF NOT EXISTS club_members (
    id BIGSERIAL PRIMARY KEY,
    club_id BIGINT NOT NULL REFERENCES clubs(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_club_members_club_user UNIQUE (club_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_club_members_user_id ON club_members(user_id);
CREATE INDEX IF NOT EXISTS idx_club_members_club_id ON club_members(club_id);
