# MOA AI 작업 실행 규칙 (AI Rules)

이 문서는 MOA (Spring Boot 3 + Flutter) 저장소에서 AI 에이전트가 준수해야 하는 작업 및 실행 규칙의 절대 기준이다. 사람의 명시적 지시와 승인된 이슈 범위 안에서만 작업을 수행한다.

---

## 1. 기준과 우선순위

- 현재 제품 개발의 기준 브랜치는 `develop`이다.
- 제품 범위는 `docs/PROJECT_CONTEXT.md` 및 `docs/PRD.md`, 유저 흐름은 `docs/USER_FLOW.md`를 따른다.
- 백엔드 REST API의 단일 진실 출처(Single Source of Truth)는 `openapi.yaml` 및 `docs/API_CONTRACT.md`이다.
- 의사결정 이력은 `docs/DECISIONS.md`에 기록하고 준수한다.
- 문서 간 내용이 충돌하거나 문서와 구현 코드가 일치하지 않을 경우, 에이전트 임의로 수정하지 말고 차이점과 영향도를 보고하여 사람의 승인을 받는다.

---

## 2. 작업 시작 전 필수 점검 (Checklist)

구현을 시작하기 전 아래 6가지 조건이 충족되어야 한다.

1. 담당자와 연결된 GitHub 이슈
2. 해결하려는 명확한 사용자 문제 및 우선순위 (P0~P3)
3. 객관적으로 검증 가능한 완료 조건 (Acceptance Criteria)
4. 제외 범위(Out of Scope) 및 의존성
5. Spring Boot DTO / Controller 사양 또는 Flutter Screen / State 사양
6. 필요 시 사람의 사전 승인

필요 정보가 누락되어 구현 결과가 크게 달라질 수 있는 경우 작업을 진행하기 전에 질문한다. 영향이 적은 세부 사항은 기존 코딩 스타일 및 패턴을 근거로 최소한의 가정을 명시한 뒤 진행한다.

---

## 3. 작업 범위 제어 (Scope Control)

- 수정 대상 파일과 영향 범위를 사전에 파악한다.
- 단일 이슈에는 해당 문제 해결을 위한 최소한의 변경만 포함한다.
- 이슈 내용과 무관한 포맷팅 정돈, 변수명 변경, 전면 리팩터링을 함게 섞어서 작업하지 않는다.
- 기존 코드, 타입, 컴포넌트, 공통 라이브러리를 우선 재사용한다.
- 라이브러리/프레임워크 API를 가상으로 추측하지 말고 설치된 버전 및 공식 문서를 확인한다.
- 사전 승인 없는 새 패키지 추가, 전체 구조 재작성, API 계약 변경, 테스트 코드 삭제를 금지한다.

---

## 4. Git 및 코드 리뷰 규칙

- 작업 시작 시 `develop` 브랜치에서 최신 코드를 pull 받은 후 브랜치를 생성한다.
- 브랜치명 형식: `feature/*`, `bugfix/*`, `hotfix/*`
- 커밋 메시지 타입: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- 1개 이슈 = 1개 PR을 원칙으로 한다.
- `main` 및 `develop` 브랜치에 직접 커밋/푸시하지 않는다.
- 브랜치 생성, 커밋, 푸시, PR 생성은 사람의 명시적 요청이나 승인된 범위 안에서만 수행한다.

---

## 5. API 및 데이터 계약 규칙

다음 변경사항은 단순 코딩이 아닌 **계약 변경(Contract Change)**으로 관리한다:

- 엔드포인트 URL, HTTP 메서드, 인증/권한 헤더
- Request/Response Body 필드, Enum 값, 에러 응답 구조
- OpenAPI Specification (`openapi.yaml`)
- DB 테이블 스키마, 컬럼, 제약조건
- Mock 데이터 구조 (`mock-data.json`)

계약 변경은 별도의 승인이 필수적이며, 승인 후에는 `OpenAPI/계약 문서` ➡️ `Spring Boot 백엔드 DTO/Controller` ➡️ `Flutter 프론트엔드 Service/Model` ➡️ `Mock/테스트` 순서로 동기화한다.

---

## 6. 보안 및 비밀정보 보호

- API 키, DB 비밀번호, JWT Secret, OAuth Client Secret, 운영 자격증명을 코드/문서/로그에 노출하지 않는다.
- `.env` 및 비밀정보는 `.gitignore`에 등록하여 관리한다.
- 로그 메시지에 개인정보(PII)나 인증 토큰을 남기지 않는다.

---

## 7. 검증 및 AI 사용 공개

- 검증 실행:
  - Spring Boot 백엔드: `cd backend && ./gradlew test`
  - Flutter 프론트엔드: `cd frontend && flutter analyze && flutter test`
  - 협업 스크립트: `python -X utf8 scripts/validate_collaboration.py`
- 검사를 실행하지 못한 경우, 이유와 수동 검증 방안 및 위험 요소를 보고서에 명시한다.
- PR 생성 시 사용한 AI 도구, AI 작업 범위, 사람이 직접 검토한 파일 및 실행 결과를 밝힌다.
