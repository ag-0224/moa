package com.moa.filter.exception;

/**
 * 서버에 FIREBASE_CREDENTIALS_PATH가 설정되지 않아 Firebase Admin SDK가
 * 초기화되지 않았을 때 로그인 시도 시 발생한다.
 */
public class FirebaseNotConfiguredException extends RuntimeException {

    public FirebaseNotConfiguredException() {
        super("Firebase 자격 증명이 설정되지 않았습니다. FIREBASE_CREDENTIALS_PATH 환경변수를 확인하세요.");
    }
}
