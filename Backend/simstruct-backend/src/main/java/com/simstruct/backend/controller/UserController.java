package com.simstruct.backend.controller;

import com.simstruct.backend.dto.*;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * User Controller - handles user profile endpoints
 */
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    /**
     * GET /api/v1/users/me - Get current user profile
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(@AuthenticationPrincipal User user) {
        System.out.println("UserController: Get current user request - " + user.getEmail());
        
        UserResponse response = userService.getUserById(user.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * PUT /api/v1/users/me - Update current user profile
     */
    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdateProfileRequest request) {
        
        System.out.println("UserController: Update profile request - " + user.getEmail());
        
        UserResponse response = userService.updateProfile(user.getId(), request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * PUT /api/v1/users/me/password - Change password
     */
    @PutMapping("/me/password")
    public ResponseEntity<ApiResponse<String>> changePassword(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody ChangePasswordRequest request) {
        
        System.out.println("UserController: Change password request - " + user.getEmail());
        
        try {
            userService.changePassword(user.getId(), request);
            return ResponseEntity.ok(ApiResponse.success("Password changed successfully"));
        } catch (RuntimeException e) {
            System.out.println("UserController: Change password failed - " + e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("PASSWORD_CHANGE_FAILED", e.getMessage()));
        }
    }

    /**
     * DELETE /api/v1/users/me - Delete current user account
     */
    @DeleteMapping("/me")
    public ResponseEntity<ApiResponse<String>> deleteAccount(@AuthenticationPrincipal User user) {
        System.out.println("UserController: Delete account request - " + user.getEmail());
        
        userService.deleteAccount(user.getId());
        return ResponseEntity.ok(ApiResponse.success("Account deleted successfully"));
    }
}
