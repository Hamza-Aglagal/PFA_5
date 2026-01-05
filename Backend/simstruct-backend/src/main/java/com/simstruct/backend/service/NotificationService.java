package com.simstruct.backend.service;

import com.simstruct.backend.dto.NotificationCountDTO;
import com.simstruct.backend.dto.NotificationDTO;
import com.simstruct.backend.entity.Notification;
import com.simstruct.backend.entity.NotificationType;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * NotificationService - business logic for notifications
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final SimpMessagingTemplate messagingTemplate;

    /**
     * Create and send a notification
     */
    @Transactional
    public NotificationDTO createNotification(String userId, NotificationType type, String title, String message) {
        return createNotification(userId, type, title, message, null, null, null);
    }

    /**
     * Create and send a notification with related entity
     */
    @Transactional
    public NotificationDTO createNotification(String userId, NotificationType type, String title, String message,
                                              String relatedId, String relatedType, String actionUrl) {
        log.info("Creating notification for user {}: {} - {}", userId, type, title);
        
        Notification notification = Notification.builder()
                .userId(userId)
                .type(type)
                .title(title)
                .message(message)
                .relatedId(relatedId)
                .relatedType(relatedType)
                .actionUrl(actionUrl)
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();
        
        notification = notificationRepository.save(notification);
        NotificationDTO dto = toDTO(notification);
        
        // Send via WebSocket to the user
        sendWebSocketNotification(userId, dto);
        
        return dto;
    }

    /**
     * Send notification via WebSocket
     */
    private void sendWebSocketNotification(String userId, NotificationDTO notification) {
        try {
            String destination = "/user/" + userId + "/notifications";
            messagingTemplate.convertAndSend(destination, notification);
            log.debug("WebSocket notification sent to user {}", userId);
        } catch (Exception e) {
            log.warn("Failed to send WebSocket notification to user {}: {}", userId, e.getMessage());
        }
    }

    /**
     * Get all notifications for a user (paginated)
     */
    public Page<NotificationDTO> getNotifications(String userId, int page, int size) {
        PageRequest pageable = PageRequest.of(page, size);
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable)
                .map(this::toDTO);
    }

    /**
     * Get all notifications for a user
     */
    public List<NotificationDTO> getAllNotifications(String userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get unread notifications for a user
     */
    public List<NotificationDTO> getUnreadNotifications(String userId) {
        return notificationRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(userId)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get notification counts
     */
    public NotificationCountDTO getNotificationCounts(String userId) {
        long unreadCount = notificationRepository.countByUserIdAndIsReadFalse(userId);
        long totalCount = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId).size();
        
        return NotificationCountDTO.builder()
                .unreadCount(unreadCount)
                .totalCount(totalCount)
                .build();
    }

    /**
     * Mark a notification as read
     */
    @Transactional
    public boolean markAsRead(String notificationId, String userId) {
        int updated = notificationRepository.markAsRead(notificationId, userId, LocalDateTime.now());
        if (updated > 0) {
            // Send updated count via WebSocket
            sendUnreadCountUpdate(userId);
            return true;
        }
        return false;
    }

    /**
     * Mark all notifications as read
     */
    @Transactional
    public int markAllAsRead(String userId) {
        int updated = notificationRepository.markAllAsReadByUserId(userId, LocalDateTime.now());
        if (updated > 0) {
            // Send updated count via WebSocket
            sendUnreadCountUpdate(userId);
        }
        return updated;
    }

    /**
     * Delete a notification
     */
    @Transactional
    public boolean deleteNotification(String notificationId, String userId) {
        Optional<Notification> notification = notificationRepository.findById(notificationId);
        if (notification.isPresent() && notification.get().getUserId().equals(userId)) {
            notificationRepository.delete(notification.get());
            return true;
        }
        return false;
    }

    /**
     * Delete all notifications for a user
     */
    @Transactional
    public void deleteAllNotifications(String userId) {
        notificationRepository.deleteByUserId(userId);
    }

    /**
     * Send unread count update via WebSocket
     */
    private void sendUnreadCountUpdate(String userId) {
        try {
            NotificationCountDTO counts = getNotificationCounts(userId);
            String destination = "/user/" + userId + "/notifications/count";
            messagingTemplate.convertAndSend(destination, counts);
            log.debug("Unread count update sent to user {}", userId);
        } catch (Exception e) {
            log.warn("Failed to send unread count update to user {}: {}", userId, e.getMessage());
        }
    }

    /**
     * Convert entity to DTO
     */
    private NotificationDTO toDTO(Notification notification) {
        return NotificationDTO.builder()
                .id(notification.getId())
                .type(notification.getType())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .relatedId(notification.getRelatedId())
                .relatedType(notification.getRelatedType())
                .actionUrl(notification.getActionUrl())
                .isRead(notification.getIsRead())
                .createdAt(notification.getCreatedAt())
                .readAt(notification.getReadAt())
                .build();
    }

    // =====================================================
    // NOTIFICATION TRIGGER METHODS
    // =====================================================

    /**
     * Send welcome notification to new user
     */
    public void sendWelcomeNotification(String userId, String userName) {
        createNotification(userId, NotificationType.WELCOME,
                "Welcome to SimStruct! 🎉",
                "Hi " + userName + "! Your account has been created successfully. Start exploring structural simulations now!",
                null, null, "/dashboard");
    }

    /**
     * Send simulation complete notification
     */
    public void sendSimulationCompleteNotification(String userId, String simulationId, String simulationName, double safetyFactor) {
        String status = safetyFactor >= 1.5 ? "✅ Safe" : safetyFactor >= 1.0 ? "⚠️ Needs Review" : "❌ Critical";
        createNotification(userId, NotificationType.SIMULATION_COMPLETE,
                "Simulation Complete",
                "Your simulation \"" + simulationName + "\" has finished. Safety Factor: " + String.format("%.2f", safetyFactor) + " " + status,
                simulationId, "simulation", "/results?id=" + simulationId);
    }

    /**
     * Send simulation complete notification (without safety factor)
     */
    public void sendSimulationCompleteNotification(String userId, String simulationId, String simulationName) {
        createNotification(userId, NotificationType.SIMULATION_COMPLETE,
                "Simulation Complete",
                "Your simulation \"" + simulationName + "\" has finished successfully.",
                simulationId, "simulation", "/results?id=" + simulationId);
    }

    /**
     * Send simulation failed notification
     */
    public void sendSimulationFailedNotification(String userId, String simulationId, String simulationName) {
        createNotification(userId, NotificationType.SIMULATION_FAILED,
                "Simulation Failed",
                "Your simulation \"" + simulationName + "\" encountered an error. Please check the parameters and try again.",
                simulationId, "simulation", "/simulations");
    }

    /**
     * Send friend request notification
     */
    public void sendFriendRequestNotification(String toUserId, String fromUserId, String fromUserName) {
        createNotification(toUserId, NotificationType.FRIEND_REQUEST,
                "New Friend Request",
                fromUserName + " wants to connect with you",
                fromUserId, "user", "/community?tab=invitations");
    }

    /**
     * Send friend request accepted notification
     */
    public void sendFriendAcceptedNotification(String toUserId, String friendId, String friendName) {
        createNotification(toUserId, NotificationType.FRIEND_ACCEPTED,
                "Friend Request Accepted",
                friendName + " accepted your friend request. You can now chat and share simulations!",
                friendId, "user", "/community?tab=friends");
    }

    /**
     * Send friend request rejected notification
     */
    public void sendFriendRejectedNotification(String toUserId, String friendName) {
        createNotification(toUserId, NotificationType.FRIEND_REJECTED,
                "Friend Request Declined",
                friendName + " declined your friend request.",
                null, null, "/community");
    }

    /**
     * Send new message notification
     */
    public void sendNewMessageNotification(String toUserId, String fromUserId, String fromUserName, String messagePreview) {
        String preview = messagePreview.length() > 50 ? messagePreview.substring(0, 50) + "..." : messagePreview;
        createNotification(toUserId, NotificationType.NEW_MESSAGE,
                "New Message from " + fromUserName,
                preview,
                fromUserId, "chat", "/chat?userId=" + fromUserId + "&userName=" + fromUserName);
    }

    /**
     * Send simulation shared notification
     */
    public void sendSimulationSharedNotification(String toUserId, String fromUserId, String fromUserName, String simulationId, String simulationName) {
        createNotification(toUserId, NotificationType.SIMULATION_RECEIVED,
                "Simulation Shared with You",
                fromUserName + " shared \"" + simulationName + "\" with you",
                simulationId, "simulation", "/community?tab=shared");
    }

    /**
     * Send system notification
     */
    public void sendSystemNotification(String userId, String title, String message) {
        createNotification(userId, NotificationType.SYSTEM, title, message);
    }
}
