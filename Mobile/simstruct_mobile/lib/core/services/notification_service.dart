import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/notification.dart';

/// Notification Service - Manages app notifications and toasts
class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  final Queue<ToastNotification> _toastQueue = Queue();
  ToastNotification? _currentToast;
  Timer? _toastTimer;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  ToastNotification? get currentToast => _currentToast;
  bool get hasUnread => unreadCount > 0;

  /// Add a new notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Remove a notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
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

  /// Load notifications from server
  Future<void> loadNotifications() async {
    // Mock loading - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Add some mock notifications
    final mockNotifications = [
      AppNotification(
        id: 'notif_1',
        title: 'Welcome to SimStruct',
        message: 'Start your first simulation to analyze structural stability',
        type: NotificationType.info,
        category: NotificationCategory.system,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Simulation Complete',
        message: 'Your beam analysis simulation has completed successfully',
        type: NotificationType.success,
        category: NotificationCategory.simulation,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'notif_3',
        title: 'New Connection Request',
        message: 'Ahmed Benali wants to connect with you',
        type: NotificationType.info,
        category: NotificationCategory.community,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif_4',
        title: 'Tip: Save Your Work',
        message: 'Your simulations are automatically saved to the cloud',
        type: NotificationType.info,
        category: NotificationCategory.system,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif_5',
        title: 'New Feature Available',
        message: 'Try our new AI-powered load optimization feature',
        type: NotificationType.info,
        category: NotificationCategory.system,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];

    _notifications.addAll(mockNotifications);
    notifyListeners();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}
