package com.simstruct.backend.repository;

import com.simstruct.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * User Repository - database operations for users
 */
@Repository
public interface UserRepository extends JpaRepository<User, String> {
    
    // Find user by email
    Optional<User> findByEmail(String email);
    
    // Check if email exists
    boolean existsByEmail(String email);
    
    // Search users by email or name
    List<User> findByEmailContainingIgnoreCaseOrNameContainingIgnoreCase(String email, String name);
}
