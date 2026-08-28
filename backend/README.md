# MOA Backend (Spring Boot 3)

계층 구조와 계층 간 의존 방향은 저장소 루트의 [`docs/REPOSITORY_STRUCTURE.md`](../docs/REPOSITORY_STRUCTURE.md)를 따른다.
API 계약의 단일 진실 출처는 루트의 [`openapi.yaml`](../openapi.yaml) / [`docs/API_CONTRACT.md`](../docs/API_CONTRACT.md)이다.

## 실행

```bash
./gradlew bootRun
```

## 검증

```bash
./gradlew test
```

로컬 프로필(`local`)은 인메모리 H2와 루트 `schema.sql`을 기반으로 스키마를 초기화한다.

## 프로필

| 프로필 | 용도 | DB |
|---|---|---|
| `local` (기본값) | 로컬 개발/테스트 | 인메모리 H2, 루트 `schema.sql`로 초기화 |
| `docker` | Moarium과 동일한 MySQL 8 컨테이너 연결 | `../docker-compose.yml`의 `database-mysql` (Hibernate `ddl-auto=update`로 테이블 생성) |
| `prod` | 운영 배포 | PostgreSQL (`schema.sql` 계약 기준, `ddl-auto=validate`) |

`docker` 프로필로 실행하기 전, 저장소 루트에서 MySQL 컨테이너를 먼저 띄운다:

```bash
# 저장소 루트에서
cp .env.example .env   # DB_PASSWORD 등 값 채우기
docker compose up -d database-mysql

# backend/ 에서
SPRING_PROFILES_ACTIVE=docker DB_HOST=localhost ./gradlew bootRun
```

> `docker` 프로필은 루트 `schema.sql`(PostgreSQL 전용 문법)을 그대로 쓰지 않고 Hibernate DDL 생성을 사용한다.
> 자세한 이유는 `src/main/resources/application.yml`의 `docker` 프로필 주석 참고.

## 인증 (구글/애플 로그인)

MOA는 이메일/비밀번호 로그인을 지원하지 않는다. 클라이언트(Flutter)가 Firebase Authentication으로
구글/애플 로그인을 완료해 Firebase ID Token을 얻고, 이 토큰을 `POST /auth/login`으로 보내면
서버가 검증한 뒤 MOA 자체 JWT(`accessToken`)를 발급한다. 자세한 흐름은
[`docs/API_CONTRACT.md`](../docs/API_CONTRACT.md#3-인증-authentication) 참고.

### Firebase 프로젝트 설정 (최초 1회)

1. [Firebase 콘솔](https://console.firebase.google.com/)에서 새 프로젝트를 만든다 (또는 기존 프로젝트 사용).
2. **Authentication → Sign-in method**에서 Google, Apple 제공자를 각각 사용 설정한다.
   - Apple은 Apple Developer 계정에서 Services ID, Key(.p8) 등록이 추가로 필요하다
     (Firebase 콘솔의 Apple 제공자 설정 화면에 안내가 표시된다).
3. **프로젝트 설정 → 서비스 계정 → 새 비공개 키 생성**으로 서비스 계정 키(JSON)를 내려받는다.
   - 이 파일은 절대 저장소에 커밋하지 않는다 (`.gitignore`에 `firebase-service-account*.json`,
     `*firebase-adminsdk*.json` 패턴이 이미 등록되어 있다).
4. 저장소 루트의 `.env`(`.env.example` 복사본)에 아래 값을 채운다.
   ```
   FIREBASE_PROJECT_ID=<Firebase 프로젝트 ID>
   FIREBASE_CREDENTIALS_PATH=/absolute/path/to/service-account.json
   JWT_SECRET=<32바이트 이상의 임의 문자열>
   ```
5. `FIREBASE_CREDENTIALS_PATH`를 환경변수로 노출한 채 백엔드를 실행한다.
   ```bash
   export $(grep -v '^#' ../.env | xargs)
   ./gradlew bootRun
   ```

`FIREBASE_CREDENTIALS_PATH`가 비어 있으면 서버는 정상적으로 뜨지만
`POST /auth/login`만 `503 FIREBASE_NOT_CONFIGURED`를 반환한다 (다른 API는 영향 없음).
