# Diagramme de Classes - SimStruct Backend

## Vue d'ensemble de l'Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              ARCHITECTURE EN COUCHES                                 │
├─────────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │   Auth      │  │ Simulation  │  │ Friendship  │  │    Chat     │  Controllers   │
│  │ Controller  │  │ Controller  │  │ Controller  │  │ Controller  │                 │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                 │
│         │                │                │                │                         │
├─────────┼────────────────┼────────────────┼────────────────┼─────────────────────────┤
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐                 │
│  │   Auth      │  │ Simulation  │  │ Friendship  │  │    Chat     │  Services       │
│  │  Service    │  │  Service    │  │  Service    │  │  Service    │                 │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                 │
│         │                │                │                │                         │
├─────────┼────────────────┼────────────────┼────────────────┼─────────────────────────┤
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐                 │
│  │   User      │  │ Simulation  │  │ Friendship  │  │ ChatMessage │  Repositories   │
│  │ Repository  │  │ Repository  │  │ Repository  │  │ Repository  │                 │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                 │
│         │                │                │                │                         │
├─────────┼────────────────┼────────────────┼────────────────┼─────────────────────────┤
│         │                │                │                │                         │
│         └────────────────┴────────────────┴────────────────┘                         │
│                                    │                                                 │
│                          ┌─────────▼─────────┐                                       │
│                          │    PostgreSQL     │  Database                             │
│                          │    Database       │                                       │
│                          └───────────────────┘                                       │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Diagramme de Classes UML Complet

### 1. Entités (Entity Layer)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                     ENTITIES                                         │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────┐
│              «Entity»              │
│               User                 │
├────────────────────────────────────┤
│ - id: String {UUID}                │
│ - name: String                     │
│ - email: String {unique}           │
│ - password: String                 │
│ - role: Role {USER|PRO|ADMIN}      │
│ - avatarUrl: String                │
│ - phone: String                    │
│ - company: String                  │
│ - jobTitle: String                 │
│ - bio: String                      │
│ - emailVerified: Boolean           │
│ - createdAt: LocalDateTime         │
│ - updatedAt: LocalDateTime         │
├────────────────────────────────────┤
│ + preUpdate(): void                │
└────────────────────────────────────┘
          │
          │ 1
          │
          ▼ *
┌────────────────────────────────────┐
│              «Entity»              │
│            Simulation              │
├────────────────────────────────────┤
│ - id: String {UUID}                │
│ - name: String                     │
│ - description: String              │
│ - beamLength: Double               │
│ - beamWidth: Double                │
│ - beamHeight: Double               │
│ - materialType: MaterialType       │
│ - elasticModulus: Double           │
│ - density: Double                  │
│ - yieldStrength: Double            │
│ - loadType: LoadType               │
│ - loadMagnitude: Double            │
│ - loadPosition: Double             │
│ - supportType: SupportType         │
│ - status: SimulationStatus         │
│ - isPublic: Boolean                │
│ - isFavorite: Boolean              │
│ - likesCount: Integer              │
│ - createdAt: LocalDateTime         │
│ - updatedAt: LocalDateTime         │
├────────────────────────────────────┤
│ + prePersist(): void               │
└────────────────────────────────────┘
          │
          │ 1
          │ ◇ (Embedded)
          ▼ 1
┌────────────────────────────────────┐
│           «Embeddable»             │
│         SimulationResult           │
├────────────────────────────────────┤
│ - maxDeflection: Double            │
│ - maxBendingMoment: Double         │
│ - maxShearForce: Double            │
│ - maxStress: Double                │
│ - safetyFactor: Double             │
│ - isSafe: Boolean                  │
│ - recommendations: String          │
│ - naturalFrequency: Double         │
│ - criticalLoad: Double             │
│ - weight: Double                   │
└────────────────────────────────────┘


┌────────────────────────────────────┐
│              «Entity»              │
│         SharedSimulation           │
├────────────────────────────────────┤
│ - id: String {UUID}                │
│ - simulation: Simulation           │
│ - sharedBy: User                   │
│ - sharedWith: User                 │
│ - message: String                  │
│ - permission: SharePermission      │
│ - sharedAt: LocalDateTime          │
├────────────────────────────────────┤
│ «enum» SharePermission:            │
│   VIEW | COMMENT | EDIT            │
└────────────────────────────────────┘


