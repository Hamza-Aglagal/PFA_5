# SimStruct Mobile App - Backend Integration TODO

**Document Created:** 2025-12-06
**Last Updated:** 2025-12-06
**Purpose:** Track features that need to be implemented to connect the Flutter mobile app with the Spring Boot backend
**Backend Base URL:** `http://localhost:8080/api/v1`
**WebSocket URL:** `ws://localhost:8080/ws`

---

## Current State Analysis

### ✅ What's COMPLETED:
- **HTTP Client setup** - `http` package added, `api_service.dart` created
- **API Configuration** - `api_config.dart` with base URL for Android emulator
- **Real Authentication** - `auth_service.dart` uses real backend /auth/login and /auth/register
- **JWT Token Storage** - Using `flutter_secure_storage` for secure token management
- **Welcome Toast** - Shows notification popup after successful login

### ❌ What's MISSING (Backend Integration):
1. **Real Notifications** - No backend notification API integration
2. **WebSocket Support** - No STOMP/WebSocket for real-time notifications
3. **Real Community Features** - No backend friendship/chat integration
4. **Real Simulation Features** - No backend simulation API integration

---

## FUNCTION-BY-FUNCTION IMPLEMENTATION PLAN

Each function will be implemented, then tested with the web frontend to ensure backend compatibility.

---

### FUNCTION 0: HTTP Client & API Configuration (PREREQUISITE)
**Priority:** 🔴 CRITICAL - Must be done first
**Status:** ✅ COMPLETED
**Completed:** 2025-12-06

#### Tasks:
- [x] 0.1 Add `http` package to `pubspec.yaml`
- [x] 0.2 Create `lib/core/config/api_config.dart` with base URL
- [x] 0.3 Create `lib/core/services/api_service.dart` (HTTP client with JWT interceptor)
- [x] 0.4 Add secure token storage using `flutter_secure_storage`

#### Files Created:
```
lib/core/
├── config/
│   └── api_config.dart       # Base URL, timeout settings ✅
└── services/
    └── api_service.dart      # HTTP client singleton ✅
```

---

### FUNCTION 1: Authentication (Backend Integration)
**Priority:** 🔴 CRITICAL
**Status:** ✅ COMPLETED
**Completed:** 2025-12-06
**Backend Endpoints:**
- `POST /api/v1/auth/register` - Register new user ✅
- `POST /api/v1/auth/login` - Login user ✅
- `POST /api/v1/auth/logout` - Logout user ✅

#### Tasks:
- [x] 1.1 Update `AuthService` to use `ApiService` for HTTP calls
- [x] 1.2 Implement real `signIn()` with backend `/auth/login`
- [x] 1.3 Implement real `signUp()` with backend `/auth/register`
- [x] 1.4 Implement real `signOut()` with backend `/auth/logout`
- [ ] 1.5 Implement token refresh mechanism (TODO later)
- [x] 1.6 Store JWT token in secure storage
- [x] 1.7 Add token to all authenticated requests (Authorization header)
- [ ] 1.8 Handle 401 errors and auto-logout (TODO later)
- [x] 1.9 Show welcome toast notification after login

#### Test Criteria:
- [x] Login with valid credentials → Token received, user stored
- [x] Login with invalid credentials → Error displayed
- [x] Register new user → Account created, auto-login
- [x] Welcome popup shows after login

---

### FUNCTION 2: User Profile (Backend Integration)
**Priority:** 🟡 MEDIUM
**Status:** ✅ COMPLETED
**Completed:** 2025-12-07
**Backend Endpoints:**
- `GET /api/v1/users/me` - Get current user profile ✅
- `PUT /api/v1/users/me` - Update profile ✅
- `PUT /api/v1/users/me/password` - Change password ✅
- `DELETE /api/v1/users/me` - Delete account ✅

#### Tasks:
- [x] 2.1 Create `lib/core/services/user_service.dart`
- [x] 2.2 Implement `getProfile()` API call
- [x] 2.3 Implement `updateProfile()` API call
- [x] 2.4 Implement `changePassword()` API call
- [x] 2.5 Create `EditProfileSheet` - Professional bottom sheet UI
- [x] 2.6 Create `ChangePasswordSheet` - Secure password change UI
- [x] 2.7 Update `profile_screen.dart` to use real backend

