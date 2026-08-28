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
## ADR 002: 로그인은 Firebase Authentication(구글/애플)만 지원

- **상태**: 승인됨 (Accepted)
- **날짜**: 2026-08-28
- **맥락**:
  - MOA는 이메일/비밀번호 회원가입 없이 구글/애플 로그인만 지원하기로 함.
  - 클라이언트(Flutter)는 `firebase_auth` + `google_sign_in` / `sign_in_with_apple`로 로그인해
    Firebase ID Token을 얻고, 이를 백엔드에 전달하는 구조를 사용함 (참고: TechTalk 프로젝트의
    `features/auth` 구현 패턴).
- **결정**:
  - 백엔드는 Firebase Admin SDK로 ID Token을 검증한 뒤, 자체 JWT(`accessToken`)를 발급하는
    하이브리드 방식을 사용한다 (매 요청마다 Firebase를 호출하지 않음).
  - `users.password_hash`는 nullable로 변경하고, 이메일/비밀번호 가입 API는 만들지 않는다.
  - `users` 테이블에 `provider`(GOOGLE/APPLE), `provider_uid`(Firebase UID)를 추가하고
    `(provider, provider_uid)`를 유니크 제약으로 둔다.
  - Firebase 프로젝트/서비스 계정 키는 사람이 Firebase 콘솔에서 직접 발급하며 저장소에는
    절대 커밋하지 않는다(`FIREBASE_CREDENTIALS_PATH` 환경 변수로 주입). 아직 프로젝트가
    생성되지 않은 환경에서도 앱이 기동되도록, 자격 증명이 없으면 `/auth/login`만
    503(FIREBASE_NOT_CONFIGURED)으로 응답하고 나머지 기능은 정상 동작한다.
- **결과**:
  - `POST /auth/login`, `GET /users/me` 엔드포인트 추가 (openapi.yaml/API_CONTRACT.md 갱신).
  - refresh token, 이메일/비밀번호 로그인은 이번 범위에서 제외 (향후 별도 이슈).
