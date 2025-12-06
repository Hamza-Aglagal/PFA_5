package com.simstruct.backend.dto;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Update Profile Request DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {

    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @Size(max = 20, message = "Phone must be less than 20 characters")
    private String phone;

    @Size(max = 100, message = "Company must be less than 100 characters")
    private String company;

    @Size(max = 100, message = "Job title must be less than 100 characters")
    private String jobTitle;

    @Size(max = 500, message = "Bio must be less than 500 characters")
    private String bio;
}
