package com.moa.constant;

import java.util.Arrays;

/**
 * users.provider 컬럼과 매핑되는 로그인 제공자.
 * Firebase Authentication의 firebase.sign_in_provider 클레임 값과 연결된다.
 */
public enum Provider {
    GOOGLE("google.com"),
    APPLE("apple.com");

    private final String firebaseSignInProvider;

    Provider(String firebaseSignInProvider) {
        this.firebaseSignInProvider = firebaseSignInProvider;
    }

    public static Provider fromFirebaseSignInProvider(String value) {
        return Arrays.stream(values())
                .filter(provider -> provider.firebaseSignInProvider.equals(value))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("지원하지 않는 로그인 제공자입니다: " + value));
    }
}
