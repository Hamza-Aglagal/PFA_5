# SimStruct Web Application - Development TODO

## 📋 Project Overview

**Tech Stack:**
- Frontend: Angular 21 (Standalone Components)
- Backend: Spring Boot (Docker)
- Database: PostgreSQL (Docker)
- Real-time: WebSocket (STOMP)
- 3D Visualization: Three.js

**Current State:** Frontend UI is built with mock data. Backend is initialized but APIs need implementation.

---

## 🔐 FUNCTION 1: AUTHENTICATION & USER MANAGEMENT ✅ COMPLETED

### Description
Complete authentication system with JWT tokens, session management, and user profile management.

### Status: FULLY IMPLEMENTED
- Backend: User entity, JWT security, Auth controller, User controller
- Frontend: Auth service, interceptor, guards, login, register, profile components
- Features: Login, register, logout, profile update, password change, reactive navbar, toast notifications

### Frontend Files
- `src/app/pages/login/login.component.ts` ✅
- `src/app/pages/register/register.component.ts` ✅
- `src/app/pages/profile/profile.component.ts` ✅
- `src/app/core/services/auth.service.ts` ✅
- `src/app/core/services/notification.service.ts` ✅
- `src/app/core/guards/auth.guard.ts` ✅
- `src/app/core/interceptors/auth.interceptor.ts` ✅
- `src/app/shared/components/navbar/navbar.component.ts` ✅

### Backend Files Created
- `entity/User.java` ✅
- `repository/UserRepository.java` ✅
- `service/AuthService.java` ✅
- `service/UserService.java` ✅
- `controller/AuthController.java` ✅
- `controller/UserController.java` ✅
- `security/JwtTokenProvider.java` ✅
- `security/JwtAuthenticationFilter.java` ✅
- `config/SecurityConfig.java` ✅
- `dto/RegisterRequest.java` ✅
- `dto/LoginRequest.java` ✅
- `dto/AuthResponse.java` ✅
- `dto/UserResponse.java` ✅

### Backend Endpoints Implemented
```
POST /api/v1/auth/register ✅
POST /api/v1/auth/login ✅
POST /api/v1/auth/refresh ✅
POST /api/v1/auth/logout ✅
GET  /api/v1/users/me ✅
PUT  /api/v1/users/me ✅
PUT  /api/v1/users/me/password ✅
DELETE /api/v1/users/me ✅
```

### Steps Completed
- [x] Step 1.1: Backend - Create User Entity & Repository
- [x] Step 1.2: Backend - JWT Security Configuration  
- [x] Step 1.3: Backend - Auth Controller & Service
- [x] Step 1.4: Backend - User Controller & Service
- [x] Step 1.5: Frontend - Auth Service Integration
- [x] Step 1.6: Frontend - HTTP Interceptor
- [x] Step 1.7: Frontend - Login Component
- [x] Step 1.8: Frontend - Register Component
- [x] Step 1.9: Frontend - Profile Component
- [x] Step 1.10: Frontend - Auth Guard

#### Step 1.7: Frontend - Login Component
- [ ] Connect form to `AuthService.login()`
- [ ] Handle success/error responses
- [ ] Show loading state during API call
- [ ] Redirect to dashboard on success

#### Step 1.8: Frontend - Register Component
- [ ] Connect form to `AuthService.register()`
- [ ] Add password confirmation validation
- [ ] Show validation errors from backend
- [ ] Redirect after successful registration

#### Step 1.9: Frontend - Profile Component
- [ ] Load user data from `GET /users/me`
- [ ] Implement profile update with `PUT /users/me`
- [ ] Implement password change with `PUT /users/me/password`
- [ ] Implement account deletion with `DELETE /users/me`
- [ ] Add avatar upload functionality (bonus)

#### Step 1.10: Frontend - Auth Guard
- [ ] Update `auth.guard.ts` to verify token validity
- [ ] Store redirect URL for post-login navigation
- [ ] Handle expired tokens

---

## 📊 FUNCTION 2: SIMULATION ENGINE ✅ COMPLETED