#### Test Criteria:
- [x] Edit Profile → Opens professional bottom sheet
- [x] Update profile → Changes saved to backend
- [x] Change password → Validates and updates on backend
- [x] Success notifications shown after updates

---

### FUNCTION 3: Simulations (Backend Integration) ✅ COMPLETED
**Status:** ✅ COMPLETED
**Completed:** 2025-12-07
**Priority:** 🔴 CRITICAL
**Estimated Time:** 2-3 hours
**Backend Endpoints:**
- `GET /api/v1/simulations` - Get all user simulations ✅
- `GET /api/v1/simulations/{id}` - Get simulation by ID ✅
- `GET /api/v1/simulations/recent` - Get recent simulations ✅
- `GET /api/v1/simulations/favorites` - Get favorites ✅
- `GET /api/v1/simulations/public` - Get community simulations ✅
- `POST /api/v1/simulations` - Create new simulation ✅
- `PUT /api/v1/simulations/{id}` - Update simulation ✅
- `DELETE /api/v1/simulations/{id}` - Delete simulation ✅
- `POST /api/v1/simulations/{id}/favorite` - Toggle favorite ✅
- `POST /api/v1/simulations/{id}/public` - Toggle public ✅

#### Tasks:
- [x] 3.1 Update `lib/core/services/simulation_service.dart` to use `ApiService`
- [x] 3.2 Implement `loadSimulations()` API call (GET all)
- [x] 3.3 Implement `loadFavoriteSimulations()` API call
- [x] 3.4 Implement `loadPublicSimulations()` API call
- [x] 3.5 Implement `createSimulationOnBackend()` API call
- [x] 3.6 Implement `deleteSimulation()` API call
- [x] 3.7 Implement `toggleFavoriteOnBackend()` API call
- [x] 3.8 Implement `togglePublicOnBackend()` API call
- [x] 3.9 Add `_parseSimulationFromBackend()` helper
- [x] 3.10 Update `simulation_screen.dart` to save to backend after run

#### Test Criteria:
- Create simulation → Appears in web frontend
- Run simulation → Results match web frontend
- Delete simulation → Removed from both mobile and web

---

### FUNCTION 4: Notifications (Backend Integration) ✅ COMPLETED
**Priority:** 🔴 CRITICAL
**Status:** ✅ COMPLETED
**Completed:** 2025-12-07
**Backend Endpoints:**
- `GET /api/v1/notifications` - Get all notifications ✅
- `GET /api/v1/notifications/page?page=0&size=20` - Get paginated notifications
- `GET /api/v1/notifications/unread` - Get unread notifications ✅
- `GET /api/v1/notifications/count` - Get notification counts ✅
- `PUT /api/v1/notifications/{id}/read` - Mark as read ✅
- `PUT /api/v1/notifications/read-all` - Mark all as read ✅
- `DELETE /api/v1/notifications/{id}` - Delete notification ✅
- `DELETE /api/v1/notifications` - Delete all notifications ✅

**WebSocket Topic:**
- `/user/{userId}/notifications` - Real-time notification updates (TODO: later)

#### Tasks:
- [ ] 4.1 Add `stomp_dart_client` or `web_socket_channel` package for WebSocket (TODO: later)
- [x] 4.2 Create backend methods in `notification_service.dart`
- [x] 4.3 Implement `loadNotifications()` with real API call
- [x] 4.4 Implement `loadUnreadCount()` API call
- [x] 4.5 Implement `markAsReadOnBackend()` API call
- [x] 4.6 Implement `markAllAsReadOnBackend()` API call
- [x] 4.7 Implement `deleteNotificationOnBackend()` API call
- [x] 4.8 Implement `deleteAllNotificationsOnBackend()` API call
- [ ] 4.9 Implement WebSocket connection for real-time updates (TODO: later)
- [x] 4.10 Update `notification.dart` model to match backend DTO
- [x] 4.11 Map backend `NotificationType` enum to mobile enum
- [x] 4.12 Updated local methods to call backend non-blocking
- [ ] 4.13 Add notification badge to app bar (main screen) (TODO: later)

