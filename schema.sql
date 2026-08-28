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
