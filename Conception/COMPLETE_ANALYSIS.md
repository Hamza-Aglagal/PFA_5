# SimStruct Complete Frontend Analysis

## Executive Summary

This document provides a comprehensive analysis of both the **Angular Web Application** and **Flutter Mobile Application** for SimStruct - a structural engineering simulation platform. The analysis covers all features, API requirements, data models, and identifies feature parity requirements between platforms.

---

## 1. Web Frontend Analysis (Angular)

### 1.1 Application Structure

```
src/app/
├── core/
│   ├── guards/          # Route protection
│   ├── interceptors/    # HTTP interceptors (auth token)
│   └── services/        # Business logic services
├── pages/
│   ├── home/           # Landing page
│   ├── login/          # Authentication
│   ├── register/       # User registration
│   ├── dashboard/      # Main dashboard
│   ├── simulation/     # Simulation wizard
│   ├── results/        # Analysis results view
│   ├── history/        # Simulation history
│   ├── profile/        # User profile management
│   └── community/      # Social features
└── shared/
    └── components/     # Reusable UI components
```

### 1.2 Routes & Pages

| Route | Component | Auth Required | Description |
|-------|-----------|---------------|-------------|
| `/` | HomeComponent | No | Landing page |
| `/login` | LoginComponent | No (Guest only) | User login |
| `/register` | RegisterComponent | No (Guest only) | User registration |
| `/dashboard` | DashboardComponent | Yes | Main dashboard |
| `/simulation` | SimulationComponent | Yes | Create simulation |
| `/results` | ResultsComponent | Yes | View results (no ID) |
| `/results/:id` | ResultsComponent | Yes | View specific result |
| `/history` | HistoryComponent | Yes | Simulation history |
| `/profile` | ProfileComponent | Yes | User profile |
| `/community` | CommunityComponent | No | Community features |
| `/community/simulation/:id` | SimulationDetailComponent | No | Public simulation detail |

### 1.3 Services Analysis

#### 1.3.1 AuthService
**Base URL:** `{apiUrl}/auth`

| Method | Endpoint | Request | Response | Description |
|--------|----------|---------|----------|-------------|
| POST | `/login` | `{email, password}` | `AuthResponse` | User login |
| POST | `/register` | `{email, password, name}` | `AuthResponse` | User registration |
| POST | `/refresh` | `{refreshToken}` | `AuthResponse` | Refresh access token |

**AuthResponse Structure:**
```typescript
{
  success: boolean;
  data: {
    accessToken: string;
    refreshToken: string;
    tokenType: string;
    expiresIn: number;
    user: {
      id: string;
      email: string;
      name: string;
      role: string;
      createdAt: string;
    }
  }
}
```

#### 1.3.2 SimulationService
**Base URL:** `{apiUrl}/simulations`

| Method | Endpoint | Request | Response | Description |
|--------|----------|---------|----------|-------------|
| POST | `/` | `SimulationRequest` | `SimulationResponse` | Create simulation |
| GET | `/` | `?page&size` | `PageResponse<SimulationResponse>` | Get user's simulations |
| GET | `/{id}` | - | `SimulationResponse` | Get simulation by ID |
| PUT | `/{id}` | `Partial<SimulationRequest>` | `SimulationResponse` | Update simulation |
| DELETE | `/{id}` | - | `void` | Delete simulation |
| POST | `/{id}/favorite` | - | `SimulationResponse` | Toggle favorite |
| GET | `/favorites` | `?page&size` | `PageResponse<SimulationResponse>` | Get favorites |
| GET | `/public` | `?page&size` | `PageResponse<SimulationResponse>` | Get public simulations |
| POST | `/{id}/like` | - | `SimulationResponse` | Like simulation |
| DELETE | `/{id}/like` | - | `SimulationResponse` | Unlike simulation |
| POST | `/{id}/clone` | - | `SimulationResponse` | Clone simulation |
| GET | `/{id}/report` | `?format=PDF` | `Blob` | Download report |
| POST | `/{id}/share` | - | `SimulationResponse` | Make simulation public |

