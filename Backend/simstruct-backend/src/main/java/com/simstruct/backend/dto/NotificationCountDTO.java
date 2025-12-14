package com.simstruct.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * NotificationCountDTO - response for unread count
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationCountDTO {
    private long unreadCount;
    private long totalCount;
}