### Description
Core simulation functionality for structural analysis with 3D visualization.

### Status: FULLY IMPLEMENTED
- Backend: Simulation entity, result calculations, CRUD operations
- Frontend: Simulation service, connected pages
- Features: Create simulation, view results, history with real data

### Frontend Files
- `src/app/pages/simulation/simulation.component.ts` ✅
- `src/app/pages/results/results.component.ts` ✅
- `src/app/pages/history/history.component.ts` ✅
- `src/app/core/services/simulation.service.ts` ✅

### Backend Files Created
- `entity/Simulation.java` ✅
- `entity/SimulationResult.java` ✅
- `repository/SimulationRepository.java` ✅
- `service/SimulationEngine.java` ✅
- `service/SimulationService.java` ✅
- `controller/SimulationController.java` ✅
- `dto/SimulationRequest.java` ✅
- `dto/SimulationResponse.java` ✅

### Backend Endpoints Implemented
```
POST /api/v1/simulations ✅
GET  /api/v1/simulations ✅
GET  /api/v1/simulations/recent ✅
GET  /api/v1/simulations/favorites ✅
GET  /api/v1/simulations/search?q=query ✅
GET  /api/v1/simulations/{id} ✅
PUT  /api/v1/simulations/{id} ✅
DELETE /api/v1/simulations/{id} ✅
POST /api/v1/simulations/{id}/favorite ✅
POST /api/v1/simulations/{id}/public ✅
GET  /api/v1/simulations/public ✅
GET  /api/v1/simulations/public/search?q=query ✅
```

### Simulation Engine Features
- Simply Supported Beam calculations
- Cantilever (Fixed-Free) calculations
- Fixed-Fixed Beam calculations
- Max Deflection, Bending Moment, Shear Force
- Stress calculation and Safety Factor
- Material support: STEEL, CONCRETE, ALUMINUM, WOOD, COMPOSITE
- Load types: POINT, DISTRIBUTED, UNIFORM, MOMENT
- Automatic recommendations based on safety factor

### Steps Completed
- [x] Step 2.1: Backend - Simulation Entity & Repository
- [x] Step 2.2: Backend - Simulation Analysis Engine
- [x] Step 2.3: Backend - Simulation Controller & Service
- [x] Step 2.4: Frontend - Create Simulation Service
- [x] Step 2.5: Frontend - Simulation Component
- [x] Step 2.6: Frontend - Results Component
- [x] Step 2.7: Frontend - History Component

---

## 💬 FUNCTION 3: REAL-TIME CHAT

### Description
Real-time messaging system between users using WebSocket.

### Frontend Files
- `src/app/pages/chat/chat.component.ts`
- `src/app/shared/components/chat-panel/chat-panel.component.ts`

### Backend Endpoints Needed
```
GET  /api/v1/chat/conversations
POST /api/v1/chat/conversations
GET  /api/v1/chat/conversations/{id}/messages
POST /api/v1/chat/conversations/{id}/messages
PUT  /api/v1/chat/conversations/{id}/read
DELETE /api/v1/chat/conversations/{id}
WebSocket: /ws/chat
```

### Steps to Complete

#### Step 3.1: Backend - Chat Entities
- [ ] Create `Conversation` entity (id, participants, createdAt, updatedAt)
- [ ] Create `ChatMessage` entity (id, conversationId, senderId, content, sentAt, isRead)
- [ ] Create `ConversationParticipant` entity for many-to-many
- [ ] Create repositories for all entities

#### Step 3.2: Backend - WebSocket Configuration
- [ ] Add Spring WebSocket dependencies
- [ ] Create `WebSocketConfig` class
- [ ] Configure STOMP broker
- [ ] Add WebSocket security configuration

#### Step 3.3: Backend - Chat Controller & Service
- [ ] Create `ChatController` for REST endpoints
- [ ] Create `ChatService` for business logic
- [ ] Create `ChatWebSocketController` for real-time messaging
- [ ] Create DTOs: `ConversationResponse`, `MessageRequest`, `MessageResponse`

