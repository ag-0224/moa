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

### 개인정보 수정 / 회원 탈퇴

마이페이지('내 정보') 화면에서 쓰는 API다.

- 개인정보 수정은 회원가입 때와 같은 `PATCH /users/me` 엔드포인트를 그대로
  재사용한다 — 최초 제출이냐 이후 수정이냐를 서버가 구분하지 않고 매번 name/
  nickname/major/studentId 전체를 덮어쓴다. 닉네임 중복 시 `409
  DUPLICATE_NICKNAME`인 것도 동일하다.
- `DELETE /users/me` — 회원 탈퇴. 계정을 완전히 삭제한다(soft delete 없음).
  `club_members`/`club_applications`에 남아있는 해당 사용자의 행도 함께
  삭제한 뒤 `users` 행을 지운다(둘 다 users.id를 참조하는 외래키에 ON DELETE
  CASCADE가 없어서, 순서대로 지우지 않으면 외래키 제약 위반이 난다). 삭제
  후에는 클라이언트가 Firebase 로그아웃 + 저장된 액세스 토큰 삭제까지 해서
  로그인 화면으로 돌아가야 한다(AuthController.deleteAccount 참고).

## 4. 동아리 (Club)

메인 페이지 홈 피드와 마이페이지에서 쓰는 동아리 목록/즐겨찾기 API다. 세 엔드포인트 모두
`Authorization: Bearer <accessToken>`이 필요하다.

- `GET /clubs/me` — 내가 가입한 동아리 목록. 응답 배열의 모든 항목은 `joined: true`다.
- `GET /clubs` — 전체 동아리 목록(메인 페이지 홈 피드). 로그인한 사용자 기준으로 각 항목에
  `joined`/`favorite`/`leader`를 함께 내려준다.
- `PATCH /clubs/{clubId}/favorite { "favorite": true|false }` — 동아리 즐겨찾기 설정.

### 가입/즐겨찾기 데이터 모델

"가입했다"는 상태는 별도의 boolean 컬럼이 아니라 `club_members` 테이블에 `(club_id,
user_id)` 행이 존재하는지로 판단한다(`User.nickname == null`이 "회원가입 미완료"를
뜻하는 것과 같은 방식). `favorite`는 가입한 동아리에 대해서만 의미가 있으므로, 가입하지
않은 동아리를 즐겨찾기하려고 하면 `404 CLUB_MEMBERSHIP_NOT_FOUND`를 반환한다.
존재하지 않는 `clubId`면 `404 CLUB_NOT_FOUND`를 반환한다.

`Club.memberCount`는 `club_members`를 `COUNT()`하는 대신 `clubs` 테이블에 직접 저장된
값을 그대로 내려준다. 가입 신청이 승인될 때(`POST .../applications/{id}/approve`)만
+1 증가시키고, 그 외에는(동아리 생성 시 1로 시작하는 것 포함) 실시간으로 다시 세지
않는다. 아직 "탈퇴" 기능이 없어서 감소 경로는 없다 — 탈퇴 플로우가 생기면 재검토한다.

### 관리자(동아리장) 권한 — clubs.leader_id

`clubs` 테이블에 `leader_id`(users FK) 컬럼이 있다. 동아리를 만든 사용자가 생성과
동시에 `leader_id`로 저장되어 곧바로 관리자가 되고(`ClubService.createClub`),
`leaderName`(표시용 문자열)도 그 사용자의 이름으로 채워진다. 목록/상세 응답의
`leader` 필드는 로그인한 사용자의 ID를 `clubs.leader_id`와 비교해서 서버가 판단하는
값이다 — 예전에는 이 FK가 없어서 프론트엔드가 `leaderName` 문자열을 자기 닉네임과
비교하는 임시방편(`StudyHomePage._isLeader`)을 썼는데, 동명이인이 있으면 잘못
판별될 수 있는 보안 구멍이었다. 지금은 이 필드가 생겼으므로 프론트엔드는 더 이상
문자열 비교를 하지 않고 `leader` 필드를 그대로 쓴다.

