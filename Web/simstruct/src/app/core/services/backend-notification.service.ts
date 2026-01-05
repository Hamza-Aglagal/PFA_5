import { Injectable, signal, computed, effect, inject, OnDestroy } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { environment } from '../config/environment';
import { AuthService } from './auth.service';
import { NotificationService } from './notification.service';

// Notification types enum matching backend
export type NotificationType =
  | 'SIMULATION_COMPLETE'
  | 'SIMULATION_FAILED'
  | 'SIMULATION_SHARED'
  | 'FRIEND_REQUEST'
  | 'FRIEND_ACCEPTED'
  | 'FRIEND_REJECTED'
  | 'NEW_MESSAGE'
  | 'SIMULATION_RECEIVED'
  | 'SYSTEM'
  | 'WELCOME'
  | 'ACCOUNT_UPDATE';

// Backend notification interface
export interface BackendNotification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  relatedId: string | null;
  relatedType: string | null;
  actionUrl: string | null;
  isRead: boolean;
  createdAt: string;
  readAt: string | null;
}

// Notification count response
export interface NotificationCount {
  unreadCount: number;
  totalCount: number;
}

// API response wrapper
interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  timestamp: string;
}

// Page response
interface PageResponse<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

@Injectable({
  providedIn: 'root'
})
export class BackendNotificationService implements OnDestroy {
  private http = inject(HttpClient);
  private router = inject(Router);
  private authService = inject(AuthService);
  private toastService = inject(NotificationService);

  private readonly API_URL = `${environment.apiUrl}/notifications`;
  private readonly WS_URL = environment.apiUrl.replace('/api/v1', '').replace('http', 'ws') + '/ws';

  // State signals
  private _notifications = signal<BackendNotification[]>([]);
  private _unreadCount = signal<number>(0);
  private _totalCount = signal<number>(0);
  private _loading = signal<boolean>(false);
  private _connected = signal<boolean>(false);

  // Public computed signals
  notifications = this._notifications.asReadonly();
  unreadNotifications = computed(() => this._notifications().filter(n => !n.isRead));
  unreadCount = this._unreadCount.asReadonly();
  totalCount = this._totalCount.asReadonly();
  loading = this._loading.asReadonly();
  connected = this._connected.asReadonly();

  // WebSocket related
  private stompClient: any = null;
  private subscriptions: any[] = [];
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectInterval = 5000;

  constructor() {
    console.log('BackendNotificationService: Initialized');

    // Watch auth state changes
    effect(() => {
      const user = this.authService.user();
      if (user) {
        console.log('BackendNotificationService: User authenticated, connecting...');
        this.loadNotifications();
        this.loadNotificationCount();
        this.connectWebSocket();
      } else {
        console.log('BackendNotificationService: User logged out, disconnecting...');
        this.disconnectWebSocket();
        this._notifications.set([]);
        this._unreadCount.set(0);
        this._totalCount.set(0);
      }
    });
  }

  ngOnDestroy(): void {
    this.disconnectWebSocket();
  }

  // =====================================================
  // REST API Methods
  // =====================================================

  /**
   * Load all notifications
   */
  loadNotifications(): void {
    this._loading.set(true);

    this.http.get<ApiResponse<BackendNotification[]>>(this.API_URL).subscribe({
      next: (response) => {
        if (response.success) {
          this._notifications.set(response.data);
          console.log('BackendNotificationService: Loaded', response.data.length, 'notifications');
        }
        this._loading.set(false);
      },
      error: (err) => {
        console.error('BackendNotificationService: Error loading notifications', err);
        this._loading.set(false);
      }
    });
  }

  /**
   * Load paginated notifications
   */
  loadNotificationsPaged(page: number = 0, size: number = 20): void {
    this._loading.set(true);

    this.http.get<ApiResponse<PageResponse<BackendNotification>>>(`${this.API_URL}/page?page=${page}&size=${size}`).subscribe({
      next: (response) => {
        if (response.success) {
          this._notifications.set(response.data.content);
          this._totalCount.set(response.data.totalElements);
          console.log('BackendNotificationService: Loaded page', page, 'with', response.data.content.length, 'notifications');
        }
        this._loading.set(false);
      },
      error: (err) => {
        console.error('BackendNotificationService: Error loading paged notifications', err);
        this._loading.set(false);
      }
    });
  }

