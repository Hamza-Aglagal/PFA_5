import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/community.dart';
import '../models/simulation.dart';

/// Community Service - Manages friends, sharing, and invitations
class CommunityService extends ChangeNotifier {
  final List<Friend> _friends = [];
  final List<SharedSimulation> _sharedWithMe = [];
  final List<SharedSimulation> _myShares = [];
  final List<Invitation> _invitations = [];
  CommunityStats _stats = const CommunityStats();
  bool _isLoading = false;
  String? _error;

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
    ]);
    _updateStats();
  }

  /// Load friends list
  Future<void> loadFriends([String? userId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _friends.clear();
      _friends.addAll(_generateMockFriends());
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load friends';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load shared simulations
  Future<void> loadSharedSimulations([String? userId]) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _sharedWithMe.clear();
      _myShares.clear();
      
      _sharedWithMe.addAll(_generateMockSharedWithMe());
      _myShares.addAll(_generateMockMyShares());
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load shared simulations';
      notifyListeners();
    }
  }

  /// Load invitations
  Future<void> loadInvitations([String? userId]) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      _invitations.clear();
      _invitations.addAll(_generateMockInvitations());
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load invitations';
      notifyListeners();
    }
  }

  /// Send friend invitation
  Future<bool> sendInvitation({
    required String email,
    String? message,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final invitation = Invitation(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'current_user',
        senderName: 'You',
        recipientEmail: email,
        status: InvitationStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        message: message,
      );
      
      _invitations.insert(0, invitation);
      _updateStats();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send invitation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String friendId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _friends.indexWhere((f) => f.id == friendId);
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

  /// Decline friend request
  Future<bool> declineFriendRequest(String friendId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _friends.removeWhere((f) => f.id == friendId);
      _updateStats();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend(String friendId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _friends.removeWhere((f) => f.id == friendId);
      _updateStats();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Share simulation with a friend
  Future<bool> shareSimulation({
    required Simulation simulation,
    required String friendId,
    SharePermission permission = SharePermission.view,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final friend = _friends.firstWhere((f) => f.id == friendId);
      
      final share = SharedSimulation(
        id: 'share_${DateTime.now().millisecondsSinceEpoch}',
        simulationId: simulation.id,
        simulationName: simulation.name,
        ownerId: 'current_user',
        ownerName: 'You',
        permission: permission,
        sharedAt: DateTime.now(),
        simulationStatus: simulation.status,
        resultStatus: simulation.result?.status,
      );
      
      _myShares.insert(0, share);
      _updateStats();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to share simulation';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove share
  Future<bool> removeShare(String shareId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _myShares.removeWhere((s) => s.id == shareId);
      _updateStats();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Accept invitation
  Future<bool> acceptInvitation(String invitationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _invitations.indexWhere((i) => i.id == invitationId);
      if (index != -1) {
        final invitation = _invitations[index];
        
        // Add as friend
        _friends.add(Friend(
          id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
          name: invitation.senderName,
          email: invitation.recipientEmail,
          avatarUrl: invitation.senderAvatarUrl,
          status: FriendStatus.accepted,
          connectedAt: DateTime.now(),
        ));
        
        // Remove invitation
        _invitations.removeAt(index);
        _updateStats();
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Decline invitation
  Future<bool> declineInvitation(String invitationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _invitations.removeWhere((i) => i.id == invitationId);
      _updateStats();
      notifyListeners();
      return true;
    } catch (e) {
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

  // ==================== MOCK DATA ====================

  List<Friend> _generateMockFriends() {
    return [
      Friend(
        id: 'friend_1',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@example.com',
        status: FriendStatus.accepted,
        connectedAt: DateTime.now().subtract(const Duration(days: 30)),
        isOnline: true,
        sharedSimulations: 3,
      ),
      Friend(
        id: 'friend_2',
        name: 'Michael Chen',
        email: 'michael.chen@example.com',
        status: FriendStatus.accepted,
        connectedAt: DateTime.now().subtract(const Duration(days: 60)),
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        sharedSimulations: 1,
      ),
      Friend(
        id: 'friend_3',
        name: 'Emma Wilson',
        email: 'emma.w@example.com',
        status: FriendStatus.pending,
        connectedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  List<SharedSimulation> _generateMockSharedWithMe() {
    return [
      SharedSimulation(
        id: 'shared_1',
        simulationId: 'sim_ext_1',
        simulationName: 'Highway Bridge Analysis',
        ownerId: 'friend_1',
        ownerName: 'Sarah Johnson',
        permission: SharePermission.view,
        sharedAt: DateTime.now().subtract(const Duration(days: 3)),
        simulationStatus: SimulationStatus.completed,
        resultStatus: ResultStatus.safe,
      ),
      SharedSimulation(
        id: 'shared_2',
        simulationId: 'sim_ext_2',
        simulationName: 'Warehouse Frame',
        ownerId: 'friend_2',
        ownerName: 'Michael Chen',
        permission: SharePermission.edit,
        sharedAt: DateTime.now().subtract(const Duration(days: 7)),
        simulationStatus: SimulationStatus.completed,
        resultStatus: ResultStatus.warning,
      ),
    ];
  }

  List<SharedSimulation> _generateMockMyShares() {
    // Get friends to use in sharedWith
    final friends = _generateMockFriends();
    final sarahJohnson = friends.firstWhere((f) => f.id == 'friend_1');
    final michaelChen = friends.firstWhere((f) => f.id == 'friend_2');
    
    return [
      SharedSimulation(
        id: 'myshare_1',
        simulationId: 'sim_001',
        simulationName: 'Bridge Load Analysis',
        ownerId: 'current_user',
        ownerName: 'You',
        permission: SharePermission.view,
        sharedAt: DateTime.now().subtract(const Duration(days: 1)),
        simulationStatus: SimulationStatus.completed,
        resultStatus: ResultStatus.safe,
        sharedWith: [sarahJohnson, michaelChen],
      ),
    ];
  }

  List<Invitation> _generateMockInvitations() {
    return [
      Invitation(
        id: 'inv_1',
        senderId: 'user_ext_1',
        senderName: 'David Miller',
        recipientEmail: 'you@example.com',
        status: InvitationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        expiresAt: DateTime.now().add(const Duration(days: 6)),
        message: 'Hi! I\'d love to collaborate on some structural projects.',
      ),
    ];
  }
}
