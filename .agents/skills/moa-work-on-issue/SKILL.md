---
name: moa-work-on-issue
description: MOA 저장소(Spring Boot 3 + Flutter)에서 기능 개발, 버그 수정, 리팩터링, 테스트 또는 문서 이슈를 계획하고 구현할 때 사용한다. Definition of Ready/Done, develop 기준 브랜치, 최소 변경 범위, 검증 명령을 강제한다.
---

# MOA 이슈 작업 (Work on Issue)

MOA 협업 계약을 지키면서 이슈 하나를 안전하게 계획하고 구현한다.

## 1. 기준 문서 읽기

작업 전에 다음 순서로 핵심 문서를 확인한다.

1. `AGENTS.md`
2. `AI_RULES.md`
3. `docs/PROJECT_CONTEXT.md`
4. `docs/COLLABORATION.md`
5. 백엔드 작업 시 `docs/REPOSITORY_STRUCTURE.md`, 프론트엔드 작업 시 `docs/USER_FLOW.md`

API 경로나 요청·응답·오류·상태·DB 스키마가 달라지면 `docs/API_CONTRACT.md`도 읽고 `$moa-change-api-contract`를 적용한다. 커밋, 푸시 또는 PR 준비 단계에서는 `$moa-prepare-pull-request`를 적용한다.

## 2. 착수 조건 확인 (Definition of Ready)

- 담당자와 연결된 GitHub 이슈가 있다.
- 해결하려는 사용자 문제와 기대 효과가 명확하다.
- 정상·오류·빈 상태·권한별 완료 조건(Acceptance Criteria)이 정해져 있다.
- 제외 범위(Out of Scope) 및 의존성이 명시되어 있다.

## 3. 범위 고정 및 브랜치 생성

1. 최신 `develop` 브랜치에서 시작한다.
2. `feature/*`, `bugfix/*`, `hotfix/*` 브랜치를 생성한다.
3. 수정할 파일과 검증 명령을 미리 정한다.

## 4. 검증 및 완료 (Definition of Done)

- 백엔드 검증: `cd backend && ./gradlew test`
- 프론트엔드 검증: `cd frontend && flutter analyze && flutter test`
- 협업 스크립트: `python -X utf8 scripts/validate_collaboration.py`
