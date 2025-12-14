package com.simstruct.backend.repository;

import com.simstruct.backend.entity.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, String> {

    // Find messages between two users
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.sender.id = :userId1 AND m.recipient.id = :userId2) OR " +
           "(m.sender.id = :userId2 AND m.recipient.id = :userId1) " +
           "ORDER BY m.sentAt ASC")
    List<ChatMessage> findConversation(@Param("userId1") String userId1, @Param("userId2") String userId2);

    // Find unread messages for a user
    @Query("SELECT m FROM ChatMessage m WHERE m.recipient.id = :userId AND m.isRead = false ORDER BY m.sentAt DESC")
    List<ChatMessage> findUnreadMessages(@Param("userId") String userId);

    // Count unread messages from a specific sender
    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.recipient.id = :userId AND m.sender.id = :senderId AND m.isRead = false")
    long countUnreadFromSender(@Param("userId") String userId, @Param("senderId") String senderId);

    // Count total unread messages for a user
    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.recipient.id = :userId AND m.isRead = false")
    long countUnreadMessages(@Param("userId") String userId);

    // Get conversation partners (users who have messaged with this user)
    @Query("SELECT DISTINCT CASE WHEN m.sender.id = :userId THEN m.recipient.id ELSE m.sender.id END " +
           "FROM ChatMessage m WHERE m.sender.id = :userId OR m.recipient.id = :userId")
    List<String> findConversationPartnerIds(@Param("userId") String userId);

    // Get latest message with each conversation partner
    @Query("SELECT m FROM ChatMessage m WHERE m.id IN " +
           "(SELECT MAX(m2.id) FROM ChatMessage m2 WHERE m2.sender.id = :userId OR m2.recipient.id = :userId " +
           "GROUP BY CASE WHEN m2.sender.id = :userId THEN m2.recipient.id ELSE m2.sender.id END) " +
           "ORDER BY m.sentAt DESC")
    List<ChatMessage> findLatestMessagesPerConversation(@Param("userId") String userId);
}
