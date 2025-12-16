package com.simstruct.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * AI Prediction Response DTO
 * Maps to Python AI API output
 * Contains structural predictions from the Deep Learning model
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AIPredictionResponse {

    /**
     * Maximum deflection in mm
     */
    private Double maxDeflection;

    /**
     * Maximum stress in MPa
     */
    private Double maxStress;

    /**
     * Stability index (0-100)
     * Higher is better
     */
    private Double stabilityIndex;

    /**
     * Seismic resistance score (0-100)
     * Higher is better
     */
    private Double seismicResistance;

    /**
     * Overall status: "Excellent", "Bon", "Acceptable", "Faible"
     */
    private String status;

    /**
     * Check if prediction indicates safe structure
     */
    public boolean isSafe() {
        if (stabilityIndex == null || seismicResistance == null) {
            return false;
        }
        return stabilityIndex >= 50 && seismicResistance >= 50;
    }

    /**
     * Get safety level as enum
     */
    public SafetyLevel getSafetyLevel() {
        if (stabilityIndex == null || seismicResistance == null) {
            return SafetyLevel.UNKNOWN;
        }
        double avg = (stabilityIndex + seismicResistance) / 2;
        if (avg >= 70) return SafetyLevel.EXCELLENT;
        if (avg >= 50) return SafetyLevel.GOOD;
        if (avg >= 30) return SafetyLevel.ACCEPTABLE;
        return SafetyLevel.POOR;
    }

    public enum SafetyLevel {
        EXCELLENT,
        GOOD,
        ACCEPTABLE,
        POOR,
        UNKNOWN
    }
}
