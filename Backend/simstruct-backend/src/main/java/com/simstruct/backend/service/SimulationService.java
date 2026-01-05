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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for simulation operations
 */
@Service
public class SimulationService {

    private static final Logger logger = LoggerFactory.getLogger(SimulationService.class);
    private static final String PERCENT_FORMAT = "%.1f%%";

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
        logger.info("SimulationService: Creating simulation for user: {}", userEmail);

        // Find user
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userEmail));

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
            logger.debug("SimulationService: Calling AI model with frontend parameters...");
            
            // ALWAYS use AI model for predictions
            logger.debug("SimulationService: Calling AI model...");
            
            // Call AI model - no fallback, must work
            AIPredictionResponse aiPrediction = aiModelService.predict(request.toAIRequest());
            logger.info("SimulationService: AI prediction successful");
            
            // Build results from AI only
            SimulationResult results = buildResultsFromAI(aiPrediction, simulation);
            simulation.setResults(results);
            simulation.setStatus(Simulation.SimulationStatus.COMPLETED);
            logger.info("SimulationService: AI analysis completed successfully");
            
        } catch (Exception e) {
            logger.error("SimulationService: Simulation failed - {}", e.getMessage());
            simulation.setStatus(Simulation.SimulationStatus.FAILED);
            throw new IllegalStateException("AI Model failed: " + e.getMessage(), e);
        }

        // Save and return
        Simulation saved = simulationRepository.save(simulation);
        logger.info("SimulationService: Simulation saved with ID: {}", saved.getId());

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
            logger.warn("SimulationService: Failed to send notification - {}", e.getMessage());
        }

        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Get simulation by ID
     */
    public SimulationResponse getSimulation(String id, String userEmail) {
        logger.debug("SimulationService: Getting simulation {} for user {}", id, userEmail);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Simulation not found: " + id));

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userEmail));

        logger.debug("SimulationService: User ID={}", user.getId());
        logger.debug("SimulationService: Simulation owner email={}", simulation.getUser().getEmail());
        logger.debug("SimulationService: Checking access for simulation {}", id);
        
        // Check access: allow if public, owner, or shared with user
        boolean isOwner = simulation.getUser().getEmail().equals(userEmail);
        logger.debug("SimulationService: isOwner={}", isOwner);
        
        boolean isPublic = simulation.getIsPublic();
        logger.debug("SimulationService: isPublic={}", isPublic);
        
        logger.debug("SimulationService: Checking if shared with user {}", user.getId());
        var sharedOpt = sharedSimulationRepository.findBySimulationIdAndSharedWithId(id, user.getId());
        boolean isShared = sharedOpt.isPresent();
        logger.debug("SimulationService: isShared={}", isShared);
        if (sharedOpt.isPresent()) {
            logger.debug("SimulationService: Found share: {}", sharedOpt.get().getId());
        } else {
            logger.debug("SimulationService: No share found for simulation={}, user={}", id, user.getId());
        }

        if (!isPublic && !isOwner && !isShared) {
            logger.warn("SimulationService: Access denied - not owner, not public, not shared");
            throw new SecurityException("Access denied to simulation: " + id);
        }

        logger.debug("SimulationService: Access granted (isOwner={}, isPublic={}, isShared={})", isOwner, isPublic, isShared);
        
        return SimulationResponse.fromEntity(simulation);
    }

    /**
     * Get all simulations for a user
     */
    public List<SimulationResponse> getUserSimulations(String userEmail) {
        logger.debug("SimulationService: Getting simulations for user: {}", userEmail);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userEmail));

        List<Simulation> simulations = simulationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        logger.debug("SimulationService: Found {} simulations", simulations.size());

        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Get recent simulations for a user (last 5)
     */
    public List<SimulationResponse> getRecentSimulations(String userEmail) {
        logger.debug("SimulationService: Getting recent simulations for: {}", userEmail);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userEmail));

        List<Simulation> simulations = simulationRepository.findTop5ByUserIdOrderByCreatedAtDesc(user.getId());
        
        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Get public simulations
     */
    public List<SimulationResponse> getPublicSimulations() {
        logger.debug("SimulationService: Getting public simulations");

        List<Simulation> simulations = simulationRepository.findByIsPublicTrueOrderByCreatedAtDesc();
        logger.debug("SimulationService: Found {} public simulations", simulations.size());

        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Search public simulations
     */
    public List<SimulationResponse> searchPublicSimulations(String query) {
        logger.debug("SimulationService: Searching public simulations for: {}", query);

        List<Simulation> simulations = simulationRepository.searchPublic(query);
        
        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Search user's simulations
     */
    public List<SimulationResponse> searchUserSimulations(String query, String userEmail) {
        logger.debug("SimulationService: Searching user simulations for: {}", query);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userEmail));

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
        logger.debug("SimulationService: Updating simulation {}", id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new SecurityException("Not authorized to update this simulation");
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
        logger.info("SimulationService: Simulation updated");

        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Delete simulation
     */
    @Transactional
    public void deleteSimulation(String id, String userEmail) {
        logger.debug("SimulationService: Deleting simulation {}", id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new SecurityException("Not authorized to delete this simulation");
        }

        simulationRepository.delete(simulation);
        logger.info("SimulationService: Simulation deleted");
    }

    /**
     * Toggle favorite status
     */
    @Transactional
    public SimulationResponse toggleFavorite(String id, String userEmail) {
        logger.debug("SimulationService: Toggling favorite for simulation {}", id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new SecurityException("Not authorized to modify this simulation");
        }

        simulation.setIsFavorite(!simulation.getIsFavorite());
        Simulation saved = simulationRepository.save(simulation);

        logger.debug("SimulationService: Favorite toggled to {}", saved.getIsFavorite());
        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Toggle public status
     */
    @Transactional
    public SimulationResponse togglePublic(String id, String userEmail) {
        logger.debug("SimulationService: Toggling public for simulation {}", id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Simulation not found: " + id));

        // Check ownership
        if (!simulation.getUser().getEmail().equals(userEmail)) {
            throw new SecurityException("Not authorized to modify this simulation");
        }

        simulation.setIsPublic(!simulation.getIsPublic());
        Simulation saved = simulationRepository.save(simulation);

        logger.debug("SimulationService: Public toggled to {}", saved.getIsPublic());
        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Get favorite simulations
     */
    public List<SimulationResponse> getFavoriteSimulations(String userEmail) {
        logger.debug("SimulationService: Getting favorites for: {}", userEmail);

        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userEmail));

        List<Simulation> simulations = simulationRepository.findByUserIdAndIsFavoriteTrueOrderByCreatedAtDesc(user.getId());
        
        return simulations.stream()
                .map(SimulationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Build results from AI prediction only (no engine fallback)
     * All values come from AI Deep Learning model
     */
    private SimulationResult buildResultsFromAI(AIPredictionResponse aiPrediction, Simulation simulation) {
        logger.debug("SimulationService: Building results from AI only");
        
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
        recommendations.append("Stability Index: ").append(String.format(PERCENT_FORMAT, aiPrediction.getStabilityIndex())).append("\n");
        recommendations.append("Seismic Resistance: ").append(String.format(PERCENT_FORMAT, aiPrediction.getSeismicResistance())).append("\n");
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
        recommendations.append("Stability Index: ").append(String.format(PERCENT_FORMAT, aiPrediction.getStabilityIndex())).append("\n");
        recommendations.append("Seismic Resistance: ").append(String.format(PERCENT_FORMAT, aiPrediction.getSeismicResistance())).append("\n\n");
        
        if (engineResults.getRecommendations() != null) {
            recommendations.append("Structural Analysis:\n");
            recommendations.append(engineResults.getRecommendations());
        }
        
        return recommendations.toString();
    }
}
