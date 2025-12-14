package com.simstruct.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConversationDTO {
    private String id;
    private String partnerId;
    private String partnerName;
    private String partnerEmail;
    private String partnerAvatar;
    private String lastMessage;
    private LocalDateTime lastMessageAt;
    private int unreadCount;
}
