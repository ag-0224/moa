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

`backend/`, `frontend/` 하위 계층 구조는 아직 코드가 없는 상태이며, 아래는 기존 **Moarium** 프로젝트(백엔드)와 **TechTalk** 프로젝트(프론트엔드)의 실제 구조를 참고하여 정의한 MOA의 목표 계층 구조다. 새 코드를 추가할 때는 이 구조를 기준으로 배치한다.

---

## 백엔드 계층 구조 (Spring Boot 3)

기존 Moarium 백엔드(`backend/spring-boot-3`)의 패키지 구성을 참고한 전형적인 Controller–Service–Repository 계층 구조다.

```text
backend/
└── src/main/java/com/moa/<module>/
    ├── MoaApplication.java             # Spring Boot 진입점
    ├── config/                         # 전역 설정 (Security, JWT, Swagger, QueryDSL, WebConfig 등)
    │   └── jwt/                        # JWT 발급·검증 설정
    ├── constant/                       # 상수, Enum (도메인/응답/필터/인가 판별 등)
    ├── controller/                     # HTTP 요청 진입점. 요청 검증 후 Service 위임, 응답 DTO 반환
    ├── dto/
    │   ├── request/                    # 요청(Request) DTO — Controller 입력 계약
    │   └── response/                   # 응답(Response) DTO — Controller 출력 계약
    ├── entity/                         # JPA Entity (DB 테이블 매핑, BaseEntity 상속)
    ├── repository/                     # Spring Data JPA Repository, QueryDSL Custom Repository
    ├── service/                        # 비즈니스 로직. Repository 조합, 트랜잭션 경계
    ├── scheduler/                      # 배치/주기 작업 (출석 자동 마감 등)
    ├── filter/
    │   ├── exception/                  # 커스텀 예외 클래스
    │   └── handler/                    # @ControllerAdvice 등 전역 예외 핸들러
    └── util/                           # 공통 유틸리티 (응답 포맷, 쿠키, 날짜, 검증 등)
```

계층 간 의존 방향: `Controller → Service → Repository → Entity`. Controller는 Service만 호출하고 Repository를 직접 참조하지 않는다. DTO는 Controller/Service 경계에서만 사용하고 Entity를 API 응답에 직접 노출하지 않는다. 계약(요청/응답 필드, 엔드포인트)은 `openapi.yaml`/`docs/API_CONTRACT.md`와 항상 동기화한다(§4 계약 변경 절차 참고).

---

## 프론트엔드 계층 구조 (Flutter, Clean Architecture)

`docs/PROJECT_CONTEXT.md`에 명시된 **Clean Architecture (Presentation / Domain / Data Layer)** 를 TechTalk 프로젝트의 실제 폴더 구조를 참고하여 구체화한 것이다. Riverpod(`hooks_riverpod`, `riverpod_generator`)를 상태 관리로, `dio`를 HTTP 클라이언트로, `get_it`을 서비스 로케이터로 사용한다.

```text
frontend/
└── lib/
    ├── app/                           # 앱 부트스트랩 (도메인/화면에 속하지 않는 앱 전역 설정)
    │   ├── di/                        # 의존성 주입 바인딩 (get_it 등록)
    │   ├── entrypoints/               # main_dev.dart, main_prod.dart 등 진입점(Flavor)
    │   ├── environment/               # 환경/Flavor 설정, Firebase 초기화
    │   ├── localization/              # 다국어 리소스
    │   ├── network/                   # Dio 인스턴스 등 네트워크 클라이언트 설정
    │   ├── notification/              # 로컬/푸시 알림 설정
    │   ├── router/                    # 라우팅(go_router 등) 정의
    │   ├── style/                     # 테마, 컬러, 텍스트 스타일
    │   └── util/                      # 앱 전역 포맷터/로거
    │
    ├── core/                          # 여러 feature가 공유하는 순수 공통 모듈 (도메인 비의존)
    │   ├── constants/                 # 전역 상수/Enum
    │   ├── helper/                    # Extension, Debouncer 등 헬퍼
    │   ├── modules/
    │   │   ├── base_use_case/         # UseCase 추상 베이스 클래스
    │   │   ├── converter/             # 타입 변환기
    │   │   ├── device/                # 디바이스 정보
    │   │   ├── error_handling/        # Result/에러 래퍼
    │   │   ├── exceptions/            # 공통 예외 타입
    │   │   ├── local/                 # 로컬 저장소 래퍼
    │   │   └── regex/                 # 검증용 정규식
    │   └── services/                  # 다이얼로그, 스낵바, Slack 알림 등 공통 서비스
    │
    ├── features/<feature>/            # 기능(도메인) 단위 모듈 — Domain + Data Layer
    │   │                              # 예: auth, blog, chat, interview, system, tech_set, topic, user, youtube
    │   ├── data_source/               # 원격(remote)/로컬(local) 데이터 소스 (API, 캐시)
    │   ├── repositories/              # Repository 인터페이스 + 구현체(_impl), 도메인 엔티티
    │   │   └── entities/
    │   └── usecases/                  # 단일 책임의 UseCase (비즈니스 규칙)
    │
    └── presentation/                  # Presentation Layer — UI와 화면 상태
        ├── app.dart                   # 루트 App 위젯
        ├── pages/<page>/              # 화면 단위 (Page, State, Event, 화면 전용 위젯)
        ├── providers/                 # Riverpod Provider (input/scroll/system/topic/user 등 도메인별 그룹핑)
        └── widgets/
            ├── base/                  # BasePage 등 공통 위젯 베이스 클래스
            ├── common/                # 재사용 가능한 디자인 시스템 컴포넌트 (button, dialog, input 등)
            └── section/                # 여러 페이지에서 재사용되는 섹션 단위 위젯
```

계층 간 의존 방향: `presentation → features/*/usecases → features/*/repositories → features/*/data_source`. `presentation`은 `data_source`를 직접 호출하지 않고 반드시 `usecases`를 거친다. `core`는 어떤 `features`에도 의존하지 않는다(반대로 `features`가 `core`를 사용하는 것은 허용). API 요청/응답 모델 변경 시 `data_source` → `repositories` → `usecases` → `presentation/providers` 순으로 동기화한다(§4 계약 변경 절차 참고).