┌────────────────────────────────────┐
│              «Entity»              │
│            Friendship              │
├────────────────────────────────────┤
│ - id: String {UUID}                │
│ - user: User                       │
│ - friend: User                     │
│ - status: FriendshipStatus         │
│ - createdAt: LocalDateTime         │
│ - updatedAt: LocalDateTime         │
├────────────────────────────────────┤
│ «enum» FriendshipStatus:           │
│   PENDING | ACCEPTED |             │
│   REJECTED | BLOCKED               │
└────────────────────────────────────┘


┌────────────────────────────────────┐
│              «Entity»              │
│           ChatMessage              │
├────────────────────────────────────┤
│ - id: String {UUID}                │
│ - sender: User                     │
│ - recipient: User                  │
│ - content: String                  │
│ - isRead: Boolean                  │
│ - relatedSimulation: Simulation    │
│ - sentAt: LocalDateTime            │
└────────────────────────────────────┘


┌────────────────────────────────────┐
│              «Entity»              │
│           Notification             │
├────────────────────────────────────┤
│ - id: String {UUID}                │
│ - userId: String                   │
│ - type: NotificationType           │
│ - title: String                    │
│ - message: String                  │
│ - relatedId: String                │
│ - relatedType: String              │
│ - actionUrl: String                │
│ - isRead: Boolean                  │
│ - createdAt: LocalDateTime         │
│ - readAt: LocalDateTime            │
├────────────────────────────────────┤
│ «enum» NotificationType:           │
│   SIMULATION_COMPLETE |            │
│   SIMULATION_FAILED |              │
│   FRIEND_REQUEST |                 │
│   FRIEND_ACCEPTED |                │
│   NEW_MESSAGE |                    │
│   SIMULATION_RECEIVED |            │
│   WELCOME | SYSTEM                 │
└────────────────────────────────────┘
```

---

### 2. Relations entre Entités

```
                                    RELATIONS
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                      │
│      ┌──────────┐          1                    *          ┌──────────────┐         │
│      │   User   │◄────────────────────────────────────────│  Simulation  │         │
│      └──────────┘                                          └──────────────┘         │
│           │                                                       │                  │
│           │                                                       │                  │
│           │ 1                                                     │ 1                │
│           │                                                       │                  │
│           ▼ *                                                     ▼ 1                │
│   ┌──────────────────┐                                 ┌───────────────────┐        │
│   │   Friendship     │                                 │ SimulationResult  │        │
│   │                  │                                 │   (Embedded)      │        │
│   └──────────────────┘                                 └───────────────────┘        │
│           │                                                       │                  │
│           │                                                       │                  │
│           │ 1..* (bidirectional)                                  │                  │
│           │                                                       │                  │
│           ▼                                                       ▼ *                │
│      ┌──────────┐                                      ┌───────────────────┐        │
│      │   User   │◄────────────────────────────────────│ SharedSimulation  │        │
│      └──────────┘         (sharedBy, sharedWith)       └───────────────────┘        │
│           │                                                                          │
│           │ 1                                                                        │
│           │                                                                          │
│           ▼ *                                                                        │
│   ┌──────────────────┐                                                              │
│   │   ChatMessage    │                                                              │
│   │ (sender/recipient)│                                                             │
│   └──────────────────┘                                                              │
│           │                                                                          │
│           │ * (optional)                                                            │
│           │                                                                          │
│           ▼ 1                                                                        │
│   ┌──────────────────┐                                                              │
│   │   Simulation     │                                                              │
│   │(relatedSimulation)│                                                             │
│   └──────────────────┘                                                              │
│                                                                                      │
│      ┌──────────┐          1                    *     ┌──────────────────┐          │
│      │   User   │◄───────────────────────────────────│   Notification   │          │
│      └──────────┘                                     └──────────────────┘          │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

