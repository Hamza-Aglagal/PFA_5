package com.simstruct.backend.service;

import com.simstruct.backend.dto.SimulationRequest;
import com.simstruct.backend.dto.SimulationResponse;
import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.SimulationRepository;
import com.simstruct.backend.repository.UserRepository;
import com.simstruct.backend.repository.SharedSimulationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * Tests simples pour SimulationService
 * 
 * Ce fichier teste les méthodes principales du service de simulation:
 * - Création de simulation
 * - Récupération par ID
 * - Récupération de toutes les simulations d'un utilisateur
 * - Suppression de simulation
 */
class SimulationServiceTest {

    // Mock = objet simulé pour ne pas utiliser la vraie base de données
    @Mock
    private SimulationRepository simulationRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SharedSimulationRepository sharedSimulationRepository;

    @Mock
    private SimulationEngine simulationEngine;

    @Mock
    private NotificationService notificationService;

    @Mock
    private AIModelService aiModelService;

    // InjectMocks = injecte les mocks ci-dessus dans le service
    @InjectMocks
    private SimulationService simulationService;

    // Données de test réutilisables
    private User testUser;
    private Simulation testSimulation;

    /**
     * Méthode exécutée avant chaque test
     * Prépare les données de test
     */
    @BeforeEach
    void setUp() {
        // Initialise Mockito
        MockitoAnnotations.openMocks(this);

        // Crée un utilisateur de test
        testUser = new User();
        testUser.setId("user123");
        testUser.setEmail("test@example.com");
        testUser.setName("Test User");

        // Crée une simulation de test
        testSimulation = new Simulation();
        testSimulation.setId("sim123");
        testSimulation.setName("Test Simulation");
        testSimulation.setDescription("Description test");
        testSimulation.setUser(testUser);
        testSimulation.setBeamLength(5.0);
        testSimulation.setBeamWidth(0.3);
        testSimulation.setBeamHeight(0.5);
    }

    /**
     * Test de récupération d'une simulation par ID
     * Vérifie qu'on peut récupérer une simulation qui existe
     */
    @Test
    void testGetSimulation_Success() {
        // ARRANGE: Prépare les données
        String simulationId = "sim123";
        String userEmail = "test@example.com";

        // Configure le mock pour retourner notre simulation de test
        when(simulationRepository.findById(simulationId))
                .thenReturn(Optional.of(testSimulation));
        
        // Configure le mock pour retourner notre utilisateur de test
        when(userRepository.findByEmail(userEmail))
                .thenReturn(Optional.of(testUser));

        // ACT: Exécute la méthode à tester
        SimulationResponse result = simulationService.getSimulation(simulationId, userEmail);

        // ASSERT: Vérifie les résultats
        assertNotNull(result, "Le résultat ne doit pas être null");
        assertEquals("sim123", result.getId(), "L'ID doit correspondre");
        assertEquals("Test Simulation", result.getName(), "Le nom doit correspondre");

        // Vérifie que le repository a bien été appelé une fois
        verify(simulationRepository, times(1)).findById(simulationId);
    }

    /**
     * Test de récupération d'une simulation inexistante
     * Vérifie qu'une erreur est levée si la simulation n'existe pas
     */
    @Test
    void testGetSimulation_NotFound() {
        // ARRANGE
        String simulationId = "sim-inexistant";
        String userEmail = "test@example.com";

        // Configure le mock pour retourner vide (simulation non trouvée)
        when(simulationRepository.findById(simulationId))
                .thenReturn(Optional.empty());

        // ACT & ASSERT: Vérifie qu'une exception est levée
        assertThrows(RuntimeException.class, () -> {
            simulationService.getSimulation(simulationId, userEmail);
        }, "Une exception doit être levée si la simulation n'existe pas");

        verify(simulationRepository, times(1)).findById(simulationId);
    }

