package com.moa.repository;

import com.moa.constant.Provider;
import com.moa.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    Optional<User> findByProviderAndProviderUid(Provider provider, String providerUid);
}
