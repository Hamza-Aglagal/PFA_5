package com.simstruct.backend.controller;

import com.simstruct.backend.dto.ApiResponse;
import com.simstruct.backend.dto.NotificationCountDTO;
import com.simstruct.backend.dto.NotificationDTO;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * NotificationController - REST API for notifications
 */
@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
@Slf4j
public class NotificationController {

    private final NotificationService notificationService;

    /**
     * Get all notifications for the current user
     * GET /api/v1/notifications
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<NotificationDTO>>> getNotifications(
            @AuthenticationPrincipal User user) {
        log.info("Getting notifications for user: {}", user.getId());
        List<NotificationDTO> notifications = notificationService.getAllNotifications(user.getId());
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    /**
     * Get notifications with pagination
     * GET /api/v1/notifications/page?page=0&size=20
     */
    @GetMapping("/page")
    public ResponseEntity<ApiResponse<Page<NotificationDTO>>> getNotificationsPaginated(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.info("Getting paginated notifications for user: {}, page: {}, size: {}", user.getId(), page, size);
        Page<NotificationDTO> notifications = notificationService.getNotifications(user.getId(), page, size);
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    /**
     * Get unread notifications
     * GET /api/v1/notifications/unread
     */
    @GetMapping("/unread")
    public ResponseEntity<ApiResponse<List<NotificationDTO>>> getUnreadNotifications(
            @AuthenticationPrincipal User user) {
        log.info("Getting unread notifications for user: {}", user.getId());
        List<NotificationDTO> notifications = notificationService.getUnreadNotifications(user.getId());
        return ResponseEntity.ok(ApiResponse.success(notifications));
    }

    /**
     * Get unread notification count
     * GET /api/v1/notifications/count
     */
    @GetMapping("/count")
    public ResponseEntity<ApiResponse<NotificationCountDTO>> getNotificationCount(
            @AuthenticationPrincipal User user) {
        log.info("Getting notification count for user: {}", user.getId());
        NotificationCountDTO counts = notificationService.getNotificationCounts(user.getId());
        return ResponseEntity.ok(ApiResponse.success(counts));
    }

    /**
     * Mark a notification as read
     * PUT /api/v1/notifications/{id}/read
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Boolean>> markAsRead(
            @AuthenticationPrincipal User user,
            @PathVariable String id) {
        log.info("Marking notification {} as read for user: {}", id, user.getId());
        boolean success = notificationService.markAsRead(id, user.getId());
        if (success) {
            return ResponseEntity.ok(ApiResponse.success(true));
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * Mark all notifications as read
     * PUT /api/v1/notifications/read-all
     */
    @PutMapping("/read-all")
    public ResponseEntity<ApiResponse<Integer>> markAllAsRead(
            @AuthenticationPrincipal User user) {
        log.info("Marking all notifications as read for user: {}", user.getId());
        int count = notificationService.markAllAsRead(user.getId());
        return ResponseEntity.ok(ApiResponse.success(count));
    }

    /**
     * Delete a notification
     * DELETE /api/v1/notifications/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Boolean>> deleteNotification(
            @AuthenticationPrincipal User user,
            @PathVariable String id) {
        log.info("Deleting notification {} for user: {}", id, user.getId());
        boolean success = notificationService.deleteNotification(id, user.getId());
        if (success) {
            return ResponseEntity.ok(ApiResponse.success(true));
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * Delete all notifications
     * DELETE /api/v1/notifications
     */
    @DeleteMapping
    public ResponseEntity<ApiResponse<Boolean>> deleteAllNotifications(
            @AuthenticationPrincipal User user) {
        log.info("Deleting all notifications for user: {}", user.getId());
        notificationService.deleteAllNotifications(user.getId());
        return ResponseEntity.ok(ApiResponse.success(true));
    }
}
