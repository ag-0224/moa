---
name: moa-prepare-pull-request
description: MOA 변경사항을 완료 검토하고 커밋, 푸시 또는 Pull Request 준비 상태를 확인할 때 사용한다. diff 검토, Definition of Done, 실제 검증 결과, AI 사용 공개 포함을 강제한다.
---

# MOA PR 준비 및 리뷰 (Prepare Pull Request)

PR 작성 전 변경사항의 정합성과 완료 기준을 최종 점검한다.

## 1. 사전 검증 실행

- `python -X utf8 scripts/validate_collaboration.py`
- 백엔드 변경 포함 시: `cd backend && ./gradlew test`
- 프론트엔드 변경 포함 시: `cd frontend && flutter analyze && flutter test`

## 2. PR 작성 체크리스트

1. 연결된 GitHub 이슈 번호 표기
2. AI 사용 도구 및 작업 범위 공개
3. 실행한 테스트 명령 및 결과 첨부
4. 롤백 방안 및 남아있는 위험 요소 기술
