package com.simstruct.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.simstruct.backend.dto.RegisterRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests d'intégration pour SharedSimulationController
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SharedSimulationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String accessToken;

    @BeforeEach
    void setUp() throws Exception {
        String uniqueEmail = "sharectrl" + System.currentTimeMillis() + "@example.com";
        
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setEmail(uniqueEmail);
        registerRequest.setPassword("password123");
        registerRequest.setName("Share Test");

        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        String response = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(response).path("data").path("accessToken").asText();
    }

    /**
     * Test de récupération des simulations partagées par moi
     */
    @Test
    void testGetMyShares_Success() throws Exception {
        mockMvc.perform(get("/api/v1/shares/my-shares")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test d'accès aux partages sans auth
     */
    @Test
    void testGetMyShares_NoAuth() throws Exception {
        mockMvc.perform(get("/api/v1/shares/my-shares"))
                .andExpect(status().isForbidden());
    }

    /**
     * Test de récupération des simulations partagées avec moi
     */
    @Test
    void testGetSharedWithMe_Success() throws Exception {
        mockMvc.perform(get("/api/v1/shares/shared-with-me")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test de partage d'une simulation inexistante
     */
    @Test
    void testShareSimulation_NotFound() throws Exception {
        mockMvc.perform(post("/api/v1/shares/nonexistent-sim/share/nonexistent-user")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isNotFound());
    }
}
