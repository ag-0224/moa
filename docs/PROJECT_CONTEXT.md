# MOA Project Context & Architecture

## 1. 프로젝트 개요

MOA 프로젝트는 기존 **Moarium** 프로젝트를 고도화하는 리팩토링 프로젝트입니다.
백엔드는 **Spring Boot 3** 기반의 고성능 RESTful API 및 비즈니스 로직을 유지하고, 프론트엔드는 기존 웹(Next.js)에서 모바일/크로스플랫폼 지원을 위한 **Flutter** 기반으로 전면 리팩토링합니다.

## 2. 기술 스택 (Tech Stack)

### 백엔드 (Backend)
- **Framework**: Spring Boot 3 (Java 17+ / Kotlin)
- **Security**: Spring Security + JWT authentication
- **Database**: PostgreSQL / MySQL (JPA / Spring Data)
- **API Spec**: OpenAPI 3.1.0 (`openapi.yaml`)
- **Build Tool**: Gradle

### 프론트엔드 (Frontend)
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod / Provider
- **HTTP Client**: Dio / http
- **Architecture**: Clean Architecture (Presentation, Domain, Data Layer)

## 3. 핵심 규칙
- API 싱글 소스는 루트의 `openapi.yaml` 및 `docs/API_CONTRACT.md`이다.
- 에이전트는 `AGENTS.md` 및 `AI_RULES.md`를 철저히 지킨다.
