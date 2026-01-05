package com.simstruct.backend.service;

import com.simstruct.backend.dto.SharedSimulationDTO;
import com.simstruct.backend.entity.SharedSimulation;
import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.SimulationResult;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.SharedSimulationRepository;
import com.simstruct.backend.repository.SimulationRepository;
import com.simstruct.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests for SharedSimulationService
 * Simple tests to verify simulation sharing functionality
 */
@ExtendWith(MockitoExtension.class)
public class SharedSimulationServiceTest {

    @Mock
    private SharedSimulationRepository sharedSimulationRepository;

    @Mock
    private SimulationRepository simulationRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private SharedSimulationService sharedSimulationService;

    private User sharedBy;
    private User sharedWith;
    private Simulation simulation;
    private SharedSimulation sharedSimulation;

    @BeforeEach
    void setUp() {
        // Create user who shares
        sharedBy = User.builder()
                .id("user123")
                .name("Owner User")
                .email("owner@example.com")
                .build();

        // Create user who receives
        sharedWith = User.builder()
                .id("friend123")
                .name("Friend User")
                .email("friend@example.com")
                .build();

        // Create simulation result
        SimulationResult result = SimulationResult.builder()
                .safetyFactor(2.5)
                .isSafe(true)
                .build();

        // Create simulation
        simulation = Simulation.builder()
                .id("sim123")
                .name("Test Simulation")
                .description("A test simulation")
                .materialType(Simulation.MaterialType.STEEL)
                .supportType(Simulation.SupportType.SIMPLY_SUPPORTED)
                .results(result)
                .build();

        // Create shared simulation
        sharedSimulation = SharedSimulation.builder()
                .id("share123")
                .simulation(simulation)
                .sharedBy(sharedBy)
                .sharedWith(sharedWith)
                .permission(SharedSimulation.SharePermission.VIEW)
                .sharedAt(LocalDateTime.now())
                .build();
    }

    /**
     * TEST 1: Share simulation - Success
     */
    @Test
    void testShareSimulation_Success() {
        // Arrange
        when(simulationRepository.findById("sim123")).thenReturn(Optional.of(simulation));
        when(userRepository.findById("user123")).thenReturn(Optional.of(sharedBy));
        when(userRepository.findById("friend123")).thenReturn(Optional.of(sharedWith));
        when(sharedSimulationRepository.findBySimulationIdAndSharedWithId("sim123", "friend123"))
                .thenReturn(Optional.empty());
        when(sharedSimulationRepository.save(any(SharedSimulation.class))).thenReturn(sharedSimulation);

        // Act
        SharedSimulationDTO result = sharedSimulationService.shareSimulation(
                "user123", "sim123", "friend123", SharedSimulation.SharePermission.VIEW);

        // Assert
        assertNotNull(result);
        assertEquals("share123", result.getId());
        assertEquals("sim123", result.getSimulationId());
        assertEquals("friend123", result.getSharedWithId());

        // Verify interactions
        verify(sharedSimulationRepository).save(any(SharedSimulation.class));
    }

    /**
     * TEST 2: Share simulation - Simulation not found
     */
    @Test
    void testShareSimulation_SimulationNotFound() {
        // Arrange
        when(simulationRepository.findById("invalid-sim")).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                sharedSimulationService.shareSimulation(
                        "user123", "invalid-sim", "friend123", SharedSimulation.SharePermission.VIEW));

        assertEquals("Simulation not found", exception.getMessage());
    }

    /**
     * TEST 3: Share simulation - Already shared
     */
    @Test
    void testShareSimulation_AlreadyShared() {
        // Arrange
        when(simulationRepository.findById("sim123")).thenReturn(Optional.of(simulation));
        when(userRepository.findById("user123")).thenReturn(Optional.of(sharedBy));
        when(userRepository.findById("friend123")).thenReturn(Optional.of(sharedWith));
        when(sharedSimulationRepository.findBySimulationIdAndSharedWithId("sim123", "friend123"))
                .thenReturn(Optional.of(sharedSimulation));

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                sharedSimulationService.shareSimulation(
                        "user123", "sim123", "friend123", SharedSimulation.SharePermission.VIEW));

        assertEquals("Simulation already shared with this user", exception.getMessage());
    }

    /**
     * TEST 4: Get my shares - Success
     */
    @Test
    void testGetMyShares_Success() {
        // Arrange
        List<SharedSimulation> shares = Arrays.asList(sharedSimulation);
        when(sharedSimulationRepository.findBySharedByIdOrderBySharedAtDesc("user123"))
                .thenReturn(shares);

        // Act
        List<SharedSimulationDTO> result = sharedSimulationService.getMyShares("user123");

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("sim123", result.get(0).getSimulationId());
    }

    /**
     * TEST 5: Get shared with me - Success
     */
    @Test
    void testGetSharedWithMe_Success() {
        // Arrange
        List<SharedSimulation> shares = Arrays.asList(sharedSimulation);
        when(sharedSimulationRepository.findBySharedWithIdOrderBySharedAtDesc("friend123"))
                .thenReturn(shares);

        // Act
        List<SharedSimulationDTO> result = sharedSimulationService.getSharedWithMe("friend123");

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("sim123", result.get(0).getSimulationId());
    }

    /**
     * TEST 6: Unshare simulation - Success
     */
    @Test
    void testUnshareSimulation_Success() {
        // Arrange
        when(sharedSimulationRepository.findById("share123")).thenReturn(Optional.of(sharedSimulation));
        doNothing().when(sharedSimulationRepository).delete(any(SharedSimulation.class));

        // Act
        sharedSimulationService.unshareSimulation("share123", "user123");

        // Assert
        verify(sharedSimulationRepository).delete(sharedSimulation);
    }

    /**
     * TEST 7: Unshare simulation - Share not found
     */
    @Test
    void testUnshareSimulation_NotFound() {
        // Arrange
        when(sharedSimulationRepository.findById("invalid-share")).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                sharedSimulationService.unshareSimulation("invalid-share", "user123"));

        assertEquals("Share not found", exception.getMessage());
    }

    /**
     * TEST 8: Unshare simulation - Not authorized
     */
    @Test
    void testUnshareSimulation_NotAuthorized() {
        // Arrange
        when(sharedSimulationRepository.findById("share123")).thenReturn(Optional.of(sharedSimulation));

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                sharedSimulationService.unshareSimulation("share123", "other-user"));

        assertEquals("Not authorized to unshare", exception.getMessage());
    }
}