#### Backend NotificationType Mapping:
```dart
// Backend types → Mobile mapping
SIMULATION_COMPLETE → NotificationCategory.simulation
SIMULATION_FAILED → NotificationCategory.simulation
SIMULATION_SHARED → NotificationCategory.community
SIMULATION_RECEIVED → NotificationCategory.community
FRIEND_REQUEST → NotificationCategory.community
FRIEND_ACCEPTED → NotificationCategory.community
FRIEND_REJECTED → NotificationCategory.community
NEW_MESSAGE → NotificationCategory.community
SYSTEM → NotificationCategory.system
WELCOME → NotificationCategory.system
ACCOUNT_UPDATE → NotificationCategory.account
```

#### Test Criteria:
- [x] Open mobile app → Load notifications from backend
- [x] Mark as read in mobile → Updates on backend
- [x] Delete notification → Removes from backend
- [ ] Real-time: WebSocket push (TODO: later)

---

### FUNCTION 5: Community - Friendships (Backend Integration) ✅ COMPLETED
**Priority:** 🟡 MEDIUM
**Status:** ✅ COMPLETED
**Completed:** 2025-12-07
**Backend Endpoints:**
- `GET /api/v1/friends` - Get all friends ✅
- `GET /api/v1/friends/search` - Search users ✅
- `GET /api/v1/friends/invitations` - Get pending invitations ✅
- `GET /api/v1/friends/sent` - Get sent requests
- `POST /api/v1/friends/request/{receiverId}` - Send friend request ✅
- `POST /api/v1/friends/accept/{senderId}` - Accept request ✅
- `POST /api/v1/friends/reject/{senderId}` - Reject request ✅
- `DELETE /api/v1/friends/{friendId}` - Remove friend ✅

#### Tasks:
- [x] 5.1 Updated `community_service.dart` with backend integration
- [x] 5.2 Implement `loadFriends()` API call with fallback
- [x] 5.3 Implement `loadInvitations()` API call with fallback
- [x] 5.4 Implement `sendFriendRequest()` API call
- [x] 5.5 Implement `acceptFriendRequest()` API call
- [x] 5.6 Implement `declineFriendRequest()` API call
- [x] 5.7 Implement `removeFriend()` API call
- [x] 5.8 Added `searchUsers()` API call
- [x] 5.9 Added `_parseFriendFromBackend()` helper
- [x] 5.10 Added `_parseInvitationFromBackend()` helper

#### Test Criteria:
- [x] Load friends from backend with fallback to mock
- [x] Send friend request to backend
- [x] Accept/reject friend requests on backend

---

### FUNCTION 6: Community - Chat (Backend Integration) ✅ COMPLETED
**Priority:** 🟢 LOW
**Status:** ✅ COMPLETED
**Completed:** 2025-12-07
**Backend Endpoints:**
- `GET /api/v1/chat/conversations` - Get all conversations ✅
- `GET /api/v1/chat/conversation/{friendId}` - Get messages with friend ✅
- `POST /api/v1/chat/send` - Send message ✅
- `POST /api/v1/chat/read/{senderId}` - Mark messages as read ✅
- `GET /api/v1/chat/unread` - Get unread message count ✅

**WebSocket Topics:**
- `/user/{userId}/chat` - Real-time chat messages (TODO: later)

#### Tasks:
- [x] 6.1 Updated `community_service.dart` with chat methods
- [x] 6.2 Implement `loadConversations()` API call with fallback
- [x] 6.3 Implement `loadMessages()` API call with fallback
- [x] 6.4 Implement `sendMessage()` API call
- [x] 6.5 Implement `markMessagesAsRead()` API call
- [x] 6.6 Implement `loadUnreadMessageCount()` API call
- [x] 6.7 Added `Conversation` model to community.dart
- [x] 6.8 Added `_parseMessageFromBackend()` helper
- [ ] 6.9 Implement WebSocket for real-time messages (TODO: later)

