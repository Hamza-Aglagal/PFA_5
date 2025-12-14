package com.simstruct.backend.controller;

import com.simstruct.backend.dto.ApiResponse;
import com.simstruct.backend.dto.ChatMessageDTO;
import com.simstruct.backend.dto.ConversationDTO;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST Controller for chat operations
 */
@RestController
@RequestMapping("/api/v1/chat")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatController {
    
    private final ChatService chatService;
    
    /**
     * Get all conversations
     */
    @GetMapping("/conversations")
    public ResponseEntity<ApiResponse<List<ConversationDTO>>> getConversations(
            @AuthenticationPrincipal User user) {
        List<ConversationDTO> conversations = chatService.getConversations(user.getId());
        return ResponseEntity.ok(ApiResponse.success(conversations));
    }
    
    /**
     * Get conversation with a specific friend
     */
    @GetMapping("/conversation/{friendId}")
    public ResponseEntity<ApiResponse<List<ChatMessageDTO>>> getConversation(
            @AuthenticationPrincipal User user,
            @PathVariable String friendId,
            @RequestParam(defaultValue = "50") int limit) {
        List<ChatMessageDTO> messages = chatService.getConversation(user.getId(), friendId);
        return ResponseEntity.ok(ApiResponse.success(messages));
    }
    
    /**
     * Send a message
     */
    @PostMapping("/send")
    public ResponseEntity<ApiResponse<ChatMessageDTO>> sendMessage(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, String> request) {
        String receiverId = request.get("receiverId");
        String content = request.get("content");
        ChatMessageDTO message = chatService.sendMessage(user.getId(), receiverId, content);
        return ResponseEntity.ok(ApiResponse.success(message));
    }
    
    /**
     * Mark messages as read
     */
    @PostMapping("/read/{senderId}")
    public ResponseEntity<ApiResponse<String>> markAsRead(
            @AuthenticationPrincipal User user,
            @PathVariable String senderId) {
        chatService.markAsRead(user.getId(), senderId);
        return ResponseEntity.ok(ApiResponse.success("Messages marked as read"));
    }
    
    /**
     * Get unread message count
     */
    @GetMapping("/unread")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(
            @AuthenticationPrincipal User user) {
        long count = chatService.getUnreadCount(user.getId());
        return ResponseEntity.ok(ApiResponse.success(count));
    }
}
