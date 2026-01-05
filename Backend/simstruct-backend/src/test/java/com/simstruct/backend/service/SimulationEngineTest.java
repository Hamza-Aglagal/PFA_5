package com.simstruct.backend.service;

import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.SimulationResult;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for SimulationEngine
 * Simple tests to verify structural analysis calculations
 */
@ExtendWith(MockitoExtension.class)
public class SimulationEngineTest {

    @InjectMocks
    private SimulationEngine simulationEngine;

    private Simulation simulation;

    @BeforeEach
    void setUp() {
        // Create base simulation with typical values
        simulation = Simulation.builder()
                .id("sim123")
                .name("Test Simulation")
                .beamLength(5.0)       // 5 meters
                .beamWidth(0.3)        // 30 cm
                .beamHeight(0.5)       // 50 cm
                .elasticModulus(200e9) // Steel: 200 GPa
                .loadMagnitude(10000.0) // 10 kN
                .loadPosition(2.5)     // Center of beam
                .materialType(Simulation.MaterialType.STEEL)
                .loadType(Simulation.LoadType.POINT)
                .supportType(Simulation.SupportType.SIMPLY_SUPPORTED)
                .yieldStrength(250e6)  // 250 MPa
                .density(7850.0)       // Steel density
                .build();
    }

    /**
     * TEST 1: Analyze simply supported beam with point load
     */
    @Test
    void testAnalyze_SimplySupportedPointLoad() {
        // Arrange
        simulation.setSupportType(Simulation.SupportType.SIMPLY_SUPPORTED);
        simulation.setLoadType(Simulation.LoadType.POINT);

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0, "Deflection should be positive");
        assertTrue(result.getMaxBendingMoment() > 0, "Bending moment should be positive");
        assertTrue(result.getMaxShearForce() > 0, "Shear force should be positive");
        assertTrue(result.getMaxStress() > 0, "Stress should be positive");
        assertTrue(result.getSafetyFactor() > 0, "Safety factor should be positive");
        assertNotNull(result.getIsSafe());
        assertNotNull(result.getRecommendations());
    }

    /**
     * TEST 2: Analyze simply supported beam with uniform load
     */
    @Test
    void testAnalyze_SimplySupportedUniformLoad() {
        // Arrange
        simulation.setSupportType(Simulation.SupportType.SIMPLY_SUPPORTED);
        simulation.setLoadType(Simulation.LoadType.UNIFORM);

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
        assertTrue(result.getMaxBendingMoment() > 0);
        assertTrue(result.getSafetyFactor() > 0);
    }

    /**
     * TEST 3: Analyze cantilever beam with point load
     */
    @Test
    void testAnalyze_CantileverPointLoad() {
        // Arrange
        simulation.setSupportType(Simulation.SupportType.FIXED_FREE);
        simulation.setLoadType(Simulation.LoadType.POINT);

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
        assertTrue(result.getMaxBendingMoment() > 0);
        assertTrue(result.getMaxShearForce() > 0);
    }

    /**
     * TEST 4: Analyze cantilever beam with uniform load
     */
    @Test
    void testAnalyze_CantileverUniformLoad() {
        // Arrange
        simulation.setSupportType(Simulation.SupportType.FIXED_FREE);
        simulation.setLoadType(Simulation.LoadType.UNIFORM);

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
        assertTrue(result.getSafetyFactor() > 0);
    }

    /**
     * TEST 5: Analyze fixed-fixed beam with point load
     */
    @Test
    void testAnalyze_FixedFixedPointLoad() {
        // Arrange
        simulation.setSupportType(Simulation.SupportType.FIXED_FIXED);
        simulation.setLoadType(Simulation.LoadType.POINT);

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
        assertTrue(result.getMaxBendingMoment() > 0);
    }

    /**
     * TEST 6: Analyze fixed-fixed beam with distributed load
     */
    @Test
    void testAnalyze_FixedFixedDistributedLoad() {
        // Arrange
        simulation.setSupportType(Simulation.SupportType.FIXED_FIXED);
        simulation.setLoadType(Simulation.LoadType.DISTRIBUTED);

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
    }

    /**
     * TEST 7: Verify safety factor calculation
     */
    @Test
    void testSafetyFactorCalculation() {
        // Arrange - Use low load for high safety factor
        simulation.setLoadMagnitude(1000.0); // 1 kN - small load

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertTrue(result.getSafetyFactor() > 1.5, "Safety factor should be > 1.5 for safe design");
        assertTrue(result.getIsSafe(), "Design should be marked as safe");
    }

    /**
     * TEST 8: Verify unsafe design detection
     */
    @Test
    void testUnsafeDesignDetection() {
        // Arrange - Use very high load for low safety factor
        simulation.setLoadMagnitude(1000000.0); // 1000 kN - very high load
        simulation.setBeamWidth(0.05);          // Small beam
        simulation.setBeamHeight(0.05);

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertTrue(result.getSafetyFactor() < 1.5, "Safety factor should be < 1.5 for unsafe design");
        assertFalse(result.getIsSafe(), "Design should be marked as unsafe");
    }

    /**
     * TEST 9: Verify weight calculation
     */
    @Test
    void testWeightCalculation() {
        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertTrue(result.getWeight() > 0, "Weight should be positive");
        
        // Expected weight = A * L * density = 0.3 * 0.5 * 5.0 * 7850 = 5887.5 kg
        double expectedWeight = 0.3 * 0.5 * 5.0 * 7850;
        assertEquals(expectedWeight, result.getWeight(), 1.0); // Allow small tolerance
    }

    /**
     * TEST 10: Verify natural frequency calculation
     */
    @Test
    void testNaturalFrequencyCalculation() {
        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertTrue(result.getNaturalFrequency() > 0, "Natural frequency should be positive");
    }

    /**
     * TEST 11: Verify recommendations are generated
     */
    @Test
    void testRecommendationsGenerated() {
        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result.getRecommendations());
        assertFalse(result.getRecommendations().isEmpty(), "Recommendations should not be empty");
    }

    /**
     * TEST 12: Test with concrete material
     */
    @Test
    void testAnalyze_ConcreteMaterial() {
        // Arrange
        simulation.setMaterialType(Simulation.MaterialType.CONCRETE);
        simulation.setElasticModulus(30e9);  // Concrete: ~30 GPa
        simulation.setYieldStrength(30e6);   // Concrete: ~30 MPa compressive
        simulation.setDensity(2400.0);       // Concrete density

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
    }

    /**
     * TEST 13: Test with aluminum material
     */
    @Test
    void testAnalyze_AluminumMaterial() {
        // Arrange
        simulation.setMaterialType(Simulation.MaterialType.ALUMINUM);
        simulation.setElasticModulus(70e9);   // Aluminum: ~70 GPa
        simulation.setYieldStrength(270e6);   // Aluminum 6061: ~270 MPa
        simulation.setDensity(2700.0);        // Aluminum density

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
    }

    /**
     * TEST 14: Test eccentric load position
     */
    @Test
    void testAnalyze_EccentricLoad() {
        // Arrange
        simulation.setLoadPosition(1.0); // Load at 1m from left (not center)

        // Act
        SimulationResult result = simulationEngine.analyze(simulation);

        // Assert
        assertNotNull(result);
        assertTrue(result.getMaxDeflection() > 0);
    }
}