#### Test Criteria:
- [x] Load conversations from backend with fallback
- [x] Send message via backend API
- [x] Mark messages as read on backend

---

### FUNCTION 7: Shared Simulations (Backend Integration)
**Priority:** 🟡 MEDIUM
**Estimated Time:** 1-2 hours
**Backend Endpoints:**
- `GET /api/v1/shared-simulations` - Get shared with me
- `GET /api/v1/shared-simulations/my-shares` - Get my shares
- `POST /api/v1/shared-simulations` - Share simulation
- `DELETE /api/v1/shared-simulations/{id}` - Unshare simulation

#### Tasks:
- [ ] 7.1 Create `lib/core/services/shared_simulation_service.dart`
- [ ] 7.2 Implement `getSharedWithMe()` API call
- [ ] 7.3 Implement `getMyShares()` API call
- [ ] 7.4 Implement `shareSimulation()` API call
- [ ] 7.5 Implement `unshareSimulation()` API call
- [ ] 7.6 Update `CommunityService` to use real shared simulations
- [ ] 7.7 Update `community_screen.dart` shared simulations tab

#### Test Criteria:
- Share simulation from mobile → Appears in friend's web view
- Share simulation from web → Appears in mobile shared list

---

## IMPLEMENTATION ORDER

Execute in this order to minimize dependencies:

1. **FUNCTION 0** - HTTP Client & API Config *(PREREQUISITE)*
2. **FUNCTION 1** - Authentication *(Required for all others)*
3. **FUNCTION 4** - Notifications *(Current web frontend focus)*
4. **FUNCTION 3** - Simulations *(Core feature)*
5. **FUNCTION 2** - User Profile
6. **FUNCTION 5** - Friendships
7. **FUNCTION 7** - Shared Simulations
8. **FUNCTION 6** - Chat *(Depends on WebSocket setup from Function 4)*

---

## PACKAGES TO ADD

Add to `pubspec.yaml`:
```yaml
dependencies:
  # HTTP Client
  http: ^1.2.0
  # OR
  dio: ^5.4.0
  
  # WebSocket/STOMP (for real-time notifications)
  stomp_dart_client: ^1.0.0
  # OR  
  web_socket_channel: ^2.4.0
```

---

## TESTING STRATEGY

After implementing each function:
1. Start backend: `cd Backend/simstruct-backend && mvnw spring-boot:run`
2. Start web frontend: `cd Web/simstruct && npm start`
3. Test mobile app locally (no Docker)
4. Verify data sync between mobile and web

### Test Scenarios:
- [ ] Login on mobile → Same user session as web
- [ ] Create data on mobile → Visible on web
- [ ] Create data on web → Visible on mobile
- [ ] Real-time updates via WebSocket

---

## NOTES

- **Android Emulator**: Use `10.0.2.2` instead of `localhost` to access host machine
- **iOS Simulator**: Can use `localhost` directly
- **Real Device**: Use your machine's IP address (e.g., `192.168.1.100`)
- **CORS**: Backend already configured to accept requests from any origin
- **JWT Token**: Include in `Authorization: Bearer {token}` header

---

## PROGRESS TRACKER

| Function | Status | Start Date | End Date | Notes |
|----------|--------|------------|----------|-------|
| Function 0 - API Setup | ✅ Completed | 2025-12-06 | 2025-12-06 | api_config.dart + api_service.dart |
| Function 1 - Auth | ✅ Completed | 2025-12-06 | 2025-12-06 | Real login/register + welcome toast |
| Function 2 - Profile | ✅ Completed | 2025-12-07 | 2025-12-07 | Edit + Change Password sheets |
| Function 3 - Simulations | ✅ Completed | 2025-12-07 | 2025-12-07 | Backend integration for all sim operations |
| Function 4 - Notifications | ⬜ Not Started | | | |
| Function 5 - Friendships | ⬜ Not Started | | | |
| Function 6 - Chat | ⬜ Not Started | | | |
| Function 7 - Shared Sims | ⬜ Not Started | | | |

---

**Legend:**
- ⬜ Not Started
- 🔄 In Progress
- ✅ Completed
- ❌ Blocked
