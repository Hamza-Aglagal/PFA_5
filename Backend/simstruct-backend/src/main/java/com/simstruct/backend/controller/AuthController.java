package com.simstruct.backend.controller;

import com.simstruct.backend.dto.*;
import com.simstruct.backend.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Auth Controller - handles authentication endpoints
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * POST /api/v1/auth/register - Register new user
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        System.out.println("AuthController: Register request received for - " + request.getEmail());
        
        try {
            AuthResponse response = authService.register(request);
            System.out.println("AuthController: Registration successful");
            return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
        } catch (RuntimeException e) {
            System.out.println("AuthController: Registration failed - " + e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(ApiResponse.error("REGISTRATION_FAILED", e.getMessage()));
        }
    }

    /**
     * POST /api/v1/auth/login - Login user
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        System.out.println("AuthController: Login request received for - " + request.getEmail());
        
        try {
            AuthResponse response = authService.login(request);
            System.out.println("AuthController: Login successful");
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (RuntimeException e) {
            System.out.println("AuthController: Login failed - " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("LOGIN_FAILED", e.getMessage()));
        }
    }

    /**
     * POST /api/v1/auth/refresh - Refresh access token
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        System.out.println("AuthController: Refresh token request received");
        
        try {
            AuthResponse response = authService.refreshToken(request);
            System.out.println("AuthController: Token refresh successful");
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (RuntimeException e) {
            System.out.println("AuthController: Token refresh failed - " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("REFRESH_FAILED", e.getMessage()));
        }
    }

    /**
     * POST /api/v1/auth/logout - Logout user (client-side token removal)
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<String>> logout() {
        System.out.println("AuthController: Logout request received");
        // JWT tokens are stateless, logout is handled client-side
        return ResponseEntity.ok(ApiResponse.success("Logged out successfully"));
    }
}
