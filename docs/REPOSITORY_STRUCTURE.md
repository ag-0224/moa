# MOA Repository Structure

```text
moa/
├── AGENTS.md                          # 에이전트 지침 및 Definition of Ready/Done
├── AI_RULES.md                        # AI 실행 규칙
├── CLAUDE.md                          # Claude 에이전트 진입점
├── openapi.yaml                       # OpenAPI 3.1.0 API 계약
├── mock-data.json                     # Mock 및 Fixture 데이터
├── schema.sql                         # Database schema
├── backend/                           # Spring Boot 3 백엔드 애플리케이션
│   ├── src/main/java (or kotlin)
│   └── build.gradle
├── frontend/                          # Flutter 프론트엔드 애플리케이션
│   ├── lib/
│   └── pubspec.yaml
├── scripts/                           # 검증 스크립트 및 AI 시스템 프롬프트
│   ├── validate_collaboration.py
│   └── prompts/
├── .agents/skills/                    # MOA 전용 저장소 스킬
│   ├── moa-work-on-issue/
│   ├── moa-change-api-contract/
│   └── moa-prepare-pull-request/
├── docs/                              # 문맥 및 설계 문서
└── .github/                           # GitHub PR/Issue 템플릿 및 Copilot 지침
```
