package com.simstruct.backend.service;

import com.simstruct.backend.dto.ChangePasswordRequest;
import com.simstruct.backend.dto.UpdateProfileRequest;
import com.simstruct.backend.dto.UserResponse;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * Tests simples pour UserService
 * 
 * Ce fichier teste les méthodes du service utilisateur:
 * - Récupération d'utilisateur par ID
 * - Mise à jour du profil
 * - Changement de mot de passe
 * - Suppression de compte
 */
class UserServiceTest {

    // Mock pour simuler la base de données
    @Mock
    private UserRepository userRepository;

    // Mock pour encoder les mots de passe
    @Mock
    private PasswordEncoder passwordEncoder;

    // Service à tester avec les mocks injectés
    @InjectMocks
    private UserService userService;

    // Données de test
    private User testUser;

    /**
     * Méthode exécutée avant chaque test
     * Prépare les données de test
     */
    @BeforeEach
    void setUp() {
        // Initialise Mockito
        MockitoAnnotations.openMocks(this);

        // Crée un utilisateur de test
        testUser = User.builder()
                .id("user123")
                .name("John Doe")
                .email("john@example.com")
                .password("hashedPassword123")
                .phone("0612345678")
                .company("Test Company")
                .jobTitle("Ingénieur")
                .bio("Bio de test")
                .build();
    }

