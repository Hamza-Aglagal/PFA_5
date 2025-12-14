package com.simstruct.backend.service;

import com.simstruct.backend.dto.SharedSimulationDTO;
import com.simstruct.backend.entity.SharedSimulation;
import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.SharedSimulationRepository;
import com.simstruct.backend.repository.SimulationRepository;
import com.simstruct.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SharedSimulationService {

    private final SharedSimulationRepository sharedSimulationRepository;
    private final SimulationRepository simulationRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    /**
     * Share simulation with a friend
     */
    @Transactional
    public SharedSimulationDTO shareSimulation(String sharedById, String simulationId, String sharedWithId, SharedSimulation.SharePermission permission) {
        System.out.println("SharedSimulationService: Sharing simulation " + simulationId + " with user " + sharedWithId);
        
        Simulation simulation = simulationRepository.findById(simulationId)
                .orElseThrow(() -> new RuntimeException("Simulation not found"));
        
        User sharedBy = userRepository.findById(sharedById)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        User sharedWith = userRepository.findById(sharedWithId)
                .orElseThrow(() -> new RuntimeException("Recipient user not found"));
        
        // Check if already shared
        sharedSimulationRepository.findBySimulationIdAndSharedWithId(simulationId, sharedWithId)
                .ifPresent(s -> {
                    throw new RuntimeException("Simulation already shared with this user");
                });
        
        SharedSimulation share = SharedSimulation.builder()
                .simulation(simulation)
                .sharedBy(sharedBy)
                .sharedWith(sharedWith)
                .permission(permission != null ? permission : SharedSimulation.SharePermission.VIEW)
                .build();
        
        share = sharedSimulationRepository.save(share);
        
        // Send notification to recipient
        try {
            notificationService.sendSimulationSharedNotification(
                sharedWith.getId(),
                sharedBy.getId(),
                sharedBy.getName(),
                simulation.getId(),
                simulation.getName()
            );
        } catch (Exception e) {
            System.out.println("SharedSimulationService: Failed to send notification - " + e.getMessage());
        }
        
        return mapToDTO(share);
    }

    /**
     * Get simulations I shared (My Shares)
     */
    public List<SharedSimulationDTO> getMyShares(String userId) {
        System.out.println("SharedSimulationService: Getting shares by user " + userId);
        return sharedSimulationRepository.findBySharedByIdOrderBySharedAtDesc(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get simulations shared with me
     */
    public List<SharedSimulationDTO> getSharedWithMe(String userId) {
        System.out.println("SharedSimulationService: Getting shares for user " + userId);
        return sharedSimulationRepository.findBySharedWithIdOrderBySharedAtDesc(userId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get simulations shared with a specific friend
     */
    public List<SharedSimulationDTO> getSharedWithFriend(String userId, String friendId) {
        System.out.println("SharedSimulationService: Getting shares between " + userId + " and " + friendId);
        
        // Sent to friend
        List<SharedSimulationDTO> sent = sharedSimulationRepository
                .findBySharedByIdAndSharedWithIdOrderBySharedAtDesc(userId, friendId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
        
        // Received from friend
        List<SharedSimulationDTO> received = sharedSimulationRepository
                .findReceivedFromFriend(userId, friendId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
        
        sent.addAll(received);
        return sent;
    }

    /**
     * Unshare simulation
     */
    @Transactional
    public void unshareSimulation(String shareId, String userId) {
        System.out.println("SharedSimulationService: Unsharing " + shareId);
        
        SharedSimulation share = sharedSimulationRepository.findById(shareId)
                .orElseThrow(() -> new RuntimeException("Share not found"));
        
        if (!share.getSharedBy().getId().equals(userId)) {
            throw new RuntimeException("Not authorized to unshare");
        }
        
        sharedSimulationRepository.delete(share);
    }

    private SharedSimulationDTO mapToDTO(SharedSimulation share) {
        Simulation sim = share.getSimulation();
        Double safetyFactor = sim.getResults() != null ? sim.getResults().getSafetyFactor() : null;
        Boolean isSafe = sim.getResults() != null ? sim.getResults().getIsSafe() : null;
        
        return SharedSimulationDTO.builder()
                .id(share.getId())
                .simulationId(sim.getId())
                .simulationName(sim.getName())
                .simulationDescription(sim.getDescription())
                .materialType(sim.getMaterialType().name())
                .supportType(sim.getSupportType().name())
                .safetyFactor(safetyFactor)
                .isSafe(isSafe)
                .sharedById(share.getSharedBy().getId())
                .sharedByName(share.getSharedBy().getName())
                .sharedWithId(share.getSharedWith().getId())
                .sharedWithName(share.getSharedWith().getName())
                .permission(share.getPermission().name())
                .message(share.getMessage())
                .sharedAt(share.getSharedAt())
                .build();
    }
}