#### Step 3.4: Backend - Message Delivery
- [ ] Implement message persistence
- [ ] Implement message broadcast via WebSocket
- [ ] Implement read receipts
- [ ] Implement typing indicators (bonus)
- [ ] Implement online/offline status (bonus)

#### Step 3.5: Frontend - Create Chat Service
- [ ] Create `chat.service.ts` in core/services
- [ ] Implement WebSocket connection with STOMP
- [ ] Handle connection/disconnection
- [ ] Implement message sending/receiving
- [ ] Manage conversation state

#### Step 3.6: Frontend - Chat Component
- [ ] Connect to real conversations from API
- [ ] Send messages through WebSocket
- [ ] Receive messages in real-time
- [ ] Implement scroll to bottom on new message
- [ ] Mark messages as read
- [ ] Show online status

#### Step 3.7: Frontend - Chat Panel (Sidebar)
- [ ] Show conversation list with unread counts
- [ ] Real-time updates for new messages
- [ ] Quick reply functionality
- [ ] Notification sound (bonus)

#### Step 3.8: Frontend - Chat Features
- [ ] Typing indicator display
- [ ] Message timestamps (just now, 5m ago, etc.)
- [ ] Unread message counter in navbar
- [ ] Message search (bonus)

---

## 🔔 FUNCTION 4: NOTIFICATIONS SYSTEM

### Description
Real-time notifications for various application events.

### Frontend Files
- `src/app/shared/components/navbar/navbar.component.ts`
- `src/app/shared/components/notification-popup/` (needs creation)
- `src/app/shared/components/toast/`

### Backend Endpoints Needed
```
GET  /api/v1/notifications
PUT  /api/v1/notifications/{id}/read
PUT  /api/v1/notifications/read-all
DELETE /api/v1/notifications/{id}
GET  /api/v1/notifications/unread-count
WebSocket: /ws/notifications
```

### Steps to Complete

#### Step 4.1: Backend - Notification Entity
- [ ] Create `Notification` entity (id, userId, type, title, message, data, isRead, createdAt)
- [ ] Create `NotificationType` enum (SIMULATION_COMPLETE, FRIEND_REQUEST, MESSAGE, SHARE, SYSTEM)
- [ ] Create `NotificationRepository`

#### Step 4.2: Backend - Notification Service
- [ ] Create `NotificationService` for CRUD operations
- [ ] Create method to create notifications
- [ ] Implement WebSocket broadcast for new notifications
- [ ] Implement batch mark as read

#### Step 4.3: Backend - Notification Controller
- [ ] Create `NotificationController` with endpoints
- [ ] Create DTOs: `NotificationResponse`, `NotificationListResponse`
- [ ] Add pagination support

#### Step 4.4: Backend - Notification Triggers
- [ ] Trigger notification on simulation complete
- [ ] Trigger notification on friend request
- [ ] Trigger notification on new message
- [ ] Trigger notification on simulation shared
- [ ] Trigger notification on friend accepted

#### Step 4.5: Frontend - Create Notification Service
- [ ] Create `notification.service.ts`
- [ ] Implement REST API calls
- [ ] Implement WebSocket subscription
- [ ] Manage notification state (signals)

#### Step 4.6: Frontend - Notification Popup Component
- [ ] Create `notification-popup.component.ts`
- [ ] Display notification list with types
- [ ] Mark as read on click
- [ ] Mark all as read button
- [ ] Delete notification

#### Step 4.7: Frontend - Navbar Integration
- [ ] Show unread notification count badge
- [ ] Real-time count updates
- [ ] Toggle notification panel
- [ ] Click to navigate to related item

#### Step 4.8: Frontend - Toast Notifications
- [ ] Show toast for new notifications
- [ ] Different styles for notification types
- [ ] Auto-dismiss after timeout
- [ ] Click to navigate

---

## 👥 FUNCTION 5: COMMUNITY & SOCIAL FEATURES

### Description
Friend system, simulation sharing, and community exploration.

### Frontend Files
- `src/app/pages/community/community.component.ts`
- `src/app/pages/community/simulation-detail/simulation-detail.component.ts`