- `PATCH /clubs/{clubId}/leader { "newLeaderId": 5 }` — 관리자 권한 넘기기. 현재
  동아리장만 호출할 수 있다.
  - 호출한 사용자가 동아리장이 아니면 `403 NOT_CLUB_LEADER`.
  - `newLeaderId`가 자기 자신이면 `400 INVALID_LEADER_TRANSFER`.
  - `newLeaderId`가 이 동아리의 가입 멤버가 아니면 `404 CLUB_MEMBERSHIP_NOT_FOUND`.
  - 성공하면 `clubs.leader_id`와 `leaderName`이 모두 새 동아리장 기준으로 바뀌고,
    응답의 `leader`는 호출한 사용자(더 이상 동아리장이 아님) 기준으로 `false`다.
- `GET /clubs/{clubId}/members` — 동아리 멤버 목록(`userId`/`name`/`leader`). 관리자
  권한 넘기기 화면에서 넘겨줄 대상을 고르는 데 쓴다. 가입한 사용자만 조회할 수
  있고, 가입하지 않았으면 `404 CLUB_MEMBERSHIP_NOT_FOUND`.

### 로컬 개발용 더미 데이터

로컬(H2) 프로필로 실행하면 `data.sql`이 서버 기동 시마다 `clubs` 테이블에 동아리 8개를
자동으로 채워 넣는다(H2는 인메모리라 재시작마다 초기화된다). `users`/`club_members`는
실제 로그인이 있어야 채워질 수 있어서 자동 시딩 대상이 아니다. 로그인 후 "가입한
동아리"/"즐겨찾기" 화면까지 확인하려면 `data.sql` 맨 아래 주석 처리된 `club_members`
INSERT 스니펫을 본인의 `user_id`에 맞게 고쳐서 H2 콘솔(`/h2-console`)에서 직접
실행하면 된다.

### 동아리 상세/가입 신청 ('지원 하기')

가입하지 않은 동아리를 눌렀을 때 보여주는 소개 화면과 그 화면의 '지원 하기'
버튼이 쓰는 API다.

- `GET /clubs/{clubId}` — 동아리 상세 조회. 목록용 `Club`과 달리 `description`을
  포함하고, `joined`가 false일 때 `applicationStatus`(`null`/`PENDING`/`REJECTED`)로
  신청 진행 상태를 함께 내려준다. 존재하지 않는 `clubId`면 `404 CLUB_NOT_FOUND`.
- `POST /clubs/{clubId}/apply { "selfIntroduction": "..." }` — 가입 신청 제출.
  성공하면 신청이 `PENDING` 상태로 생성(또는 재신청)된다.
  - 이미 가입한 동아리면 `409 CLUB_ALREADY_JOINED`.
  - 이미 `PENDING` 신청서가 있으면 `409 CLUB_APPLICATION_ALREADY_PENDING`.
  - `REJECTED` 신청서가 있으면 새로 만들지 않고 그 신청서를 재사용해 새
    자기소개로 다시 `PENDING`으로 돌린다(재신청).

가입 신청은 `club_members`가 아니라 별도의 `club_applications` 테이블에
저장된다. `club_members`(가입 확정)에 행이 생기려면 동아리장이 신청을
승인해야 한다.

### 가입 신청 승인/거절 (관리자 전용)

동아리장만 호출할 수 있는 세 엔드포인트다. 동아리장이 아니면 셋 다
`403 NOT_CLUB_LEADER`를 반환한다.

- `GET /clubs/{clubId}/applications` — 아직 처리하지 않은 `PENDING` 신청서
  목록(`id`/`userId`/`applicantName`/`selfIntroduction`/`status`/`appliedAt`).
  `APPROVED`/`REJECTED`는 내려주지 않는다 — 승인된 건 이미 멤버 목록에서
  보이고, 거절된 건 더 조치할 게 없다.
- `POST /clubs/{clubId}/applications/{applicationId}/approve` — 승인.
  `club_members`에 행이 새로 생기고(`memberCount` +1), 신청서 상태가
  `APPROVED`로 바뀐다.
- `POST /clubs/{clubId}/applications/{applicationId}/reject` — 거절. 신청서
  상태만 `REJECTED`로 바뀌고 `club_members`에는 변화가 없다. 지원자는 이후
  `POST /clubs/{clubId}/apply`로 재신청할 수 있다(위 "동아리 상세/가입 신청"
  참고).