**SimulationRequest:**
```typescript
{
  name: string;
  description?: string;
  beamLength: number;
  beamHeight: number;
  beamWidth: number;
  materialType: 'CONCRETE' | 'STEEL' | 'WOOD' | 'ALUMINUM' | 'COMPOSITE';
  elasticModulus: number;
  loadType: 'POINT' | 'DISTRIBUTED' | 'MOMENT' | 'TRIANGULAR' | 'TRAPEZOIDAL' | 'UNIFORM';
  loadMagnitude: number;
  loadPosition?: number;
  supportType: 'SIMPLY_SUPPORTED' | 'FIXED_FIXED' | 'FIXED_FREE' | 'FIXED_PINNED' | 'CONTINUOUS' | 'FIXED' | 'PINNED';
  isPublic?: boolean;
}
```

**SimulationResponse:**
```typescript
{
  id: string;
  name: string;
  description?: string;
  beamLength: number;
  beamHeight: number;
  beamWidth: number;
  materialType: string;
  elasticModulus: number;
  loadType: string;
  loadMagnitude: number;
  loadPosition?: number;
  supportType: string;
  isPublic: boolean;
  isFavorite: boolean;
  likesCount: number;
  createdAt: string;
  updatedAt: string;
  results?: {
    maxDeflection: number;
    maxBendingMoment: number;
    maxShearForce: number;
    maxStress: number;
    safetyFactor: number;
  }
}
```

#### 1.3.3 CommunityService
**Base URL:** `{apiUrl}`

**Friends API:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/friends` | Get accepted friends |
| GET | `/friends/requests/pending` | Get pending friend requests |
| GET | `/friends/requests/sent` | Get sent friend requests |
| POST | `/friends/request/{userId}` | Send friend request |
| PUT | `/friends/{friendshipId}/accept` | Accept friend request |
| DELETE | `/friends/{friendshipId}/reject` | Reject friend request |
| DELETE | `/friends/{friendshipId}` | Remove friend |

**Invitations API:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/invitations/sent` | Get sent invitations |
| GET | `/invitations/received` | Get received invitations |
| POST | `/invitations` | Send invitation by email |
| PUT | `/invitations/{id}/accept` | Accept invitation |
| PUT | `/invitations/{id}/decline` | Decline invitation |
| DELETE | `/invitations/{id}` | Cancel invitation |

**Shared Simulations API:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/shared-simulations/with-me` | Get simulations shared with me |
| POST | `/shared-simulations` | Share simulation with friend |
| DELETE | `/shared-simulations/{id}` | Unshare simulation |

#### 1.3.4 NotificationService
**Base URL:** `{apiUrl}/notifications`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get all notifications |
| GET | `/unread` | Get unread notifications |
| GET | `/count` | Get unread count |
| PUT | `/{id}/read` | Mark as read |
| PUT | `/read-all` | Mark all as read |
| DELETE | `/{id}` | Delete notification |
| DELETE | `/` | Clear all notifications |

#### 1.3.5 ChatService
**Base URL:** `{apiUrl}/chat`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/conversations` | Get all conversations |
| GET | `/conversations/{id}/messages` | Get messages for conversation |
| GET | `/unread-count` | Get total unread message count |
| POST | `/conversations/{userId}` | Start/get conversation with user |
| POST | `/conversations/{id}/messages` | Send message |
| PUT | `/conversations/{id}/read` | Mark conversation as read |
| DELETE | `/conversations/{id}` | Delete conversation |

### 1.4 Features Identified

1. **Authentication**
   - Login with email/password
   - Registration with name/email/password
   - JWT token management with refresh
   - Logout
   - Session persistence

