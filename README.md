# MOA (Moarium Refactored Project)

> MOA는 기존 **Moarium** 프로젝트를 백엔드는 **Spring Boot 3**, 프론트엔드는 **Flutter**로 리팩토링 및 고도화하는 프로젝트입니다.  
> 체계적인 AI 에이전트 가버넌스 및 **바이브코딩 시스템(Vibe Coding System)**을 탑재하여 품질 기준과 테스트 자동화를 준수합니다.

---

## 🏗️ 프로젝트 아키텍처

- **백엔드 (Backend)**: Spring Boot 3 (REST Controller, Spring Data JPA, Spring Security, Swagger/OpenAPI)
- **프론트엔드 (Frontend)**: Flutter (Dart, App / Cross-platform UI, Riverpod / Provider 상태 관리, Clean Architecture)
- **계약 및 명세 (Contract)**: `openapi.yaml`, `mock-data.json`, `schema.sql`

```text
moa/
├── AGENTS.md                   # 에이전트 핵심 가버넌스 및 Definition of Ready/Done
├── AI_RULES.md                 # AI 실행 규칙 (우선순위, 보안, 범위 제어)
├── CLAUDE.md                   # Claude / AI 숏컷 가이드 문서
├── openapi.yaml                # 백엔드/프론트엔드 단일 진실 출처 (REST API 계약)
├── mock-data.json              # Mock 및 테스트 데이터 Fixture
├── schema.sql                  # 데이터베이스 스키마 및 제약조건
├── backend/                    # Spring Boot 3 애플리케이션
├── frontend/                   # Flutter 애플리케이션
├── scripts/                    # 검증 스크립트 및 AI 프롬프트
│   ├── validate_collaboration.py
│   └── prompts/
├── .agents/skills/             # 저장소 전용 에이전트 스킬
│   ├── moa-work-on-issue
│   ├── moa-change-api-contract
│   └── moa-prepare-pull-request
└── docs/                       # 기획, 레포 구조, API 계약, 의사결정 문서
```

---

## ⚡ 바이브코딩 시스템 (Vibe Coding System) 사용법

### 1. 작업 전 확인 규칙
작업을 시작하기 전 반드시 아래 기준 문서를 확인합니다:
- [`AGENTS.md`](file:///Users/ag/Documents/moa/AGENTS.md)
- [`AI_RULES.md`](file:///Users/ag/Documents/moa/AI_RULES.md)
- [`docs/PROJECT_CONTEXT.md`](file:///Users/ag/Documents/moa/docs/PROJECT_CONTEXT.md)

### 2. 에이전트 스킬 (Skills)
- **이슈 작업 계획 및 구현**: `$moa-work-on-issue`
- **API 및 DB 계약 변경**: `$moa-change-api-contract`
- **PR 준비 및 검증**: `$moa-prepare-pull-request`

### 3. 검증 스크립트 실행
```bash
# 1. 협업 계약 및 스킬, 프롬프트, 문서 검증
python -X utf8 scripts/validate_collaboration.py

# 2. 백엔드 검증 (Spring Boot)
cd backend && ./gradlew test

# 3. 프론트엔드 검증 (Flutter)
cd frontend && flutter analyze && flutter test
```

---

## 🌿 Git 브랜치 전략

- `main`: 운영 및 출시 브랜치
- `develop`: 메인 개발 통합 브랜치
- `feature/*`, `bugfix/*`, `hotfix/*`: 기능 단위 작업 브랜치
- 모든 커밋은 `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:` 접두사를 사용합니다.