### 3. Enumerations

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   ENUMERATIONS                                       │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐             │
│  │   «enumeration»   │   │   «enumeration»   │   │   «enumeration»   │             │
│  │    User.Role      │   │   MaterialType    │   │     LoadType      │             │
│  ├───────────────────┤   ├───────────────────┤   ├───────────────────┤             │
│  │ USER              │   │ STEEL             │   │ POINT             │             │
│  │ PRO               │   │ CONCRETE          │   │ DISTRIBUTED       │             │
│  │ ADMIN             │   │ WOOD              │   │ UNIFORM           │             │
│  └───────────────────┘   │ ALUMINUM          │   │ MOMENT            │             │
│                          │ COMPOSITE         │   │ TRIANGULAR        │             │
│                          └───────────────────┘   │ TRAPEZOIDAL       │             │
│                                                  └───────────────────┘             │
│                                                                                      │
│  ┌───────────────────┐   ┌───────────────────┐   ┌───────────────────┐             │
│  │   «enumeration»   │   │   «enumeration»   │   │   «enumeration»   │             │
│  │    SupportType    │   │ SimulationStatus  │   │ SharePermission   │             │
│  ├───────────────────┤   ├───────────────────┤   ├───────────────────┤             │
│  │ SIMPLY_SUPPORTED  │   │ PENDING           │   │ VIEW              │             │
│  │ FIXED_FIXED       │   │ RUNNING           │   │ COMMENT           │             │
│  │ FIXED_FREE        │   │ COMPLETED         │   │ EDIT              │             │
│  │ FIXED_PINNED      │   │ FAILED            │   └───────────────────┘             │
│  │ CONTINUOUS        │   └───────────────────┘                                      │
│  │ PINNED            │                                                              │
│  └───────────────────┘                                                              │
│                                                                                      │
│  ┌───────────────────┐   ┌───────────────────┐                                      │
│  │   «enumeration»   │   │   «enumeration»   │                                      │
│  │ FriendshipStatus  │   │ NotificationType  │                                      │
│  ├───────────────────┤   ├───────────────────┤                                      │
│  │ PENDING           │   │ SIMULATION_COMPLETE│                                     │
│  │ ACCEPTED          │   │ SIMULATION_FAILED │                                      │
│  │ REJECTED          │   │ FRIEND_REQUEST    │                                      │
│  │ BLOCKED           │   │ FRIEND_ACCEPTED   │                                      │
│  └───────────────────┘   │ NEW_MESSAGE       │                                      │
│                          │ SIMULATION_RECEIVED│                                     │
│                          │ WELCOME           │                                      │
│                          │ SYSTEM            │                                      │
│                          └───────────────────┘                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

### 4. Services Layer

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    SERVICES                                          │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────┐       ┌────────────────────────────────────┐
│           «Service»                │       │           «Service»                │
│          AuthService               │       │       SimulationService            │
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ - userRepository: UserRepository   │       │ - simulationRepository             │
│ - passwordEncoder: PasswordEncoder │       │ - userRepository                   │
│ - jwtTokenProvider: JwtTokenProvider│      │ - sharedSimulationRepository       │
│ - notificationService              │       │ - simulationEngine                 │
├────────────────────────────────────┤       │ - notificationService              │
│ + register(RegisterRequest)        │       │ - aiModelService                   │
│   : AuthResponse                   │       ├────────────────────────────────────┤
│ + login(LoginRequest)              │       │ + createSimulation(request, email) │
│   : AuthResponse                   │       │   : SimulationResponse             │
│ + refreshToken(RefreshTokenRequest)│       │ + getSimulation(id, email)         │
│   : AuthResponse                   │       │   : SimulationResponse             │
└────────────────────────────────────┘       │ + getUserSimulations(email)        │
                                             │   : List<SimulationResponse>       │
                                             │ + updateSimulation(id, request)    │
