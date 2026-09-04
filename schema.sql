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

-- clubs는 users보다 나중에 생성돼야 한다(leader_id가 users를 참조하므로).
CREATE TABLE IF NOT EXISTS clubs (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    -- 항상 leader_id가 가리키는 사용자의 이름과 같다(관리자 권한을 넘기면
    -- ClubService.transferLeadership이 둘을 함께 갱신한다). 그래도 목록/상세
    -- 응답을 만들 때마다 users를 조인하지 않도록 표시용으로 그대로 저장해둔다.
    leader_name VARCHAR(50) NOT NULL,
    -- 이 동아리의 관리자(동아리장). 동아리를 만든 사용자로 시작해서(ClubService.createClub),
    -- PATCH /clubs/{clubId}/leader로 다른 가입 멤버에게 넘길 수 있다(ClubService.transferLeadership).
    -- 로그인한 사용자가 관리자인지는 이 컬럼과 요청자 ID를 비교해서 판단한다
    -- (leaderName 문자열 비교는 동명이인에 취약해서 인가에는 쓰지 않는다).
    leader_id BIGINT NOT NULL REFERENCES users(id),
    category VARCHAR(50) NOT NULL,
    member_count INTEGER NOT NULL DEFAULT 0,
    thumbnail_url VARCHAR(500),
    -- 가입 전 소개(동아리 상세 화면)에만 쓰인다. 목록 화면에는 노출하지 않는다.
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_clubs_leader_id ON clubs(leader_id);

-- club_members는 (club_id, user_id) 행의 존재 자체가 '가입했다'는 뜻이다. 별도의
-- is_joined 컬럼은 없고, 가입한 동아리에 한해서만 의미가 있는 is_favorite만 저장한다.
CREATE TABLE IF NOT EXISTS club_members (
    id BIGSERIAL PRIMARY KEY,
    club_id BIGINT NOT NULL REFERENCES clubs(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
    -- 이번 학기 휴가 총 일수. 기본값 3은 스터디 출석 기능(AttendanceService)이
    -- 목데이터 시절부터 써오던 상수와 같다. 나중에 동아리장이 인원별로 휴가를
    -- 더 주는 기능(관리 페이지, 아직 미구현)이 생기면 이 컬럼을 UPDATE하면 된다.
    vacation_days_total INTEGER NOT NULL DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_club_members_club_user UNIQUE (club_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_club_members_user_id ON club_members(user_id);
CREATE INDEX IF NOT EXISTS idx_club_members_club_id ON club_members(club_id);

-- 가입 신청서. club_members(가입 확정)와는 별개 테이블이다 — 신청은 아직
-- 가입이 아니고, 동아리장이 승인해야 club_members에 행이 생긴다(승인 기능
-- 자체는 이번 범위 밖이라 아직 없다). 사용자당 동아리 하나에 신청서 하나만
-- 존재할 수 있고, 거절되면 같은 행을 재사용해 다시 신청(PENDING)한다.
CREATE TABLE IF NOT EXISTS club_applications (
    id BIGSERIAL PRIMARY KEY,
    club_id BIGINT NOT NULL REFERENCES clubs(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    self_introduction VARCHAR(1000) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_club_applications_club_user UNIQUE (club_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_club_applications_user_id ON club_applications(user_id);


-- 스터디 출석 기록. 하루에 한 번, PRESENT(출석) 또는 VACATION(휴가) 중 하나만
-- 남는다. 결석(ABSENT)은 별도로 저장하지 않고 "그 날짜에 이 club_id/user_id
-- 조합의 행이 없다"로 표현한다 — 지나간 날짜인데 행이 없으면 결석으로
-- 계산하고, 오늘 날짜인데 행이 없으면 "아직 정하지 않음(예정)"으로 다르게
-- 취급한다(AttendanceService/AttendanceMark 참고). (club_id, user_id,
-- attendance_date) 조합마다 하나의 행만 존재하므로, 출석/휴가를 다시
-- 선택하면 새로 INSERT하지 않고 기존 행의 status를 바꾼다(하루에 출석과
-- 휴가를 동시에 가질 수 없음).
CREATE TABLE IF NOT EXISTS attendance_records (
    id BIGSERIAL PRIMARY KEY,
    club_id BIGINT NOT NULL REFERENCES clubs(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_attendance_records_club_user_date UNIQUE (club_id, user_id, attendance_date)
);

CREATE INDEX IF NOT EXISTS idx_attendance_records_club_date ON attendance_records(club_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_records_user_id ON attendance_records(user_id);

-- 스터디별 그날의 출석번호(하루 4자리, "출석 하기" 버튼의 출석번호 입력이
-- 검증하는 정답). clubs.leader_id가 생겨서 서버가 "누가 이 스터디의
-- 동아리장인지"는 판단할 수 있게 됐지만, 동아리장이 매일 번호를 새로
-- 발급/조회하는 API는 이번 변경 범위(관리자 권한 인프라 + 가입 신청
-- 승인/거절)에 포함되지 않아 아직 만들지 않았다. 그 전까지는 로컬 개발용
-- 시드 데이터(data.sql)로만 채워 넣는다.
CREATE TABLE IF NOT EXISTS attendance_codes (
    id BIGSERIAL PRIMARY KEY,
    club_id BIGINT NOT NULL REFERENCES clubs(id),
    code VARCHAR(4) NOT NULL,
    attendance_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_attendance_codes_club_date UNIQUE (club_id, attendance_date)
);
