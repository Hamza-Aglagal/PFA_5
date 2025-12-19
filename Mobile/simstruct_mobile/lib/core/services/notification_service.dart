import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/notification.dart';
import 'api_service.dart';

/// Notification Service - Manages app notifications and toasts
class NotificationService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  final List<AppNotification> _notifications = [];
  final Queue<ToastNotification> _toastQueue = Queue();
  ToastNotification? _currentToast;
  Timer? _toastTimer;
  bool _isLoading = false;
  int _unreadCountFromBackend = 0;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => _unreadCountFromBackend > 0 ? _unreadCountFromBackend : unreadNotifications.length;
  ToastNotification? get currentToast => _currentToast;
  bool get hasUnread => unreadCount > 0;
  bool get isLoading => _isLoading;

  /// Add a new notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Mark notification as read (calls backend + local update)
  void markAsRead(String notificationId) {
    // Call backend (non-blocking)
    markAsReadOnBackend(notificationId);
    
    // Immediate local update for responsiveness
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read (calls backend + local update)
  void markAllAsRead() {
    // Call backend (non-blocking)
    markAllAsReadOnBackend();
    
    // Immediate local update
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Remove a notification (calls backend + local update)
  void removeNotification(String notificationId) {
    // Call backend
    deleteNotificationOnBackend(notificationId);
    
    // Local update
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications (calls backend + local update)
  void clearAll() {
    // Call backend
    deleteAllNotificationsOnBackend();
    
    // Local update
    _notifications.clear();
    notifyListeners();
  }

  /// Get notifications by category
  List<AppNotification> getByCategory(NotificationCategory category) {
    return _notifications.where((n) => n.category == category).toList();
  }

  // ==================== TOAST NOTIFICATIONS ====================

  /// Show a toast notification
  void showToast(ToastNotification toast) {
    _toastQueue.add(toast);
    _processToastQueue();
  }

  /// Show a success toast
  void showSuccess(String message, {VoidCallback? action, String? actionLabel}) {
    showToast(ToastNotification.success(message, action: action, actionLabel: actionLabel));
  }

  /// Show an error toast
  void showError(String message, {VoidCallback? action, String? actionLabel}) {
    showToast(ToastNotification.error(message, action: action, actionLabel: actionLabel));
  }

  /// Show a warning toast
  void showWarning(String message, {VoidCallback? action, String? actionLabel}) {
    showToast(ToastNotification.warning(message, action: action, actionLabel: actionLabel));
  }

  /// Show an info toast
  void showInfo(String message, {VoidCallback? action, String? actionLabel}) {
    showToast(ToastNotification.info(message, action: action, actionLabel: actionLabel));
  }

  /// Process toast queue
  void _processToastQueue() {
    if (_currentToast != null || _toastQueue.isEmpty) return;

    _currentToast = _toastQueue.removeFirst();
    notifyListeners();

    _toastTimer?.cancel();
    _toastTimer = Timer(_currentToast!.duration, () {
      dismissToast();
    });
  }

  /// Dismiss current toast
  void dismissToast() {
    _toastTimer?.cancel();
    _currentToast = null;
    notifyListeners();

    // Process next toast after a small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _processToastQueue();
    });
  }

  // ==================== SIMULATION NOTIFICATIONS ====================

  /// Notify simulation started
  void notifySimulationStarted(String simulationName) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Simulation Started',
      message: '$simulationName is now running',
      type: NotificationType.info,
      category: NotificationCategory.simulation,
      createdAt: DateTime.now(),
    ));
    showInfo('Simulation "$simulationName" started');
  }

  /// Notify simulation completed
  void notifySimulationCompleted(String simulationName, {String? resultStatus}) {
    final isSuccess = resultStatus == 'safe';
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Simulation Complete',
      message: '$simulationName analysis is complete',
      type: isSuccess ? NotificationType.success : NotificationType.warning,
      category: NotificationCategory.simulation,
      createdAt: DateTime.now(),
    ));
    showSuccess('Simulation "$simulationName" completed!');
  }

  /// Notify simulation failed
  void notifySimulationFailed(String simulationName, String error) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Simulation Failed',
      message: '$simulationName encountered an error: $error',
      type: NotificationType.error,
      category: NotificationCategory.simulation,
      createdAt: DateTime.now(),
    ));
    showError('Simulation "$simulationName" failed');
  }

  // ==================== COMMUNITY NOTIFICATIONS ====================

  /// Notify friend request received
  void notifyFriendRequest(String senderName) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Friend Request',
      message: '$senderName wants to connect with you',
      type: NotificationType.info,
      category: NotificationCategory.community,
      createdAt: DateTime.now(),
    ));
  }

  /// Notify friend request accepted
  void notifyFriendAccepted(String friendName) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Friend Request Accepted',
      message: '$friendName accepted your friend request',
      type: NotificationType.success,
      category: NotificationCategory.community,
      createdAt: DateTime.now(),
    ));
    showSuccess('$friendName is now your friend!');
  }

  /// Notify simulation shared
  void notifySimulationShared(String simulationName, String sharedBy) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Simulation Shared',
      message: '$sharedBy shared "$simulationName" with you',
      type: NotificationType.info,
      category: NotificationCategory.community,
      createdAt: DateTime.now(),
    ));
  }

  // ==================== SYSTEM NOTIFICATIONS ====================

  /// Notify system update
  void notifySystemUpdate(String title, String message) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.info,
      category: NotificationCategory.system,
      createdAt: DateTime.now(),
    ));
  }

  /// Load notifications from REAL BACKEND
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConfig.notifications);
      
      _notifications.clear();
      
      if (response.success && response.data != null) {
        // Parse backend response - handle different response formats
        List<dynamic> notifList = [];
        
        if (response.data is List) {
          notifList = response.data;
        } else if (response.data is Map) {
          final data = response.data['data'] ?? response.data['content'] ?? response.data['notifications'];
          if (data is List) {
            notifList = data;
          }
        }
        
        _notifications.addAll(
          notifList.map((json) => _parseNotificationFromBackend(json as Map<String, dynamic>)).toList()
        );
        debugPrint('Loaded ${_notifications.length} notifications from backend');
      } else {
        debugPrint('Failed to load notifications: ${response.message}');
        // No mock data - show empty list
      }
      
      // Also get unread count
      await loadUnreadCount();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      // No mock data - show empty list
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load unread notification count from backend
  Future<void> loadUnreadCount() async {
    try {
      final response = await _apiService.get(ApiConfig.notificationsCount);
      
      if (response.success && response.data != null) {
        // Backend may return {count: X} or just a number or {unread: X, total: Y}
        final data = response.data;
        if (data is int) {
          _unreadCountFromBackend = data;
        } else if (data is Map) {
          final innerData = data['data'] ?? data;
          if (innerData is int) {
            _unreadCountFromBackend = innerData;
          } else if (innerData is Map) {
            _unreadCountFromBackend = innerData['unread'] ?? innerData['count'] ?? innerData['total'] ?? 0;
          } else {
            _unreadCountFromBackend = 0;
          }
        } else {
          _unreadCountFromBackend = 0;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  /// Mark notification as read - CALLS REAL BACKEND
  Future<void> markAsReadOnBackend(String notificationId) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.notifications}/$notificationId/read',
      );
      
      if (response.success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
        
        // Update count
        if (_unreadCountFromBackend > 0) {
          _unreadCountFromBackend--;
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  /// Mark all notifications as read - CALLS REAL BACKEND
  Future<void> markAllAsReadOnBackend() async {
    try {
      final response = await _apiService.put(ApiConfig.notificationsReadAll);
      
      if (response.success) {
        // Update local state
        for (var i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = _notifications[i].copyWith(isRead: true);
          }
        }
        
        _unreadCountFromBackend = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  /// Delete notification - CALLS REAL BACKEND
  Future<bool> deleteNotificationOnBackend(String notificationId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.notifications}/$notificationId',
      );
      
      if (response.success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications - CALLS REAL BACKEND
  Future<bool> deleteAllNotificationsOnBackend() async {
    try {
      final response = await _apiService.delete(ApiConfig.notifications);
      
      if (response.success) {
        _notifications.clear();
        _unreadCountFromBackend = 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return false;
    }
  }

  /// Parse notification from backend response
  AppNotification _parseNotificationFromBackend(Map<String, dynamic> json) {
    // Map backend NotificationType to mobile NotificationType and Category
    final backendType = json['type']?.toString().toUpperCase() ?? 'SYSTEM';
    
    NotificationType type = NotificationType.info;
    NotificationCategory category = NotificationCategory.system;
    
    // Map backend types
    switch (backendType) {
      case 'SIMULATION_COMPLETE':
        type = NotificationType.success;
        category = NotificationCategory.simulation;
        break;
      case 'SIMULATION_FAILED':
        type = NotificationType.error;
        category = NotificationCategory.simulation;
        break;
      case 'SIMULATION_SHARED':
      case 'SIMULATION_RECEIVED':
        type = NotificationType.info;
        category = NotificationCategory.community;
        break;
      case 'FRIEND_REQUEST':
      case 'FRIEND_ACCEPTED':
      case 'FRIEND_REJECTED':
        type = NotificationType.info;
        category = NotificationCategory.community;
        break;
      case 'NEW_MESSAGE':
        type = NotificationType.info;
        category = NotificationCategory.community;
        break;
      case 'WELCOME':
        type = NotificationType.success;
        category = NotificationCategory.system;
        break;
      case 'ACCOUNT_UPDATE':
        type = NotificationType.info;
        category = NotificationCategory.account;
        break;
      default:
        type = NotificationType.info;
        category = NotificationCategory.system;
    }

    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      type: type,
      category: category,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl'],
      data: {
        'relatedId': json['relatedId'],
        'relatedType': json['relatedType'],
        'backendType': backendType,
      },
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
