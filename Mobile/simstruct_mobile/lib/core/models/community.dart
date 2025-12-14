import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'user.dart';
import 'simulation.dart';

/// Friend Status
enum FriendStatus {
  pending,
  accepted,
  blocked;

  String get displayName {
    switch (this) {
      case FriendStatus.pending:
        return 'Pending';
      case FriendStatus.accepted:
        return 'Friends';
      case FriendStatus.blocked:
        return 'Blocked';
    }
  }

  Color get color {
    switch (this) {
      case FriendStatus.pending:
        return AppColors.warning;
      case FriendStatus.accepted:
        return AppColors.success;
      case FriendStatus.blocked:
        return AppColors.error;
    }
  }
}

/// Invitation Status
enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired;

  String get displayName {
    switch (this) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
    }
  }

  Color get color {
    switch (this) {
      case InvitationStatus.pending:
        return AppColors.warning;
      case InvitationStatus.accepted:
        return AppColors.success;
      case InvitationStatus.declined:
        return AppColors.error;
      case InvitationStatus.expired:
        return AppColors.textSecondaryLight;
    }
  }
}

/// Share Permission Level
enum SharePermission {
  view,
  edit,
  admin;

  String get displayName {
    switch (this) {
      case SharePermission.view:
        return 'View Only';
      case SharePermission.edit:
        return 'Can Edit';
      case SharePermission.admin:
        return 'Full Access';
    }
  }

  IconData get icon {
    switch (this) {
      case SharePermission.view:
        return Icons.visibility_outlined;
      case SharePermission.edit:
        return Icons.edit_outlined;
      case SharePermission.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}

/// Friend Model
class Friend {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final FriendStatus status;
  final DateTime connectedAt;
  final bool isOnline;
  final DateTime? lastSeen;
  final int sharedSimulations;

  const Friend({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.status = FriendStatus.accepted,
    required this.connectedAt,
    this.isOnline = false,
    this.lastSeen,
    this.sharedSimulations = 0,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String get lastSeenText {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';
    
    final diff = DateTime.now().difference(lastSeen!);
    if (diff.inMinutes < 5) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return 'Long ago';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'status': status.name,
      'connectedAt': connectedAt.toIso8601String(),
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'sharedSimulations': sharedSimulations,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      status: FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.pending,
      ),
      connectedAt: DateTime.parse(json['connectedAt'] ?? DateTime.now().toIso8601String()),
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      sharedSimulations: json['sharedSimulations'] ?? 0,
    );
  }
}

/// Shared Simulation Model
class SharedSimulation {
  final String id;
  final String simulationId;
  final String simulationName;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatarUrl;
  final SharePermission permission;
  final DateTime sharedAt;
  final SimulationStatus simulationStatus;
  final ResultStatus? resultStatus;
  final String? description;
  final int likes;
  final int comments;
  final List<Friend> sharedWith; // List of friends this simulation is shared with

  const SharedSimulation({
    required this.id,
    required this.simulationId,
    required this.simulationName,
    required this.ownerId,
    required this.ownerName,
    this.ownerAvatarUrl,
    this.permission = SharePermission.view,
    required this.sharedAt,
    this.simulationStatus = SimulationStatus.draft,
    this.resultStatus,
    this.description,
    this.likes = 0,
    this.comments = 0,
    this.sharedWith = const [],
  });

  /// Alias for owner info
  Friend get sharedBy => Friend(
    id: ownerId,
    name: ownerName,
    email: '',
    avatarUrl: ownerAvatarUrl,
    connectedAt: sharedAt,
  );

  /// Alias for message (description)
  String? get message => description;

  /// Get simulation info as a simple object
  SharedSimulationInfo get simulation => SharedSimulationInfo(
    id: simulationId,
    name: simulationName,
    status: simulationStatus,
    resultStatus: resultStatus,
  );

  String get ownerInitials {
    final parts = ownerName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return ownerName.substring(0, 2).toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'simulationId': simulationId,
      'simulationName': simulationName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerAvatarUrl': ownerAvatarUrl,
      'permission': permission.name,
      'sharedAt': sharedAt.toIso8601String(),
      'simulationStatus': simulationStatus.name,
      'resultStatus': resultStatus?.name,
      'sharedWith': sharedWith.map((f) => f.toJson()).toList(),
    };
  }

  factory SharedSimulation.fromJson(Map<String, dynamic> json) {
    return SharedSimulation(
      id: json['id'] ?? '',
      simulationId: json['simulationId'] ?? '',
      simulationName: json['simulationName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerAvatarUrl: json['ownerAvatarUrl'],
      permission: SharePermission.values.firstWhere(
        (e) => e.name == json['permission'],
        orElse: () => SharePermission.view,
      ),
      sharedAt: DateTime.parse(json['sharedAt'] ?? DateTime.now().toIso8601String()),
      simulationStatus: SimulationStatus.values.firstWhere(
        (e) => e.name == json['simulationStatus'],
        orElse: () => SimulationStatus.draft,
      ),
      resultStatus: json['resultStatus'] != null
          ? ResultStatus.values.firstWhere(
              (e) => e.name == json['resultStatus'],
              orElse: () => ResultStatus.warning,
            )
          : null,
      sharedWith: json['sharedWith'] != null
          ? (json['sharedWith'] as List).map((f) => Friend.fromJson(f)).toList()
          : [],
    );
  }
}

/// Shared Simulation Info (for reference in SharedSimulation)
class SharedSimulationInfo {
  final String id;
  final String name;
  final SimulationStatus status;
  final ResultStatus? resultStatus;

  const SharedSimulationInfo({
    required this.id,
    required this.name,
    required this.status,
    this.resultStatus,
  });

  String get statusText => status.displayName;
}

/// Invitation Model
class Invitation {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String? recipientId;
  final String recipientEmail;
  final String? toUserId;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? message;

  const Invitation({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    this.recipientId,
    this.toUserId,
    required this.recipientEmail,
    this.status = InvitationStatus.pending,
    required this.createdAt,
    this.expiresAt,
    this.message,
  });

  /// Alias for createdAt
  DateTime get sentAt => createdAt;

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  String get senderInitials {
    final parts = senderName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return senderName.substring(0, 2).toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'recipientId': recipientId,
      'recipientEmail': recipientEmail,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'message': message,
    };
  }

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatarUrl: json['senderAvatarUrl'],
      recipientId: json['recipientId'],
      recipientEmail: json['recipientEmail'] ?? '',
      status: InvitationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvitationStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      message: json['message'],
    );
  }
}

