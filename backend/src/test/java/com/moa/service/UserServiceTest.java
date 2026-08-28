package com.moa.service;

import com.moa.constant.Provider;
import com.moa.dto.request.CompleteProfileRequest;
import com.moa.dto.response.UserResponse;
import com.moa.entity.User;
import com.moa.filter.exception.DuplicateNicknameException;
import com.moa.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.lang.reflect.Field;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Test
    void completeProfileFillsNicknameAndMarksProfileCompleted() {
        UserService userService = new UserService(userRepository);
        User user = User.createOAuthUser("user@example.com", "Test User", Provider.GOOGLE, "uid-1");
        CompleteProfileRequest request = new CompleteProfileRequest("홍길동", "gildong", "컴퓨터공학과", "20240001");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.findByNickname("gildong")).thenReturn(Optional.empty());
        when(userRepository.save(user)).thenReturn(user);

        UserResponse response = userService.completeProfile(1L, request);

        assertThat(response.nickname()).isEqualTo("gildong");
        assertThat(response.profileCompleted()).isTrue();
        assertThat(user.isProfileCompleted()).isTrue();
    }

    @Test
    void completeProfileThrowsWhenNicknameTakenByAnotherUser() throws Exception {
        UserService userService = new UserService(userRepository);
        User user = User.createOAuthUser("user@example.com", "Test User", Provider.GOOGLE, "uid-1");
        setId(user, 1L);
        User otherUser = User.createOAuthUser("other@example.com", "Other User", Provider.APPLE, "uid-2");
        setId(otherUser, 2L);
        CompleteProfileRequest request = new CompleteProfileRequest("홍길동", "taken", "컴퓨터공학과", "20240001");

        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(userRepository.findByNickname("taken")).thenReturn(Optional.of(otherUser));

        assertThatThrownBy(() -> userService.completeProfile(1L, request))
                .isInstanceOf(DuplicateNicknameException.class);
    }

    // User.id는 @GeneratedValue라 setter가 없다. 실제로는 DB에 저장되면서 채워지지만,
    // 단위 테스트에서는 저장을 흉내낼 수 없으므로 리플렉션으로 직접 채운다.
    private static void setId(User user, Long id) throws Exception {
        Field field = User.class.getDeclaredField("id");
        field.setAccessible(true);
        field.set(user, id);
    }
}
