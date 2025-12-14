/// API Configuration
/// Simple config file for backend URLs

class ApiConfig {
  // For Android Emulator: use 10.0.2.2 (points to host machine localhost)
  // For iOS Simulator: use localhost
  // For Real Device: use your computer's IP address (e.g., 192.168.1.100)
  
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String authMe = '$baseUrl/auth/me';
  
  // User endpoints
  static const String userMe = '$baseUrl/users/me';
  static const String userPassword = '$baseUrl/users/me/password';
  
  // Notification endpoints
  static const String notifications = '$baseUrl/notifications';
  static const String notificationsPage = '$baseUrl/notifications/page';
  static const String notificationsUnread = '$baseUrl/notifications/unread';
  static const String notificationsCount = '$baseUrl/notifications/count';
  static const String notificationsReadAll = '$baseUrl/notifications/read-all';
  
  // Simulation endpoints
  static const String simulations = '$baseUrl/simulations';
  
  // Friendship endpoints
  static const String friends = '$baseUrl/friends';
  static const String friendsSearch = '$baseUrl/friends/search';
  static const String friendsInvitations = '$baseUrl/friends/invitations';
  static const String friendsSent = '$baseUrl/friends/sent';
  // Dynamic: POST /friends/request/{receiverId}
  // Dynamic: POST /friends/accept/{senderId}
  // Dynamic: POST /friends/reject/{senderId}
  // Dynamic: DELETE /friends/cancel/{receiverId}
  // Dynamic: DELETE /friends/{friendId}
  
  // Chat endpoints
  static const String chatConversations = '$baseUrl/chat/conversations';
  static const String chatSend = '$baseUrl/chat/send';
  static const String chatUnread = '$baseUrl/chat/unread';
  // Dynamic: GET /chat/conversation/{friendId}
  // Dynamic: POST /chat/read/{senderId}
  
  // Shared Simulation endpoints
  static const String sharesMyShares = '$baseUrl/shares/my-shares';
  static const String sharesSharedWithMe = '$baseUrl/shares/shared-with-me';
  static const String shares = '$baseUrl/shares';
  // Dynamic: GET /shares/with-friend/{friendId}
  // Dynamic: POST /shares?simulationId=...&friendId=...&permission=...
  // Dynamic: DELETE /shares/{shareId}
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
}
