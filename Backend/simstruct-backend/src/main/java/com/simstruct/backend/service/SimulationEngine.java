package com.simstruct.backend.service;

import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.SimulationResult;
import org.springframework.stereotype.Service;

/**
 * Simulation Engine - performs structural analysis calculations
 * Simple beam theory calculations for educational purposes
 */
@Service
public class SimulationEngine {

    /**
     * Run structural analysis on a simulation
     */
    public SimulationResult analyze(Simulation simulation) {
        System.out.println("SimulationEngine: Starting analysis for " + simulation.getName());

        // Get parameters
        double L = simulation.getBeamLength();  // Length in meters
        double b = simulation.getBeamWidth();   // Width in meters
        double h = simulation.getBeamHeight();  // Height in meters
        double E = simulation.getElasticModulus(); // Elastic modulus in Pa
        double P = simulation.getLoadMagnitude();  // Load in N
        double a = simulation.getLoadPosition() != null ? simulation.getLoadPosition() : L / 2; // Load position

        // Calculate section properties
        double I = calculateMomentOfInertia(b, h);  // Second moment of area
        double A = b * h;  // Cross-sectional area
        double yMax = h / 2;  // Distance to extreme fiber

        System.out.println("SimulationEngine: I = " + I + " m^4, A = " + A + " m^2");

        // Calculate results based on support type
        double maxDeflection;
        double maxBendingMoment;
        double maxShearForce;

        switch (simulation.getSupportType()) {
            case SIMPLY_SUPPORTED:
                maxDeflection = calculateSimplySupportedDeflection(P, L, E, I, a, simulation.getLoadType());
                maxBendingMoment = calculateSimplySupportedMoment(P, L, a, simulation.getLoadType());
                maxShearForce = calculateSimplySupportedShear(P, L, a, simulation.getLoadType());
                break;
            case FIXED_FREE: // Cantilever
                maxDeflection = calculateCantileverDeflection(P, L, E, I, simulation.getLoadType());
                maxBendingMoment = calculateCantileverMoment(P, L, simulation.getLoadType());
                maxShearForce = calculateCantileverShear(P, L, simulation.getLoadType());
                break;
            case FIXED_FIXED:
                maxDeflection = calculateFixedFixedDeflection(P, L, E, I, simulation.getLoadType());
                maxBendingMoment = calculateFixedFixedMoment(P, L, simulation.getLoadType());
                maxShearForce = P / 2; // For central load
                break;
            default:
                maxDeflection = calculateSimplySupportedDeflection(P, L, E, I, a, simulation.getLoadType());
                maxBendingMoment = calculateSimplySupportedMoment(P, L, a, simulation.getLoadType());
                maxShearForce = calculateSimplySupportedShear(P, L, a, simulation.getLoadType());
        }

        // Calculate stress
        double maxStress = (maxBendingMoment * yMax) / I;

        // Calculate safety factor
        double yieldStrength = simulation.getYieldStrength() != null ? 
                               simulation.getYieldStrength() : getDefaultYieldStrength(simulation.getMaterialType());
        double safetyFactor = yieldStrength / maxStress;
        boolean isSafe = safetyFactor >= 1.5;

        // Calculate weight
        double density = simulation.getDensity() != null ? 
                        simulation.getDensity() : getDefaultDensity(simulation.getMaterialType());
        double weight = A * L * density;

        // Calculate natural frequency (simplified for beam)
        double naturalFrequency = calculateNaturalFrequency(E, I, density, A, L);

        // Generate recommendations
        String recommendations = generateRecommendations(safetyFactor, maxDeflection, L, maxStress, yieldStrength);

        System.out.println("SimulationEngine: Analysis complete. Safety factor = " + safetyFactor);

        return SimulationResult.builder()
                .maxDeflection(maxDeflection)
                .maxBendingMoment(maxBendingMoment)
                .maxShearForce(maxShearForce)
                .maxStress(maxStress)
                .safetyFactor(safetyFactor)
                .isSafe(isSafe)
                .recommendations(recommendations)
                .naturalFrequency(naturalFrequency)
                .weight(weight)
                .build();
    }

    /**
     * Calculate moment of inertia for rectangular section
     */
    private double calculateMomentOfInertia(double b, double h) {
        return (b * Math.pow(h, 3)) / 12;
    }

    // ========== SIMPLY SUPPORTED BEAM ==========

