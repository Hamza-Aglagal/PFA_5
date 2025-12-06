package com.simstruct.backend.dto;

import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.SimulationResult;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Simulation Response DTO - for API responses
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SimulationResponse {

    private String id;
    private String name;
    private String description;

    // Owner info
    private String userId;
    private String userName;

    // Structure parameters
    private Double beamLength;
    private Double beamWidth;
    private Double beamHeight;

    // Material
    private Simulation.MaterialType materialType;
    private Double elasticModulus;
    private Double density;
    private Double yieldStrength;

    // Load
    private Simulation.LoadType loadType;
    private Double loadMagnitude;
    private Double loadPosition;

    // Support
    private Simulation.SupportType supportType;

    // Status and visibility
    private Simulation.SimulationStatus status;
    private Boolean isPublic;
    private Boolean isFavorite;
    private Integer likesCount;

    // Results (nested)
    private ResultsDto results;

    // Timestamps
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * Nested Results DTO
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ResultsDto {
        private Double maxDeflection;
        private Double maxBendingMoment;
        private Double maxShearForce;
        private Double maxStress;
        private Double safetyFactor;
        private Boolean isSafe;
        private String recommendations;
        private Double naturalFrequency;
        private Double criticalLoad;
        private Double weight;
    }

    /**
     * Convert from entity to response
     */
    public static SimulationResponse fromEntity(Simulation simulation) {
        SimulationResponseBuilder builder = SimulationResponse.builder()
                .id(simulation.getId())
                .name(simulation.getName())
                .description(simulation.getDescription())
                .userId(simulation.getUser().getId())
                .userName(simulation.getUser().getName())
                .beamLength(simulation.getBeamLength())
                .beamWidth(simulation.getBeamWidth())
                .beamHeight(simulation.getBeamHeight())
                .materialType(simulation.getMaterialType())
                .elasticModulus(simulation.getElasticModulus())
                .density(simulation.getDensity())
                .yieldStrength(simulation.getYieldStrength())
                .loadType(simulation.getLoadType())
                .loadMagnitude(simulation.getLoadMagnitude())
                .loadPosition(simulation.getLoadPosition())
                .supportType(simulation.getSupportType())
                .status(simulation.getStatus())
                .isPublic(simulation.getIsPublic())
                .isFavorite(simulation.getIsFavorite())
                .likesCount(simulation.getLikesCount())
                .createdAt(simulation.getCreatedAt())
                .updatedAt(simulation.getUpdatedAt());

        // Map results if present
        if (simulation.getResults() != null) {
            SimulationResult r = simulation.getResults();
            builder.results(ResultsDto.builder()
                    .maxDeflection(r.getMaxDeflection())
                    .maxBendingMoment(r.getMaxBendingMoment())
                    .maxShearForce(r.getMaxShearForce())
                    .maxStress(r.getMaxStress())
                    .safetyFactor(r.getSafetyFactor())
                    .isSafe(r.getIsSafe())
                    .recommendations(r.getRecommendations())
                    .naturalFrequency(r.getNaturalFrequency())
                    .criticalLoad(r.getCriticalLoad())
                    .weight(r.getWeight())
                    .build());
        }

        return builder.build();
    }
}
