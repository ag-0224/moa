package com.moa.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.IOException;

/**
 * Firebase Admin SDK 초기화.
 *
 * FIREBASE_CREDENTIALS_PATH 환경변수가 설정되지 않은 환경(로컬 최초 셋업, CI 등)에서도
 * 애플리케이션 기동이 실패하지 않도록, 이 값이 없으면 FirebaseApp/FirebaseAuth 빈을
 * 아예 등록하지 않는다. 이 경우 AuthService가 FirebaseNotConfiguredException(503)으로
 * 응답한다 (login 시도 시에만 실패하고, 그 외 API는 정상 동작).
 */
@Configuration
public class FirebaseConfig {

    @Bean
    @ConditionalOnProperty(name = "FIREBASE_CREDENTIALS_PATH")
    public FirebaseApp firebaseApp() throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        String credentialsPath = System.getenv("FIREBASE_CREDENTIALS_PATH");
        try (FileInputStream serviceAccount = new FileInputStream(credentialsPath)) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();
            return FirebaseApp.initializeApp(options);
        }
    }

    @Bean
    @ConditionalOnBean(FirebaseApp.class)
    public FirebaseAuth firebaseAuth(FirebaseApp firebaseApp) {
        return FirebaseAuth.getInstance(firebaseApp);
    }
}
