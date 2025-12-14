import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/community.dart';
import '../models/simulation.dart';
import 'api_service.dart';

/// Community Service - Manages friends, sharing, and invitations
class CommunityService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Friend> _friends = [];
  final List<SharedSimulation> _sharedWithMe = [];
  final List<SharedSimulation> _myShares = [];
  final List<Invitation> _invitations = [];
  final List<ChatMessage> _messages = [];
  final List<Conversation> _conversations = [];
  CommunityStats _stats = const CommunityStats();
  bool _isLoading = false;
  String? _error;
  int _unreadMessageCount = 0;

  // Additional getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<Conversation> get conversations => List.unmodifiable(_conversations);
  int get unreadMessageCount => _unreadMessageCount;

  // Getters
  List<Friend> get friends => List.unmodifiable(_friends);
  List<Friend> get onlineFriends => _friends.where((f) => f.isOnline).toList();
  List<Friend> get pendingFriends =>
      _friends.where((f) => f.status == FriendStatus.pending).toList();
  List<SharedSimulation> get sharedWithMe => List.unmodifiable(_sharedWithMe);
  List<SharedSimulation> get sharedSimulations => [..._sharedWithMe, ..._myShares];
  List<SharedSimulation> get myShares => List.unmodifiable(_myShares);
  List<Invitation> get invitations => List.unmodifiable(_invitations);
  List<Invitation> get pendingInvitations =>
      _invitations.where((i) => i.status == InvitationStatus.pending).toList();
  CommunityStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize community data
  Future<void> initialize([String? userId]) async {
    await Future.wait([
      loadFriends(userId),
      loadSharedSimulations(userId),
      loadInvitations(userId),
      loadConversations(),
      loadUnreadMessageCount(),
    ]);
    _updateStats();
  }

  /// Load friends list from backend
  Future<void> loadFriends([String? userId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConfig.friends);
      debugPrint('loadFriends response: ${response.success}, data: ${response.data}');
      
      _friends.clear();
      
      if (response.success && response.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> data = response.data is List 
            ? response.data 
            : (response.data['data'] ?? []);
        _friends.addAll(data.map((json) => _parseFriendFromBackend(json as Map<String, dynamic>)).toList());
        debugPrint('Loaded ${_friends.length} friends from backend');
      }
      // No fallback to mock - show empty list if no friends
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading friends: $e');
      // Show empty list on error
      _friends.clear();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parse Friend from backend FriendDTO
  Friend _parseFriendFromBackend(Map<String, dynamic> json) {
    return Friend(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      status: FriendStatus.accepted,
      connectedAt: json['connectedAt'] != null 
          ? DateTime.parse(json['connectedAt']) 
          : DateTime.now(),
      isOnline: json['status'] == 'online',
      sharedSimulations: json['sharedSimulations'] ?? 0,
    );
  }

  /// Load shared simulations from backend
  Future<void> loadSharedSimulations([String? userId]) async {
    try {
      _sharedWithMe.clear();
      _myShares.clear();
      
      // Load simulations shared with me
      final sharedWithMeResponse = await _apiService.get(ApiConfig.sharesSharedWithMe);
      debugPrint('Shared with me response: ${sharedWithMeResponse.success}');
      if (sharedWithMeResponse.success && sharedWithMeResponse.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> data = sharedWithMeResponse.data is List 
            ? sharedWithMeResponse.data 
            : (sharedWithMeResponse.data['data'] ?? []);
        _sharedWithMe.addAll(data.map((json) => _parseSharedSimulationFromBackend(json as Map<String, dynamic>)).toList());
      }
      
      // Load my shares
      final mySharesResponse = await _apiService.get(ApiConfig.sharesMyShares);
      debugPrint('My shares response: ${mySharesResponse.success}');
      if (mySharesResponse.success && mySharesResponse.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> data = mySharesResponse.data is List 
            ? mySharesResponse.data 
            : (mySharesResponse.data['data'] ?? []);
        _myShares.addAll(data.map((json) => _parseSharedSimulationFromBackend(json as Map<String, dynamic>)).toList());
      }
      
      debugPrint('Loaded ${_sharedWithMe.length} shared with me, ${_myShares.length} my shares');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading shared simulations: $e');
      _error = 'Failed to load shared simulations';
      notifyListeners();
    }
  }

  /// Parse SharedSimulation from backend SharedSimulationDTO
  SharedSimulation _parseSharedSimulationFromBackend(Map<String, dynamic> json) {
    return SharedSimulation(
      id: json['id']?.toString() ?? '',
      simulationId: json['simulationId']?.toString() ?? '',
      simulationName: json['simulationName'] ?? 'Untitled',
      // Backend uses sharedById/sharedByName
      ownerId: json['sharedById']?.toString() ?? json['ownerId']?.toString() ?? '',
      ownerName: json['sharedByName'] ?? json['ownerName'] ?? 'Unknown',
      description: json['simulationDescription'] ?? json['message'],
      permission: _parseSharePermission(json['permission']),
      sharedAt: json['sharedAt'] != null 
          ? DateTime.parse(json['sharedAt']) 
          : DateTime.now(),
      simulationStatus: SimulationStatus.completed,
      resultStatus: json['isSafe'] == true ? ResultStatus.safe : (json['isSafe'] == false ? ResultStatus.critical : null),
    );
  }

  /// Parse share permission
  SharePermission _parseSharePermission(String? permission) {
    switch (permission?.toUpperCase()) {
      case 'EDIT':
        return SharePermission.edit;
      case 'ADMIN':
        return SharePermission.admin;
      default:
        return SharePermission.view;
    }
  }

  /// Load invitations from backend
  Future<void> loadInvitations([String? userId]) async {
    try {
      final response = await _apiService.get(ApiConfig.friendsInvitations);
      debugPrint('loadInvitations response: ${response.success}, data: ${response.data}');
      
      _invitations.clear();
      
      if (response.success && response.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> data = response.data is List 
            ? response.data 
            : (response.data['data'] ?? []);
        _invitations.addAll(data.map((json) => _parseInvitationFromBackend(json as Map<String, dynamic>)).toList());
        debugPrint('Loaded ${_invitations.length} invitations from backend');
      }
      // No fallback to mock - show empty list if no invitations
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading invitations: $e');
      _invitations.clear();
      notifyListeners();
    }
  }

  /// Parse Invitation from backend InvitationDTO
  Invitation _parseInvitationFromBackend(Map<String, dynamic> json) {
    return Invitation(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      recipientId: json['recipientId']?.toString(),
      recipientEmail: json['recipientEmail'] ?? '',
      status: _parseInvitationStatus(json['status']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  /// Parse invitation status from backend
  InvitationStatus _parseInvitationStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return InvitationStatus.pending;
      case 'ACCEPTED':
        return InvitationStatus.accepted;
      case 'DECLINED':
      case 'REJECTED':
        return InvitationStatus.declined;
      default:
        return InvitationStatus.pending;
    }
  }

  /// Send friend invitation (search user first, then send request)
  Future<bool> sendInvitation({
    required String email,
    String? message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Search for user by email first
      final searchResponse = await _apiService.get(
        '${ApiConfig.friendsSearch}?query=$email',
      );
      debugPrint('Search response: ${searchResponse.success}, data: ${searchResponse.data}');
      
      if (searchResponse.success && searchResponse.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> users = searchResponse.data is List 
            ? searchResponse.data 
            : (searchResponse.data['data'] ?? []);
        debugPrint('Found ${users.length} users matching email: $email');
        
        if (users.isNotEmpty) {
          final userId = users.first['id']?.toString();
          debugPrint('Sending friend request to user ID: $userId');
          if (userId != null) {
            _isLoading = false;
            return await sendFriendRequest(userId);
          }
        }
      }
      
      // User not found
      _error = 'User not found with email: $email';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error sending invitation: $e');
      _error = 'Failed to send invitation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send friend request to user by ID (backend call)
  Future<bool> sendFriendRequest(String receiverId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      debugPrint('Sending friend request to: $receiverId');
      final response = await _apiService.post(
        '${ApiConfig.friends}/request/$receiverId',
      );
      debugPrint('Friend request response: ${response.success}, message: ${response.message}');
      
      _isLoading = false;
      
      if (response.success) {
        // Reload invitations to show updated list
        await loadInvitations();
        _updateStats();
        notifyListeners();
        return true;
      }
      
      _error = response.message;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      _error = 'Failed to send friend request';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Search users to add as friends
  Future<List<Friend>> searchUsers(String query) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.friendsSearch}?query=$query',
      );
      
      if (response.success && response.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> data = response.data is List 
            ? response.data 
            : (response.data['data'] ?? []);
        return data.map((json) => _parseFriendFromBackend(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  /// Accept friend request (calls backend)
  Future<bool> acceptFriendRequest(String senderId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.friends}/accept/$senderId',
      );
      
      if (response.success) {
        // Reload friends and invitations
        await Future.wait([
          loadFriends(),
          loadInvitations(),
        ]);
        _updateStats();
        notifyListeners();
        return true;
      }
      
      // Fallback: local update
      final index = _friends.indexWhere((f) => f.id == senderId);
      if (index != -1) {
        _friends[index] = Friend(
          id: _friends[index].id,
          name: _friends[index].name,
          email: _friends[index].email,
          avatarUrl: _friends[index].avatarUrl,
          status: FriendStatus.accepted,
          connectedAt: DateTime.now(),
          isOnline: _friends[index].isOnline,
          lastSeen: _friends[index].lastSeen,
          sharedSimulations: _friends[index].sharedSimulations,
        );
        _updateStats();
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Decline friend request (calls backend)
  Future<bool> declineFriendRequest(String senderId) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.friends}/reject/$senderId',
      );
      
      if (response.success) {
        await loadInvitations();
        _updateStats();
        notifyListeners();
        return true;
      }
      
      // Fallback: local update
      _friends.removeWhere((f) => f.id == senderId);
      _updateStats();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove friend (calls backend)
  Future<bool> removeFriend(String friendId) async {
    try {
      final response = await _apiService.delete(
        '${ApiConfig.friends}/$friendId',
      );
      
      // Always update locally for responsive UI
      _friends.removeWhere((f) => f.id == friendId);
      _updateStats();
      notifyListeners();
      
      return response.success;
    } catch (e) {
      // Still remove locally
      _friends.removeWhere((f) => f.id == friendId);
      _updateStats();
      notifyListeners();
      return false;
    }
  }

  /// Share simulation with a friend (calls backend)
  Future<bool> shareSimulation({
    required Simulation simulation,
    required String friendId,
    SharePermission permission = SharePermission.view,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Map permission to backend format
      String backendPermission = 'VIEW';
      if (permission == SharePermission.edit) {
        backendPermission = 'EDIT';
      } else if (permission == SharePermission.admin) {
        backendPermission = 'ADMIN';
      }
      
      // Call backend to share
      final response = await _apiService.post(
        '${ApiConfig.shares}?simulationId=${simulation.id}&friendId=$friendId&permission=$backendPermission',
      );
      
      if (response.success) {
        // Reload shared simulations
        await loadSharedSimulations();
        _updateStats();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to share simulation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove share (calls backend)
  Future<bool> removeShare(String shareId) async {
    try {
      final response = await _apiService.delete('${ApiConfig.shares}/$shareId');
      
      if (response.success) {
        _myShares.removeWhere((s) => s.id == shareId);
        _updateStats();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Accept invitation (calls backend with senderId)
  Future<bool> acceptInvitation(String invitationId) async {
    try {
      // Find the invitation to get senderId
      final invitationIndex = _invitations.indexWhere((i) => i.id == invitationId);
      if (invitationIndex == -1) {
        debugPrint('Invitation not found: $invitationId');
        return false;
      }
      
      final invitation = _invitations[invitationIndex];
      debugPrint('Accepting invitation from senderId: ${invitation.senderId}');
      
      // Call backend to accept friend request using senderId
      final response = await _apiService.post(
        '${ApiConfig.friends}/accept/${invitation.senderId}',
      );
      debugPrint('Accept response: ${response.success}, message: ${response.message}');
      
      if (response.success) {
        // Reload friends and invitations from backend
        await Future.wait([
          loadFriends(),
          loadInvitations(),
        ]);
        _updateStats();
        notifyListeners();
        return true;
      }
      
      // Fallback: local update
      _invitations.removeWhere((i) => i.id == invitationId);
      _updateStats();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      return false;
    }
  }

  /// Decline invitation (calls backend with senderId)
  Future<bool> declineInvitation(String invitationId) async {
    try {
      // Find the invitation to get senderId
      final invitationIndex = _invitations.indexWhere((i) => i.id == invitationId);
      if (invitationIndex == -1) {
        debugPrint('Invitation not found for decline: $invitationId');
        return false;
      }
      
      final invitation = _invitations[invitationIndex];
      debugPrint('Declining invitation from senderId: ${invitation.senderId}');
      
      // Call backend to reject friend request
      final response = await _apiService.post(
        '${ApiConfig.friends}/reject/${invitation.senderId}',
      );
      debugPrint('Reject response: ${response.success}, message: ${response.message}');
      
      if (response.success) {
        await loadInvitations();
        _updateStats();
        notifyListeners();
        return true;
      }
      
      // Fallback: local update
      _invitations.removeWhere((i) => i.id == invitationId);
      _updateStats();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error declining invitation: $e');
      return false;
    }
  }

  /// Respond to invitation (accept or decline)
  Future<bool> respondToInvitation(String invitationId, bool accept) async {
    return accept ? acceptInvitation(invitationId) : declineInvitation(invitationId);
  }

  /// Search friends
  List<Friend> searchFriends(String query) {
    if (query.isEmpty) return _friends;
    final lowerQuery = query.toLowerCase();
    return _friends.where((f) {
      return f.name.toLowerCase().contains(lowerQuery) ||
          f.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Update stats
  void _updateStats() {
    _stats = CommunityStats(
      totalFriends: _friends.where((f) => f.status == FriendStatus.accepted).length,
      pendingInvitations: pendingInvitations.length,
      sharedSimulations: _myShares.length,
      receivedShares: _sharedWithMe.length,
    );
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==================== CHAT METHODS (Function 6) ====================

  /// Load all conversations from backend
  Future<void> loadConversations() async {
    try {
      final response = await _apiService.get(ApiConfig.chatConversations);
      debugPrint('loadConversations response: ${response.success}');
      
      _conversations.clear();
      
      if (response.success && response.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> data = response.data is List 
            ? response.data 
            : (response.data['data'] ?? []);
        _conversations.addAll(data.map((json) => Conversation.fromJson(json as Map<String, dynamic>)).toList());
        debugPrint('Loaded ${_conversations.length} conversations');
      }
      // No fallback to mock - show empty list if no conversations
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      _conversations.clear();
      notifyListeners();
    }
  }

  /// Load messages for a specific conversation/friend
  Future<List<ChatMessage>> loadMessages(String friendId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.baseUrl}/chat/conversation/$friendId',
      );
      debugPrint('loadMessages response for $friendId: ${response.success}');
      
      if (response.success && response.data != null) {
        // ApiService already extracts data from response.data field
        final List<dynamic> data = response.data is List 
            ? response.data 
            : (response.data['data'] ?? []);
        return data.map((json) => _parseMessageFromBackend(json as Map<String, dynamic>)).toList();
      }
      
      // No fallback to mock - return empty list if no messages
      return [];
    } catch (e) {
      debugPrint('Error loading messages: $e');
      return [];
    }
  }

  /// Parse ChatMessage from backend ChatMessageDTO
  ChatMessage _parseMessageFromBackend(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      sentAt: json['sentAt'] != null 
          ? DateTime.parse(json['sentAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      simulationId: json['relatedSimulationId'],
    );
  }

  /// Send a message to a friend
  Future<ChatMessage?> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.chatSend,
        body: {
          'receiverId': receiverId,
          'content': content,
        },
      );
      debugPrint('sendMessage response: ${response.success}');
      
      if (response.success && response.data != null) {
        final msgData = response.data is Map ? response.data : {};
        final message = _parseMessageFromBackend(msgData as Map<String, dynamic>);
        _messages.add(message);
        
        // Update conversation list
        await loadConversations();
        notifyListeners();
        return message;
      }
      
      // Backend failed - show error
      _error = response.message;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error sending message: $e');
      _error = 'Failed to send message';
      notifyListeners();
      return null;
    }
  }

  /// Mark messages from a sender as read
  Future<void> markMessagesAsRead(String senderId) async {
    try {
      await _apiService.post(
        '${ApiConfig.baseUrl}/chat/read/$senderId',
      );
      
      // Update local messages
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].senderId == senderId && !_messages[i].isRead) {
          _messages[i] = ChatMessage(
            id: _messages[i].id,
            senderId: _messages[i].senderId,
            senderName: _messages[i].senderName,
            senderAvatarUrl: _messages[i].senderAvatarUrl,
            content: _messages[i].content,
            sentAt: _messages[i].sentAt,
            isRead: true,
            simulationId: _messages[i].simulationId,
          );
        }
      }
      
      // Reload unread count
      await loadUnreadMessageCount();
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }

  /// Load unread message count from backend
  Future<void> loadUnreadMessageCount() async {
    try {
      final response = await _apiService.get(ApiConfig.chatUnread);
      
      if (response.success && response.data != null) {
        // Handle different response formats
        if (response.data is int) {
          _unreadMessageCount = response.data;
        } else if (response.data is Map) {
          _unreadMessageCount = response.data['count'] ?? response.data['unread'] ?? 0;
        } else {
          _unreadMessageCount = 0;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
      // Silent fail
    }
  }
}