  /**
   * Load notification counts
   */
  loadNotificationCount(): void {
    this.http.get<ApiResponse<NotificationCount>>(`${this.API_URL}/count`).subscribe({
      next: (response) => {
        if (response.success) {
          this._unreadCount.set(response.data.unreadCount);
          this._totalCount.set(response.data.totalCount);
          console.log('BackendNotificationService: Unread count:', response.data.unreadCount);
        }
      },
      error: (err) => {
        console.error('BackendNotificationService: Error loading count', err);
      }
    });
  }

  /**
   * Load only unread notifications
   */
  loadUnreadNotifications(): void {
    this._loading.set(true);

    this.http.get<ApiResponse<BackendNotification[]>>(`${this.API_URL}/unread`).subscribe({
      next: (response) => {
        if (response.success) {
          // Merge with existing, keeping read notifications
          const readNotifications = this._notifications().filter(n => n.isRead);
          this._notifications.set([...response.data, ...readNotifications]);
          this._unreadCount.set(response.data.length);
        }
        this._loading.set(false);
      },
      error: (err) => {
        console.error('BackendNotificationService: Error loading unread', err);
        this._loading.set(false);
      }
    });
  }

  /**
   * Mark a notification as read
   */
  markAsRead(notificationId: string): void {
    this.http.put<ApiResponse<BackendNotification>>(`${this.API_URL}/${notificationId}/read`, {}).subscribe({
      next: (response) => {
        if (response.success) {
          // Update local state
          this._notifications.update(notifications =>
            notifications.map(n => n.id === notificationId ? { ...n, isRead: true } : n)
          );
          this._unreadCount.update(count => Math.max(0, count - 1));
          console.log('BackendNotificationService: Marked as read:', notificationId);
        }
      },
      error: (err) => {
        console.error('BackendNotificationService: Error marking as read', err);
      }
    });
  }

  /**
   * Mark all notifications as read
   */
  markAllAsRead(): void {
    this.http.put<ApiResponse<void>>(`${this.API_URL}/read-all`, {}).subscribe({
      next: (response) => {
        if (response.success) {
          // Update local state
          this._notifications.update(notifications =>
            notifications.map(n => ({ ...n, isRead: true }))
          );
          this._unreadCount.set(0);
          console.log('BackendNotificationService: Marked all as read');
        }
      },
      error: (err) => {
        console.error('BackendNotificationService: Error marking all as read', err);
      }
    });
  }

  /**
   * Delete a notification
   */
  deleteNotification(notificationId: string): void {
    this.http.delete<ApiResponse<void>>(`${this.API_URL}/${notificationId}`).subscribe({
      next: (response) => {
        if (response.success) {
          const notification = this._notifications().find(n => n.id === notificationId);
          this._notifications.update(notifications =>
            notifications.filter(n => n.id !== notificationId)
          );
          if (notification && !notification.isRead) {
            this._unreadCount.update(count => Math.max(0, count - 1));
          }
          this._totalCount.update(count => Math.max(0, count - 1));
          console.log('BackendNotificationService: Deleted notification:', notificationId);
        }
      },
      error: (err) => {
        console.error('BackendNotificationService: Error deleting notification', err);
      }
    });
  }

  /**
   * Delete all notifications
   */
  deleteAllNotifications(): void {
    this.http.delete<ApiResponse<void>>(this.API_URL).subscribe({
      next: (response) => {
        if (response.success) {
          this._notifications.set([]);
          this._unreadCount.set(0);
          this._totalCount.set(0);
          console.log('BackendNotificationService: Deleted all notifications');
        }
      },
      error: (err) => {
        console.error('BackendNotificationService: Error deleting all notifications', err);
      }
    });
  }

