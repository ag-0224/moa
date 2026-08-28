# MOA Architecture Decision Records (ADR)

이 문서는 MOA 프로젝트 진행 중 내려진 기술적, 구조적 의사결정을 기록합니다.

---

## ADR 001: Moarium 프로젝트 리팩토링 및 백엔드/프론트엔드 기술 스택 선정

- **상태**: 승인됨 (Accepted)
- **날짜**: 2026-08-28
- **맥락**:
  - 기존 Moarium 시스템의 백엔드(Spring Boot)는 이식성이 높으나 프론트엔드는 모바일 환경 및 크로스플랫폼 확장에 제약이 있었음.
- **결정**:
  - 백엔드는 기존 Spring Boot 3 기반 고도화 유지.
  - 프론트엔드는 Flutter 기반 모바일/크로스플랫폼으로 전환.
  - 저장소 내 체계적인 AI Vibe Coding 가버넌스 시스템 구축.
- **결과**:
  - `openapi.yaml`을 기준으로 한 Spring Boot REST Controller 및 Flutter Client 1:1 계약 검증 체계 구축.
