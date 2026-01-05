import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/community.dart';
import 'package:simstruct_mobile/core/models/simulation.dart';
import 'package:simstruct_mobile/app/theme/app_colors.dart';

void main() {
  group('FriendStatus enum', () {
    test('should have correct displayName for pending', () {
      expect(FriendStatus.pending.displayName, equals('Pending'));
    });

    test('should have correct displayName for accepted', () {
      expect(FriendStatus.accepted.displayName, equals('Friends'));
    });

    test('should have correct displayName for blocked', () {
      expect(FriendStatus.blocked.displayName, equals('Blocked'));
    });

    test('should have correct color for pending', () {
      expect(FriendStatus.pending.color, equals(AppColors.warning));
    });

    test('should have correct color for accepted', () {
      expect(FriendStatus.accepted.color, equals(AppColors.success));
    });

    test('should have correct color for blocked', () {
      expect(FriendStatus.blocked.color, equals(AppColors.error));
    });
  });

  group('InvitationStatus enum', () {
    test('should have correct displayName for pending', () {
      expect(InvitationStatus.pending.displayName, equals('Pending'));
    });

    test('should have correct displayName for accepted', () {
      expect(InvitationStatus.accepted.displayName, equals('Accepted'));
    });

    test('should have correct displayName for declined', () {
      expect(InvitationStatus.declined.displayName, equals('Declined'));
    });

    test('should have correct displayName for expired', () {
      expect(InvitationStatus.expired.displayName, equals('Expired'));
    });

    test('should have correct color for pending', () {
      expect(InvitationStatus.pending.color, equals(AppColors.warning));
    });

    test('should have correct color for accepted', () {
      expect(InvitationStatus.accepted.color, equals(AppColors.success));
    });

    test('should have correct color for declined', () {
      expect(InvitationStatus.declined.color, equals(AppColors.error));
    });

    test('should have correct color for expired', () {
      expect(InvitationStatus.expired.color, equals(AppColors.textSecondaryLight));
    });
  });

  group('SharePermission enum', () {
    test('should have correct displayName for view', () {
      expect(SharePermission.view.displayName, equals('View Only'));
    });

    test('should have correct displayName for edit', () {
      expect(SharePermission.edit.displayName, equals('Can Edit'));
    });

    test('should have correct displayName for admin', () {
      expect(SharePermission.admin.displayName, equals('Full Access'));
    });

    test('should have correct icon for view', () {
      expect(SharePermission.view.icon, equals(Icons.visibility_outlined));
    });

    test('should have correct icon for edit', () {
      expect(SharePermission.edit.icon, equals(Icons.edit_outlined));
    });

    test('should have correct icon for admin', () {
      expect(SharePermission.admin.icon, equals(Icons.admin_panel_settings_outlined));
    });
  });

  group('Friend model', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);
    
    test('should create a Friend with required parameters', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
      );
      
      expect(friend.id, equals('1'));
      expect(friend.name, equals('John Doe'));
      expect(friend.email, equals('john@example.com'));
      expect(friend.status, equals(FriendStatus.accepted));
      expect(friend.isOnline, isFalse);
      expect(friend.sharedSimulations, equals(0));
    });

    test('should create a Friend with all parameters', () {
      final lastSeen = DateTime.now().subtract(const Duration(hours: 2));
      final friend = Friend(
        id: '1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        status: FriendStatus.pending,
        connectedAt: testDate,
        isOnline: true,
        lastSeen: lastSeen,
        sharedSimulations: 5,
      );
      
      expect(friend.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(friend.status, equals(FriendStatus.pending));
      expect(friend.isOnline, isTrue);
      expect(friend.sharedSimulations, equals(5));
    });

    test('should return correct initials for two-word name', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
      );
      
      expect(friend.initials, equals('JD'));
    });

    test('should return correct initials for single-word name', () {
      final friend = Friend(
        id: '1',
        name: 'John',
        email: 'john@example.com',
        connectedAt: testDate,
      );
      
      expect(friend.initials, equals('JO'));
    });

    test('should return "Online" for online user', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
        isOnline: true,
      );
      
      expect(friend.lastSeenText, equals('Online'));
    });

    test('should return "Offline" for offline user with no lastSeen', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
        isOnline: false,
        lastSeen: null,
      );
      
      expect(friend.lastSeenText, equals('Offline'));
    });

    test('should return "Just now" for recently seen user', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
      );
      
      expect(friend.lastSeenText, equals('Just now'));
    });

    test('should return minutes ago for user seen within hour', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      
      expect(friend.lastSeenText, equals('30m ago'));
    });

    test('should return hours ago for user seen within day', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 5)),
      );
      
      expect(friend.lastSeenText, equals('5h ago'));
    });

    test('should return days ago for user seen within week', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(days: 3)),
      );
      
      expect(friend.lastSeenText, equals('3d ago'));
    });

    test('should return "Long ago" for user seen more than a week ago', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        connectedAt: testDate,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(days: 10)),
      );
      
      expect(friend.lastSeenText, equals('Long ago'));
    });

    test('should convert to JSON correctly', () {
      final friend = Friend(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        avatarUrl: 'https://example.com/avatar.jpg',
        status: FriendStatus.accepted,
        connectedAt: testDate,
        isOnline: true,
        lastSeen: testDate,
        sharedSimulations: 3,
      );
      
      final json = friend.toJson();
      
      expect(json['id'], equals('1'));
      expect(json['name'], equals('John Doe'));
      expect(json['email'], equals('john@example.com'));
      expect(json['avatarUrl'], equals('https://example.com/avatar.jpg'));
      expect(json['status'], equals('accepted'));
      expect(json['isOnline'], isTrue);
      expect(json['sharedSimulations'], equals(3));
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'status': 'accepted',
        'connectedAt': testDate.toIso8601String(),
        'isOnline': true,
        'lastSeen': testDate.toIso8601String(),
        'sharedSimulations': 5,
      };
      
      final friend = Friend.fromJson(json);
      
      expect(friend.id, equals('1'));
      expect(friend.name, equals('John Doe'));
      expect(friend.email, equals('john@example.com'));
      expect(friend.status, equals(FriendStatus.accepted));
      expect(friend.sharedSimulations, equals(5));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final friend = Friend.fromJson(json);
      
      expect(friend.id, equals(''));
      expect(friend.name, equals(''));
      expect(friend.email, equals(''));
      expect(friend.status, equals(FriendStatus.pending));
      expect(friend.isOnline, isFalse);
      expect(friend.sharedSimulations, equals(0));
    });
  });

  group('SharedSimulation model', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create a SharedSimulation with required parameters', () {
      final shared = SharedSimulation(
        id: '1',
        simulationId: 'sim1',
        simulationName: 'Test Simulation',
        ownerId: 'owner1',
        ownerName: 'John Doe',
        sharedAt: testDate,
      );
      
      expect(shared.id, equals('1'));
      expect(shared.simulationId, equals('sim1'));
      expect(shared.permission, equals(SharePermission.view));
      expect(shared.simulationStatus, equals(SimulationStatus.draft));
      expect(shared.likes, equals(0));
      expect(shared.comments, equals(0));
    });

    test('should return correct owner initials', () {
      final shared = SharedSimulation(
        id: '1',
        simulationId: 'sim1',
        simulationName: 'Test Simulation',
        ownerId: 'owner1',
        ownerName: 'John Doe',
        sharedAt: testDate,
      );
      
      expect(shared.ownerInitials, equals('JD'));
    });

    test('should return correct owner initials for single name', () {
      final shared = SharedSimulation(
        id: '1',
        simulationId: 'sim1',
        simulationName: 'Test Simulation',
        ownerId: 'owner1',
        ownerName: 'John',
        sharedAt: testDate,
      );
      
      expect(shared.ownerInitials, equals('JO'));
    });

    test('should return sharedBy as Friend', () {
      final shared = SharedSimulation(
        id: '1',
        simulationId: 'sim1',
        simulationName: 'Test Simulation',
        ownerId: 'owner1',
        ownerName: 'John Doe',
        ownerAvatarUrl: 'https://example.com/avatar.jpg',
        sharedAt: testDate,
      );
      
      final sharedBy = shared.sharedBy;
      expect(sharedBy.id, equals('owner1'));
      expect(sharedBy.name, equals('John Doe'));
      expect(sharedBy.avatarUrl, equals('https://example.com/avatar.jpg'));
    });

    test('should return message as description', () {
      final shared = SharedSimulation(
        id: '1',
        simulationId: 'sim1',
        simulationName: 'Test Simulation',
        ownerId: 'owner1',
        ownerName: 'John Doe',
        sharedAt: testDate,
        description: 'Check this out!',
      );
      
      expect(shared.message, equals('Check this out!'));
    });

    test('should return simulation info', () {
      final shared = SharedSimulation(
        id: '1',
        simulationId: 'sim1',
        simulationName: 'Test Simulation',
        ownerId: 'owner1',
        ownerName: 'John Doe',
        sharedAt: testDate,
        simulationStatus: SimulationStatus.completed,
        resultStatus: ResultStatus.safe,
      );
      
      final simInfo = shared.simulation;
      expect(simInfo.id, equals('sim1'));
      expect(simInfo.name, equals('Test Simulation'));
      expect(simInfo.status, equals(SimulationStatus.completed));
      expect(simInfo.resultStatus, equals(ResultStatus.safe));
    });

    test('should convert to JSON correctly', () {
      final shared = SharedSimulation(
        id: '1',
        simulationId: 'sim1',
        simulationName: 'Test Simulation',
        ownerId: 'owner1',
        ownerName: 'John Doe',
        permission: SharePermission.edit,
        sharedAt: testDate,
        simulationStatus: SimulationStatus.running,
        resultStatus: ResultStatus.warning,
      );
      
      final json = shared.toJson();
      
      expect(json['id'], equals('1'));
      expect(json['simulationId'], equals('sim1'));
      expect(json['permission'], equals('edit'));
      expect(json['simulationStatus'], equals('running'));
      expect(json['resultStatus'], equals('warning'));
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'simulationId': 'sim1',
        'simulationName': 'Test Simulation',
        'ownerId': 'owner1',
        'ownerName': 'John Doe',
        'permission': 'admin',
        'sharedAt': testDate.toIso8601String(),
        'simulationStatus': 'completed',
        'resultStatus': 'safe',
        'sharedWith': [],
      };
      
      final shared = SharedSimulation.fromJson(json);
      
      expect(shared.permission, equals(SharePermission.admin));
      expect(shared.simulationStatus, equals(SimulationStatus.completed));
      expect(shared.resultStatus, equals(ResultStatus.safe));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final shared = SharedSimulation.fromJson(json);
      
      expect(shared.id, equals(''));
      expect(shared.permission, equals(SharePermission.view));
      expect(shared.simulationStatus, equals(SimulationStatus.draft));
    });

    test('should parse sharedWith list from JSON', () {
      final json = {
        'id': '1',
        'simulationId': 'sim1',
        'simulationName': 'Test Simulation',
        'ownerId': 'owner1',
        'ownerName': 'John Doe',
        'sharedAt': testDate.toIso8601String(),
        'sharedWith': [
          {
            'id': 'friend1',
            'name': 'Jane Doe',
            'email': 'jane@example.com',
            'connectedAt': testDate.toIso8601String(),
          }
        ],
      };
      
      final shared = SharedSimulation.fromJson(json);
      
      expect(shared.sharedWith.length, equals(1));
      expect(shared.sharedWith.first.name, equals('Jane Doe'));
    });
  });

  group('SharedSimulationInfo model', () {
    test('should create SharedSimulationInfo with required parameters', () {
      final info = SharedSimulationInfo(
        id: 'sim1',
        name: 'Test Simulation',
        status: SimulationStatus.completed,
      );
      
      expect(info.id, equals('sim1'));
      expect(info.name, equals('Test Simulation'));
      expect(info.status, equals(SimulationStatus.completed));
      expect(info.resultStatus, isNull);
    });

    test('should return correct statusText', () {
      final info = SharedSimulationInfo(
        id: 'sim1',
        name: 'Test',
        status: SimulationStatus.completed,
      );
      
      expect(info.statusText, equals('Completed'));
    });
  });

  group('Invitation model', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create an Invitation with required parameters', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        recipientEmail: 'jane@example.com',
        createdAt: testDate,
      );
      
      expect(invitation.id, equals('1'));
      expect(invitation.senderId, equals('sender1'));
      expect(invitation.status, equals(InvitationStatus.pending));
    });

    test('should return sentAt as alias for createdAt', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        recipientEmail: 'jane@example.com',
        createdAt: testDate,
      );
      
      expect(invitation.sentAt, equals(testDate));
    });

    test('should return false for isExpired when no expiresAt', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        recipientEmail: 'jane@example.com',
        createdAt: testDate,
      );
      
      expect(invitation.isExpired, isFalse);
    });

    test('should return true for isExpired when past expiry date', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        recipientEmail: 'jane@example.com',
        createdAt: testDate,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      
      expect(invitation.isExpired, isTrue);
    });

    test('should return false for isExpired when before expiry date', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        recipientEmail: 'jane@example.com',
        createdAt: testDate,
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
      
      expect(invitation.isExpired, isFalse);
    });

    test('should return correct sender initials for two-word name', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        recipientEmail: 'jane@example.com',
        createdAt: testDate,
      );
      
      expect(invitation.senderInitials, equals('JD'));
    });

    test('should return correct sender initials for single-word name', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John',
        recipientEmail: 'jane@example.com',
        createdAt: testDate,
      );
      
      expect(invitation.senderInitials, equals('JO'));
    });

    test('should convert to JSON correctly', () {
      final invitation = Invitation(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        recipientId: 'recipient1',
        recipientEmail: 'jane@example.com',
        status: InvitationStatus.accepted,
        createdAt: testDate,
        expiresAt: testDate.add(const Duration(days: 7)),
        message: 'Hello!',
      );
      
      final json = invitation.toJson();
      
      expect(json['id'], equals('1'));
      expect(json['senderId'], equals('sender1'));
      expect(json['status'], equals('accepted'));
      expect(json['message'], equals('Hello!'));
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'senderId': 'sender1',
        'senderName': 'John Doe',
        'recipientEmail': 'jane@example.com',
        'status': 'declined',
        'createdAt': testDate.toIso8601String(),
        'message': 'Please join!',
      };
      
      final invitation = Invitation.fromJson(json);
      
      expect(invitation.status, equals(InvitationStatus.declined));
      expect(invitation.message, equals('Please join!'));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final invitation = Invitation.fromJson(json);
      
      expect(invitation.id, equals(''));
      expect(invitation.status, equals(InvitationStatus.pending));
    });
  });

  group('ChatMessage model', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create a ChatMessage with required parameters', () {
      final message = ChatMessage(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        content: 'Hello!',
        sentAt: testDate,
      );
      
      expect(message.id, equals('1'));
      expect(message.content, equals('Hello!'));
      expect(message.isRead, isFalse);
      expect(message.simulationId, isNull);
    });

    test('should create a ChatMessage with all parameters', () {
      final message = ChatMessage(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        senderAvatarUrl: 'https://example.com/avatar.jpg',
        content: 'Check this simulation!',
        sentAt: testDate,
        isRead: true,
        simulationId: 'sim1',
      );
      
      expect(message.isRead, isTrue);
      expect(message.simulationId, equals('sim1'));
    });

    test('should convert to JSON correctly', () {
      final message = ChatMessage(
        id: '1',
        senderId: 'sender1',
        senderName: 'John Doe',
        content: 'Hello!',
        sentAt: testDate,
        isRead: true,
        simulationId: 'sim1',
      );
      
      final json = message.toJson();
      
      expect(json['id'], equals('1'));
      expect(json['content'], equals('Hello!'));
      expect(json['isRead'], isTrue);
      expect(json['simulationId'], equals('sim1'));
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'senderId': 'sender1',
        'senderName': 'John Doe',
        'content': 'Hello!',
        'sentAt': testDate.toIso8601String(),
        'isRead': true,
        'simulationId': 'sim1',
      };
      
      final message = ChatMessage.fromJson(json);
      
      expect(message.content, equals('Hello!'));
      expect(message.isRead, isTrue);
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final message = ChatMessage.fromJson(json);
      
      expect(message.id, equals(''));
      expect(message.content, equals(''));
      expect(message.isRead, isFalse);
    });
  });

  group('CommunityStats model', () {
    test('should create CommunityStats with default values', () {
      const stats = CommunityStats();
      
      expect(stats.totalFriends, equals(0));
      expect(stats.pendingInvitations, equals(0));
      expect(stats.sharedSimulations, equals(0));
      expect(stats.receivedShares, equals(0));
    });

    test('should create CommunityStats with custom values', () {
      const stats = CommunityStats(
        totalFriends: 10,
        pendingInvitations: 3,
        sharedSimulations: 5,
        receivedShares: 7,
      );
      
      expect(stats.totalFriends, equals(10));
      expect(stats.pendingInvitations, equals(3));
      expect(stats.sharedSimulations, equals(5));
      expect(stats.receivedShares, equals(7));
    });

    test('should convert to JSON correctly', () {
      const stats = CommunityStats(
        totalFriends: 10,
        pendingInvitations: 3,
        sharedSimulations: 5,
        receivedShares: 7,
      );
      
      final json = stats.toJson();
      
      expect(json['totalFriends'], equals(10));
      expect(json['pendingInvitations'], equals(3));
      expect(json['sharedSimulations'], equals(5));
      expect(json['receivedShares'], equals(7));
    });

    test('should create from JSON correctly', () {
      final json = {
        'totalFriends': 10,
        'pendingInvitations': 3,
        'sharedSimulations': 5,
        'receivedShares': 7,
      };
      
      final stats = CommunityStats.fromJson(json);
      
      expect(stats.totalFriends, equals(10));
      expect(stats.pendingInvitations, equals(3));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final stats = CommunityStats.fromJson(json);
      
      expect(stats.totalFriends, equals(0));
      expect(stats.pendingInvitations, equals(0));
    });
  });

  group('Conversation model', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should create a Conversation with required parameters', () {
      final conversation = Conversation(
        id: '1',
        partnerId: 'partner1',
        partnerName: 'John Doe',
        lastMessage: 'Hello!',
        lastMessageAt: testDate,
      );
      
      expect(conversation.id, equals('1'));
      expect(conversation.partnerName, equals('John Doe'));
      expect(conversation.unreadCount, equals(0));
    });

    test('should create a Conversation with all parameters', () {
      final conversation = Conversation(
        id: '1',
        partnerId: 'partner1',
        partnerName: 'John Doe',
        partnerEmail: 'john@example.com',
        partnerAvatar: 'https://example.com/avatar.jpg',
        lastMessage: 'Hello!',
        lastMessageAt: testDate,
        unreadCount: 5,
      );
      
      expect(conversation.partnerEmail, equals('john@example.com'));
      expect(conversation.unreadCount, equals(5));
    });

    test('should return correct partner initials for two-word name', () {
      final conversation = Conversation(
        id: '1',
        partnerId: 'partner1',
        partnerName: 'John Doe',
        lastMessage: 'Hello!',
        lastMessageAt: testDate,
      );
      
      expect(conversation.partnerInitials, equals('JD'));
    });

    test('should return correct partner initials for single-word name', () {
      final conversation = Conversation(
        id: '1',
        partnerId: 'partner1',
        partnerName: 'John',
        lastMessage: 'Hello!',
        lastMessageAt: testDate,
      );
      
      expect(conversation.partnerInitials, equals('JO'));
    });

    test('should handle single character name', () {
      final conversation = Conversation(
        id: '1',
        partnerId: 'partner1',
        partnerName: 'J',
        lastMessage: 'Hello!',
        lastMessageAt: testDate,
      );
      
      expect(conversation.partnerInitials, equals('J'));
    });

    test('should convert to JSON correctly', () {
      final conversation = Conversation(
        id: '1',
        partnerId: 'partner1',
        partnerName: 'John Doe',
        partnerEmail: 'john@example.com',
        lastMessage: 'Hello!',
        lastMessageAt: testDate,
        unreadCount: 3,
      );
      
      final json = conversation.toJson();
      
      expect(json['id'], equals('1'));
      expect(json['partnerName'], equals('John Doe'));
      expect(json['unreadCount'], equals(3));
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'partnerId': 'partner1',
        'partnerName': 'John Doe',
        'lastMessage': 'Hello!',
        'lastMessageAt': testDate.toIso8601String(),
        'unreadCount': 5,
      };
      
      final conversation = Conversation.fromJson(json);
      
      expect(conversation.partnerName, equals('John Doe'));
      expect(conversation.unreadCount, equals(5));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = <String, dynamic>{};
      
      final conversation = Conversation.fromJson(json);
      
      expect(conversation.id, equals(''));
      expect(conversation.partnerName, equals('Unknown'));
      expect(conversation.unreadCount, equals(0));
    });

    test('should handle null lastMessageAt in JSON', () {
      final json = {
        'id': '1',
        'partnerId': 'partner1',
        'partnerName': 'John Doe',
        'lastMessage': 'Hello!',
      };
      
      final conversation = Conversation.fromJson(json);
      
      expect(conversation.lastMessageAt, isNotNull);
    });
  });
}
