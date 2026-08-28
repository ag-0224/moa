package com.moa.service;

import com.moa.dto.response.UserResponse;
import com.moa.entity.User;
import com.moa.filter.exception.InvalidAuthTokenException;
import com.moa.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserResponse getMyInfo(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new InvalidAuthTokenException("사용자를 찾을 수 없습니다."));
        return UserResponse.from(user);
    }
}