2. **Simulation**
   - Multi-step wizard (Structure → Material → Loading → Review)
   - 3D preview with Three.js
   - Structure types: Beam, Frame, Truss, Column
   - Materials: Steel, Concrete, Aluminum, Wood
   - Load types: Point, Distributed, Moment
   - Support types: Simply Supported, Cantilever, Fixed-Fixed
   - Run analysis with backend calculation
   - View results with 3D visualization

3. **Results**
   - Safety factor display
   - Maximum stress analysis
   - Maximum deflection
   - Bending moment
   - Shear force
   - AI-generated recommendations
   - Export report (PDF)
   - Share simulation
   - 3D stress visualization

4. **History**
   - List all user simulations
   - Filter by status (completed, failed, pending)
   - Sort by date, name, safety factor
   - Search functionality
   - Grid/List view toggle
   - Bulk selection and deletion
   - View results
   - Download report
   - Duplicate simulation
   - Delete simulation

5. **Community**
   - Explore public simulations
   - Friends management
   - Friend requests (send/accept/reject)
   - Email invitations
   - Share simulations with friends
   - Like simulations
   - Chat with friends (real-time messaging)
   - My shares management

6. **Profile**
   - View/edit profile information
   - Security settings (2FA, password)
   - Notification preferences
   - Billing/subscription management
   - Usage statistics

7. **Notifications**
   - In-app notifications
   - Toast notifications
   - Unread count badge
   - Mark as read
   - Clear all

---

## 2. Mobile Frontend Analysis (Flutter)

### 2.1 Application Structure

```
lib/
├── app/
│   ├── router/        # Navigation routes
│   └── theme/         # App theming
├── core/
│   ├── constants/     # App constants
│   ├── models/        # Data models
│   ├── services/      # Business logic
│   └── utils/         # Utilities
├── features/
│   ├── auth/          # Login, Register, Forgot Password
│   ├── community/     # Friends, Shares, Chat
│   ├── dashboard/     # Main dashboard
│   ├── history/       # Simulation history
│   ├── home/          # Home screen
│   ├── main/          # Bottom navigation shell
│   ├── notifications/ # Notifications screen
│   ├── onboarding/    # Onboarding flow
│   ├── profile/       # User profile
│   ├── results/       # Analysis results
│   ├── settings/      # App settings
│   ├── simulation/    # Simulation wizard
│   └── splash/        # Splash screen
└── shared/
    ├── animations/    # Custom animations
    └── widgets/       # Reusable widgets
```

### 2.2 Routes

| Route | Screen | Description |
|-------|--------|-------------|
| `/` | SplashScreen | App launch |
| `/onboarding` | OnboardingScreen | First-time user onboarding |
| `/login` | LoginScreen | User login |
| `/register` | RegisterScreen | User registration |
| `/forgot-password` | ForgotPasswordScreen | Password recovery |
| `/home` | HomeScreen | Main home (in shell) |
| `/dashboard` | DashboardScreen | Dashboard (in shell) |
| `/history` | HistoryScreen | History (in shell) |
| `/community` | CommunityScreen | Community (in shell) |
| `/profile` | ProfileScreen | Profile (in shell) |
| `/simulation` | SimulationScreen | Create simulation |
| `/results/:id` | ResultsScreen | View results |
| `/notifications` | NotificationsScreen | Notifications |
| `/settings` | SettingsScreen | App settings |

### 2.3 Data Models

#### User Model
```dart
class User {
  String id;
  String email;
  String name;
  UserRole role;  // user, pro, admin
  SubscriptionPlan subscriptionPlan;  // free, pro, enterprise
  bool emailVerified;
  DateTime createdAt;
  DateTime updatedAt;
  UserProfile profile;
}

class UserProfile {
  String? avatarUrl;
  String? phone;
  String? company;
  String? jobTitle;
  String? bio;
  UsageStats stats;
}

class UsageStats {
  int totalSimulations;
  int monthlySimulations;
  int sharedSimulations;
  int completedSimulations;
  int failedSimulations;
  double storageUsed;
  DateTime? lastSimulationAt;
}
```