/// Chat Message Model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final String? simulationId; // If sharing a simulation in chat

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.sentAt,
    this.isRead = false,
    this.simulationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
      'simulationId': simulationId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatarUrl: json['senderAvatarUrl'],
      content: json['content'] ?? '',
      sentAt: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      simulationId: json['simulationId'],
    );
  }
}

/// Community Stats
class CommunityStats {
  final int totalFriends;
  final int pendingInvitations;
  final int sharedSimulations;
  final int receivedShares;

  const CommunityStats({
    this.totalFriends = 0,
    this.pendingInvitations = 0,
    this.sharedSimulations = 0,
    this.receivedShares = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalFriends': totalFriends,
      'pendingInvitations': pendingInvitations,
      'sharedSimulations': sharedSimulations,
      'receivedShares': receivedShares,
    };
  }

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      totalFriends: json['totalFriends'] ?? 0,
      pendingInvitations: json['pendingInvitations'] ?? 0,
      sharedSimulations: json['sharedSimulations'] ?? 0,
      receivedShares: json['receivedShares'] ?? 0,
    );
  }
}

/// Conversation Model (for chat list)
class Conversation {
  final String id;
  final String partnerId;
  final String partnerName;
  final String? partnerEmail;
  final String? partnerAvatar;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    this.partnerEmail,
    this.partnerAvatar,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  String get partnerInitials {
    final parts = partnerName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return partnerName.length >= 2 
        ? partnerName.substring(0, 2).toUpperCase() 
        : partnerName.toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'partnerEmail': partnerEmail,
      'partnerAvatar': partnerAvatar,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      partnerId: json['partnerId']?.toString() ?? '',
      partnerName: json['partnerName'] ?? 'Unknown',
      partnerEmail: json['partnerEmail'],
      partnerAvatar: json['partnerAvatar'],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt']) 
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
