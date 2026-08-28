# MOA Collaboration Protocol & AI Vibe Coding Guidelines

## 1. AI와 사람의 페어 프로그래밍 원칙

1. **지시와 승인 중심**: AI 에이전트는 사람의 명시적인 요구사항과 승인된 이슈 안에서만 실행한다.
2. **단일 이슈 집중**: 1개 이슈 = 1개 브랜치 (`feature/*`) = 1개 PR.
3. **투명한 공개**: PR 생성 시 사용한 AI 도구, AI 수행 범위, 검증 명령 결과를 명시한다.

## 2. 리뷰 및 검증 스크립트

모든 커밋 및 PR 전 저장소 상단 검증 스크립트를 실행한다:
```bash
python -X utf8 scripts/validate_collaboration.py
```
게이트웨이 검증을 통과하지 않은 코드는 PR 병합 대상이 될 수 없다.