  /**
   * Navigate to notification action
   */
  navigateToAction(notification: BackendNotification): void {
    if (!notification.isRead) {
      this.markAsRead(notification.id);
    }

    if (notification.actionUrl) {
      this.router.navigateByUrl(notification.actionUrl);
    }
  }

  // =====================================================
  // WebSocket Methods
  // =====================================================

  /**
   * Connect to WebSocket for real-time notifications
   */
  private connectWebSocket(): void {
    // Skip if already connected or connecting
    if (this.stompClient?.connected || this._connected()) {
      return;
    }

    const token = localStorage.getItem('token');
    if (!token) {
      console.log('BackendNotificationService: No token, skipping WebSocket connection');
      return;
    }

    // Dynamic import for SockJS and STOMP
    this.loadWebSocketLibraries().then(() => {
      this.initializeWebSocket(token);
    }).catch(err => {
      console.error('BackendNotificationService: Failed to load WebSocket libraries', err);
    });
  }

  /**
   * Load WebSocket libraries dynamically
   */
  private async loadWebSocketLibraries(): Promise<void> {
    // Using global SockJS and Stomp if available
    if (typeof (window as any).SockJS === 'undefined') {
      console.log('BackendNotificationService: SockJS not loaded, using fallback polling');
      return Promise.reject(new Error('SockJS not available'));
    }
  }

  /**
   * Initialize WebSocket connection
   */
  private initializeWebSocket(token: string): void {
    try {
      const SockJS = (window as any).SockJS;
      const Stomp = (window as any).Stomp;

      if (!SockJS || !Stomp) {
        console.warn('BackendNotificationService: WebSocket libraries not available');
        return;
      }

      const wsUrl = environment.apiUrl.replace('/api/v1', '') + '/ws';
      const socket = new SockJS(wsUrl);
      this.stompClient = Stomp.over(socket);

      // Disable debug logging
      this.stompClient.debug = null;

      const headers = {
        'Authorization': `Bearer ${token}`
      };

      this.stompClient.connect(headers,
        // On connect
        (frame: any) => {
          console.log('BackendNotificationService: WebSocket connected');
          this._connected.set(true);
          this.reconnectAttempts = 0;
          this.subscribeToNotifications();
        },
        // On error
        (error: any) => {
          console.error('BackendNotificationService: WebSocket error', error);
          this._connected.set(false);
          this.handleReconnect();
        }
      );

      // Handle disconnect
      socket.onclose = () => {
        console.log('BackendNotificationService: WebSocket disconnected');
        this._connected.set(false);
        this.handleReconnect();
      };

    } catch (err) {
      console.error('BackendNotificationService: Failed to initialize WebSocket', err);
    }
  }

  /**
   * Subscribe to notification topics
   */
  private subscribeToNotifications(): void {
    if (!this.stompClient?.connected) {
      return;
    }

    const user = this.authService.user();
    if (!user) {
      return;
    }

    // Subscribe to user-specific notifications
    const notificationSub = this.stompClient.subscribe(
      `/user/${user.id}/notifications`,
      (message: any) => {
        try {
          const notification = JSON.parse(message.body) as BackendNotification;
          this.handleIncomingNotification(notification);
        } catch (err) {
          console.error('BackendNotificationService: Error parsing notification', err);
        }
      }
    );
    this.subscriptions.push(notificationSub);

    // Subscribe to unread count updates
    const countSub = this.stompClient.subscribe(
      `/user/${user.id}/notifications/count`,
      (message: any) => {
        try {
          const count = JSON.parse(message.body) as NotificationCount;
          this._unreadCount.set(count.unreadCount);
          this._totalCount.set(count.totalCount);
        } catch (err) {
          console.error('BackendNotificationService: Error parsing count', err);
        }
      }
    );
    this.subscriptions.push(countSub);

    console.log('BackendNotificationService: Subscribed to notification channels');
  }

  /**
   * Handle incoming notification
   */
  private handleIncomingNotification(notification: BackendNotification): void {
    console.log('BackendNotificationService: New notification received', notification);

    // Add to list
    this._notifications.update(notifications => [notification, ...notifications]);
    this._unreadCount.update(count => count + 1);
    this._totalCount.update(count => count + 1);

    // Show toast notification
    this.showToastForNotification(notification);

    // Play notification sound (optional)
    this.playNotificationSound();
  }

