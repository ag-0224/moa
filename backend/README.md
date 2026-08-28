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
