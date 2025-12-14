package com.simstruct.backend.service;

import com.simstruct.backend.dto.*;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.UserRepository;
import com.simstruct.backend.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Auth Service - handles authentication business logic
 */
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final NotificationService notificationService;

    /**
     * Register a new user
     */
    public AuthResponse register(RegisterRequest request) {
        System.out.println("AuthService: Registering new user - " + request.getEmail());

        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            System.out.println("AuthService: Email already exists - " + request.getEmail());
            throw new RuntimeException("Email already registered");
        }

        // Create new user
        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(User.Role.USER)
                .build();

        // Save user
        user = userRepository.save(user);
        System.out.println("AuthService: User created with ID - " + user.getId());

        // Send welcome notification
        try {
            notificationService.sendWelcomeNotification(user.getId(), user.getName());
        } catch (Exception e) {
            System.out.println("AuthService: Failed to send welcome notification - " + e.getMessage());
        }

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        // Return response
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtTokenProvider.getExpirationTime())
                .user(UserResponse.fromUser(user))
                .build();
    }

    /**
     * Login user
     */
    public AuthResponse login(LoginRequest request) {
        System.out.println("AuthService: Login attempt for - " + request.getEmail());

        // Find user by email
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> {
                    System.out.println("AuthService: User not found - " + request.getEmail());
                    return new RuntimeException("Invalid email or password");
                });

        // Check password
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            System.out.println("AuthService: Invalid password for - " + request.getEmail());
            throw new RuntimeException("Invalid email or password");
        }

        System.out.println("AuthService: Login successful for - " + user.getEmail());

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        // Return response
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtTokenProvider.getExpirationTime())
                .user(UserResponse.fromUser(user))
                .build();
    }

    /**
     * Refresh access token
     */
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        System.out.println("AuthService: Refreshing token");

        // Validate refresh token
        if (!jwtTokenProvider.validateToken(request.getRefreshToken())) {
            System.out.println("AuthService: Invalid refresh token");
            throw new RuntimeException("Invalid refresh token");
        }

        // Get user ID from token
        String userId = jwtTokenProvider.getUserIdFromToken(request.getRefreshToken());

        // Find user
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        System.out.println("AuthService: Token refreshed for - " + user.getEmail());

        // Generate new tokens
        String accessToken = jwtTokenProvider.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        // Return response
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtTokenProvider.getExpirationTime())
                .user(UserResponse.fromUser(user))
                .build();
    }
}