    /**
     * Test de récupération de toutes les simulations d'un utilisateur
     * Vérifie qu'on récupère bien la liste complète
     */
    @Test
    void testGetUserSimulations_Success() {
        // ARRANGE
        String userEmail = "test@example.com";

        // Crée une deuxième simulation pour le test
        Simulation simulation2 = new Simulation();
        simulation2.setId("sim456");
        simulation2.setName("Simulation 2");
        simulation2.setUser(testUser);

        List<Simulation> simulationList = Arrays.asList(testSimulation, simulation2);

        // Configure les mocks
        when(userRepository.findByEmail(userEmail))
                .thenReturn(Optional.of(testUser));
        when(simulationRepository.findByUserIdOrderByCreatedAtDesc(testUser.getId()))
                .thenReturn(simulationList);

        // ACT
        List<SimulationResponse> result = simulationService.getUserSimulations(userEmail);

        // ASSERT
        assertNotNull(result, "Le résultat ne doit pas être null");
        assertEquals(2, result.size(), "Doit retourner 2 simulations");
        assertEquals("sim123", result.get(0).getId(), "Première simulation doit être sim123");
        assertEquals("sim456", result.get(1).getId(), "Deuxième simulation doit être sim456");

        // Vérifie les appels aux mocks
        verify(userRepository, times(1)).findByEmail(userEmail);
        verify(simulationRepository, times(1)).findByUserIdOrderByCreatedAtDesc(testUser.getId());
    }

    /**
     * Test de récupération avec utilisateur inexistant
     * Vérifie qu'une erreur est levée si l'utilisateur n'existe pas
     */
    @Test
    void testGetUserSimulations_UserNotFound() {
        // ARRANGE
        String userEmail = "inexistant@example.com";

        // Configure le mock pour retourner vide
        when(userRepository.findByEmail(userEmail))
                .thenReturn(Optional.empty());

        // ACT & ASSERT
        assertThrows(RuntimeException.class, () -> {
            simulationService.getUserSimulations(userEmail);
        }, "Une exception doit être levée si l'utilisateur n'existe pas");

        verify(userRepository, times(1)).findByEmail(userEmail);
        // Le repository de simulation ne doit PAS être appelé
        verify(simulationRepository, never()).findByUserIdOrderByCreatedAtDesc(anyString());
    }

    /**
     * Test de suppression d'une simulation
     * Vérifie qu'on peut supprimer une simulation qui existe
     */
    @Test
    void testDeleteSimulation_Success() {
        // ARRANGE
        String simulationId = "sim123";
        String userEmail = "test@example.com";

        when(simulationRepository.findById(simulationId))
                .thenReturn(Optional.of(testSimulation));
        // doNothing = ne fait rien quand delete() est appelé (comportement par défaut)
        doNothing().when(simulationRepository).delete(testSimulation);

        // ACT
        simulationService.deleteSimulation(simulationId, userEmail);

        // ASSERT
        // Vérifie que delete a bien été appelé
        verify(simulationRepository, times(1)).delete(testSimulation);
    }

    /**
     * Test de suppression avec mauvais propriétaire
     * Vérifie qu'on ne peut pas supprimer la simulation d'un autre utilisateur
     */
    @Test
    void testDeleteSimulation_UnauthorizedUser() {
        // ARRANGE
        String simulationId = "sim123";
        String wrongUserEmail = "autreuser@example.com"; // Utilisateur différent

        when(simulationRepository.findById(simulationId))
                .thenReturn(Optional.of(testSimulation));

        // ACT & ASSERT
        assertThrows(RuntimeException.class, () -> {
            simulationService.deleteSimulation(simulationId, wrongUserEmail);
        }, "Une exception doit être levée si l'utilisateur n'est pas le propriétaire");

        // Vérifie que delete n'a PAS été appelé
        verify(simulationRepository, never()).delete(any());
    }

    /**
     * Test de récupération des simulations publiques
     * Vérifie qu'on récupère bien toutes les simulations publiques
     */
    @Test
    void testGetPublicSimulations_Success() {
        // ARRANGE
        testSimulation.setIsPublic(true);
        testSimulation.setUser(testUser); // Important: assigner l'utilisateur

        Simulation publicSimulation2 = new Simulation();
        publicSimulation2.setId("sim789");
        publicSimulation2.setName("Public Simulation 2");
        publicSimulation2.setIsPublic(true);
        publicSimulation2.setUser(testUser); // Important: assigner l'utilisateur

        List<Simulation> publicSimulations = Arrays.asList(testSimulation, publicSimulation2);

        when(simulationRepository.findByIsPublicTrueOrderByCreatedAtDesc())
                .thenReturn(publicSimulations);

        // ACT
        List<SimulationResponse> result = simulationService.getPublicSimulations();

        // ASSERT
        assertNotNull(result, "Le résultat ne doit pas être null");
        assertEquals(2, result.size(), "Doit retourner 2 simulations publiques");

        verify(simulationRepository, times(1)).findByIsPublicTrueOrderByCreatedAtDesc();
    }
}
