package com.simstruct.backend.controller;

import com.simstruct.backend.dto.ApiResponse;
import com.simstruct.backend.dto.FriendDTO;
import com.simstruct.backend.dto.InvitationDTO;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.service.FriendshipService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller for friendship operations
 */
@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FriendshipController {
    
    private final FriendshipService friendshipService;
    
    /**
     * Get all friends
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<FriendDTO>>> getFriends(
            @AuthenticationPrincipal User user) {
        List<FriendDTO> friends = friendshipService.getFriends(user.getId());
        return ResponseEntity.ok(ApiResponse.success(friends));
    }
    
    /**
     * Search users to add as friends
     */
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<FriendDTO>>> searchUsers(
            @AuthenticationPrincipal User user,
            @RequestParam String query) {
        List<FriendDTO> users = friendshipService.searchUsers(query, user.getId());
        return ResponseEntity.ok(ApiResponse.success(users));
    }
    
    /**
     * Get pending friend requests (received)
     */
    @GetMapping("/invitations")
    public ResponseEntity<ApiResponse<List<InvitationDTO>>> getPendingInvitations(
            @AuthenticationPrincipal User user) {
        List<InvitationDTO> invitations = friendshipService.getPendingInvitations(user.getId());
        return ResponseEntity.ok(ApiResponse.success(invitations));
    }
    
    /**
     * Get sent friend requests
     */
    @GetMapping("/sent")
    public ResponseEntity<ApiResponse<List<InvitationDTO>>> getSentInvitations(
            @AuthenticationPrincipal User user) {
        List<InvitationDTO> invitations = friendshipService.getSentInvitations(user.getId());
        return ResponseEntity.ok(ApiResponse.success(invitations));
    }
    
    /**
     * Send friend request
     */
    @PostMapping("/request/{receiverId}")
    public ResponseEntity<ApiResponse<InvitationDTO>> sendFriendRequest(
            @AuthenticationPrincipal User user,
            @PathVariable String receiverId) {
        InvitationDTO invitation = friendshipService.sendFriendRequest(user.getId(), receiverId);
        return ResponseEntity.ok(ApiResponse.success(invitation));
    }
    
    /**
     * Accept friend request
     */
    @PostMapping("/accept/{senderId}")
    public ResponseEntity<ApiResponse<FriendDTO>> acceptFriendRequest(
            @AuthenticationPrincipal User user,
            @PathVariable String senderId) {
        FriendDTO friend = friendshipService.acceptFriendRequest(user.getId(), senderId);
        return ResponseEntity.ok(ApiResponse.success(friend));
    }
    
    /**
     * Reject friend request
     */
    @PostMapping("/reject/{senderId}")
    public ResponseEntity<ApiResponse<String>> rejectFriendRequest(
            @AuthenticationPrincipal User user,
            @PathVariable String senderId) {
        friendshipService.rejectFriendRequest(user.getId(), senderId);
        return ResponseEntity.ok(ApiResponse.success("Friend request rejected"));
    }
    
    /**
     * Cancel sent friend request
     */
    @DeleteMapping("/cancel/{receiverId}")
    public ResponseEntity<ApiResponse<String>> cancelFriendRequest(
            @AuthenticationPrincipal User user,
            @PathVariable String receiverId) {
        friendshipService.cancelFriendRequest(user.getId(), receiverId);
        return ResponseEntity.ok(ApiResponse.success("Friend request cancelled"));
    }
    
    /**
     * Remove friend
     */
    @DeleteMapping("/{friendId}")
    public ResponseEntity<ApiResponse<String>> removeFriend(
            @AuthenticationPrincipal User user,
            @PathVariable String friendId) {
        friendshipService.removeFriend(friendId, user.getId());
        return ResponseEntity.ok(ApiResponse.success("Friend removed"));
    }
}
