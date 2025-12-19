package com.simstruct.backend.service;

import com.simstruct.backend.dto.NotificationDTO;
import com.simstruct.backend.entity.Notification;
import com.simstruct.backend.entity.NotificationType;
import com.simstruct.backend.repository.NotificationRepository;
import com.simstruct.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests SIMPLES pour NotificationService
 * Code junior - tests basiques seulement
 */
@ExtendWith(MockitoExtension.class)
public class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SimpMessagingTemplate messagingTemplate;

    @InjectMocks
    private NotificationService notificationService;

    private Notification testNotification;

    @BeforeEach
    void setUp() {
        testNotification = Notification.builder()
                .id("notif123")
                .userId("user123")
                .type(NotificationType.WELCOME)
                .title("Bienvenue !")
                .message("Bienvenue sur SimStruct")
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();
    }

    /**
     * TEST 1: Créer une notification simple
     */
    @Test
    void testCreateNotification_Success() {
        when(notificationRepository.save(any(Notification.class))).thenReturn(testNotification);

        NotificationDTO result = notificationService.createNotification(
                "user123",
                NotificationType.WELCOME,
                "Bienvenue !",
                "Bienvenue sur SimStruct"
        );

        assertNotNull(result);
        assertEquals("Bienvenue !", result.getTitle());
        verify(notificationRepository).save(any(Notification.class));
    }

    /**
     * TEST 2: Créer notification avec lien
     */
    @Test
    void testCreateNotification_WithUrl() {
        Notification notifWithUrl = Notification.builder()
                .id("notif456")
                .userId("user123")
                .type(NotificationType.SIMULATION_COMPLETE)
                .title("Simulation terminée")
                .message("Votre simulation est prête")
                .actionUrl("/simulations/sim123")
                .isRead(false)
                .createdAt(LocalDateTime.now())
                .build();

        when(notificationRepository.save(any(Notification.class))).thenReturn(notifWithUrl);

        NotificationDTO result = notificationService.createNotification(
                "user123",
                NotificationType.SIMULATION_COMPLETE,
                "Simulation terminée",
                "Votre simulation est prête",
                "sim123",
                "SIMULATION",
                "/simulations/sim123"
        );

        assertNotNull(result);
        assertEquals("/simulations/sim123", result.getActionUrl());
    }

    /**
     * TEST 3: Récupérer notifications paginées
     */
    @Test
    void testGetNotifications_Paginated() {
        Page<Notification> page = new PageImpl<>(Arrays.asList(testNotification));
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(eq("user123"), any(PageRequest.class)))
                .thenReturn(page);

        Page<NotificationDTO> result = notificationService.getNotifications("user123", 0, 10);

        assertNotNull(result);
        assertEquals(1, result.getTotalElements());
    }

    /**
     * TEST 4: Récupérer toutes les notifications
     */
    @Test
    void testGetAllNotifications() {
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc("user123"))
                .thenReturn(Arrays.asList(testNotification));

        List<NotificationDTO> result = notificationService.getAllNotifications("user123");

        assertNotNull(result);
        assertEquals(1, result.size());
    }

    /**
     * TEST 6: Supprimer notification
     */
    @Test
    void testDeleteNotification() {
        when(notificationRepository.findById("notif123")).thenReturn(Optional.of(testNotification));

        boolean result = notificationService.deleteNotification("notif123", "user123");

        assertTrue(result);
        verify(notificationRepository).delete(testNotification);
    }

    /**
     * TEST 7: Envoyer notification de bienvenue
     */
    @Test
    void testSendWelcomeNotification() {
        when(notificationRepository.save(any(Notification.class))).thenReturn(testNotification);

        notificationService.sendWelcomeNotification("user123", "John Doe");

        verify(notificationRepository).save(any(Notification.class));
    }

    /**
     * TEST 8: Liste vide
     */
    @Test
    void testGetNotifications_Empty() {
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc("user-empty"))
                .thenReturn(Arrays.asList());

        List<NotificationDTO> result = notificationService.getAllNotifications("user-empty");

        assertTrue(result.isEmpty());
    }
}