#### Simulation Model
```dart
class Simulation {
  String id;
  String name;
  String? description;
  String userId;
  SimulationParams params;
  SimulationStatus status;  // draft, running, completed, failed
  AnalysisResult? result;
  DateTime createdAt;
  DateTime updatedAt;
  bool isFavorite;
  bool isShared;
  List<String> tags;
}

class SimulationParams {
  StructureType structureType;  // beam, frame, truss, column
  double length;
  double width;
  double height;
  StructuralMaterial material;  // steel, concrete, aluminum, wood
  double elasticModulus;
  double density;
  double yieldStrength;
  LoadType loadType;  // point, distributed, moment
  double loadMagnitude;
  double loadPosition;
  SupportType supportType;  // simplySupported, cantilever, fixedFixed, etc.
}

class AnalysisResult {
  double safetyFactor;
  double maxDeflection;
  double maxStress;
  double bucklingLoad;
  double naturalFrequency;
  ResultStatus status;  // safe, warning, critical
  List<String> recommendations;
  List<StressPoint> stressDistribution;
  List<DeflectionPoint> deflectionCurve;
  AIInsight? aiInsight;
}
```

#### Community Models
```dart
class Friend {
  String id;
  String name;
  String email;
  String? avatarUrl;
  FriendStatus status;  // pending, accepted, blocked
  DateTime connectedAt;
  bool isOnline;
  DateTime? lastSeen;
  int sharedSimulations;
}

class SharedSimulation {
  String id;
  String simulationId;
  String simulationName;
  String ownerId;
  String ownerName;
  SharePermission permission;  // view, edit, admin
  DateTime sharedAt;
  SimulationStatus simulationStatus;
  ResultStatus? resultStatus;
  List<Friend> sharedWith;
}

class Invitation {
  String id;
  String senderId;
  String senderName;
  String recipientEmail;
  InvitationStatus status;  // pending, accepted, declined, expired
  DateTime createdAt;
  DateTime? expiresAt;
  String? message;
}

class ChatMessage {
  String id;
  String senderId;
  String senderName;
  String content;
  DateTime sentAt;
  bool isRead;
  String? simulationId;
}
```

#### Notification Models
```dart
class AppNotification {
  String id;
  String title;
  String message;
  NotificationType type;  // success, error, warning, info
  NotificationCategory category;  // simulation, community, system, account
  DateTime createdAt;
  bool isRead;
  String? actionUrl;
}
```

### 2.4 Features Identified

1. **Authentication**
   - Login with email/password
   - Registration with name/email/password
   - Forgot password flow
   - Token management
   - Logout

2. **Onboarding**
   - First-time user tutorial
   - Feature introduction

3. **Dashboard**
   - Quick stats overview
   - Recent simulations
   - Quick action buttons

4. **Simulation**
   - Multi-step wizard
   - Structure type selection
   - Material selection with auto-fill properties
   - Dimension inputs
   - Load configuration
   - Support type selection
   - Run analysis
   - Real-time progress tracking

5. **Results**
   - Safety factor display with color coding
   - Stress analysis
   - Deflection analysis
   - AI insights
   - Recommendations
   - Visual charts

6. **History**
   - List all simulations
   - Filter and search
   - View results
   - Delete simulation
   - Toggle favorite
   - Duplicate simulation

7. **Community**
   - Explore tab (shared simulations)
   - Friends tab (manage friends)
   - Invitations tab (pending invitations)
   - My Shares tab
   - Add friend by email
   - Accept/decline friend requests
   - Share simulation with friends
   - Chat with friends
   - Clone shared simulations
   - View shared simulation details

8. **Profile**
   - View profile information
   - Edit profile
   - Usage statistics
   - Account management

9. **Notifications**
   - View all notifications
   - Filter by category
   - Mark as read
   - Clear notifications
   - Toast notifications

