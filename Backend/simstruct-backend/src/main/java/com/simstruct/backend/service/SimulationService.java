package com.simstruct.backend.service;

import com.simstruct.backend.dto.SimulationRequest;
import com.simstruct.backend.dto.SimulationResponse;
import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.SimulationResult;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.SimulationRepository;
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
    private final SimulationEngine simulationEngine;

    public SimulationService(SimulationRepository simulationRepository,
                            UserRepository userRepository,
                            SimulationEngine simulationEngine) {
        this.simulationRepository = simulationRepository;
        this.userRepository = userRepository;
        this.simulationEngine = simulationEngine;
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
            // Run simulation
            System.out.println("SimulationService: Running simulation engine...");
            SimulationResult results = simulationEngine.analyze(simulation);
            simulation.setResults(results);
            simulation.setStatus(Simulation.SimulationStatus.COMPLETED);
            System.out.println("SimulationService: Simulation completed successfully");
        } catch (Exception e) {
            System.out.println("SimulationService: Simulation failed - " + e.getMessage());
            simulation.setStatus(Simulation.SimulationStatus.FAILED);
        }

        // Save and return
        Simulation saved = simulationRepository.save(simulation);
        System.out.println("SimulationService: Simulation saved with ID: " + saved.getId());

        return SimulationResponse.fromEntity(saved);
    }

    /**
     * Get simulation by ID
     */
    public SimulationResponse getSimulation(String id, String userEmail) {
        System.out.println("SimulationService: Getting simulation " + id);

        Simulation simulation = simulationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Simulation not found: " + id));

        // Check access
        if (!simulation.getIsPublic() && !simulation.getUser().getEmail().equals(userEmail)) {
            throw new RuntimeException("Access denied to simulation: " + id);
        }

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
}