### Backend Endpoints Needed
```
# Friends
GET  /api/v1/friends
POST /api/v1/friends/request/{userId}
PUT  /api/v1/friends/accept/{friendshipId}
DELETE /api/v1/friends/{friendshipId}
GET  /api/v1/friends/pending
GET  /api/v1/friends/requests

# Invitations
POST /api/v1/invitations
GET  /api/v1/invitations/sent
GET  /api/v1/invitations/received
PUT  /api/v1/invitations/{id}/accept
DELETE /api/v1/invitations/{id}

# User Search
GET  /api/v1/users/search?q={query}

# Shared Simulations
POST /api/v1/shared-simulations
GET  /api/v1/shared-simulations/sent
GET  /api/v1/shared-simulations/received
GET  /api/v1/shared-simulations/with/{userId}
DELETE /api/v1/shared-simulations/{id}

# Public Simulations
GET  /api/v1/simulations/public
POST /api/v1/simulations/{id}/like
DELETE /api/v1/simulations/{id}/like
POST /api/v1/simulations/{id}/comment
GET  /api/v1/simulations/{id}/comments
```

### Steps to Complete

#### Step 5.1: Backend - Friendship Entity
- [ ] Create `Friendship` entity (id, requesterId, addresseeId, status, createdAt)
- [ ] Create `FriendshipStatus` enum (PENDING, ACCEPTED, REJECTED, BLOCKED)
- [ ] Create `FriendshipRepository` with custom queries

#### Step 5.2: Backend - Invitation Entity
- [ ] Create `Invitation` entity (id, senderId, recipientEmail, message, status, createdAt, expiresAt)
- [ ] Create `InvitationRepository`

#### Step 5.3: Backend - SharedSimulation Entity
- [ ] Create `SharedSimulation` entity (id, simulationId, sharedById, sharedWithId, permission, message, sharedAt)
- [ ] Create `SharePermission` enum (VIEW, EDIT, FULL)
- [ ] Create `SharedSimulationRepository`

#### Step 5.4: Backend - Like & Comment Entities
- [ ] Create `SimulationLike` entity (id, userId, simulationId, createdAt)
- [ ] Create `SimulationComment` entity (id, userId, simulationId, content, createdAt)
- [ ] Create repositories

#### Step 5.5: Backend - Friends Controller & Service
- [ ] Create `FriendsController` with all endpoints
- [ ] Create `FriendsService` with business logic
- [ ] Create DTOs: `FriendResponse`, `FriendRequestResponse`
- [ ] Send notifications on friend request/accept

#### Step 5.6: Backend - Invitation Controller & Service
- [ ] Create `InvitationController`
- [ ] Create `InvitationService`
- [ ] Create DTOs: `InvitationRequest`, `InvitationResponse`
- [ ] Send email for invitations (bonus)

#### Step 5.7: Backend - User Search
- [ ] Add search endpoint to `UserController`
- [ ] Implement search by name/email
- [ ] Exclude current user from results
- [ ] Indicate existing friendship status

#### Step 5.8: Backend - Shared Simulation Controller
- [ ] Create `SharedSimulationController`
- [ ] Create `SharedSimulationService`
- [ ] Create DTOs for sharing
- [ ] Send notification on share

#### Step 5.9: Backend - Public Simulations & Interactions
- [ ] Add public simulations endpoint
- [ ] Implement like/unlike functionality
- [ ] Implement comments CRUD
- [ ] Add like count and view count tracking

#### Step 5.10: Frontend - Create Community Service
- [ ] Create `community.service.ts`
- [ ] Implement friends API calls
- [ ] Implement invitation API calls
- [ ] Implement user search
- [ ] Implement simulation sharing

#### Step 5.11: Frontend - Community Component - Explore Tab
- [ ] Load public simulations from API
- [ ] Implement filtering (structure type, material)
- [ ] Implement sorting (recent, popular, views)
- [ ] Implement search
- [ ] Like/unlike functionality
- [ ] View simulation details

