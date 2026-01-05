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
 * Tests d'intégration pour FriendshipController
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class FriendshipControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String accessToken;

    @BeforeEach
    void setUp() throws Exception {
        String uniqueEmail = "friendctrl" + System.currentTimeMillis() + "@example.com";
        
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setEmail(uniqueEmail);
        registerRequest.setPassword("password123");
        registerRequest.setName("Friend Test");

        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        String response = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(response).path("data").path("accessToken").asText();
    }

    /**
     * Test de récupération des amis
     */
    @Test
    void testGetFriends_Success() throws Exception {
        mockMvc.perform(get("/api/v1/friends")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test d'accès aux amis sans auth
     */
    @Test
    void testGetFriends_NoAuth() throws Exception {
        mockMvc.perform(get("/api/v1/friends"))
                .andExpect(status().isForbidden());
    }

    /**
     * Test de recherche d'utilisateurs
     */
    @Test
    void testSearchUsers_Success() throws Exception {
        mockMvc.perform(get("/api/v1/friends/search")
                .header("Authorization", "Bearer " + accessToken)
                .param("query", "test"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test de récupération des invitations en attente
     */
    @Test
    void testGetPendingInvitations_Success() throws Exception {
        mockMvc.perform(get("/api/v1/friends/invitations")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test de récupération des demandes envoyées
     */
    @Test
    void testGetSentRequests_Success() throws Exception {
        mockMvc.perform(get("/api/v1/friends/sent")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }
}
