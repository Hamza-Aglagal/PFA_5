package com.simstruct.backend.controller;

import com.simstruct.backend.dto.SimulationRequest;
import com.simstruct.backend.dto.SimulationResponse;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.service.SimulationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST Controller for simulation operations
 */
@RestController
@RequestMapping("/api/v1/simulations")
public class SimulationController {

    private final SimulationService simulationService;

    public SimulationController(SimulationService simulationService) {
        this.simulationService = simulationService;
    }

    /**
     * Create a new simulation
     * POST /api/v1/simulations
     */
    @PostMapping
    public ResponseEntity<?> createSimulation(
            @Valid @RequestBody SimulationRequest request,
            @AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Creating simulation for " + user.getEmail());
            System.out.println("SimulationController: Request = " + request);
            SimulationResponse response = simulationService.createSimulation(request, user.getEmail());
            System.out.println("SimulationController: Success! ID = " + response.getId());
            return ResponseEntity.ok(Map.of("success", true, "data", response));
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Get simulation by ID
     * GET /api/v1/simulations/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getSimulation(
            @PathVariable String id,
            @AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Getting simulation " + id);
            SimulationResponse response = simulationService.getSimulation(id, user.getEmail());
            return ResponseEntity.ok(Map.of("success", true, "data", response));
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Get all user's simulations
     * GET /api/v1/simulations
     */
    @GetMapping
    public ResponseEntity<?> getUserSimulations(@AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Getting all simulations for " + user.getEmail());
            List<SimulationResponse> response = simulationService.getUserSimulations(user.getEmail());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Get recent simulations (last 5)
     * GET /api/v1/simulations/recent
     */
    @GetMapping("/recent")
    public ResponseEntity<?> getRecentSimulations(@AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Getting recent simulations");
            List<SimulationResponse> response = simulationService.getRecentSimulations(user.getEmail());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Get favorite simulations
     * GET /api/v1/simulations/favorites
     */
    @GetMapping("/favorites")
    public ResponseEntity<?> getFavoriteSimulations(@AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Getting favorite simulations");
            List<SimulationResponse> response = simulationService.getFavoriteSimulations(user.getEmail());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Get public simulations (community)
     * GET /api/v1/simulations/public
     */
    @GetMapping("/public")
    public ResponseEntity<?> getPublicSimulations() {
        
        try {
            System.out.println("SimulationController: Getting public simulations");
            List<SimulationResponse> response = simulationService.getPublicSimulations();
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Search public simulations
     * GET /api/v1/simulations/public/search?q=query
     */
    @GetMapping("/public/search")
    public ResponseEntity<?> searchPublicSimulations(@RequestParam("q") String query) {
        
        try {
            System.out.println("SimulationController: Searching public simulations for: " + query);
            List<SimulationResponse> response = simulationService.searchPublicSimulations(query);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Search user's simulations
     * GET /api/v1/simulations/search?q=query
     */
    @GetMapping("/search")
    public ResponseEntity<?> searchUserSimulations(
            @RequestParam("q") String query,
            @AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Searching user simulations for: " + query);
            List<SimulationResponse> response = simulationService.searchUserSimulations(query, user.getEmail());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Update simulation
     * PUT /api/v1/simulations/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateSimulation(
            @PathVariable String id,
            @Valid @RequestBody SimulationRequest request,
            @AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Updating simulation " + id);
            SimulationResponse response = simulationService.updateSimulation(id, request, user.getEmail());
            return ResponseEntity.ok(Map.of("success", true, "data", response));
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Delete simulation
     * DELETE /api/v1/simulations/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSimulation(
            @PathVariable String id,
            @AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Deleting simulation " + id);
            simulationService.deleteSimulation(id, user.getEmail());
            return ResponseEntity.ok(Map.of("success", true, "message", "Simulation deleted successfully"));
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Toggle favorite status
     * POST /api/v1/simulations/{id}/favorite
     */
    @PostMapping("/{id}/favorite")
    public ResponseEntity<?> toggleFavorite(
            @PathVariable String id,
            @AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Toggling favorite for " + id);
            SimulationResponse response = simulationService.toggleFavorite(id, user.getEmail());
            return ResponseEntity.ok(Map.of("success", true, "data", response));
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    /**
     * Toggle public status
     * POST /api/v1/simulations/{id}/public
     */
    @PostMapping("/{id}/public")
    public ResponseEntity<?> togglePublic(
            @PathVariable String id,
            @AuthenticationPrincipal User user) {
        
        try {
            System.out.println("SimulationController: Toggling public for " + id);
            SimulationResponse response = simulationService.togglePublic(id, user.getEmail());
            return ResponseEntity.ok(Map.of("success", true, "data", response));
        } catch (Exception e) {
            System.err.println("SimulationController: ERROR - " + e.getMessage());
            return ResponseEntity.status(500).body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}
