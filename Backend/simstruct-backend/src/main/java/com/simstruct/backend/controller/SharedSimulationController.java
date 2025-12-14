package com.simstruct.backend.controller;

import com.simstruct.backend.dto.ApiResponse;
import com.simstruct.backend.dto.SharedSimulationDTO;
import com.simstruct.backend.entity.SharedSimulation;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.service.SharedSimulationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller for simulation sharing operations
 */
@RestController
@RequestMapping("/api/v1/shares")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SharedSimulationController {
    
    private final SharedSimulationService sharedSimulationService;
    
    /**
     * Get simulations I shared with others
     */
    @GetMapping("/my-shares")
    public ResponseEntity<ApiResponse<List<SharedSimulationDTO>>> getMyShares(
            @AuthenticationPrincipal User user) {
        List<SharedSimulationDTO> shares = sharedSimulationService.getMyShares(user.getId());
        return ResponseEntity.ok(ApiResponse.success(shares));
    }
    
    /**
     * Get simulations shared with me
     */
    @GetMapping("/shared-with-me")
    public ResponseEntity<ApiResponse<List<SharedSimulationDTO>>> getSharedWithMe(
            @AuthenticationPrincipal User user) {
        List<SharedSimulationDTO> shares = sharedSimulationService.getSharedWithMe(user.getId());
        return ResponseEntity.ok(ApiResponse.success(shares));
    }
    
    /**
     * Get simulations shared with a specific friend
     */
    @GetMapping("/with-friend/{friendId}")
    public ResponseEntity<ApiResponse<List<SharedSimulationDTO>>> getSharedWithFriend(
            @AuthenticationPrincipal User user,
            @PathVariable String friendId) {
        List<SharedSimulationDTO> shares = sharedSimulationService.getSharedWithFriend(user.getId(), friendId);
        return ResponseEntity.ok(ApiResponse.success(shares));
    }
    
    /**
     * Share a simulation with a friend
     */
    @PostMapping
    public ResponseEntity<ApiResponse<SharedSimulationDTO>> shareSimulation(
            @AuthenticationPrincipal User user,
            @RequestParam String simulationId,
            @RequestParam String friendId,
            @RequestParam(defaultValue = "VIEW") SharedSimulation.SharePermission permission) {
        SharedSimulationDTO share = sharedSimulationService.shareSimulation(
                user.getId(), simulationId, friendId, permission);
        return ResponseEntity.ok(ApiResponse.success(share));
    }
    
    /**
     * Unshare a simulation
     */
    @DeleteMapping("/{shareId}")
    public ResponseEntity<ApiResponse<String>> unshareSimulation(
            @AuthenticationPrincipal User user,
            @PathVariable String shareId) {
        sharedSimulationService.unshareSimulation(user.getId(), shareId);
        return ResponseEntity.ok(ApiResponse.success("Simulation unshared successfully"));
    }
}
