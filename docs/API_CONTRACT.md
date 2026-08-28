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
