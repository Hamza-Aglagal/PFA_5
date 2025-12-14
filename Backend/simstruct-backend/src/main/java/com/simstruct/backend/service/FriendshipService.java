package com.simstruct.backend.service;

import com.simstruct.backend.dto.FriendDTO;
import com.simstruct.backend.dto.InvitationDTO;
import com.simstruct.backend.entity.Friendship;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.FriendshipRepository;
import com.simstruct.backend.repository.SharedSimulationRepository;
import com.simstruct.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FriendshipService {

    private final FriendshipRepository friendshipRepository;
    private final UserRepository userRepository;
    private final SharedSimulationRepository sharedSimulationRepository;
    private final NotificationService notificationService;

    /**
     * Get all friends for a user
     */
    public List<FriendDTO> getFriends(String userId) {
        System.out.println("FriendshipService: Getting friends for user " + userId);
        List<Friendship> friendships = friendshipRepository.findAcceptedFriendships(userId);
        
        return friendships.stream().map(f -> {
            User friend = f.getUser().getId().equals(userId) ? f.getFriend() : f.getUser();
            int sharedCount = (int) (sharedSimulationRepository.countBySharedById(friend.getId()) +
                                     sharedSimulationRepository.countBySharedWithId(friend.getId()));
            
            return FriendDTO.builder()
                    .id(friend.getId())
                    .friendshipId(f.getId())
                    .name(friend.getName())
                    .email(friend.getEmail())
                    .avatarUrl(friend.getAvatarUrl())
                    .company(friend.getCompany())
                    .status(f.getStatus().name())
                    .connectedAt(f.getCreatedAt())
                    .sharedSimulations(sharedCount)
                    .build();
        }).collect(Collectors.toList());
    }

    /**
     * Get pending friend requests received
     */
    public List<InvitationDTO> getPendingInvitations(String userId) {
        System.out.println("FriendshipService: Getting pending invitations for " + userId);
        List<Friendship> pending = friendshipRepository.findPendingRequestsReceived(userId);
        
        return pending.stream().map(f -> InvitationDTO.builder()
                .id(f.getId())
                .senderId(f.getUser().getId())
                .senderName(f.getUser().getName())
                .senderEmail(f.getUser().getEmail())
                .recipientId(f.getFriend().getId())
                .recipientName(f.getFriend().getName())
                .recipientEmail(f.getFriend().getEmail())
                .status(f.getStatus().name())
                .createdAt(f.getCreatedAt())
                .build()
        ).collect(Collectors.toList());
    }

    /**
     * Get sent friend requests
     */
    public List<InvitationDTO> getSentInvitations(String userId) {
        System.out.println("FriendshipService: Getting sent invitations for " + userId);
        List<Friendship> sent = friendshipRepository.findPendingRequestsSent(userId);
        
        return sent.stream().map(f -> InvitationDTO.builder()
                .id(f.getId())
                .senderId(f.getUser().getId())
                .senderName(f.getUser().getName())
                .senderEmail(f.getUser().getEmail())
                .recipientId(f.getFriend().getId())
                .recipientName(f.getFriend().getName())
                .recipientEmail(f.getFriend().getEmail())
                .status(f.getStatus().name())
                .createdAt(f.getCreatedAt())
                .build()
        ).collect(Collectors.toList());
    }

    /**
     * Send friend request
     */
    @Transactional
    public InvitationDTO sendFriendRequest(String userId, String friendId) {
        System.out.println("FriendshipService: Sending friend request from " + userId + " to " + friendId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        User friend = userRepository.findById(friendId)
                .orElseThrow(() -> new RuntimeException("User with ID " + friendId + " not found"));
        
        if (user.getId().equals(friend.getId())) {
            throw new RuntimeException("Cannot send friend request to yourself");
        }
        
        // Check if friendship already exists
        friendshipRepository.findByUsers(userId, friend.getId()).ifPresent(f -> {
            throw new RuntimeException("Friend request already exists with status: " + f.getStatus());
        });
        
        Friendship friendship = Friendship.builder()
                .user(user)
                .friend(friend)
                .status(Friendship.FriendshipStatus.PENDING)
                .build();
        
        friendship = friendshipRepository.save(friendship);
        System.out.println("FriendshipService: Friend request created with ID: " + friendship.getId());
        
        // Send notification to friend
        try {
            notificationService.sendFriendRequestNotification(
                friend.getId(), 
                user.getId(), 
                user.getName()
            );
        } catch (Exception e) {
            System.out.println("FriendshipService: Failed to send notification - " + e.getMessage());
        }
        
        return InvitationDTO.builder()
                .id(friendship.getId())
                .senderId(user.getId())
                .senderName(user.getName())
                .senderEmail(user.getEmail())
                .recipientId(friend.getId())
                .recipientName(friend.getName())
                .recipientEmail(friend.getEmail())
                .status(friendship.getStatus().name())
                .createdAt(friendship.getCreatedAt())
                .build();
    }

    /**
     * Accept friend request
     */
    @Transactional
    public FriendDTO acceptFriendRequest(String receiverId, String senderId) {
        System.out.println("FriendshipService: Accepting friend request from " + senderId + " to " + receiverId);
        
        // Find the pending friendship where sender is user and receiver is friend
        Friendship friendship = friendshipRepository.findByUsers(senderId, receiverId)
                .orElseThrow(() -> new RuntimeException("Friend request not found"));
        
        if (!friendship.getStatus().equals(Friendship.FriendshipStatus.PENDING)) {
            throw new RuntimeException("Friend request is not pending");
        }
        
        // Check that the current user is the receiver (friend field)
        if (!friendship.getFriend().getId().equals(receiverId)) {
            throw new RuntimeException("Not authorized to accept this request");
        }
        
        friendship.setStatus(Friendship.FriendshipStatus.ACCEPTED);
        friendshipRepository.save(friendship);
        System.out.println("FriendshipService: Friend request accepted, status: " + friendship.getStatus());
        
        User friend = friendship.getUser();
        User receiver = friendship.getFriend();
        
        // Send notification to the original sender
        try {
            notificationService.sendFriendAcceptedNotification(
                friend.getId(),
                receiver.getId(),
                receiver.getName()
            );
        } catch (Exception e) {
            System.out.println("FriendshipService: Failed to send notification - " + e.getMessage());
        }
        
        return FriendDTO.builder()
                .id(friend.getId())
                .friendshipId(friendship.getId())
                .name(friend.getName())
                .email(friend.getEmail())
                .avatarUrl(friend.getAvatarUrl())
                .company(friend.getCompany())
                .status(friendship.getStatus().name())
                .connectedAt(friendship.getUpdatedAt())
                .sharedSimulations(0)
                .build();
    }

    /**
     * Reject friend request
     */
    @Transactional
    public void rejectFriendRequest(String receiverId, String senderId) {
        System.out.println("FriendshipService: Rejecting friend request from " + senderId);
        
        Friendship friendship = friendshipRepository.findByUsers(senderId, receiverId)
                .orElseThrow(() -> new RuntimeException("Friend request not found"));
        
        if (!friendship.getFriend().getId().equals(receiverId)) {
            throw new RuntimeException("Not authorized to reject this request");
        }
        
        friendship.setStatus(Friendship.FriendshipStatus.REJECTED);
        friendshipRepository.save(friendship);
    }

    /**
     * Cancel sent friend request
     */
    @Transactional
    public void cancelFriendRequest(String senderId, String receiverId) {
        System.out.println("FriendshipService: Canceling friend request to " + receiverId);
        
        Friendship friendship = friendshipRepository.findByUsers(senderId, receiverId)
                .orElseThrow(() -> new RuntimeException("Friend request not found"));
        
        if (!friendship.getUser().getId().equals(senderId)) {
            throw new RuntimeException("Not authorized to cancel this request");
        }
        
        friendshipRepository.delete(friendship);
    }

    /**
     * Remove friend
     */
    @Transactional
    public void removeFriend(String friendshipId, String userId) {
        System.out.println("FriendshipService: Removing friend " + friendshipId);
        
        Friendship friendship = friendshipRepository.findById(friendshipId)
                .orElseThrow(() -> new RuntimeException("Friendship not found"));
        
        if (!friendship.getUser().getId().equals(userId) && !friendship.getFriend().getId().equals(userId)) {
            throw new RuntimeException("Not authorized to remove this friendship");
        }
        
        friendshipRepository.delete(friendship);
    }

    /**
     * Search users by email or name (excludes current user and existing friends)
     */
    public List<FriendDTO> searchUsers(String query, String currentUserId) {
        System.out.println("FriendshipService: Searching users with query: " + query + " for user: " + currentUserId);
        
        if (query == null || query.trim().length() < 2) {
            return new ArrayList<>();
        }
        
        List<User> users = userRepository.findByEmailContainingIgnoreCaseOrNameContainingIgnoreCase(query.trim(), query.trim());
        System.out.println("FriendshipService: Found " + users.size() + " users matching query");
        
        // Get existing friendships to exclude
        List<String> existingFriendIds = friendshipRepository.findAllByUserId(currentUserId).stream()
                .map(f -> f.getUser().getId().equals(currentUserId) ? f.getFriend().getId() : f.getUser().getId())
                .collect(Collectors.toList());
        
        return users.stream()
                .filter(u -> !u.getId().equals(currentUserId)) // Exclude self
                .filter(u -> !existingFriendIds.contains(u.getId())) // Exclude existing friends/pending
                .limit(10)
                .map(u -> {
                    System.out.println("FriendshipService: Including user in results: " + u.getEmail());
                    return FriendDTO.builder()
                            .id(u.getId())
                            .name(u.getName())
                            .email(u.getEmail())
                            .avatarUrl(u.getAvatarUrl())
                            .company(u.getCompany())
                            .status("AVAILABLE")
                            .build();
                }).collect(Collectors.toList());
    }
}
