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
 * Tests d'intégration pour ChatController
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ChatControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String accessToken;

    @BeforeEach
    void setUp() throws Exception {
        String uniqueEmail = "chatctrl" + System.currentTimeMillis() + "@example.com";
        
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setEmail(uniqueEmail);
        registerRequest.setPassword("password123");
        registerRequest.setName("Chat Test");

        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        String response = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(response).path("data").path("accessToken").asText();
    }

    /**
     * Test de récupération des conversations
     */
    @Test
    void testGetConversations_Success() throws Exception {
        mockMvc.perform(get("/api/v1/chat/conversations")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test d'accès aux conversations sans auth
     */
    @Test
    void testGetConversations_NoAuth() throws Exception {
        mockMvc.perform(get("/api/v1/chat/conversations"))
                .andExpect(status().isForbidden());
    }

    /**
     * Test de récupération du compteur de messages non lus
     */
    @Test
    void testGetUnreadCount_Success() throws Exception {
        mockMvc.perform(get("/api/v1/chat/unread")
                .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    /**
     * Test d'envoi d'un message à un utilisateur inexistant
     */
    @Test
    void testSendMessage_ToNonexistent() throws Exception {
        String messagePayload = "{\"content\": \"Test message\"}";

        mockMvc.perform(post("/api/v1/chat/conversations/nonexistent-id/messages")
                .header("Authorization", "Bearer " + accessToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(messagePayload))
                .andExpect(status().isNotFound());
    }
}
