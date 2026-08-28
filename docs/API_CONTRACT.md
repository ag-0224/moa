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