┌────────────────────────────────────┐       │ + deleteSimulation(id, email)      │
│           «Service»                │       │ + toggleFavorite(id, email)        │
│        FriendshipService           │       │ + searchPublicSimulations(query)   │
├────────────────────────────────────┤       └────────────────────────────────────┘
│ - friendshipRepository             │
│ - userRepository                   │       ┌────────────────────────────────────┐
│ - sharedSimulationRepository       │       │           «Service»                │
│ - notificationService              │       │     SharedSimulationService        │
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ + getFriends(userId)               │       │ - sharedSimulationRepository       │
│   : List<FriendDTO>                │       │ - simulationRepository             │
│ + getPendingInvitations(userId)    │       │ - userRepository                   │
│   : List<InvitationDTO>            │       │ - notificationService              │
│ + sendFriendRequest(userId, id)    │       ├────────────────────────────────────┤
│   : InvitationDTO                  │       │ + shareSimulation(...)             │
│ + acceptFriendRequest(receiver,    │       │   : SharedSimulationDTO            │
│   sender): FriendDTO               │       │ + getMyShares(userId)              │
│ + rejectFriendRequest(id)          │       │   : List<SharedSimulationDTO>      │
│ + removeFriend(userId, friendId)   │       │ + getSharedWithMe(userId)          │
└────────────────────────────────────┘       │   : List<SharedSimulationDTO>      │
                                             │ + unshareSimulation(shareId)       │
                                             └────────────────────────────────────┘

┌────────────────────────────────────┐       ┌────────────────────────────────────┐
│           «Service»                │       │           «Service»                │
│          ChatService               │       │       NotificationService          │
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ - chatMessageRepository            │       │ - notificationRepository           │
│ - userRepository                   │       │ - userRepository                   │
│ - simulationRepository             │       │ - messagingTemplate                │
│ - notificationService              │       ├────────────────────────────────────┤
├────────────────────────────────────┤       │ + createNotification(...)          │
│ + sendMessage(senderId, recipientId│       │   : NotificationDTO                │
│   , content): ChatMessageDTO       │       │ + getNotifications(userId)         │
│ + getConversation(userId, partnerId│       │   : Page<NotificationDTO>          │
│   ): List<ChatMessageDTO>          │       │ + markAsRead(notificationId)       │
│ + getConversations(userId)         │       │ + sendWelcomeNotification(...)     │
│   : List<ConversationDTO>          │       │ + sendFriendRequestNotification    │
│ + markAsRead(messageId)            │       │ + sendSimulationCompleteNotif...   │
│ + countUnread(userId): long        │       │ + sendWebSocketNotification(...)   │
└────────────────────────────────────┘       └────────────────────────────────────┘

┌────────────────────────────────────┐
│           «Service»                │
│         AIModelService             │
├────────────────────────────────────┤
│ - webClient: WebClient             │
│ - aiApiUrl: String                 │
├────────────────────────────────────┤
│ + predict(BuildingPredictionRequest│
│   ): AIPredictionResponse          │
│ + isHealthy(): boolean             │
│ + getModelInfo(): String           │
└────────────────────────────────────┘
```

---

### 5. Controllers Layer

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   CONTROLLERS                                        │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────┐       ┌────────────────────────────────────┐
│        «RestController»            │       │        «RestController»            │
│         AuthController             │       │      SimulationController          │
│   @RequestMapping("/api/v1/auth")  │       │ @RequestMapping("/api/v1/simulations")│
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ - authService: AuthService         │       │ - simulationService                │
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ POST /register                     │       │ POST /                             │
│ POST /login                        │       │ GET /{id}                          │
│ POST /refresh                      │       │ GET /                              │
│ POST /logout                       │       │ GET /recent                        │
└────────────────────────────────────┘       │ GET /favorites                     │
                                             │ GET /public                        │
┌────────────────────────────────────┐       │ PUT /{id}                          │
│        «RestController»            │       │ DELETE /{id}                       │
│      FriendshipController          │       │ POST /{id}/favorite                │
│ @RequestMapping("/api/v1/friends") │       └────────────────────────────────────┘
├────────────────────────────────────┤
│ - friendshipService                │       ┌────────────────────────────────────┐
├────────────────────────────────────┤       │        «RestController»            │
│ GET /                              │       │    SharedSimulationController      │
│ GET /invitations                   │       │ @RequestMapping("/api/v1/shares")  │
│ POST /request                      │       ├────────────────────────────────────┤
│ POST /accept/{senderId}            │       │ - sharedSimulationService          │
│ POST /reject/{id}                  │       ├────────────────────────────────────┤
│ DELETE /{friendId}                 │       │ POST /                             │
│ GET /search                        │       │ GET /my-shares                     │
└────────────────────────────────────┘       │ GET /shared-with-me                │
                                             │ DELETE /{shareId}                  │
┌────────────────────────────────────┐       └────────────────────────────────────┘
│        «RestController»            │
│         ChatController             │       ┌────────────────────────────────────┐
│   @RequestMapping("/api/v1/chat")  │       │        «RestController»            │
├────────────────────────────────────┤       │     NotificationController         │
│ - chatService: ChatService         │       │@RequestMapping("/api/v1/notifications")│
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ POST /send                         │       │ - notificationService              │
│ GET /conversation/{partnerId}      │       ├────────────────────────────────────┤
│ GET /conversations                 │       │ GET /                              │
│ POST /read/{messageId}             │       │ GET /count                         │
│ GET /unread                        │       │ POST /{id}/read                    │
└────────────────────────────────────┘       │ POST /read-all                     │
                                             │ DELETE /{id}                       │
                                             └────────────────────────────────────┘
```

