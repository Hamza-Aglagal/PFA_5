package com.simstruct.backend.service;

import com.simstruct.backend.dto.*;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.UserRepository;
import com.simstruct.backend.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests pour AuthService
 * Tests simples pour vérifier l'authentification et l'inscription
 */
@ExtendWith(MockitoExtension.class)
public class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenProvider jwtTokenProvider;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private AuthService authService;

    private User testUser;
    private RegisterRequest registerRequest;
    private LoginRequest loginRequest;

    @BeforeEach
    void setUp() {
        // Créer un utilisateur de test simple
        testUser = new User();
        testUser.setId("user123");
        testUser.setName("Test User");
        testUser.setEmail("test@example.com");
        testUser.setPassword("hashedPassword123");
        testUser.setRole(User.Role.USER);

        // Créer une demande d'inscription simple
        registerRequest = new RegisterRequest();
        registerRequest.setName("New User");
        registerRequest.setEmail("newuser@example.com");
        registerRequest.setPassword("password123");

        // Créer une demande de connexion simple
        loginRequest = new LoginRequest();
        loginRequest.setEmail("test@example.com");
        loginRequest.setPassword("password123");
    }

    /**
     * TEST 1: Inscription réussie d'un nouvel utilisateur
     */
    @Test
    void testRegister_Success() {
        // ARRANGE: Préparer les données
        when(userRepository.existsByEmail(registerRequest.getEmail())).thenReturn(false);
        when(passwordEncoder.encode(registerRequest.getPassword())).thenReturn("hashedPassword");
        when(userRepository.save(any(User.class))).thenReturn(testUser);
        when(jwtTokenProvider.generateAccessToken(anyString(), anyString())).thenReturn("access-token");
        when(jwtTokenProvider.generateRefreshToken(anyString())).thenReturn("refresh-token");
        when(jwtTokenProvider.getExpirationTime()).thenReturn(3600L);

        // ACT: Exécuter le test
        AuthResponse response = authService.register(registerRequest);

        // ASSERT: Vérifier les résultats
        assertNotNull(response, "La réponse ne doit pas être null");
        assertEquals("access-token", response.getAccessToken());
        assertEquals("refresh-token", response.getRefreshToken());
        assertEquals("Bearer", response.getTokenType());
        assertNotNull(response.getUser());

        // Vérifier que les méthodes ont été appelées
        verify(userRepository).existsByEmail(registerRequest.getEmail());
        verify(userRepository).save(any(User.class));
        verify(passwordEncoder).encode(registerRequest.getPassword());
    }

    /**
     * TEST 2: Inscription échoue si l'email existe déjà
     */
    @Test
    void testRegister_EmailAlreadyExists() {
        // ARRANGE: Email déjà utilisé
        when(userRepository.existsByEmail(registerRequest.getEmail())).thenReturn(true);

        // ACT & ASSERT: Vérifier que l'exception est levée
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authService.register(registerRequest);
        });

        assertEquals("Email already registered", exception.getMessage());
        verify(userRepository, never()).save(any());
    }

    /**
     * TEST 3: Connexion réussie avec email et mot de passe corrects
     */
    @Test
    void testLogin_Success() {
        // ARRANGE: Préparer les données
        when(userRepository.findByEmail(loginRequest.getEmail())).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(loginRequest.getPassword(), testUser.getPassword())).thenReturn(true);
        when(jwtTokenProvider.generateAccessToken(anyString(), anyString())).thenReturn("access-token");
        when(jwtTokenProvider.generateRefreshToken(anyString())).thenReturn("refresh-token");
        when(jwtTokenProvider.getExpirationTime()).thenReturn(3600L);

        // ACT: Exécuter le test
        AuthResponse response = authService.login(loginRequest);

        // ASSERT: Vérifier les résultats
        assertNotNull(response);
        assertEquals("access-token", response.getAccessToken());
        assertEquals("refresh-token", response.getRefreshToken());
        assertEquals("Bearer", response.getTokenType());
        assertNotNull(response.getUser());

        verify(userRepository).findByEmail(loginRequest.getEmail());
        verify(passwordEncoder).matches(loginRequest.getPassword(), testUser.getPassword());
    }

    /**
     * TEST 4: Connexion échoue avec email inexistant
     */
    @Test
    void testLogin_UserNotFound() {
        // ARRANGE: Email n'existe pas
        when(userRepository.findByEmail(loginRequest.getEmail())).thenReturn(Optional.empty());

        // ACT & ASSERT: Vérifier que l'exception est levée
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authService.login(loginRequest);
        });

        assertEquals("Invalid email or password", exception.getMessage());
        verify(passwordEncoder, never()).matches(anyString(), anyString());
    }

    /**
     * TEST 5: Connexion échoue avec mauvais mot de passe
     */
    @Test
    void testLogin_WrongPassword() {
        // ARRANGE: Mot de passe incorrect
        when(userRepository.findByEmail(loginRequest.getEmail())).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(loginRequest.getPassword(), testUser.getPassword())).thenReturn(false);

        // ACT & ASSERT: Vérifier que l'exception est levée
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authService.login(loginRequest);
        });

        assertEquals("Invalid email or password", exception.getMessage());
        verify(jwtTokenProvider, never()).generateAccessToken(anyString(), anyString());
    }

    /**
     * TEST 7: Rafraîchir le token échoue avec token invalide
     */
    @Test
    void testRefreshToken_InvalidToken() {
        // ARRANGE: Token invalide
        RefreshTokenRequest request = new RefreshTokenRequest();
        request.setRefreshToken("invalid-token");

        when(jwtTokenProvider.validateToken(request.getRefreshToken())).thenReturn(false);

        // ACT & ASSERT: Vérifier que l'exception est levée
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authService.refreshToken(request);
        });

        assertEquals("Invalid refresh token", exception.getMessage());
        verify(userRepository, never()).findById(anyString());
    }

    /**
     * TEST 8: Rafraîchir le token échoue si l'utilisateur n'existe plus
     */
    @Test
    void testRefreshToken_UserNotFound() {
        // ARRANGE: Utilisateur supprimé
        RefreshTokenRequest request = new RefreshTokenRequest();
        request.setRefreshToken("valid-refresh-token");

        when(jwtTokenProvider.validateToken(request.getRefreshToken())).thenReturn(true);
        when(jwtTokenProvider.getUserIdFromToken(request.getRefreshToken())).thenReturn("user123");
        when(userRepository.findById("user123")).thenReturn(Optional.empty());

        // ACT & ASSERT: Vérifier que l'exception est levée
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            authService.refreshToken(request);
        });

        assertEquals("User not found", exception.getMessage());
    }
}