- 두 엔드포인트 모두 `applicationId`가 존재하지 않거나 그 동아리 소속이
  아니면 `404 CLUB_APPLICATION_NOT_FOUND`, 이미 `APPROVED`/`REJECTED`로
  처리된 신청서면 `409 CLUB_APPLICATION_NOT_PENDING`을 반환한다(중복
  승인으로 `memberCount`가 두 번 늘어나는 걸 막기 위해서다).

### 스터디 등록 (동아리 생성)

메인 페이지의 "스터디 등록" 플로팅 버튼 → 등록 화면의 "작성완료" 제출이
호출하는 API다.

- `POST /clubs` (multipart/form-data) — 필드: `name`(필수, 100자 이하),
  `description`(필수), `thumbnail`(선택, 이미지 파일). JSON이 아니라
  multipart인 이유는 사진 파일을 같이 받기 위해서다.
  - 성공하면 만든 사용자가 곧바로 그 스터디의 회장 겸 첫 멤버가 되어
    `joined: true`인 `ClubDetail`을 응답한다(`club_members` 행이 즉시 생성됨
    — 가입 신청/승인 절차 없음).
  - `name`이 비어있거나 100자를 넘으면 `400 INVALID_CLUB_NAME`.
  - 이미 존재하는 이름이면 `409 DUPLICATE_CLUB_NAME`.
  - 등록 화면에는 카테고리 선택 UI가 없어서, 새로 만들어지는 동아리의
    `category`는 서버가 `"스터디"` 고정값으로 채운다(`ClubService.DEFAULT_CATEGORY`).
    카테고리별 분류가 필요해지면 그때 선택 UI와 함께 재검토한다.
  - 업로드된 사진은 로컬 디스크(`app.upload.dir`, 기본값 `uploads/clubs/`)에
    저장되고, `/uploads/clubs/{파일명}` 경로로 정적 서빙된다(인증 불필요 —
    `Image.network`가 토큰을 붙이지 않으므로). 여러 인스턴스로 배포하게 되면
    이 로컬 디스크 방식은 S3 등으로 옮겨야 한다.


## 5. 스터디 출석 (Attendance)

스터디 홈 화면(`StudyHomePage`)의 출석현황/내 정보 탭이 쓰는 API다. 네
엔드포인트 모두 `Authorization: Bearer <accessToken>`이 필요하고, 가입하지
않은 스터디(clubId)에 대해 호출하면 `404 CLUB_MEMBERSHIP_NOT_FOUND`를
반환한다.

- `GET /clubs/{clubId}/attendance/overview` — 출석현황 탭. 이번 주(월~일)
  전체 인원의 출석 도장(`weeklyMarks`)과 오늘 상태(`todayMark`), 로그인한
  사용자 본인의 이번 학기 누적 휴가 사용/총 일수(`myVacationDaysUsed`/
  `myVacationDaysTotal`)를 함께 내려준다. `members` 배열은 로그인한 사용자
  본인(`isMe: true`)이 항상 첫 번째다.
- `POST /clubs/{clubId}/attendance/check-in { "code": "1234" }` — "출석
  하기" 버튼의 출석번호 입력 제출. 오늘 발급된 번호와 일치하면 오늘을
  `PRESENT`로 기록한다.
  - 오늘의 출석번호 자체가 아직 없으면 `404 ATTENDANCE_CODE_NOT_ISSUED`.
  - 번호가 일치하지 않으면 `409 INVALID_ATTENDANCE_CODE`.
- `POST /clubs/{clubId}/attendance/vacation` — "출석 하기" 버튼의 휴가 사용
  제출. 오늘을 `VACATION`으로 기록한다(결석으로 집계되지 않음). 이번 학기
  휴가를 이미 모두 썼으면 `409 VACATION_LIMIT_EXCEEDED`(프론트엔드가
  `overview`의 `myVacationDaysUsed`/`myVacationDaysTotal`로 먼저 걸러서
  확인 대신 안내만 보여주므로, 이 응답은 주로 동시 요청 같은 경쟁 상황에
  대한 서버 측 방어다).