10. **Settings**
    - Dark mode toggle
    - Language selection
    - Units selection (Metric/Imperial)
    - Haptic feedback toggle
    - Auto sync toggle
    - Clear cache
    - Export data
    - Help center
    - Contact support
    - Terms & Privacy
    - Sign out
    - Delete account

---

## 3. Feature Comparison Matrix

| Feature | Web | Mobile | Parity Status |
|---------|-----|--------|---------------|
| **Authentication** | | | |
| Login | ✅ | ✅ | ✅ Match |
| Register | ✅ | ✅ | ✅ Match |
| Forgot Password | ❌ | ✅ | ⚠️ Add to Web |
| JWT Refresh | ✅ | ✅ | ✅ Match |
| Logout | ✅ | ✅ | ✅ Match |
| **Simulation** | | | |
| Structure Types | ✅ | ✅ | ✅ Match |
| Material Selection | ✅ | ✅ | ✅ Match |
| Load Configuration | ✅ | ✅ | ✅ Match |
| Support Types | ✅ | ✅ | ✅ Match |
| 3D Preview | ✅ | ❌ | ⚠️ Web only (OK) |
| Run Analysis | ✅ | ✅ | ✅ Match |
| **Results** | | | |
| Safety Factor | ✅ | ✅ | ✅ Match |
| Stress Analysis | ✅ | ✅ | ✅ Match |
| Deflection | ✅ | ✅ | ✅ Match |
| 3D Visualization | ✅ | ❌ | ⚠️ Web only (OK) |
| AI Insights | ✅ | ✅ | ✅ Match |
| Export PDF | ✅ | ❌ | ⚠️ Add to Mobile |
| **History** | | | |
| List Simulations | ✅ | ✅ | ✅ Match |
| Filter/Search | ✅ | ✅ | ✅ Match |
| Delete | ✅ | ✅ | ✅ Match |
| Favorite Toggle | ✅ | ✅ | ✅ Match |
| Duplicate | ✅ | ✅ | ✅ Match |
| Bulk Delete | ✅ | ❌ | ⚠️ Web only (OK) |
| **Community** | | | |
| Public Simulations | ✅ | ✅ | ✅ Match |
| Friends List | ✅ | ✅ | ✅ Match |
| Friend Requests | ✅ | ✅ | ✅ Match |
| Email Invitations | ✅ | ✅ | ✅ Match |
| Share with Friends | ✅ | ✅ | ✅ Match |
| Like Simulations | ✅ | ❌ | ⚠️ **REMOVE from Web** |
| Chat | ✅ | ✅ | ✅ Match |
| Clone Simulation | ✅ | ✅ | ✅ Match |
| **Profile** | | | |
| View Profile | ✅ | ✅ | ✅ Match |
| Edit Profile | ✅ | ✅ | ✅ Match |
| Usage Stats | ✅ | ✅ | ✅ Match |
| **Notifications** | | | |
| In-app Notifications | ✅ | ✅ | ✅ Match |
| Toast Messages | ✅ | ✅ | ✅ Match |
| Unread Count | ✅ | ✅ | ✅ Match |
| Mark as Read | ✅ | ✅ | ✅ Match |
| **Settings** | | | |
| Theme Toggle | ✅ | ✅ | ✅ Match |
| Language | ❌ | ✅ | ⚠️ Add to Web |
| Units (Metric/Imperial) | ❌ | ✅ | ⚠️ Add to Web |
| Change Password | ✅ | ✅ | ✅ Match |
| Delete Account | ✅ | ✅ | ✅ Match |
| **Other** | | | |
| Onboarding | ❌ | ✅ | ⚠️ Mobile only (OK) |
| Splash Screen | ❌ | ✅ | ⚠️ Mobile only (OK) |
| 2FA | ✅ | ❌ | ⚠️ Add to Mobile |

### Features to REMOVE (Not in Both Platforms)

Based on the requirement to ensure feature parity:

