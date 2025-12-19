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

    // ========== AI BUILDING PARAMETERS (REQUIRED) ==========
    // All AI parameters must be provided by frontend for AI model prediction
    
    @NotNull(message = "Number of floors is required")
    @Min(value = 1, message = "Number of floors must be at least 1")
    @Max(value = 50, message = "Number of floors cannot exceed 50")
    private Double numFloors;
    
    @NotNull(message = "Floor height is required")
    @DecimalMin(value = "2.5", message = "Floor height must be at least 2.5m")
    @DecimalMax(value = "6.0", message = "Floor height cannot exceed 6.0m")
    private Double floorHeight;
    
    @NotNull(message = "Number of beams is required")
    @Min(value = 10, message = "Number of beams must be at least 10")
    @Max(value = 500, message = "Number of beams cannot exceed 500")
    private Integer numBeams;
    
    @NotNull(message = "Number of columns is required")
    @Min(value = 4, message = "Number of columns must be at least 4")
    @Max(value = 200, message = "Number of columns cannot exceed 200")
    private Integer numColumns;
    
    @NotNull(message = "Beam section is required")
    @DecimalMin(value = "20.0", message = "Beam section must be at least 20cm")
    @DecimalMax(value = "100.0", message = "Beam section cannot exceed 100cm")
    private Double beamSection;
    
    @NotNull(message = "Column section is required")
    @DecimalMin(value = "30.0", message = "Column section must be at least 30cm")
    @DecimalMax(value = "150.0", message = "Column section cannot exceed 150cm")
    private Double columnSection;
    
    @NotNull(message = "Concrete strength is required")
    @DecimalMin(value = "20.0", message = "Concrete strength must be at least 20 MPa")
    @DecimalMax(value = "90.0", message = "Concrete strength cannot exceed 90 MPa")
    private Double concreteStrength;
    
    @NotNull(message = "Steel grade is required")
    @DecimalMin(value = "235.0", message = "Steel grade must be at least 235 MPa")
    @DecimalMax(value = "460.0", message = "Steel grade cannot exceed 460 MPa")
    private Double steelGrade;
    
    @NotNull(message = "Wind load is required")
    @DecimalMin(value = "0.5", message = "Wind load must be at least 0.5 kN/m²")
    @DecimalMax(value = "3.0", message = "Wind load cannot exceed 3.0 kN/m²")
    private Double windLoad;
    
    @NotNull(message = "Live load is required")
    @DecimalMin(value = "1.5", message = "Live load must be at least 1.5 kN/m²")
    @DecimalMax(value = "5.0", message = "Live load cannot exceed 5.0 kN/m²")
    private Double liveLoad;
    
    @NotNull(message = "Dead load is required")
    @DecimalMin(value = "3.0", message = "Dead load must be at least 3.0 kN/m²")
    @DecimalMax(value = "8.0", message = "Dead load cannot exceed 8.0 kN/m²")
    private Double deadLoad;
    
    /**
     * Convert to BuildingPredictionRequest for AI API
     */
    public BuildingPredictionRequest toAIRequest() {
        return BuildingPredictionRequest.builder()
                .numFloors(this.numFloors)
                .floorHeight(this.floorHeight)
                .numBeams(this.numBeams)
                .numColumns(this.numColumns)
                .beamSection(this.beamSection)
                .columnSection(this.columnSection)
                .concreteStrength(this.concreteStrength)
                .steelGrade(this.steelGrade)
                .windLoad(this.windLoad)
                .liveLoad(this.liveLoad)
                .deadLoad(this.deadLoad)
                .build();
    }
}
