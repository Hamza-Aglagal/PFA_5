package com.simstruct.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Simulation Entity - stores simulation data and results
 */
@Entity
@Table(name = "simulations")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Simulation {

    @Id
    private String id;

    @Column(nullable = false)
    private String name;

    @Column(length = 1000)
    private String description;

    // Owner of the simulation
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // Structure parameters
    @Column(nullable = false)
    private Double beamLength;

    @Column(nullable = false)
    private Double beamWidth;

    @Column(nullable = false)
    private Double beamHeight;

    // Material properties
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MaterialType materialType;

    @Column(nullable = false)
    private Double elasticModulus; // in Pa

    @Column
    private Double density; // in kg/m³

    @Column
    private Double yieldStrength; // in Pa

    // Load configuration
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LoadType loadType;

    @Column(nullable = false)
    private Double loadMagnitude; // in N or N/m

    @Column
    private Double loadPosition; // in meters from left

    // Support configuration
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SupportType supportType;

    // Status and visibility
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private SimulationStatus status = SimulationStatus.PENDING;

    @Builder.Default
    private Boolean isPublic = false;

    @Builder.Default
    private Boolean isFavorite = false;

    @Builder.Default
    private Integer likesCount = 0;

    // Embedded results
    @Embedded
    private SimulationResult results;

    // Timestamps
    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        if (this.id == null) {
            this.id = UUID.randomUUID().toString();
        }
    }

    // Enums
    public enum MaterialType {
        STEEL, CONCRETE, WOOD, ALUMINUM, COMPOSITE
    }

    public enum LoadType {
        POINT, DISTRIBUTED, UNIFORM, MOMENT, TRIANGULAR, TRAPEZOIDAL
    }

    public enum SupportType {
        SIMPLY_SUPPORTED, FIXED_FIXED, FIXED_FREE, FIXED_PINNED, CONTINUOUS, PINNED
    }

    public enum SimulationStatus {
        PENDING, RUNNING, COMPLETED, FAILED
    }
}
