package com.simstruct.backend.service;

import com.simstruct.backend.dto.AIPredictionResponse;
import com.simstruct.backend.dto.SimulationRequest;
import com.simstruct.backend.dto.SimulationResponse;
import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.SimulationResult;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.SimulationRepository;
import com.simstruct.backend.repository.SharedSimulationRepository;
import com.simstruct.backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for simulation operations
 */
@Service
public class SimulationService {

    private final SimulationRepository simulationRepository;
    private final UserRepository userRepository;
    private final SharedSimulationRepository sharedSimulationRepository;
    private final SimulationEngine simulationEngine;
    private final NotificationService notificationService;
    private final AIModelService aiModelService;

    public SimulationService(SimulationRepository simulationRepository,
                            UserRepository userRepository,
                            SharedSimulationRepository sharedSimulationRepository,
                            SimulationEngine simulationEngine,
                            NotificationService notificationService,
                            AIModelService aiModelService) {
        this.simulationRepository = simulationRepository;
        this.userRepository = userRepository;
        this.sharedSimulationRepository = sharedSimulationRepository;
        this.simulationEngine = simulationEngine;
        this.notificationService = notificationService;
        this.aiModelService = aiModelService;
    }

    /**
     * Create and run a new simulation
     */
    @Transactional
    public SimulationResponse createSimulation(SimulationRequest request, String userEmail) {
        System.out.println("SimulationService: Creating simulation for user: " + userEmail);

        // Find user
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found: " + userEmail));

        // Build simulation entity
        Simulation simulation = Simulation.builder()
                .name(request.getName())
                .description(request.getDescription())
                .user(user)
                .beamLength(request.getBeamLength())
                .beamWidth(request.getBeamWidth())
                .beamHeight(request.getBeamHeight())
                .materialType(request.getMaterialType())
                .elasticModulus(request.getElasticModulus())
                .density(request.getDensity())
                .yieldStrength(request.getYieldStrength())
                .loadType(request.getLoadType())
                .loadMagnitude(request.getLoadMagnitude())
                .loadPosition(request.getLoadPosition())
                .supportType(request.getSupportType())
                .status(Simulation.SimulationStatus.RUNNING)
                .isPublic(request.getIsPublic() != null ? request.getIsPublic() : false)
                .isFavorite(false)
                .likesCount(0)
                .build();

        try {
            // Call AI model with parameters from frontend
            System.out.println("SimulationService: Calling AI model with frontend parameters...");
            
            // ALWAYS use AI model for predictions
            System.out.println("SimulationService: Calling AI model...");
            
            // Call AI model - no fallback, must work
            AIPredictionResponse aiPrediction = aiModelService.predict(request.toAIRequest());
            System.out.println("SimulationService: AI prediction successful");
            
            // Build results from AI only
            SimulationResult results = buildResultsFromAI(aiPrediction, simulation);
            simulation.setResults(results);
            simulation.setStatus(Simulation.SimulationStatus.COMPLETED);
            System.out.println("SimulationService: AI analysis completed successfully");
            
        } catch (Exception e) {
            System.out.println("SimulationService: Simulation failed - " + e.getMessage());
            simulation.setStatus(Simulation.SimulationStatus.FAILED);
            throw new RuntimeException("AI Model failed: " + e.getMessage(), e);
        }

        // Save and return
        Simulation saved = simulationRepository.save(simulation);
        System.out.println("SimulationService: Simulation saved with ID: " + saved.getId());

        // Send notification based on status
        try {
            if (saved.getStatus() == Simulation.SimulationStatus.COMPLETED) {
                notificationService.sendSimulationCompleteNotification(
                    user.getId(),
                    saved.getId(),
                    saved.getName()
                );
            } else if (saved.getStatus() == Simulation.SimulationStatus.FAILED) {
                notificationService.sendSimulationFailedNotification(
                    user.getId(),
                    saved.getId(),
                    saved.getName()
                );
            }
        } catch (Exception e) {
            System.out.println("SimulationService: Failed to send notification - " + e.getMessage());
        }

        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Get simulation by ID
     */
    public SimulationResponse getSimulation(String id, String userEmail) {
        System.out.println("SimulationService: Getting simulation " + id + " for user " + userEmail);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Simulation not found: " + id));

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found: " + userEmail));

        System.out.println("SimulationService: User ID=" + user.getId());
        System.out.println("SimulationService: Simulation owner email=" + simulation.getUser().getEmail());
        System.out.println("SimulationService: Checking access for simulation " + id);
        
        // Check access: allow if public, owner, or shared with user
        boolean isOwner = simulation.getUser().getEmail().equals(userEmail);
        System.out.println("SimulationService: isOwner=" + isOwner);
        
        boolean isPublic = simulation.getIsPublic();
        System.out.println("SimulationService: isPublic=" + isPublic);
        
        System.out.println("SimulationService: Checking if shared with user " + user.getId());
        var sharedOpt = sharedSimulationRepository.findBySimulationIdAndSharedWithId(id, user.getId());
        boolean isShared = sharedOpt.isPresent();
        System.out.println("SimulationService: isShared=" + isShared);
        if (sharedOpt.isPresent()) {
            System.out.println("SimulationService: Found share: " + sharedOpt.get().getId());
        } else {
            System.out.println("SimulationService: No share found for simulation=" + id + ", user=" + user.getId());
        }

        if (!isPublic && !isOwner && !isShared) {
            System.err.println("SimulationService: Access denied - not owner, not public, not shared");
            throw new RuntimeException("Access denied to simulation: " + id);
        }

        System.out.println("SimulationService: Access granted (isOwner=" + isOwner + 
                          ", isPublic=" + isPublic + ", isShared=" + isShared + ")");
        
        return SimulationResponse.fromEntity(simulation);
    }

    /**
     * Get all simulations for a user
     */
    public List<SimulationResponse> getUserSimulations(String userEmail) {
        System.out.println("SimulationService: Getting simulations for user: " + userEmail);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found: " + userEmail));

        List<Simulation> simulations = simulationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        System.out.println("SimulationService: Found " + simulations.size() + " simulations");

        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Get recent simulations for a user (last 5)
     */
    public List<SimulationResponse> getRecentSimulations(String userEmail) {
        System.out.println("SimulationService: Getting recent simulations for: " + userEmail);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found: " + userEmail));

        List<Simulation> simulations = simulationRepository.findTop5ByUserIdOrderByCreatedAtDesc(user.getId());
        
        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Get public simulations
     */
    public List<SimulationResponse> getPublicSimulations() {
        System.out.println("SimulationService: Getting public simulations");

        List<Simulation> simulations = simulationRepository.findByIsPublicTrueOrderByCreatedAtDesc();
        System.out.println("SimulationService: Found " + simulations.size() + " public simulations");

        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Search public simulations
     */
    public List<SimulationResponse> searchPublicSimulations(String query) {
        System.out.println("SimulationService: Searching public simulations for: " + query);

        List<Simulation> simulations = simulationRepository.searchPublic(query);
        
        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Search user's simulations
     */
    public List<SimulationResponse> searchUserSimulations(String query, String userEmail) {
        System.out.println("SimulationService: Searching user simulations for: " + query);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found: " + userEmail));

        List<Simulation> simulations = simulationRepository.searchByUser(query, user.getId());
        
        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Update simulation
     */
    @Transactional
    public SimulationResponse updateSimulation(String id, SimulationRequest request, String userEmail) {
        System.out.println("SimulationService: Updating simulation " + id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new RuntimeException("Not authorized to update this simulation");
        }

        // Update fields
        simulation.setName(request.getName());
        simulation.setDescription(request.getDescription());
        simulation.setBeamLength(request.getBeamLength());
        simulation.setBeamWidth(request.getBeamWidth());
        simulation.setBeamHeight(request.getBeamHeight());
        simulation.setMaterialType(request.getMaterialType());
        simulation.setElasticModulus(request.getElasticModulus());
        simulation.setDensity(request.getDensity());
        simulation.setYieldStrength(request.getYieldStrength());
        simulation.setLoadType(request.getLoadType());
        simulation.setLoadMagnitude(request.getLoadMagnitude());
        simulation.setLoadPosition(request.getLoadPosition());
        simulation.setSupportType(request.getSupportType());
        simulation.setIsPublic(request.getIsPublic() != null ? request.getIsPublic() : simulation.getIsPublic());

        // Re-run simulation
        try {
            SimulationResult results = simulationEngine.analyze(simulation);
            simulation.setResults(results);
            simulation.setStatus(Simulation.SimulationStatus.COMPLETED);
        } catch (Exception e) {
            simulation.setStatus(Simulation.SimulationStatus.FAILED);
        }

        Simulation saved = simulationRepository.save(simulation);
        System.out.println("SimulationService: Simulation updated");

        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Delete simulation
     */
    @Transactional
    public void deleteSimulation(String id, String userEmail) {
        System.out.println("SimulationService: Deleting simulation " + id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new RuntimeException("Not authorized to delete this simulation");
        }

        simulationRepository.delete(simulation);
        System.out.println("SimulationService: Simulation deleted");
    }

    /**
     * Toggle favorite status
     */
    @Transactional
    public SimulationResponse toggleFavorite(String id, String userEmail) {
        System.out.println("SimulationService: Toggling favorite for simulation " + id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new RuntimeException("Not authorized to modify this simulation");
        }

        simulation.setIsFavorite(!simulation.getIsFavorite());
        Simulation saved = simulationRepository.save(simulation);

        System.out.println("SimulationService: Favorite toggled to " + saved.getIsFavorite());
        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Toggle public status
     */
    @Transactional
    public SimulationResponse togglePublic(String id, String userEmail) {
        System.out.println("SimulationService: Toggling public for simulation " + id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new RuntimeException("Not authorized to modify this simulation");
        }

        simulation.setIsPublic(!simulation.getIsPublic());
        Simulation saved = simulationRepository.save(simulation);

        System.out.println("SimulationService: Public toggled to " + saved.getIsPublic());
        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Get favorite simulations
     */
    public List<SimulationResponse> getFavoriteSimulations(String userEmail) {
        System.out.println("SimulationService: Getting favorites for: " + userEmail);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found: " + userEmail));

        List<Simulation> simulations = simulationRepository.findByUserIdAndIsFavoriteTrueOrderByCreatedAtDesc(user.getId());
        
        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Merge AI predictions with traditional engine results
     * AI provides: maxDeflection, maxStress, stabilityIndex, seismicResistance
     * Engine provides: maxBendingMoment, maxShearForce, safetyFactor, naturalFrequency, etc.
     */
    private SimulationResult mergeResults(AIPredictionResponse aiPrediction, SimulationResult engineResults) {
        System.out.println("SimulationService: Merging AI predictions with engine results");
        
        // Use AI predictions for deflection and stress (more accurate from ML)
        // Use engine results for other mechanical properties
        return SimulationResult.builder()
                .maxDeflection(aiPrediction.getMaxDeflection()) // From AI
                .maxStress(aiPrediction.getMaxStress())         // From AI
                .maxBendingMoment(engineResults.getMaxBendingMoment())
                .maxShearForce(engineResults.getMaxShearForce())
                .safetyFactor(engineResults.getSafetyFactor())
                .isSafe(aiPrediction.isSafe() && engineResults.getIsSafe())
                .recommendations(generateHybridRecommendations(aiPrediction, engineResults))
                .naturalFrequency(engineResults.getNaturalFrequency())
                .criticalLoad(engineResults.getCriticalLoad())
                .weight(engineResults.getWeight())
                .build();
    }

    /**
     * Build results from AI prediction only (no engine fallback)
     * All values come from AI Deep Learning model
     */
    private SimulationResult buildResultsFromAI(AIPredictionResponse aiPrediction, Simulation simulation) {
        System.out.println("SimulationService: Building results from AI only");
        
        // Calculate safety factor from AI stress vs material yield strength
        double yieldStrength = simulation.getYieldStrength() != null ? simulation.getYieldStrength() : 250.0;
        double safetyFactor = yieldStrength / Math.max(aiPrediction.getMaxStress(), 1.0);
        boolean isSafe = aiPrediction.isSafe() && safetyFactor >= 1.5;
        
        // Simple weight calculation
        double volume = simulation.getBeamLength() * simulation.getBeamWidth() * simulation.getBeamHeight();
        double density = simulation.getDensity() != null ? simulation.getDensity() : 7850.0;
        double weight = volume * density;
        
        // Generate recommendations from AI
        String recommendations = generateAIRecommendations(aiPrediction, safetyFactor);
        
        return SimulationResult.builder()
                .maxDeflection(aiPrediction.getMaxDeflection())
                .maxStress(aiPrediction.getMaxStress())
                .maxBendingMoment(aiPrediction.getMaxStress() * 0.5) // Approximate
                .maxShearForce(simulation.getLoadMagnitude() / 2)    // Approximate
                .safetyFactor(safetyFactor)
                .isSafe(isSafe)
                .recommendations(recommendations)
                .naturalFrequency(10.0) // Default value
                .criticalLoad(simulation.getLoadMagnitude() * safetyFactor)
                .weight(weight)
                .build();
    }

    /**
     * Generate recommendations from AI analysis only
     */
    private String generateAIRecommendations(AIPredictionResponse aiPrediction, double safetyFactor) {
        StringBuilder recommendations = new StringBuilder();
        
        recommendations.append("🤖 AI Deep Learning Analysis\n\n");
        recommendations.append("Status: ").append(aiPrediction.getStatus()).append("\n");
        recommendations.append("Stability Index: ").append(String.format("%.1f%%", aiPrediction.getStabilityIndex())).append("\n");
        recommendations.append("Seismic Resistance: ").append(String.format("%.1f%%", aiPrediction.getSeismicResistance())).append("\n");
        recommendations.append("Safety Factor: ").append(String.format("%.2f", safetyFactor)).append("\n\n");
        
        if (aiPrediction.getStabilityIndex() >= 70) {
            recommendations.append("✅ Structure meets stability requirements\n");
        } else if (aiPrediction.getStabilityIndex() >= 50) {
            recommendations.append("⚠️ Consider reinforcing structure for better stability\n");
        } else {
            recommendations.append("❌ Structure needs significant reinforcement\n");
        }
        
        if (aiPrediction.getSeismicResistance() >= 70) {
            recommendations.append("✅ Good seismic resistance\n");
        } else if (aiPrediction.getSeismicResistance() >= 50) {
            recommendations.append("⚠️ Improve seismic resistance for earthquake zones\n");
        } else {
            recommendations.append("❌ Seismic resistance insufficient for high-risk areas\n");
        }
        
        return recommendations.toString();
    }

    /**
     * Generate recommendations from both AI and engine analysis
     */
    private String generateHybridRecommendations(AIPredictionResponse aiPrediction, SimulationResult engineResults) {
        StringBuilder recommendations = new StringBuilder();
        
        recommendations.append("AI Analysis Status: ").append(aiPrediction.getStatus()).append("\n");
        recommendations.append("Stability Index: ").append(String.format("%.1f%%", aiPrediction.getStabilityIndex())).append("\n");
        recommendations.append("Seismic Resistance: ").append(String.format("%.1f%%", aiPrediction.getSeismicResistance())).append("\n\n");
        
        if (engineResults.getRecommendations() != null) {
            recommendations.append("Structural Analysis:\n");
            recommendations.append(engineResults.getRecommendations());
        }
        
        return recommendations.toString();
    }
}
