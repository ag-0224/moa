# MOA API Contract Guidelines

## 1. 개요
MOA 프로젝트의 REST API 표준 가이드라인입니다. 기계 판독 가능한 단일 출처는 저장소 루트의 [`openapi.yaml`](file:///Users/ag/Documents/moa/openapi.yaml)입니다.

## 2. 응답 포맷 (Standard Response Schema)

### 성공 응답 (Success)
```json
{
  "success": true,
  "data": { ... },
  "error": null
}
```

### 에러 응답 (Error)
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "INVALID_INPUT",
    "message": "입력값이 올바르지 않습니다.",
    "details": []
  }
}
```

> `GET /health`는 표준 응답 포맷이 정해지기 전에 만들어진 예외로, `{status, timestamp}`를 그대로 반환한다.
> 새 엔드포인트는 모두 위 표준 포맷을 따른다. `/health` 자체를 바꾸는 것은 이번 범위가 아니다.

## 3. 인증 (Authentication)

MOA는 이메일/비밀번호 로그인을 지원하지 않는다. 구글/애플 로그인만 지원하며, 클라이언트(Flutter)가
Firebase Authentication(`firebase_auth` + `google_sign_in` / `sign_in_with_apple`)으로 로그인을
완료해 Firebase ID Token을 얻고, 그 토큰을 `POST /auth/login`으로 백엔드에 전달한다.

1. 클라이언트: Firebase로 구글/애플 로그인 → Firebase ID Token 획득
2. 클라이언트 → 서버: `POST /auth/login { "idToken": "..." }`
3. 서버: Firebase Admin SDK로 idToken 검증 → 최초 로그인이면 `users` 테이블에 사용자 생성 → MOA 자체 JWT(`accessToken`) 발급
4. 클라이언트: 이후 요청에 `Authorization: Bearer <accessToken>` 헤더 사용 (예: `GET /users/me`)

서버에 Firebase 자격 증명(`FIREBASE_CREDENTIALS_PATH`)이 설정되지 않은 환경에서는
`POST /auth/login`이 `503 FIREBASE_NOT_CONFIGURED`를 반환한다. Firebase 프로젝트 생성 및
서비스 계정 키 발급 방법은 [`backend/README.md`](../backend/README.md)를 참고한다.

이미 다른 로그인 제공자(Provider)로 가입된 이메일로 로그인을 시도하면(예: 구글로 가입한
이메일과 같은 이메일로 애플 로그인 시도) `POST /auth/login`이 `409 DUPLICATE_EMAIL`을 반환한다.

### 회원가입(추가 정보 입력)

최초 OAuth 로그인 시 서버가 자동으로 만드는 `users` 행에는 이름/이메일만 채워지고
`nickname`/`major`/`studentId`는 비어(`null`) 있다. `User.profileCompleted`는 이 nickname이
설정됐는지 여부와 동치이며, `POST /auth/login`과 `GET /users/me` 응답 모두에 포함된다.
클라이언트는 이 값 하나로 로그인 직후나 앱 재시작 후 세션 복원 시 메인 화면으로 보낼지
회원가입 화면(추가 정보 입력)으로 보낼지 판단한다: `profileCompleted == false`면
회원가입 화면, `true`면 메인 화면.

회원가입 화면의 '작성 완료' 버튼은 `PATCH /users/me { "name", "nickname", "major",
"studentId" }`를 호출한다. 이미 다른 사용자가 쓰고 있는 닉네임이면 `409
DUPLICATE_NICKNAME`을 반환한다.

## 4. 동아리 (Club)

메인 페이지 홈 피드와 마이페이지에서 쓰는 동아리 목록/즐겨찾기 API다. 세 엔드포인트 모두
`Authorization: Bearer <accessToken>`이 필요하다.

- `GET /clubs/me` — 내가 가입한 동아리 목록. 응답 배열의 모든 항목은 `joined: true`다.
- `GET /clubs` — 전체 동아리 목록(메인 페이지 홈 피드). 로그인한 사용자 기준으로 각 항목에
  `joined`/`favorite`를 함께 내려준다.
- `PATCH /clubs/{clubId}/favorite { "favorite": true|false }` — 동아리 즐겨찾기 설정.

### 가입/즐겨찾기 데이터 모델

"가입했다"는 상태는 별도의 boolean 컬럼이 아니라 `club_members` 테이블에 `(club_id,
user_id)` 행이 존재하는지로 판단한다(`User.nickname == null`이 "회원가입 미완료"를
뜻하는 것과 같은 방식). `favorite`는 가입한 동아리에 대해서만 의미가 있으므로, 가입하지
않은 동아리를 즐겨찾기하려고 하면 `404 CLUB_MEMBERSHIP_NOT_FOUND`를 반환한다.
존재하지 않는 `clubId`면 `404 CLUB_NOT_FOUND`를 반환한다.

`Club.memberCount`는 `club_members`를 `COUNT()`하는 대신 `clubs` 테이블에 직접 저장된
값을 그대로 내려준다. 아직 실제 "동아리 가입/탈퇴" 기능이 없어서 `club_members`가
비어 있거나 희소할 수 있는 현재 상태에서는, 실시간 카운트보다 저장된 값이 더 신뢰할
수 있는 의도적인 단순화다. 실제 가입/탈퇴 플로우가 생기면 재검토한다.

### 로컬 개발용 더미 데이터

로컬(H2) 프로필로 실행하면 `data.sql`이 서버 기동 시마다 `clubs` 테이블에 동아리 8개를
자동으로 채워 넣는다(H2는 인메모리라 재시작마다 초기화된다). `users`/`club_members`는
실제 로그인이 있어야 채워질 수 있어서 자동 시딩 대상이 아니다. 로그인 후 "가입한
동아리"/"즐겨찾기" 화면까지 확인하려면 `data.sql` 맨 아래 주석 처리된 `club_members`
INSERT 스니펫을 본인의 `user_id`에 맞게 고쳐서 H2 콘솔(`/h2-console`)에서 직접
실행하면 된다.