1. **Like/Unlike Simulations** - Present in Web, NOT in Mobile
   - **Action:** Remove from Web backend requirements
   - **Reason:** Mobile doesn't have this feature

### Features That Are Platform-Specific (OK to Keep)

1. **3D Preview/Visualization** - Web only (hardware intensive)
2. **Onboarding Flow** - Mobile only (appropriate for mobile UX)
3. **Splash Screen** - Mobile only (standard mobile pattern)
4. **Bulk Operations** - Web only (better suited for desktop UX)

---

## 4. Consolidated API Requirements

Based on the analysis, here are ALL API endpoints needed for the backend:

### 4.1 Authentication APIs
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

### 4.2 User APIs
```
GET    /api/v1/users/me
PUT    /api/v1/users/me
PUT    /api/v1/users/me/password
DELETE /api/v1/users/me
GET    /api/v1/users/me/stats
```

### 4.3 Simulation APIs
```
POST   /api/v1/simulations
GET    /api/v1/simulations
GET    /api/v1/simulations/{id}
PUT    /api/v1/simulations/{id}
DELETE /api/v1/simulations/{id}
POST   /api/v1/simulations/{id}/favorite
GET    /api/v1/simulations/favorites
GET    /api/v1/simulations/public
POST   /api/v1/simulations/{id}/clone
GET    /api/v1/simulations/{id}/report
POST   /api/v1/simulations/{id}/share
```

### 4.4 Friends APIs
```
GET    /api/v1/friends
GET    /api/v1/friends/requests/pending
GET    /api/v1/friends/requests/sent
POST   /api/v1/friends/request/{userId}
PUT    /api/v1/friends/{friendshipId}/accept
DELETE /api/v1/friends/{friendshipId}/reject
DELETE /api/v1/friends/{friendshipId}
```

### 4.5 Invitations APIs
```
GET    /api/v1/invitations/sent
GET    /api/v1/invitations/received
POST   /api/v1/invitations
PUT    /api/v1/invitations/{id}/accept
PUT    /api/v1/invitations/{id}/decline
DELETE /api/v1/invitations/{id}
```

### 4.6 Shared Simulations APIs
```
GET    /api/v1/shared-simulations/with-me
POST   /api/v1/shared-simulations
DELETE /api/v1/shared-simulations/{id}
```

### 4.7 Notification APIs
```
GET    /api/v1/notifications
GET    /api/v1/notifications/unread
GET    /api/v1/notifications/count
PUT    /api/v1/notifications/{id}/read
PUT    /api/v1/notifications/read-all
DELETE /api/v1/notifications/{id}
DELETE /api/v1/notifications
```

### 4.8 Chat APIs
```
GET    /api/v1/chat/conversations
GET    /api/v1/chat/conversations/{id}/messages
GET    /api/v1/chat/unread-count
POST   /api/v1/chat/conversations/{userId}
POST   /api/v1/chat/conversations/{id}/messages
PUT    /api/v1/chat/conversations/{id}/read
DELETE /api/v1/chat/conversations/{id}
```

### 4.9 WebSocket Endpoints (Real-time)
```
WS     /ws/chat          # Real-time chat messages
WS     /ws/notifications # Real-time notifications
```

---

## 5. Data Models Summary

### Core Entities

1. **User**
   - id (UUID)
   - email (unique)
   - password (hashed)
   - name
   - role (USER, PRO, ADMIN)
   - emailVerified
   - avatarUrl
   - phone
   - company
   - jobTitle
   - bio
   - createdAt
   - updatedAt
   - deletedAt (soft delete)

2. **Simulation**
   - id (UUID)
   - userId (FK)
   - name
   - description
   - beamLength
   - beamHeight
   - beamWidth
   - materialType (enum)
   - elasticModulus
   - loadType (enum)
   - loadMagnitude
   - loadPosition
   - supportType (enum)
   - isPublic
   - isFavorite
   - status (DRAFT, RUNNING, COMPLETED, FAILED)
   - createdAt
   - updatedAt
   - deletedAt (soft delete)

