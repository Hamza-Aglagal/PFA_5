package com.simstruct.backend.service;

import com.simstruct.backend.dto.FriendDTO;
import com.simstruct.backend.dto.InvitationDTO;
import com.simstruct.backend.entity.Friendship;
import com.simstruct.backend.entity.User;
import com.simstruct.backend.repository.FriendshipRepository;
import com.simstruct.backend.repository.SharedSimulationRepository;
import com.simstruct.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests SIMPLES pour FriendshipService  
 * Code junior - seulement les tests basiques
 */
@ExtendWith(MockitoExtension.class)
public class FriendshipServiceTest {

    @Mock
    private FriendshipRepository friendshipRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SharedSimulationRepository sharedSimulationRepository;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private FriendshipService friendshipService;

    private User user1;
    private User user2;
    private Friendship friendship;

    @BeforeEach
    void setUp() {
        user1 = new User();
        user1.setId("user123");
        user1.setName("User One");
        user1.setEmail("user1@example.com");

        user2 = new User();
        user2.setId("user456");
        user2.setName("User Two");
        user2.setEmail("user2@example.com");

        friendship = new Friendship();
        friendship.setId("friendship123");
        friendship.setUser(user1);
        friendship.setFriend(user2);
        friendship.setStatus(Friendship.FriendshipStatus.ACCEPTED);
        friendship.setCreatedAt(LocalDateTime.now());
    }

    /**
     * TEST 1: Récupérer la liste des amis
     */
    @Test
    void testGetFriends_Success() {
        when(friendshipRepository.findAcceptedFriendships("user123")).thenReturn(Arrays.asList(friendship));
        when(sharedSimulationRepository.countBySharedById(anyString())).thenReturn(2L);
        when(sharedSimulationRepository.countBySharedWithId(anyString())).thenReturn(3L);

        List<FriendDTO> friends = friendshipService.getFriends("user123");

        assertNotNull(friends);
        assertEquals(1, friends.size());
        verify(friendshipRepository).findAcceptedFriendships("user123");
    }

    /**
     * TEST 2: Liste vide si aucun ami
     */
    @Test
    void testGetFriends_Empty() {
        when(friendshipRepository.findAcceptedFriendships("user-alone")).thenReturn(Arrays.asList());

        List<FriendDTO> friends = friendshipService.getFriends("user-alone");

        assertTrue(friends.isEmpty());
    }

    /**
     * TEST 3: Récupérer invitations reçues
     */
    @Test
    void testGetPendingInvitations() {
        Friendship pending = new Friendship();
        pending.setId("inv1");
        pending.setUser(user2);
        pending.setFriend(user1);
        pending.setStatus(Friendship.FriendshipStatus.PENDING);
        pending.setCreatedAt(LocalDateTime.now());

        when(friendshipRepository.findPendingRequestsReceived("user123")).thenReturn(Arrays.asList(pending));

        List<InvitationDTO> invitations = friendshipService.getPendingInvitations("user123");

        assertNotNull(invitations);
        assertEquals(1, invitations.size());
    }

    /**
     * TEST 4: Récupérer invitations envoyées
     */
    @Test
    void testGetSentInvitations() {
        Friendship sent = new Friendship();
        sent.setId("inv2");
        sent.setUser(user1);
        sent.setFriend(user2);
        sent.setStatus(Friendship.FriendshipStatus.PENDING);
        sent.setCreatedAt(LocalDateTime.now());

        when(friendshipRepository.findPendingRequestsSent("user123")).thenReturn(Arrays.asList(sent));

        List<InvitationDTO> invitations = friendshipService.getSentInvitations("user123");

        assertNotNull(invitations);
        assertEquals(1, invitations.size());
    }

    /**
     * TEST 5: Envoyer demande d'ami
     */
    @Test
    void testSendFriendRequest_Success() {
        when(userRepository.findById("user123")).thenReturn(Optional.of(user1));
        when(userRepository.findById("user456")).thenReturn(Optional.of(user2));
        when(friendshipRepository.save(any(Friendship.class))).thenReturn(friendship);

        InvitationDTO result = friendshipService.sendFriendRequest("user123", "user456");

        assertNotNull(result);
        verify(friendshipRepository).save(any(Friendship.class));
    }

    /**
     * TEST 6: Ami inexistant
     */
    @Test
    void testSendFriendRequest_NotFound() {
        when(userRepository.findById("user123")).thenReturn(Optional.of(user1));
        when(userRepository.findById("user-bad")).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            friendshipService.sendFriendRequest("user123", "user-bad");
        });
    }

    /**
     * TEST 7: Supprimer un ami
     */
    @Test
    void testRemoveFriend_Success() {
        when(friendshipRepository.findById("friendship123")).thenReturn(Optional.of(friendship));

        friendshipService.removeFriend("friendship123", "user123");

        verify(friendshipRepository).delete(friendship);
    }

    /**
     * TEST 8: Supprimer ami inexistant
     */
    @Test
    void testRemoveFriend_NotFound() {
        when(friendshipRepository.findById("bad-id")).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            friendshipService.removeFriend("bad-id", "user123");
        });
    }
}
