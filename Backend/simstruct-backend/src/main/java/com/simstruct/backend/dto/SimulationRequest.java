package com.simstruct.backend.dto;

import com.simstruct.backend.entity.Simulation;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Simulation Request DTO - for creating/updating simulations
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SimulationRequest {

    @NotBlank(message = "Name is required")
    @Size(min = 1, max = 100, message = "Name must be between 1 and 100 characters")
    private String name;

    @Size(max = 1000, message = "Description cannot exceed 1000 characters")
    private String description;

    // Structure parameters
    @NotNull(message = "Beam length is required")
    @Positive(message = "Beam length must be positive")
    private Double beamLength;

    @NotNull(message = "Beam width is required")
    @Positive(message = "Beam width must be positive")
    private Double beamWidth;

    @NotNull(message = "Beam height is required")
    @Positive(message = "Beam height must be positive")
    private Double beamHeight;

    // Material
    @NotNull(message = "Material type is required")
    private Simulation.MaterialType materialType;

    @NotNull(message = "Elastic modulus is required")
    @Positive(message = "Elastic modulus must be positive")
    private Double elasticModulus;

    private Double density;
    private Double yieldStrength;

    // Load
    @NotNull(message = "Load type is required")
    private Simulation.LoadType loadType;

    @NotNull(message = "Load magnitude is required")
    @Positive(message = "Load magnitude must be positive")
    private Double loadMagnitude;

    @PositiveOrZero(message = "Load position must be non-negative")
    private Double loadPosition;

    // Support
    @NotNull(message = "Support type is required")
    private Simulation.SupportType supportType;

    // Visibility
    @Builder.Default
    private Boolean isPublic = false;
}
