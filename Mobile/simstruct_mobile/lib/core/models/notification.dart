import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Notification Type Enum
enum NotificationType {
  success,
  error,
  warning,
  info;

  Color get color {
    switch (this) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.info;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case NotificationType.success:
        return AppColors.success.withValues(alpha: 0.1);
      case NotificationType.error:
        return AppColors.error.withValues(alpha: 0.1);
      case NotificationType.warning:
        return AppColors.warning.withValues(alpha: 0.1);
      case NotificationType.info:
        return AppColors.info.withValues(alpha: 0.1);
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.error:
        return Icons.error_rounded;
      case NotificationType.warning:
        return Icons.warning_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
    }
  }
}

/// App Notification Category
enum NotificationCategory {
  simulation,
  community,
  system,
  account;

  String get displayName {
    switch (this) {
      case NotificationCategory.simulation:
        return 'Simulation';
      case NotificationCategory.community:
        return 'Community';
      case NotificationCategory.system:
        return 'System';
      case NotificationCategory.account:
        return 'Account';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.simulation:
        return Icons.analytics_outlined;
      case NotificationCategory.community:
        return Icons.people_outlined;
      case NotificationCategory.system:
        return Icons.settings_outlined;
      case NotificationCategory.account:
        return Icons.person_outlined;
    }
  }
}

/// App Notification Model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.category = NotificationCategory.system,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.data,
  });

  /// Get relative time
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationCategory? category,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
      'data': data,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NotificationCategory.system,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl'],
      data: json['data'],
    );
  }
}

/// Toast Notification - For Quick Messages
class ToastNotification {
  final String id;
  final String message;
  final String? title;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? action;
  final String? actionLabel;

  const ToastNotification({
    required this.id,
    required this.message,
    this.title,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 3),
    this.action,
    this.actionLabel,
  });

  factory ToastNotification.success(String message, {String? title, VoidCallback? action, String? actionLabel}) {
    return ToastNotification(
      id: 'toast_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      title: title,
      type: NotificationType.success,
      action: action,
      actionLabel: actionLabel,
    );
  }

  factory ToastNotification.error(String message, {String? title, VoidCallback? action, String? actionLabel}) {
    return ToastNotification(
      id: 'toast_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      title: title,
      type: NotificationType.error,
      duration: const Duration(seconds: 5),
      action: action,
      actionLabel: actionLabel,
    );
  }

  factory ToastNotification.warning(String message, {String? title, VoidCallback? action, String? actionLabel}) {
    return ToastNotification(
      id: 'toast_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      title: title,
      type: NotificationType.warning,
      duration: const Duration(seconds: 4),
      action: action,
      actionLabel: actionLabel,
    );
  }

  factory ToastNotification.info(String message, {String? title, VoidCallback? action, String? actionLabel}) {
    return ToastNotification(
      id: 'toast_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      title: title,
      type: NotificationType.info,
      action: action,
      actionLabel: actionLabel,
    );
  }

  factory ToastNotification.welcome(String userName) {
    return ToastNotification(
      id: 'toast_welcome_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Welcome Back! 👋',
      message: 'Hello $userName, great to see you again!',
      type: NotificationType.success,
      duration: const Duration(seconds: 4),
    );
  }

  factory ToastNotification.connectionRestored() {
    return ToastNotification(
      id: 'toast_connection_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Connected',
      message: 'Internet connection has been restored',
      type: NotificationType.success,
      duration: const Duration(seconds: 3),
    );
  }
}

/// In-App Notification Settings
class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool simulationComplete;
  final bool communityActivity;
  final bool systemUpdates;
  final bool marketingEmails;

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.simulationComplete = true,
    this.communityActivity = true,
    this.systemUpdates = true,
    this.marketingEmails = false,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? simulationComplete,
    bool? communityActivity,
    bool? systemUpdates,
    bool? marketingEmails,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      simulationComplete: simulationComplete ?? this.simulationComplete,
      communityActivity: communityActivity ?? this.communityActivity,
      systemUpdates: systemUpdates ?? this.systemUpdates,
      marketingEmails: marketingEmails ?? this.marketingEmails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'simulationComplete': simulationComplete,
      'communityActivity': communityActivity,
      'systemUpdates': systemUpdates,
      'marketingEmails': marketingEmails,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      simulationComplete: json['simulationComplete'] ?? true,
      communityActivity: json['communityActivity'] ?? true,
      systemUpdates: json['systemUpdates'] ?? true,
      marketingEmails: json['marketingEmails'] ?? false,
    );
  }
}
