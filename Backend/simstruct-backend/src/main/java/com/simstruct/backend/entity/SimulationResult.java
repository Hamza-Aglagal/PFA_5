package com.simstruct.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Simulation Result - embedded class for analysis results
 */
@Embeddable
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SimulationResult {

    @Column(name = "max_deflection")
    private Double maxDeflection; // in meters

    @Column(name = "max_bending_moment")
    private Double maxBendingMoment; // in N·m

    @Column(name = "max_shear_force")
    private Double maxShearForce; // in N

    @Column(name = "max_stress")
    private Double maxStress; // in Pa

    @Column(name = "safety_factor")
    private Double safetyFactor;

    @Column(name = "is_safe")
    private Boolean isSafe;

    @Column(name = "recommendations", length = 2000)
    private String recommendations;

    // Additional results
    @Column(name = "natural_frequency")
    private Double naturalFrequency; // in Hz

    @Column(name = "critical_load")
    private Double criticalLoad; // in N (for buckling)

    @Column(name = "weight")
    private Double weight; // in kg
}