    /**
     * Test de récupération d'utilisateur par ID - Succès
     * Vérifie qu'on peut récupérer un utilisateur qui existe
     */
    @Test
    void testGetUserById_Success() {
        // ARRANGE: Prépare le mock
        String userId = "user123";
        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));

        // ACT: Exécute la méthode
        UserResponse result = userService.getUserById(userId);

        // ASSERT: Vérifie les résultats
        assertNotNull(result, "Le résultat ne doit pas être null");
        assertEquals("user123", result.getId(), "L'ID doit correspondre");
        assertEquals("John Doe", result.getName(), "Le nom doit correspondre");
        assertEquals("john@example.com", result.getEmail(), "L'email doit correspondre");

        // Vérifie que le repository a été appelé
        verify(userRepository, times(1)).findById(userId);
    }

    /**
     * Test de récupération d'utilisateur - Utilisateur inexistant
     * Vérifie qu'une exception est levée si l'utilisateur n'existe pas
     */
    @Test
    void testGetUserById_NotFound() {
        // ARRANGE
        String userId = "user-inexistant";
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // ACT & ASSERT: Vérifie qu'une exception est levée
        assertThrows(RuntimeException.class, () -> {
            userService.getUserById(userId);
        }, "Une exception doit être levée si l'utilisateur n'existe pas");

        verify(userRepository, times(1)).findById(userId);
    }

    /**
     * Test de mise à jour du profil - Succès
     * Vérifie qu'on peut mettre à jour les informations d'un utilisateur
     */
    @Test
    void testUpdateProfile_Success() {
        // ARRANGE
        String userId = "user123";
        UpdateProfileRequest request = new UpdateProfileRequest();
        request.setName("Jane Doe");
        request.setPhone("0687654321");
        request.setCompany("Nouvelle Entreprise");
        request.setJobTitle("Lead Developer");
        request.setBio("Nouvelle bio");

        // Configure les mocks
        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // ACT
        UserResponse result = userService.updateProfile(userId, request);

        // ASSERT
        assertNotNull(result, "Le résultat ne doit pas être null");
        // Vérifie que save a été appelé (le profil a été modifié)
        verify(userRepository, times(1)).save(any(User.class));
        verify(userRepository, times(1)).findById(userId);
    }

    /**
     * Test de mise à jour avec utilisateur inexistant
     */
    @Test
    void testUpdateProfile_UserNotFound() {
        // ARRANGE
        String userId = "user-inexistant";
        UpdateProfileRequest request = new UpdateProfileRequest();
        request.setName("Jane Doe");

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // ACT & ASSERT
        assertThrows(RuntimeException.class, () -> {
            userService.updateProfile(userId, request);
        }, "Une exception doit être levée si l'utilisateur n'existe pas");

        // save ne doit PAS être appelé
        verify(userRepository, never()).save(any());
    }

    /**
     * Test de changement de mot de passe - Succès
     * Vérifie qu'on peut changer le mot de passe avec le bon ancien mot de passe
     */
    @Test
    void testChangePassword_Success() {
        // ARRANGE
        String userId = "user123";
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setCurrentPassword("oldPassword");
        request.setNewPassword("newPassword123");

        // Configure les mocks
        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches("oldPassword", testUser.getPassword())).thenReturn(true);
        when(passwordEncoder.encode("newPassword123")).thenReturn("hashedNewPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // ACT
        userService.changePassword(userId, request);

        // ASSERT
        // Vérifie que le mot de passe a été vérifié
        verify(passwordEncoder, times(1)).matches("oldPassword", "hashedPassword123");
        // Vérifie que le nouveau mot de passe a été encodé
        verify(passwordEncoder, times(1)).encode("newPassword123");
        // Vérifie que l'utilisateur a été sauvegardé
        verify(userRepository, times(1)).save(testUser);
    }

    /**
     * Test de changement de mot de passe - Mauvais mot de passe actuel
     * Vérifie qu'une erreur est levée si l'ancien mot de passe est incorrect
     */
    @Test
    void testChangePassword_WrongCurrentPassword() {
        // ARRANGE
        String userId = "user123";
        ChangePasswordRequest request = new ChangePasswordRequest();
        request.setCurrentPassword("wrongPassword");
        request.setNewPassword("newPassword123");

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        // Le mot de passe actuel ne correspond PAS
        when(passwordEncoder.matches("wrongPassword", testUser.getPassword())).thenReturn(false);

        // ACT & ASSERT
        assertThrows(RuntimeException.class, () -> {
            userService.changePassword(userId, request);
        }, "Une exception doit être levée si le mot de passe actuel est incorrect");

        // Vérifie que save n'a PAS été appelé
        verify(userRepository, never()).save(any());
    }

    /**
     * Test de suppression de compte - Succès
     * Vérifie qu'on peut supprimer un compte existant
     */
    @Test
    void testDeleteAccount_Success() {
        // ARRANGE
        String userId = "user123";

        when(userRepository.existsById(userId)).thenReturn(true);
        doNothing().when(userRepository).deleteById(userId);

        // ACT
        userService.deleteAccount(userId);

        // ASSERT
        // Vérifie que existsById a été appelé
        verify(userRepository, times(1)).existsById(userId);
        // Vérifie que deleteById a été appelé
        verify(userRepository, times(1)).deleteById(userId);
    }

    /**
     * Test de suppression de compte - Utilisateur inexistant
     * Vérifie qu'une erreur est levée si l'utilisateur n'existe pas
     */
    @Test
    void testDeleteAccount_UserNotFound() {
        // ARRANGE
        String userId = "user-inexistant";

        when(userRepository.existsById(userId)).thenReturn(false);

        // ACT & ASSERT
        assertThrows(RuntimeException.class, () -> {
            userService.deleteAccount(userId);
        }, "Une exception doit être levée si l'utilisateur n'existe pas");

        // Vérifie que deleteById n'a PAS été appelé
        verify(userRepository, never()).deleteById(anyString());
    }

    /**
     * Test de mise à jour partielle du profil
     * Vérifie qu'on peut mettre à jour seulement certains champs
     */
    @Test
    void testUpdateProfile_PartialUpdate() {
        // ARRANGE: Mise à jour seulement du nom et du téléphone
        String userId = "user123";
        UpdateProfileRequest request = new UpdateProfileRequest();
        request.setName("Updated Name");
        request.setPhone("0699999999");
        // Les autres champs restent null

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // ACT
        UserResponse result = userService.updateProfile(userId, request);

        // ASSERT
        assertNotNull(result, "Le résultat ne doit pas être null");
        verify(userRepository, times(1)).save(any(User.class));
    }
}
