-- 이 파일은 로컬(H2) 개발용 스키마 초기화 스크립트다.
-- 단일 진실 출처는 저장소 루트의 schema.sql이며, 그 파일이 바뀌면 이 파일도 함께 동기화한다.

-- MOA Database Schema Definition (PostgreSQL / MySQL compatible)

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
