package com.moa.config.jwt;

import com.moa.constant.Role;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class TokenProviderTest {

    private static final String TEST_SECRET = "test-secret-key-must-be-at-least-32-bytes-long!";

    private final TokenProvider tokenProvider = new TokenProvider(new JwtProperties(TEST_SECRET, 60_000L));

    @Test
    void createsAndValidatesToken() {
        String token = tokenProvider.createToken(1L, Role.USER);

        assertThat(tokenProvider.validate(token)).isTrue();
        assertThat(tokenProvider.getUserId(token)).isEqualTo(1L);
        assertThat(tokenProvider.getRole(token)).isEqualTo(Role.USER);
    }

    @Test
    void rejectsTamperedToken() {
        String token = tokenProvider.createToken(1L, Role.USER);
        String tampered = token + "invalid_signature";

        assertThat(tokenProvider.validate(tampered)).isFalse();
    }

    @Test
    void throwsWhenSecretMissing() {
        TokenProvider unconfigured = new TokenProvider(new JwtProperties("", 60_000L));

        assertThatThrownBy(() -> unconfigured.createToken(1L, Role.USER))
                .isInstanceOf(IllegalStateException.class);
    }
}
