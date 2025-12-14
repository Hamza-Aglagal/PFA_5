package com.simstruct.backend.service;

import com.simstruct.backend.dto.ChatMessageDTO;
import com.simstruct.backend.dto.ConversationDTO;
import com.simstruct.backend.entity.ChatMessage;
import com.simstruct.backend.entity.Simulation;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.ChatMessageRepository;
import com.simstruct.backend.repository.SimulationRepository;
import com.simstruct.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;
    private final SimulationRepository simulationRepository;
    private final NotificationService notificationService;

    /**
     * Send a message (without simulation)
     */
    @Transactional
    public ChatMessageDTO sendMessage(String senderId, String recipientId, String content) {
        return sendMessage(senderId, recipientId, content, null);
    }

    /**
     * Send a message (with optional simulation)
     */
    @Transactional
    public ChatMessageDTO sendMessage(String senderId, String recipientId, String content, String simulationId) {
        System.out.println("ChatService: Sending message from " + senderId + " to " + recipientId);
        
        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new RuntimeException("Sender not found"));
        
        User recipient = userRepository.findById(recipientId)
                .orElseThrow(() -> new RuntimeException("Recipient not found"));
        
        Simulation simulation = null;
        if (simulationId != null && !simulationId.isEmpty()) {
            simulation = simulationRepository.findById(simulationId).orElse(null);
        }
        
        ChatMessage message = ChatMessage.builder()
                .sender(sender)
                .recipient(recipient)
                .content(content)
                .isRead(false)
                .relatedSimulation(simulation)
                .build();
        
        message = chatMessageRepository.save(message);
        
        // Send notification to recipient
        try {
            notificationService.sendNewMessageNotification(
                recipient.getId(),
                sender.getId(),
                sender.getName(),
                content.length() > 50 ? content.substring(0, 50) + "..." : content
            );
        } catch (Exception e) {
            System.out.println("ChatService: Failed to send notification - " + e.getMessage());
        }
        
        return mapToDTO(message);
    }

    /**
     * Get conversation between two users
     */
    public List<ChatMessageDTO> getConversation(String userId, String partnerId) {
        System.out.println("ChatService: Getting conversation between " + userId + " and " + partnerId);
        
        return chatMessageRepository.findConversation(userId, partnerId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get all conversations for a user
     */
    public List<ConversationDTO> getConversations(String userId) {
        System.out.println("ChatService: Getting conversations for " + userId);
        
        List<ChatMessage> latestMessages = chatMessageRepository.findLatestMessagesPerConversation(userId);
        
        return latestMessages.stream().map(msg -> {
            User partner = msg.getSender().getId().equals(userId) ? msg.getRecipient() : msg.getSender();
            long unread = chatMessageRepository.countUnreadFromSender(userId, partner.getId());
            
            return ConversationDTO.builder()
                    .id(msg.getId())
                    .partnerId(partner.getId())
                    .partnerName(partner.getName())
                    .partnerEmail(partner.getEmail())
                    .partnerAvatar(partner.getAvatarUrl())
                    .lastMessage(msg.getContent())
                    .lastMessageAt(msg.getSentAt())
                    .unreadCount((int) unread)
                    .build();
        }).collect(Collectors.toList());
    }

    /**
     * Mark messages as read
     */
    @Transactional
    public void markAsRead(String userId, String partnerId) {
        System.out.println("ChatService: Marking messages as read from " + partnerId);
        
        List<ChatMessage> unread = chatMessageRepository.findConversation(userId, partnerId)
                .stream()
                .filter(m -> m.getRecipient().getId().equals(userId) && !m.getIsRead())
                .collect(Collectors.toList());
        
        unread.forEach(m -> m.setIsRead(true));
        chatMessageRepository.saveAll(unread);
    }

    /**
     * Get unread count
     */
    public long getUnreadCount(String userId) {
        return chatMessageRepository.countUnreadMessages(userId);
    }

    private ChatMessageDTO mapToDTO(ChatMessage message) {
        return ChatMessageDTO.builder()
                .id(message.getId())
                .senderId(message.getSender().getId())
                .senderName(message.getSender().getName())
                .recipientId(message.getRecipient().getId())
                .recipientName(message.getRecipient().getName())
                .content(message.getContent())
                .isRead(message.getIsRead())
                .relatedSimulationId(message.getRelatedSimulation() != null ? message.getRelatedSimulation().getId() : null)
                .relatedSimulationName(message.getRelatedSimulation() != null ? message.getRelatedSimulation().getName() : null)
                .sentAt(message.getSentAt())
                .build();
    }
}