    private double calculateSimplySupportedDeflection(double P, double L, double E, double I, double a, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform distributed load: δ = 5wL⁴/(384EI)
            double w = P / L; // Load per unit length
            return (5 * w * Math.pow(L, 4)) / (384 * E * I);
        } else {
            // Point load at center: δ = PL³/(48EI)
            // Point load at 'a' from left: δ = Pa²(L-a)²/(3EIL)
            if (Math.abs(a - L/2) < 0.01) {
                return (P * Math.pow(L, 3)) / (48 * E * I);
            } else {
                double b = L - a;
                return (P * Math.pow(a, 2) * Math.pow(b, 2)) / (3 * E * I * L);
            }
        }
    }

    private double calculateSimplySupportedMoment(double P, double L, double a, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform load: M_max = wL²/8
            double w = P / L;
            return (w * Math.pow(L, 2)) / 8;
        } else {
            // Point load: M_max = P*a*(L-a)/L
            double b = L - a;
            return (P * a * b) / L;
        }
    }

    private double calculateSimplySupportedShear(double P, double L, double a, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform load: V_max = wL/2
            double w = P / L;
            return (w * L) / 2;
        } else {
            // Point load: V_max = P(L-a)/L or Pa/L
            double b = L - a;
            return Math.max(P * b / L, P * a / L);
        }
    }

    // ========== CANTILEVER BEAM ==========

    private double calculateCantileverDeflection(double P, double L, double E, double I, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform load at free end: δ = wL⁴/(8EI)
            double w = P / L;
            return (w * Math.pow(L, 4)) / (8 * E * I);
        } else {
            // Point load at free end: δ = PL³/(3EI)
            return (P * Math.pow(L, 3)) / (3 * E * I);
        }
    }

    private double calculateCantileverMoment(double P, double L, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform load: M_max = wL²/2
            double w = P / L;
            return (w * Math.pow(L, 2)) / 2;
        } else {
            // Point load: M_max = P*L
            return P * L;
        }
    }

    private double calculateCantileverShear(double P, double L, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform load: V_max = wL
            double w = P / L;
            return w * L;
        } else {
            // Point load: V_max = P
            return P;
        }
    }

    // ========== FIXED-FIXED BEAM ==========

    private double calculateFixedFixedDeflection(double P, double L, double E, double I, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform load: δ = wL⁴/(384EI)
            double w = P / L;
            return (w * Math.pow(L, 4)) / (384 * E * I);
        } else {
            // Central point load: δ = PL³/(192EI)
            return (P * Math.pow(L, 3)) / (192 * E * I);
        }
    }

    private double calculateFixedFixedMoment(double P, double L, Simulation.LoadType loadType) {
        if (loadType == Simulation.LoadType.UNIFORM || loadType == Simulation.LoadType.DISTRIBUTED) {
            // Uniform load: M_max = wL²/12 (at supports) or wL²/24 (at center)
            double w = P / L;
            return (w * Math.pow(L, 2)) / 12;
        } else {
            // Central point load: M_max = PL/8
            return (P * L) / 8;
        }
    }

    // ========== UTILITY METHODS ==========

    private double calculateNaturalFrequency(double E, double I, double density, double A, double L) {
        // First mode natural frequency: f = (π²/2π) * √(EI/ρAL⁴)
        double omega = Math.pow(Math.PI, 2) * Math.sqrt((E * I) / (density * A * Math.pow(L, 4)));
        return omega / (2 * Math.PI); // Convert to Hz
    }

    private double getDefaultYieldStrength(Simulation.MaterialType material) {
        switch (material) {
            case STEEL: return 250e6;      // 250 MPa
            case CONCRETE: return 30e6;    // 30 MPa (compressive)
            case ALUMINUM: return 280e6;   // 280 MPa
            case WOOD: return 40e6;        // 40 MPa
            case COMPOSITE: return 200e6;  // 200 MPa
            default: return 250e6;
        }
    }

    private double getDefaultDensity(Simulation.MaterialType material) {
        switch (material) {
            case STEEL: return 7850;       // kg/m³
            case CONCRETE: return 2400;
            case ALUMINUM: return 2700;
            case WOOD: return 600;
            case COMPOSITE: return 1600;
            default: return 7850;
        }
    }

    private String generateRecommendations(double safetyFactor, double deflection, double length, 
                                          double stress, double yieldStrength) {
        StringBuilder sb = new StringBuilder();

        // Safety factor recommendations
        if (safetyFactor >= 3.0) {
            sb.append("✅ Excellent safety margin. Structure is over-designed. ");
            sb.append("Consider optimizing cross-section to reduce material cost. ");
        } else if (safetyFactor >= 2.0) {
            sb.append("✅ Good safety factor. Structure meets typical design requirements. ");
        } else if (safetyFactor >= 1.5) {
            sb.append("⚠️ Adequate but minimal safety margin. ");
            sb.append("Consider increasing section size for additional safety. ");
        } else if (safetyFactor >= 1.0) {
            sb.append("⚠️ WARNING: Safety factor below recommended minimum of 1.5. ");
            sb.append("Increase section dimensions or use stronger material. ");
        } else {
            sb.append("❌ CRITICAL: Structure will likely fail under load! ");
            sb.append("Immediate redesign required. Increase section size significantly. ");
        }

        // Deflection check (typical limit: L/250 for beams)
        double deflectionLimit = length / 250;
        if (deflection > deflectionLimit) {
            sb.append("⚠️ Deflection exceeds L/250 limit. Consider increasing stiffness. ");
        } else if (deflection > length / 500) {
            sb.append("Deflection is acceptable but could be reduced for better serviceability. ");
        }

        // Stress utilization
        double utilization = (stress / yieldStrength) * 100;
        sb.append(String.format("Stress utilization: %.1f%%. ", utilization));

        return sb.toString().trim();
    }
}
