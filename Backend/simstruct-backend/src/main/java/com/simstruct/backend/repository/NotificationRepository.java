package com.simstruct.backend.repository;

import com.simstruct.backend.entity.Notification;
import com.simstruct.backend.entity.NotificationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * NotificationRepository - data access for notifications
 */
@Repository
public interface NotificationRepository extends JpaRepository<Notification, String> {

    // Find all notifications for a user, ordered by creation date
    Page<Notification> findByUserIdOrderByCreatedAtDesc(String userId, Pageable pageable);
    
    // Find all notifications for a user
    List<Notification> findByUserIdOrderByCreatedAtDesc(String userId);
    
    // Find unread notifications for a user
    List<Notification> findByUserIdAndIsReadFalseOrderByCreatedAtDesc(String userId);
    
    // Count unread notifications
    long countByUserIdAndIsReadFalse(String userId);
    
    // Find by type for a user
    List<Notification> findByUserIdAndTypeOrderByCreatedAtDesc(String userId, NotificationType type);
    
    // Mark all as read for a user
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = :now WHERE n.userId = :userId AND n.isRead = false")
    int markAllAsReadByUserId(@Param("userId") String userId, @Param("now") LocalDateTime now);
    
    // Mark specific notification as read
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = :now WHERE n.id = :id AND n.userId = :userId")
    int markAsRead(@Param("id") String id, @Param("userId") String userId, @Param("now") LocalDateTime now);
    
    // Delete old notifications (older than X days)
    @Modifying
    @Query("DELETE FROM Notification n WHERE n.createdAt < :cutoff")
    int deleteOlderThan(@Param("cutoff") LocalDateTime cutoff);
    
    // Delete all notifications for a user
    void deleteByUserId(String userId);
}
