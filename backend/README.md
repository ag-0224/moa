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
