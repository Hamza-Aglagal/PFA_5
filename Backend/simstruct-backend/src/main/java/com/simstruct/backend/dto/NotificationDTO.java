package com.simstruct.backend.dto;

import com.simstruct.backend.entity.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * NotificationDTO - response for notification data
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {
    private String id;
    private NotificationType type;
    private String title;
    private String message;
    private String relatedId;
    private String relatedType;
    private String actionUrl;
    private Boolean isRead;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
}
