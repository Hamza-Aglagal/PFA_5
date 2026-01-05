package com.simstruct.backend.service;

import com.simstruct.backend.dto.ChatMessageDTO;
import com.simstruct.backend.dto.ConversationDTO;
import com.simstruct.backend.entity.ChatMessage;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.ChatMessageRepository;
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
 * Tests for ChatService
 * Simple tests to verify chat functionality
 */
@ExtendWith(MockitoExtension.class)
public class ChatServiceTest {

    @Mock
    private ChatMessageRepository chatMessageRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SimulationRepository simulationRepository;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private ChatService chatService;

    private User sender;
    private User recipient;
    private ChatMessage chatMessage;

    @BeforeEach
    void setUp() {
        // Create sender
        sender = User.builder()
                .id("sender123")
                .name("Sender User")
                .email("sender@example.com")
                .build();

        // Create recipient
        recipient = User.builder()
                .id("recipient123")
                .name("Recipient User")
                .email("recipient@example.com")
                .build();

        // Create chat message
        chatMessage = ChatMessage.builder()
                .id("msg123")
                .sender(sender)
                .recipient(recipient)
                .content("Hello!")
                .isRead(false)
                .sentAt(LocalDateTime.now())
                .build();
    }

    /**
     * TEST 1: Send message - Success
     */
    @Test
    void testSendMessage_Success() {
        // Arrange
        when(userRepository.findById("sender123")).thenReturn(Optional.of(sender));
        when(userRepository.findById("recipient123")).thenReturn(Optional.of(recipient));
        when(chatMessageRepository.save(any(ChatMessage.class))).thenReturn(chatMessage);

        // Act
        ChatMessageDTO result = chatService.sendMessage("sender123", "recipient123", "Hello!");

        // Assert
        assertNotNull(result);
        assertEquals("msg123", result.getId());
        assertEquals("Hello!", result.getContent());
        assertEquals("sender123", result.getSenderId());
        assertEquals("recipient123", result.getRecipientId());

        // Verify interactions
        verify(userRepository).findById("sender123");
        verify(userRepository).findById("recipient123");
        verify(chatMessageRepository).save(any(ChatMessage.class));
    }

    /**
     * TEST 2: Send message - Sender not found
     */
    @Test
    void testSendMessage_SenderNotFound() {
        // Arrange
        when(userRepository.findById("invalid-sender")).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                chatService.sendMessage("invalid-sender", "recipient123", "Hello!"));

        assertEquals("Sender not found", exception.getMessage());
    }

    /**
     * TEST 3: Send message - Recipient not found
     */
    @Test
    void testSendMessage_RecipientNotFound() {
        // Arrange
        when(userRepository.findById("sender123")).thenReturn(Optional.of(sender));
        when(userRepository.findById("invalid-recipient")).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () ->
                chatService.sendMessage("sender123", "invalid-recipient", "Hello!"));

        assertEquals("Recipient not found", exception.getMessage());
    }

    /**
     * TEST 4: Get conversation - Success
     */
    @Test
    void testGetConversation_Success() {
        // Arrange
        List<ChatMessage> messages = Arrays.asList(chatMessage);
        when(chatMessageRepository.findConversation("sender123", "recipient123"))
                .thenReturn(messages);

        // Act
        List<ChatMessageDTO> result = chatService.getConversation("sender123", "recipient123");

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("Hello!", result.get(0).getContent());
    }

    /**
     * TEST 5: Get conversations - Success
     */
    @Test
    void testGetConversations_Success() {
        // Arrange
        List<ChatMessage> messages = Arrays.asList(chatMessage);
        when(chatMessageRepository.findLatestMessagesPerConversation("sender123"))
                .thenReturn(messages);
        when(chatMessageRepository.countUnreadFromSender(anyString(), anyString()))
                .thenReturn(2L);

        // Act
        List<ConversationDTO> result = chatService.getConversations("sender123");

        // Assert
        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("recipient123", result.get(0).getPartnerId());
        assertEquals("Recipient User", result.get(0).getPartnerName());
    }

    /**
     * TEST 6: Get unread count - Success
     */
    @Test
    void testGetUnreadCount_Success() {
        // Arrange
        when(chatMessageRepository.countUnreadMessages("user123")).thenReturn(5L);

        // Act
        long count = chatService.getUnreadCount("user123");

        // Assert
        assertEquals(5L, count);
    }

    /**
     * TEST 7: Mark as read - Success
     */
    @Test
    void testMarkAsRead_Success() {
        // Arrange
        ChatMessage unreadMessage = ChatMessage.builder()
                .id("msg456")
                .sender(recipient)
                .recipient(sender)
                .content("Hi!")
                .isRead(false)
                .build();

        List<ChatMessage> messages = Arrays.asList(unreadMessage);
        when(chatMessageRepository.findConversation("sender123", "recipient123"))
                .thenReturn(messages);

        // Act
        chatService.markAsRead("sender123", "recipient123");

        // Assert
        verify(chatMessageRepository).saveAll(anyList());
    }
}