---

### 6. DTOs (Data Transfer Objects)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            DATA TRANSFER OBJECTS                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│   «DTO» Request      │  │   «DTO» Response     │  │   «DTO» Domain       │
├──────────────────────┤  ├──────────────────────┤  ├──────────────────────┤
│ LoginRequest         │  │ ApiResponse<T>       │  │ FriendDTO            │
│ - email: String      │  │ - success: boolean   │  │ - id: String         │
│ - password: String   │  │ - data: T            │  │ - friendshipId       │
├──────────────────────┤  │ - error: String      │  │ - name: String       │
│ RegisterRequest      │  ├──────────────────────┤  │ - email: String      │
│ - name: String       │  │ AuthResponse         │  │ - avatarUrl          │
│ - email: String      │  │ - accessToken        │  │ - status             │
│ - password: String   │  │ - refreshToken       │  │ - sharedSimulations  │
├──────────────────────┤  │ - tokenType          │  ├──────────────────────┤
│ SimulationRequest    │  │ - expiresIn          │  │ InvitationDTO        │
│ - name: String       │  │ - user: UserResponse │  │ - id: String         │
│ - beamLength         │  ├──────────────────────┤  │ - senderId           │
│ - beamWidth          │  │ SimulationResponse   │  │ - senderName         │
│ - beamHeight         │  │ - id: String         │  │ - recipientId        │
│ - materialType       │  │ - name: String       │  │ - status             │
│ - loadType           │  │ - results            │  │ - createdAt          │
│ - loadMagnitude      │  │ - status             │  ├──────────────────────┤
│ - supportType        │  │ - isPublic           │  │ SharedSimulationDTO  │
│ - numFloors          │  ├──────────────────────┤  │ - id: String         │
│ - floorHeight        │  │ UserResponse         │  │ - simulationId       │
│ - numBeams           │  │ - id: String         │  │ - simulationName     │
│ - numColumns         │  │ - name: String       │  │ - sharedByName       │
│ - beamSection        │  │ - email: String      │  │ - permission         │
│ - columnSection      │  │ - role: Role         │  │ - sharedAt           │
│ - concreteStrength   │  └──────────────────────┘  ├──────────────────────┤
│ - steelGrade         │                            │ ChatMessageDTO       │
│ - windLoad           │                            │ - id: String         │
│ - liveLoad           │                            │ - senderId           │
│ - deadLoad           │                            │ - recipientId        │
├──────────────────────┤                            │ - content: String    │
│ BuildingPrediction   │                            │ - isRead: boolean    │
│ Request              │                            │ - sentAt             │
│ - numFloors: Double  │                            ├──────────────────────┤
│ - floorHeight        │                            │ NotificationDTO      │
│ - numBeams: Integer  │                            │ - id: String         │
│ - numColumns         │                            │ - type               │
│ - beamSection        │                            │ - title: String      │
│ - columnSection      │                            │ - message: String    │
│ - concreteStrength   │                            │ - isRead: boolean    │
│ - steelGrade         │                            │ - createdAt          │
│ - windLoad           │                            └──────────────────────┘
│ - liveLoad           │
│ - deadLoad           │
└──────────────────────┘
```

---

### 7. Repositories Layer

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  REPOSITORIES                                        │
│                    (extends JpaRepository<Entity, String>)                          │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────┐       ┌────────────────────────────────────┐
│        «Interface»                 │       │        «Interface»                 │
│       UserRepository               │       │    SimulationRepository            │
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ + findByEmail(email): Optional     │       │ + findByUserIdOrderByCreatedAtDesc │
│ + existsByEmail(email): boolean    │       │ + findByIsPublicTrueOrderBy...     │
│ + findByEmailContaining...         │       │ + findByUserIdAndIsFavoriteTrue... │
│   OrNameContaining(...)            │       │ + countByUserId(userId): long      │
└────────────────────────────────────┘       │ + searchByUser(query, userId)      │
                                             │ + searchPublic(query)              │
┌────────────────────────────────────┐       │ + findTop5ByUserIdOrderBy...       │
│        «Interface»                 │       └────────────────────────────────────┘
│    FriendshipRepository            │
├────────────────────────────────────┤       ┌────────────────────────────────────┐
│ + findAcceptedFriendships(userId)  │       │        «Interface»                 │
│ + findPendingRequestsReceived(id)  │       │  SharedSimulationRepository        │
│ + findPendingRequestsSent(userId)  │       ├────────────────────────────────────┤
│ + findByUsers(user1, user2)        │       │ + findBySharedByIdOrderBy...       │
│ + countFriends(userId): long       │       │ + findBySharedWithIdOrderBy...     │
└────────────────────────────────────┘       │ + findBySimulationIdAndSharedWithId│
                                             │ + countBySharedById(userId)        │
┌────────────────────────────────────┐       └────────────────────────────────────┘
│        «Interface»                 │
│   ChatMessageRepository            │       ┌────────────────────────────────────┐
├────────────────────────────────────┤       │        «Interface»                 │
│ + findConversation(user1, user2)   │       │    NotificationRepository          │
│ + findLatestMessagesPerConversation│       ├────────────────────────────────────┤
│ + countUnreadFromSender(...)       │       │ + findByUserIdOrderByCreatedAtDesc │
│ + countUnreadMessages(userId)      │       │ + countByUserIdAndIsReadFalse      │
└────────────────────────────────────┘       │ + findByUserIdAndIsReadFalse(...)  │
                                             └────────────────────────────────────┘
```

