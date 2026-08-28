# MOA Frontend (Flutter)

계층 구조와 계층 간 의존 방향은 저장소 루트의 [`docs/REPOSITORY_STRUCTURE.md`](../docs/REPOSITORY_STRUCTURE.md)를 따른다.
API 계약의 단일 진실 출처는 루트의 [`openapi.yaml`](../openapi.yaml) / [`docs/API_CONTRACT.md`](../docs/API_CONTRACT.md)이다.

## 아키텍처 요약

기능(feature) 단위 Clean Architecture를 따른다.

```text
lib/
├── app/            # 앱 전역 설정 (환경 변수, Dio 클라이언트, Firebase 옵션)
├── core/           # feature 비의존 공통 모듈 (Result, ApiException, TokenStorage)
├── features/       # 기능별 domain + data 계층 (auth, user, health)
│   └── {feature}/
│       ├── data_source/    # 원격(Dio) 데이터 접근
│       ├── repositories/   # 인터페이스 + 구현체
│       └── usecases/       # 단일 책임 유스케이스
└── presentation/   # 화면(pages), 상태 관리(providers/Riverpod)
```

의존 방향: `presentation → usecases → repositories(interface) ← repositories(impl) → data_source`.
`presentation`/`features`는 `core`를 참조할 수 있으나 `core`는 역참조하지 않는다.

### 의도적인 단순화 (TechTalk 대비)

이 스캐폴딩은 TechTalk의 패턴을 참고하되, 이 환경에서 검증 불가능한 코드 생성 도구에
의존하지 않도록 아래를 의도적으로 생략했다. 필요해지면 팀에서 별도로 도입 여부를 결정한다.

- `riverpod_generator` / `hooks_riverpod` 코드 생성 → 순수 `flutter_riverpod` `Provider`로 대체 (build_runner 불필요).
- `go_router` → 아직 화면 수가 적어 `app.dart`의 단순 `switch`(인증 상태 기반) 분기로 대체.
- `get_it` 등 별도 서비스 로케이터 → Riverpod provider를 DI 컨테이너로 사용.

## 시작하기

이 스캐폴딩은 Flutter SDK 없이(순수 Dart 코드로) 작성되었다. 네이티브 플랫폼 폴더
(`android/`, `ios/` 등)가 없으므로, 아래 순서로 최초 1회 보강한다.

```bash
cd frontend

# 1) 네이티브 플랫폼 스캐폴딩 생성 (기존 pubspec.yaml/lib/은 덮어쓰지 않음)
flutter create --platforms=android,ios --org com.moa .

# 2) 의존성 설치
flutter pub get

# 3) Firebase 프로젝트 연결 (아래 "Firebase 설정" 선행 필요)
#    lib/app/firebase/firebase_options.dart의 placeholder 값을 실제 값으로 교체한다.
flutterfire configure
```

## 검증

```bash
flutter analyze
flutter test
```

> 이 저장소의 스캐폴딩 작업은 Flutter SDK가 없는 환경에서 수행되었다. 위 명령은
> 아직 실행/통과 여부가 확인되지 않았다 (검증 공백). `flutter create` 및
> `flutter pub get` 실행 후 사용자 환경에서 직접 확인이 필요하다.

## Firebase 설정 (최초 1회)

백엔드와 동일한 Firebase 프로젝트를 사용한다 (`backend/README.md`의 "Firebase 프로젝트 설정" 참고).
새 프로젝트를 아직 만들지 않았다면 백엔드 쪽 안내를 먼저 따른다.

1. `flutterfire configure`를 실행해 Firebase 프로젝트를 선택하고, 사용할 플랫폼(Android/iOS)을 지정한다.
   - 이 명령이 `lib/app/firebase/firebase_options.dart`(현재 placeholder)를 실제 값으로 재생성한다.
   - `flutterfire` CLI가 없다면 `dart pub global activate flutterfire_cli`로 설치한다.
2. **Google 로그인**: Firebase 콘솔의 Authentication에서 Google 제공자를 사용 설정했는지 확인한다.
   - Android: 릴리즈/디버그 SHA-1(SHA-256) 지문을 Firebase 콘솔의 Android 앱 설정에 등록해야
     `google_sign_in`이 동작한다 (`./gradlew signingReport`로 확인).
   - iOS: `flutterfire configure`가 생성한 `GoogleService-Info.plist`의 `REVERSED_CLIENT_ID`를
     `ios/Runner/Info.plist`의 URL Scheme으로 등록해야 한다 (`flutterfire configure`가 대부분 자동 처리).
3. **Apple 로그인**: Apple Developer 계정에서 "Sign In with Apple" capability를 앱 ID에 추가하고,
   Xcode에서 Runner 타깃에 Sign In with Apple capability를 추가한다.
   - Firebase 콘솔의 Authentication → Apple 제공자 설정에서 Services ID/Key 등록이 필요하다
     (백엔드 Firebase Admin SDK 설정과는 별개로, 클라이언트 로그인을 위해 필요).
4. Firebase 프로젝트가 아직 연결되지 않은 상태(placeholder `firebase_options.dart`)에서도
   앱은 정상적으로 뜬다 — `lib/main.dart`가 `Firebase.initializeApp` 실패를 흡수하기 때문이다.
   로그인 버튼을 누르기 전까지는 영향이 없고, 누르면 에러 상태(`AuthError`)로 안내된다.

## 백엔드 연동

기본 API base URL은 `http://localhost:8080/api/v1` (`lib/app/environment/env.dart`)이다.
다른 값을 쓰려면 실행 시 `--dart-define`으로 재정의한다.

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

인증 흐름(`POST /auth/login`, `GET /users/me`)과 `{success, data, error}` 응답 봉투는
[`docs/API_CONTRACT.md`](../docs/API_CONTRACT.md)를 따른다. 예외적으로 `GET /health`는
이 봉투를 쓰지 않고 `{status, timestamp}`를 그대로 반환한다 (계약 문서에 명시된 기존 예외).
