package com.simstruct.backend.service;

import com.simstruct.backend.dto.ChangePasswordRequest;
import com.simstruct.backend.dto.UpdateProfileRequest;
import com.simstruct.backend.dto.UserResponse;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * User Service - handles user profile business logic
 */
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * Get user by ID
     */
    public UserResponse getUserById(String userId) {
        System.out.println("UserService: Getting user by ID - " + userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return UserResponse.fromUser(user);
    }

    /**
     * Update user profile
     */
    public UserResponse updateProfile(String userId, UpdateProfileRequest request) {
        System.out.println("UserService: Updating profile for user - " + userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Update fields if provided
        if (request.getName() != null) {
            user.setName(request.getName());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }
        if (request.getCompany() != null) {
            user.setCompany(request.getCompany());
        }
        if (request.getJobTitle() != null) {
            user.setJobTitle(request.getJobTitle());
        }
        if (request.getBio() != null) {
            user.setBio(request.getBio());
        }

        // Save updated user
        user = userRepository.save(user);
        System.out.println("UserService: Profile updated successfully");
        
        return UserResponse.fromUser(user);
    }

    /**
     * Change user password
     */
    public void changePassword(String userId, ChangePasswordRequest request) {
        System.out.println("UserService: Changing password for user - " + userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            System.out.println("UserService: Current password is incorrect");
            throw new RuntimeException("Current password is incorrect");
        }

        // Update password
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
        
        System.out.println("UserService: Password changed successfully");
    }

    /**
     * Delete user account
     */
    public void deleteAccount(String userId) {
        System.out.println("UserService: Deleting account for user - " + userId);
        
        if (!userRepository.existsById(userId)) {
            throw new RuntimeException("User not found");
        }
        
        userRepository.deleteById(userId);
        System.out.println("UserService: Account deleted successfully");
    }
}