#### Step 5.12: Frontend - Community Component - Friends Tab
- [ ] Display friends list from API
- [ ] Open chat with friend
- [ ] Remove friend functionality
- [ ] Show shared simulation count

#### Step 5.13: Frontend - Community Component - Invitations Tab
- [ ] Show received friend requests
- [ ] Show sent invitations
- [ ] Accept/decline requests
- [ ] Cancel sent invitations
- [ ] Send new invitations (email or search)

#### Step 5.14: Frontend - Community Component - My Shares Tab
- [ ] Show simulations I've shared
- [ ] Show simulations shared with me
- [ ] Manage sharing permissions
- [ ] Remove sharing

#### Step 5.15: Frontend - Simulation Detail Page
- [ ] Load simulation details
- [ ] Display results and 3D view
- [ ] Like/unlike button
- [ ] Comments section
- [ ] Share button
- [ ] Download/clone option

---

## 🐳 FUNCTION 6: DOCKER SETUP

### Description
Docker configuration for development and production.

### Steps to Complete

#### Step 6.1: Backend Dockerfile
- [ ] Create `Dockerfile` for Spring Boot application
- [ ] Multi-stage build for smaller image
- [ ] Configure JVM options

#### Step 6.2: Frontend Dockerfile
- [ ] Create `Dockerfile` for Angular application
- [ ] Build stage with Node.js
- [ ] Production stage with Nginx
- [ ] Configure Nginx for SPA routing

#### Step 6.3: Docker Compose - Development
- [ ] Create `docker-compose.dev.yml`
- [ ] PostgreSQL service with volume
- [ ] Backend service with hot reload
- [ ] Frontend service with hot reload
- [ ] Network configuration

#### Step 6.4: Docker Compose - Production
- [ ] Create `docker-compose.prod.yml`
- [ ] Add Nginx reverse proxy
- [ ] SSL/TLS configuration
- [ ] Environment variables
- [ ] Health checks

#### Step 6.5: Database Initialization
- [ ] Create initial migration scripts
- [ ] Seed data for testing
- [ ] Flyway/Liquibase configuration

---

## 📝 ADDITIONAL FEATURES (BONUS)

### Email Service
- [ ] Configure SMTP settings
- [ ] Email templates (welcome, password reset, invitation)
- [ ] Email verification flow

### File Upload
- [ ] Avatar upload for users
- [ ] Simulation file import/export
- [ ] Configure storage (local or cloud)

### Analytics Dashboard
- [ ] Track simulation usage
- [ ] User activity metrics
- [ ] Export analytics data

### Admin Panel
- [ ] User management
- [ ] System statistics
- [ ] Content moderation

---

## 🚀 DEPLOYMENT CHECKLIST

- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] SSL certificates installed
- [ ] CORS settings for production
- [ ] Rate limiting configured
- [ ] Logging and monitoring setup
- [ ] Backup strategy implemented

---

## 📌 PRIORITY ORDER

1. **Function 1: Authentication** - Required for all other features
2. **Function 6: Docker Setup** - Development environment
3. **Function 2: Simulation** - Core feature
4. **Function 4: Notifications** - UX improvement
5. **Function 3: Chat** - Social feature
6. **Function 5: Community** - Social feature

---

## 📞 API Response Format

All API responses follow this format:

```json
// Success
{
  "success": true,
  "data": { ... },
  "error": null
}

// Error
{
  "success": false,
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": { ... },
    "timestamp": "2024-01-15T10:30:00Z",
    "path": "/api/v1/endpoint"
  }
}
```

---

## 📊 Database Schema Summary

### Tables
- `users` - User accounts
- `simulations` - Simulation records with results
- `friendships` - Friend relationships
- `invitations` - Email invitations
- `shared_simulations` - Simulation shares between users
- `simulation_likes` - Like records
- `simulation_comments` - Comment records
- `conversations` - Chat conversations
- `conversation_participants` - Conversation members
- `chat_messages` - Chat messages
- `notifications` - User notifications

---

**Last Updated:** December 6, 2025
**Author:** Development Team
