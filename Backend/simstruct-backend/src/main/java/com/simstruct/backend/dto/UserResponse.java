package com.simstruct.backend.dto;

import com.simstruct.backend.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * User Response DTO - user data returned to frontend
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

    private String id;
    private String email;
    private String name;
    private String role;
    private String avatarUrl;
    private String phone;
    private String company;
    private String jobTitle;
    private String bio;
    private Boolean emailVerified;
    private LocalDateTime createdAt;

    // Convert User entity to UserResponse
    public static UserResponse fromUser(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .role(user.getRole().name())
                .avatarUrl(user.getAvatarUrl())
                .phone(user.getPhone())
                .company(user.getCompany())
                .jobTitle(user.getJobTitle())
                .bio(user.getBio())
                .emailVerified(user.getEmailVerified())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