3. **SimulationResult**
   - id (UUID)
   - simulationId (FK, unique)
   - maxDeflection
   - maxBendingMoment
   - maxShearForce
   - maxStress
   - safetyFactor
   - recommendations (JSON)
   - stressDistribution (JSON)
   - deflectionCurve (JSON)
   - aiInsights (JSON)
   - createdAt

4. **Friendship**
   - id (UUID)
   - requesterId (FK User)
   - addresseeId (FK User)
   - status (PENDING, ACCEPTED, BLOCKED)
   - createdAt
   - updatedAt

5. **Invitation**
   - id (UUID)
   - senderId (FK User)
   - recipientEmail
   - message
   - status (PENDING, ACCEPTED, DECLINED, EXPIRED)
   - expiresAt
   - createdAt
   - updatedAt

6. **SharedSimulation**
   - id (UUID)
   - simulationId (FK)
   - ownerId (FK User)
   - sharedWithId (FK User)
   - permission (VIEW, COMMENT, EDIT)
   - message
   - createdAt

7. **Notification**
   - id (UUID)
   - userId (FK)
   - type (INFO, SUCCESS, WARNING, ERROR)
   - category (SIMULATION, COMMUNITY, SYSTEM, MARKETING)
   - title
   - message
   - actionUrl
   - data (JSON)
   - isRead
   - createdAt

8. **Conversation**
   - id (UUID)
   - participant1Id (FK User)
   - participant2Id (FK User)
   - lastMessageAt
   - createdAt

9. **ChatMessage**
   - id (UUID)
   - conversationId (FK)
   - senderId (FK User)
   - content
   - isRead
   - createdAt

10. **RefreshToken**
    - id (UUID)
    - userId (FK)
    - token (hashed)
    - expiresAt
    - createdAt
    - revokedAt

---

## 6. Authentication & Authorization Flow

### 6.1 Registration Flow
1. User submits name, email, password
2. Backend validates input
3. Backend creates user with hashed password
4. Backend generates access + refresh tokens
5. Backend returns tokens and user info
6. Client stores tokens and redirects to dashboard

### 6.2 Login Flow
1. User submits email, password
2. Backend validates credentials
3. Backend generates access + refresh tokens
4. Backend returns tokens and user info
5. Client stores tokens and redirects to dashboard

### 6.3 Token Refresh Flow
1. Client detects 401 response or token expiring
2. Client sends refresh token
3. Backend validates refresh token
4. Backend generates new access + refresh tokens
5. Backend returns new tokens
6. Client updates stored tokens

### 6.4 Authorization
- JWT tokens contain: userId, email, role
- All protected endpoints require valid JWT
- Role-based access for admin features
- Resource ownership validation (e.g., user can only edit own simulations)

---

## 7. Real-time Features

### 7.1 Chat System
- WebSocket connection for real-time messaging
- Message delivery confirmation
- Read receipts
- Typing indicators (optional)
- Online status tracking

### 7.2 Notifications
- WebSocket connection for push notifications
- New simulation completed
- Friend request received
- Invitation received
- Simulation shared with user

---

## 8. Conclusions

### Key Requirements for Backend:
1. RESTful API with consistent response format
2. JWT-based authentication with refresh tokens
3. PostgreSQL database with proper relationships
4. WebSocket support for real-time features
5. File storage for reports (PDF generation)
6. Soft deletes for data recovery
7. Pagination for list endpoints
8. Proper validation and error handling
9. Rate limiting for sensitive endpoints
10. CORS configuration for web and mobile

### Removed Features (Not in Parity):
- Like/Unlike simulations (Web only - removed)

### Platform-Specific Features (OK to Keep):
- 3D visualization (Web only)
- Onboarding (Mobile only)
- Bulk operations (Web only)
