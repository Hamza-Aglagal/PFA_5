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
 * Tests d'intégration pour UserController
 * Teste les endpoints de gestion du profil utilisateur
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String accessToken;

    @BeforeEach
    void setUp() throws Exception {
        String uniqueEmail = "userctrl" + System.currentTimeMillis() + "@example.com";
        
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setEmail(uniqueEmail);
        registerRequest.setPassword("password123");
        registerRequest.setName("User Test");

        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        String response = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(response).path("data").path("accessToken").asText();
    }

    /**
     * Test de récupération du profil utilisateur
     */
    @Test
    void testGetCurrentUser_Success() throws Exception {
        mockMvc.perform(get("/api/v1/users/me")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.email").exists());
    }

    /**
     * Test d'accès au profil sans authentification
     */
    @Test
    void testGetCurrentUser_NoAuth() throws Exception {
        mockMvc.perform(get("/api/v1/users/me"))
                .andExpect(status().isForbidden());
    }

    /**
     * Test de mise à jour du profil
     */
    @Test
    void testUpdateProfile_Success() throws Exception {
        String updatePayload = "{\"name\": \"Updated Name\", \"phone\": \"0612345678\"}";

        mockMvc.perform(put("/api/v1/users/me")
                .header("Authorization", "Bearer " + accessToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(updatePayload))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test de changement de mot de passe
     */
    @Test
    void testChangePassword_WrongCurrent() throws Exception {
        String passwordPayload = "{\"currentPassword\": \"wrongpassword\", \"newPassword\": \"newpassword123\"}";

        mockMvc.perform(put("/api/v1/users/me/password")
                .header("Authorization", "Bearer " + accessToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(passwordPayload))
                .andExpect(status().isBadRequest());
    }

    /**
     * Test de changement de mot de passe avec succès
     */
    @Test
    void testChangePassword_Success() throws Exception {
        String passwordPayload = "{\"currentPassword\": \"password123\", \"newPassword\": \"newpassword123\"}";

        mockMvc.perform(put("/api/v1/users/me/password")
                .header("Authorization", "Bearer " + accessToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(passwordPayload))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test de suppression de compte
     */
    @Test
    void testDeleteAccount_Success() throws Exception {
        // Créer un nouvel utilisateur pour ce test
        String uniqueEmail = "delete" + System.currentTimeMillis() + "@example.com";
        
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setEmail(uniqueEmail);
        registerRequest.setPassword("password123");
        registerRequest.setName("Delete Test");

        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        String response = result.getResponse().getContentAsString();
        String deleteToken = objectMapper.readTree(response).path("data").path("accessToken").asText();

        // Supprimer le compte
        mockMvc.perform(delete("/api/v1/users/me")
                .header("Authorization", "Bearer " + deleteToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}
