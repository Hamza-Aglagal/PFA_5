package com.simstruct.backend.dto;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests pour les DTOs
 * Vérifie que les getters et setters fonctionnent correctement
 */
class DtoTest {

    @Test
    void testApiResponse_Success() {
        ApiResponse<String> response = ApiResponse.success("data");
        
        assertTrue(response.isSuccess());
        assertEquals("data", response.getData());
        assertNull(response.getError());
    }

    @Test
    void testApiResponse_Error() {
        ApiResponse<String> response = ApiResponse.error("ERROR_CODE", "Error message");
        
        assertFalse(response.isSuccess());
        assertNull(response.getData());
        assertNotNull(response.getError());
    }

    @Test
    void testLoginRequest() {
        LoginRequest request = new LoginRequest();
        request.setEmail("test@example.com");
        request.setPassword("password123");
        
        assertEquals("test@example.com", request.getEmail());
        assertEquals("password123", request.getPassword());
    }

    @Test
    void testRegisterRequest() {
        RegisterRequest request = new RegisterRequest();
        request.setEmail("test@example.com");
        request.setPassword("password123");
        request.setName("Test User");
        
        assertEquals("test@example.com", request.getEmail());
        assertEquals("password123", request.getPassword());
        assertEquals("Test User", request.getName());
    }

    @Test
    void testAuthResponse() {
        AuthResponse response = new AuthResponse();
        response.setAccessToken("accessToken");
        response.setRefreshToken("refreshToken");
        response.setTokenType("Bearer");
        response.setExpiresIn(3600L);
        
        assertEquals("accessToken", response.getAccessToken());
        assertEquals("refreshToken", response.getRefreshToken());
        assertEquals("Bearer", response.getTokenType());
        assertEquals(3600L, response.getExpiresIn());
    }

    @Test
    void testRefreshTokenRequest() {
        RefreshTokenRequest request = new RefreshTokenRequest();
        request.setRefreshToken("refreshToken");
        
        assertEquals("refreshToken", request.getRefreshToken());
    }

    @Test
    void testSimulationRequest_Builder() {
        SimulationRequest request = new SimulationRequest();
        request.setName("Test Simulation");
        request.setBeamLength(5.0);
        request.setBeamWidth(0.3);
        
        assertEquals("Test Simulation", request.getName());
        assertEquals(5.0, request.getBeamLength());
        assertEquals(0.3, request.getBeamWidth());
    }

    @Test
    void testSimulationResponse() {
        SimulationResponse response = new SimulationResponse();
        response.setId("sim123");
        response.setName("Test Simulation");
        response.setUserId("user123");
        
        assertEquals("sim123", response.getId());
        assertEquals("Test Simulation", response.getName());
        assertEquals("user123", response.getUserId());
    }
}
