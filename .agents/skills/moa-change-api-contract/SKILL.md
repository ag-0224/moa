---
name: moa-change-api-contract
description: MOA API 경로, HTTP 메서드, 인증, DTO 필드, 오류 응답, OpenAPI 스키마, DB 스키마 변경 시 사용한다. 계약 변경 승인 및 5단계 순서 동기화를 강제한다.
---

# MOA API 계약 변경 (Change API Contract)

MOA 프로젝트 (Spring Boot 3 + Flutter)의 API 및 데이터 계약을 안전하게 동기화한다.

## 1. 계약 변경의 정의

다음 항목의 변경은 단순 구현이 아닌 **계약 변경**이다:
- 엔드포인트 URL, HTTP 메서드, Header/Auth 사양
- Request/Response Body DTO 필드명, 타입, Nullability, Enum 값
- `openapi.yaml` 및 `docs/API_CONTRACT.md`
- `schema.sql` (DB 테이블, 컬럼, 제약조건)
- `mock-data.json`

## 2. 동기화 순서 (5-Step Sync)

1. 계약 문서 갱신 (`openapi.yaml`, `docs/API_CONTRACT.md`)
2. Spring Boot 백엔드 DTO / Controller / Entity / Service
3. Flutter 프론트엔드 API Client / Model / Provider State
4. Mock 데이터 (`mock-data.json`) 및 Fixture
5. 백엔드/프론트엔드 테스트 및 검증 스크립트 실행