  /**
   * Show toast for notification
   */
  private showToastForNotification(notification: BackendNotification): void {
    let toastType: 'success' | 'info' | 'warning' | 'error' = 'info';

    switch (notification.type) {
      case 'SIMULATION_COMPLETE':
      case 'FRIEND_ACCEPTED':
      case 'WELCOME':
        toastType = 'success';
        break;
      case 'SIMULATION_FAILED':
        toastType = 'error';
        break;
      case 'FRIEND_REJECTED':
        toastType = 'warning';
        break;
      default:
        toastType = 'info';
    }

    this.toastService.show(toastType, notification.title, notification.message, 5000);
  }

  /**
   * Play notification sound
   */
  private playNotificationSound(): void {
    try {
      // Optional: Add notification sound
      // const audio = new Audio('/assets/sounds/notification.mp3');
      // audio.volume = 0.3;
      // audio.play().catch(() => {});
    } catch (e) {
      // Ignore audio errors
    }
  }

  /**
   * Handle WebSocket reconnection
   */
  private handleReconnect(): void {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.log('BackendNotificationService: Max reconnect attempts reached');
      return;
    }

    if (!this.authService.user()) {
      return;
    }

    this.reconnectAttempts++;
    console.log(`BackendNotificationService: Reconnecting (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);

    setTimeout(() => {
      this.connectWebSocket();
    }, this.reconnectInterval);
  }

  /**
   * Disconnect WebSocket
   */
  private disconnectWebSocket(): void {
    try {
      // Unsubscribe from all subscriptions
      this.subscriptions.forEach(sub => {
        try {
          sub.unsubscribe();
        } catch (e) { }
      });
      this.subscriptions = [];

      // Disconnect STOMP client
      if (this.stompClient?.connected) {
        this.stompClient.disconnect(() => {
          console.log('BackendNotificationService: WebSocket disconnected');
        });
      }
      this.stompClient = null;
      this._connected.set(false);
    } catch (err) {
      console.error('BackendNotificationService: Error disconnecting', err);
    }
  }

  // =====================================================
  // Utility Methods
  // =====================================================

  /**
   * Get notification icon based on type
   */
  getNotificationIcon(type: NotificationType): string {
    const icons: Record<NotificationType, string> = {
      'SIMULATION_COMPLETE': 'check_circle',
      'SIMULATION_FAILED': 'error',
      'SIMULATION_SHARED': 'share',
      'FRIEND_REQUEST': 'person_add',
      'FRIEND_ACCEPTED': 'how_to_reg',
      'FRIEND_REJECTED': 'person_remove',
      'NEW_MESSAGE': 'message',
      'SIMULATION_RECEIVED': 'inbox',
      'SYSTEM': 'info',
      'WELCOME': 'celebration',
      'ACCOUNT_UPDATE': 'manage_accounts'
    };
    return icons[type] || 'notifications';
  }

  /**
   * Get notification color based on type
   */
  getNotificationColor(type: NotificationType): string {
    const colors: Record<NotificationType, string> = {
      'SIMULATION_COMPLETE': 'text-green-500',
      'SIMULATION_FAILED': 'text-red-500',
      'SIMULATION_SHARED': 'text-blue-500',
      'FRIEND_REQUEST': 'text-indigo-500',
      'FRIEND_ACCEPTED': 'text-green-500',
      'FRIEND_REJECTED': 'text-orange-500',
      'NEW_MESSAGE': 'text-blue-500',
      'SIMULATION_RECEIVED': 'text-purple-500',
      'SYSTEM': 'text-gray-500',
      'WELCOME': 'text-yellow-500',
      'ACCOUNT_UPDATE': 'text-gray-500'
    };
    return colors[type] || 'text-gray-500';
  }

  /**
   * Format notification time
   */
  formatTime(dateString: string): string {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString();
  }
}