---

### 8. Security Layer

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    SECURITY                                          │
└─────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────┐       ┌────────────────────────────────────┐
│           «Service»                │       │         «Component»                │
│        JwtTokenProvider            │       │      JwtAuthenticationFilter       │
├────────────────────────────────────┤       ├────────────────────────────────────┤
│ - jwtSecret: String                │       │ - jwtTokenProvider                 │
│ - jwtExpiration: Long              │       │ - userRepository                   │
│ - refreshExpiration: Long          │       ├────────────────────────────────────┤
├────────────────────────────────────┤       │ + doFilterInternal(request,        │
│ + generateAccessToken(userId,      │       │   response, chain)                 │
│   email): String                   │       │ - getJwtFromRequest(request)       │
│ + generateRefreshToken(userId)     │       │ - extractUserFromToken(token)      │
│   : String                         │       └────────────────────────────────────┘
│ + validateToken(token): boolean    │
│ + getUserIdFromToken(token): String│       ┌────────────────────────────────────┐
│ + getEmailFromToken(token): String │       │       «Configuration»              │
│ + getExpirationTime(): long        │       │       SecurityConfig               │
│ - getSigningKey(): SecretKey       │       ├────────────────────────────────────┤
└────────────────────────────────────┘       │ + securityFilterChain(...)         │
                                             │ + passwordEncoder(): BCrypt        │
                                             │ + corsConfigurationSource()        │
                                             └────────────────────────────────────┘
```

---

## Légende

| Symbole | Signification |
|---------|---------------|
| `─────` | Association |
| `◄────` | Association avec direction |
| `◇────` | Composition (embedded) |
| `──▶──` | Dépendance |
| `1` | Multiplicité: un |
| `*` | Multiplicité: plusieurs |
| `0..1` | Multiplicité: zéro ou un |

---

**Auteur:** Analyse automatique du backend SimStruct  
**Date:** Décembre 2025  
**Version:** 1.0
