# MOA (Spring Boot + Flutter) Agent Instructions

이 저장소에서 작업하는 모든 코딩 에이전트는 작업을 시작하기 전에 이 파일과 아래 기준 문서를 반드시 읽고 따라야 한다.

1. `AI_RULES.md`
2. `docs/PROJECT_CONTEXT.md`
3. `docs/COLLABORATION.md`
4. 작업 관련 계약 및 설계 문서
   - 저장소 구조: `docs/REPOSITORY_STRUCTURE.md`
   - 제품 범위: `docs/PRD.md`, `docs/USER_FLOW.md`
   - API·DB 계약: `docs/API_CONTRACT.md`, `openapi.yaml`
   - 기존 의사결정: `docs/DECISIONS.md`

문서와 코드 또는 계약이 충돌하면 임의로 고치거나 단독 판단하지 않고, 충돌 지점과 영향을 사용자에게 보고한 뒤 승인을 받는다. `develop` 브랜치의 최신 코드를 현재 기준으로 삼는다.

---

## 1. 저장소 구조 및 지침

- 루트 디렉터리는 `openapi.yaml`, `mock-data.json`, `schema.sql`, `AGENTS.md`, `AI_RULES.md`, `scripts/`, `docs/`, `.agents/` 등 프로젝트 가버넌스 및 계약 문서를 관리한다.
- 백엔드(Spring Boot 3) 코드는 `backend/` 디렉터리에 위치하며, 빌드 및 검증은 `./gradlew test` 및 `./gradlew build`를 사용한다.
- 프론트엔드(Flutter) 코드는 `frontend/` 디렉터리에 위치하며, 검증은 `flutter analyze` 및 `flutter test`를 사용한다.
- 백엔드/프론트엔드 전용 하위 지침이 있는 경우, 하위 디렉터리의 지침을 추가로 읽되 하위 지침이 루트의 보안·계약·Git·승인 규칙을 대체하지 않는다.

---

## 2. 작업 시작 게이트 (Definition of Ready)

- 연결된 이슈, 담당자, 사용자 문제, 완료 기준, 제외 범위, 의존성을 확인한다.
- UI 작업이면 화면 상태와 디자인 시스템 기준을, API 작업이면 요청·응답·오류 계약(OpenAPI)을 확인한다.
- 중요한 제품 결정이나 계약 승인이 없으면 구현을 멈추고 질문한다.
- 하루를 넘길 작업은 독립적으로 검증 가능한 작은 이슈 단위로 나눈다.
- 한 작업자는 동시에 하나의 `In Progress` 이슈만 다룬다.

---

## 3. 구현 규칙

- 최신 `develop` 브랜치에서 `feature/*`, `bugfix/*`, `hotfix/*` 형식으로 브랜치를 생성한다.
- 이슈 하나당 PR 하나를 원칙으로 하며, 이슈와 관련 없는 파일 수정이나 포맷팅 변경을 섞지 않는다.
- 기존 클래스, DTO, 컴포넌트, 상태 관리 패키지(Riverpod 등)를 우선 재사용한다.
- 승인 없이 새로운 외부 프레임워크나 라이브러리를 도입하거나 API·DB 계약을 바꾸지 않는다.
- 비밀값, API 키, 운영 인증정보, 개인정보를 코드, 로그, 문서, Fixture에 절대 포함하지 않는다.
- 테스트를 삭제하거나 통과시키기 위해 검증 강도를 약화하지 않는다.

---

## 4. API 및 DB 계약 변경 절차

`openapi.yaml`, Spring Boot Controller/DTO, Flutter API Service/Model, DB 스키마(`schema.sql`)의 변경은 **계약 변경**으로 취급한다.
계약 변경 시 반드시 프론트엔드·백엔드 양쪽 승인을 확인한 뒤 다음 순서로 동기화한다:

1. 계약 문서 및 명세 (`openapi.yaml`, `docs/API_CONTRACT.md`)
2. Spring Boot 백엔드 (Controller, DTO, Entity, Repository)
3. Flutter 프론트엔드 (API Client, Model, State/Provider)
4. Mock 데이터 및 Fixture (`mock-data.json`)
5. 통합 테스트 및 문서 갱신

---

## 5. 검증과 완료 (Definition of Done)

- 정상 흐름, 예외/오류 흐름, 빈 데이터(Empty State), 권한 거부 시나리오를 종합 검토한다.
- 변경 범위에 맞는 검증 명령을 실행한다:
  - 백엔드 검증: `cd backend && ./gradlew test` (또는 프로젝트 루트에서 `npm/gradle` 래퍼 스크립트 실행)
  - 프론트엔드 검증: `cd frontend && flutter analyze && flutter test`
  - 협업 인프라/스킬/문서 검증: `python -X utf8 scripts/validate_collaboration.py`
- 실행하지 못한 검사는 통과했다고 허위 보고하지 말고, 이유와 수동 확인 방법 및 남은 위험을 명시한다.
- 커밋 메시지는 `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:` 커스텀 뷰를 명확히 사용한다.
- `main`과 `develop` 브랜치에 직접 push하지 않는다.
- PR 본문에 AI 사용 도구, 작업 범위, 사람이 직접 확인한 항목, 실행한 테스트 명령 및 결과를 투명하게 공개한다.

---

## 6. 저장소 전용 스킬 사용

관련 작업 수행 시 `.agents/skills/`에 정의된 스킬을 적용한다.

- 일반 이슈 계획 및 구현: `$moa-work-on-issue`
- API·DB·DTO 계약 변경: `$moa-change-api-contract`
- 커밋·PR 준비 및 완료 검증: `$moa-prepare-pull-request`