- `GET /clubs/{clubId}/attendance/me?year=2026&month=8` — 내 정보 탭. 지정한
  달의 출석 달력(`dailyMarks`, 문자열 day-of-month 키 -> `AttendanceMark`)과
  그 달의 출석/결석 일수(`presentCount`/`absentCount`), 이번 학기 누적 휴가
  사용/총 일수, 스터디가 만들어진 날짜(`studyCreatedAt`, `YYYY-MM-DD`)를
  내려준다. 미래 달이나 스터디 생성일 이전 달을 조회하면 전부 빈 상태(0)로
  내려온다. `studyCreatedAt`은 스터디마다 고정된 값이라 프론트엔드가 월별
  달력 화면에서 더 이전 달로 넘어갈 수 없게 막는 하한선으로 쓴다.

### 출석 표시 상태 (AttendanceMark)

`PRESENT`(출석)/`VACATION`(휴가)만 `attendance_records` 테이블에 실제로
저장된다. `ABSENT`(결석)는 별도 컬럼이 아니라 "지나간 날짜인데 그 인원의
행이 없음"으로 계산하고, `UPCOMING`(예정)은 "오늘인데 아직 정하지 않음" 또는
"아직 오지 않은 미래의 날짜"일 때 채워진다. 하루에 한 사람당 최대 한 행만
존재하므로(unique(club_id, user_id, attendance_date)), 출석/휴가를 다시
선택하면 새 행을 만들지 않고 기존 행의 상태만 바꾼다.

### 스터디 생성일 이전 날짜는 출석 대상이 아님

스터디가 생성되기 전날까지는 애초에 출석을 기록할 수 없었던 날이라,
`ABSENT`(결석)로 집계하지 않는다. `AttendanceOverviewResponse.weeklyMarks`와
`MyStudyInfoResponse.dailyMarks` 둘 다, 스터디 생성일(`clubs.created_at`)
이전 날짜는 아직 오지 않은 미래의 날짜와 똑같이 `UPCOMING`으로 채운다(화면에
는 빈 회색 칸으로 보여서 결석과 구분된다 — 별도의 enum 값을 추가하지 않고
기존 `UPCOMING`을 재사용). `GET .../attendance/me`로 스터디 생성일이 속한
달보다 이전 달을 조회하면 `dailyMarks`가 빈 맵으로, 생성일이 속한 달을
조회하면 생성일 이전 날짜만 맵에서 빠진 채로 내려온다.

### 출석번호 발급은 이번 범위 밖

`clubs.leader_id`가 생겨서(위 "관리자(동아리장) 권한" 참고) 서버가 "누가 이
스터디의 동아리장인지"는 이제 정확히 판단할 수 있다. 다만 동아리장이 매일
출석번호를 새로 발급/조회하는 API(관리 페이지의 "출석번호 확인")는 그 판단
로직이 생긴 것과 별개로 아직 만들지 않았다 — 이번 변경 범위는 관리자 권한
인프라(생성 시 자동 지정 + 넘겨주기)와 가입 신청 승인/거절까지다. 로컬(H2)
개발 환경에서는 `data.sql`이 서버 기동 시마다 스터디 1번(알고리즘 스터디)의
오늘자 코드를 `'1234'`로 고정 시딩해서 개발/테스트를 가능하게 한다.
`leader_id` 기준 인가로 실제 발급/재발급 API와 관리 페이지를 붙이는 건
다음 이슈로 남겨둔다.

### 이번 학기 휴가 총 일수 (vacationDaysTotal)

`club_members` 테이블에 `vacation_days_total` 컬럼(기본값 3)으로 저장된다.
현재는 인원별로 다르게 부여하는 UI가 없어 전부 기본값 3을 쓰지만, 컬럼
자체는 이미 인원별로 다른 값을 가질 수 있게 돼 있다 — 나중에 동아리장이
개별적으로 휴가를 더 주는 기능(관리 페이지, 아직 미구현)이 생기면 이
컬럼을 UPDATE하면 되고 별도의 계약 변경이 필요 없다.
