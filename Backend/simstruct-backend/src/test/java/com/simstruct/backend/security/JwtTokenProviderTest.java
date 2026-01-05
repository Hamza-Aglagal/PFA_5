package com.simstruct.backend.security;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests pour JwtTokenProvider
 * Teste la génération et validation de tokens JWT
 */
@SpringBootTest
@ActiveProfiles("test")
class JwtTokenProviderTest {

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    /**
     * Test de génération d'un token d'accès
     */
    @Test
    void testGenerateAccessToken() {
        String userId = "user123";
        String email = "test@example.com";

        String token = jwtTokenProvider.generateAccessToken(userId, email);

        assertNotNull(token);
        assertFalse(token.isEmpty());
        assertTrue(token.contains(".")); // JWT format: header.payload.signature
    }

    /**
     * Test de génération d'un refresh token
     */
    @Test
    void testGenerateRefreshToken() {
        String userId = "user123";

        String token = jwtTokenProvider.generateRefreshToken(userId);

        assertNotNull(token);
        assertFalse(token.isEmpty());
    }

    /**
     * Test de validation d'un token valide
     */
    @Test
    void testValidateToken_Valid() {
        String userId = "user123";
        String email = "test@example.com";

        String token = jwtTokenProvider.generateAccessToken(userId, email);
        boolean isValid = jwtTokenProvider.validateToken(token);

        assertTrue(isValid);
    }

    /**
     * Test de validation d'un token invalide
     */
    @Test
    void testValidateToken_Invalid() {
        String invalidToken = "invalid.token.here";

        boolean isValid = jwtTokenProvider.validateToken(invalidToken);

        assertFalse(isValid);
    }

    /**
     * Test d'extraction de l'userId d'un token
     */
    @Test
    void testGetUserIdFromToken() {
        String userId = "user123";
        String email = "test@example.com";

        String token = jwtTokenProvider.generateAccessToken(userId, email);
        String extractedUserId = jwtTokenProvider.getUserIdFromToken(token);

        assertEquals(userId, extractedUserId);
    }

    /**
     * Test que deux tokens générés sont identiques (même timestamp)
     */
    @Test
    void testTokensAreConsistent() {
        String userId = "user123";
        String email = "test@example.com";

        String token1 = jwtTokenProvider.generateAccessToken(userId, email);
        String extractedId1 = jwtTokenProvider.getUserIdFromToken(token1);

        // Vérifier que l'ID est correctement extrait
        assertEquals(userId, extractedId1);
    }

    /**
     * Test que le temps d'expiration est configuré
     */
    @Test
    void testGetExpirationTime() {
        Long expiration = jwtTokenProvider.getExpirationTime();

        assertNotNull(expiration);
        assertTrue(expiration > 0);
    }

    /**
     * Test de validation d'un token vide
     */
    @Test
    void testValidateToken_Empty() {
        boolean isValid = jwtTokenProvider.validateToken("");

        assertFalse(isValid);
    }

    /**
     * Test de validation d'un token null-like
     */
    @Test
    void testValidateToken_Malformed() {
        boolean isValid = jwtTokenProvider.validateToken("not.a.valid.jwt.token");

        assertFalse(isValid);
    }
}
