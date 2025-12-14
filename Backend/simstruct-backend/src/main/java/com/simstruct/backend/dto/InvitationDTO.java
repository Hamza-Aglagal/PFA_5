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
public class InvitationDTO {
    private String id;
    private String senderId;
    private String senderName;
    private String senderEmail;
    private String recipientId;
    private String recipientName;
    private String recipientEmail;
    private String status;
    private LocalDateTime createdAt;
}
