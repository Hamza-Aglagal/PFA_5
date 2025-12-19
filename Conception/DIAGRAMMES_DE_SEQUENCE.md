# Diagrammes de Séquence - SimStruct Backend

## Table des matières
1. [Inscription Utilisateur](#1-inscription-utilisateur)
2. [Connexion Utilisateur](#2-connexion-utilisateur)
3. [Création de Simulation avec IA](#3-création-de-simulation-avec-ia)
4. [Consultation de Simulation (Contrôle d'Accès)](#4-consultation-de-simulation-contrôle-daccès)
5. [Partage de Simulation](#5-partage-de-simulation)
6. [Demande d'Amitié](#6-demande-damitié)
7. [Acceptation d'Amitié](#7-acceptation-damitié)
8. [Envoi de Message Chat](#8-envoi-de-message-chat)
9. [Validation JWT](#9-validation-jwt)

---

## 1. Inscription Utilisateur

```
┌──────────┐          ┌──────────────┐          ┌─────────────┐          ┌──────────────┐
│  Client  │          │AuthController│          │ AuthService │          │ UserRepository│
└────┬─────┘          └──────┬───────┘          └──────┬──────┘          └──────┬───────┘
     │                       │                         │                        │
     │ POST /api/v1/auth/register                      │                        │
     │ {name, email, password}                         │                        │
     │──────────────────────▶│                         │                        │
     │                       │                         │                        │
     │                       │ register(request)       │                        │
     │                       │────────────────────────▶│                        │
     │                       │                         │                        │
     │                       │                         │ existsByEmail(email)   │
     │                       │                         │───────────────────────▶│
     │                       │                         │                        │
     │                       │                         │◀───────────────────────│
     │                       │                         │     false              │
     │                       │                         │                        │
     │                       │                         │ BCrypt.encode(password)│
     │                       │                         │─────────┐              │
     │                       │                         │         │              │
     │                       │                         │◀────────┘              │
     │                       │                         │                        │
     │                       │                         │ save(user)             │
     │                       │                         │───────────────────────▶│
     │                       │                         │                        │
     │                       │                         │◀───────────────────────│
     │                       │                         │     User saved         │
     │                       │                         │                        │
     │                       │                         │ generateTokens(user)   │
     │                       │                         │─────────┐              │
     │                       │                         │         │              │
     │                       │                         │◀────────┘              │
     │                       │                         │ {accessToken,          │
     │                       │                         │  refreshToken}         │
     │                       │                         │                        │
     │                       │◀────────────────────────│                        │
     │                       │   AuthResponse          │                        │
     │                       │                         │                        │
     │◀──────────────────────│                         │                        │
     │  201 Created          │                         │                        │
     │  {accessToken,        │                         │                        │
     │   refreshToken, user} │                         │                        │
     │                       │                         │                        │
```

---

## 2. Connexion Utilisateur

```
┌──────────┐          ┌──────────────┐          ┌─────────────┐          ┌──────────────┐
│  Client  │          │AuthController│          │ AuthService │          │ UserRepository│
└────┬─────┘          └──────┬───────┘          └──────┬──────┘          └──────┬───────┘
     │                       │                         │                        │
     │ POST /api/v1/auth/login                         │                        │
     │ {email, password}     │                         │                        │
     │──────────────────────▶│                         │                        │
     │                       │                         │                        │
     │                       │ login(request)          │                        │
     │                       │────────────────────────▶│                        │
     │                       │                         │                        │
     │                       │                         │ findByEmail(email)     │
     │                       │                         │───────────────────────▶│
     │                       │                         │                        │
     │                       │                         │◀───────────────────────│
     │                       │                         │   Optional<User>       │
     │                       │                         │                        │
     │                       │                         │ BCrypt.matches(        │
     │                       │                         │   password, hash)      │
     │                       │                         │─────────┐              │
     │                       │                         │         │              │
     │                       │                         │◀────────┘              │
     │                       │                         │   true                 │
     │                       │                         │                        │
     │                       │                         │ jwtProvider.           │
     │                       │                         │  generateAccessToken() │
     │                       │                         │─────────┐              │
     │                       │                         │         │              │
     │                       │                         │◀────────┘              │
     │                       │                         │ accessToken (15 min)   │
     │                       │                         │                        │
     │                       │                         │ jwtProvider.           │
     │                       │                         │  generateRefreshToken()│
     │                       │                         │─────────┐              │
     │                       │                         │         │              │
     │                       │                         │◀────────┘              │
     │                       │                         │ refreshToken (7 days)  │
     │                       │                         │                        │
     │                       │◀────────────────────────│                        │
     │                       │   AuthResponse          │                        │
     │                       │                         │                        │
     │◀──────────────────────│                         │                        │
     │  200 OK               │                         │                        │
     │  {accessToken,        │                         │                        │
     │   refreshToken, user} │                         │                        │
     │                       │                         │                        │
```

---

## 3. Création de Simulation avec IA

```
┌──────────┐     ┌────────────────┐     ┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│  Client  │     │SimulController │     │SimulationService│     │AIModelService│     │  AI Model   │
└────┬─────┘     └───────┬────────┘     └────────┬────────┘     └──────┬───────┘     └──────┬──────┘
     │                   │                       │                     │                    │
     │ POST /api/v1/simulations                  │                     │                    │
     │ {name, beamLength, beamWidth,             │                     │                    │
     │  beamHeight, materialType,                │                     │                    │
     │  loadMagnitude, ...}                      │                     │                    │
     │ Authorization: Bearer <token>             │                     │                    │
     │──────────────────▶│                       │                     │                    │
     │                   │                       │                     │                    │
     │                   │ @AuthenticationPrincipal                    │                    │
     │                   │ user = currentUser    │                     │                    │
     │                   │                       │                     │                    │
     │                   │ createSimulation(     │                     │                    │
     │                   │   request, userId)    │                     │                    │
     │                   │──────────────────────▶│                     │                    │
     │                   │                       │                     │                    │
     │                   │                       │ buildSimulation()   │                    │
     │                   │                       │──────────┐          │                    │
     │                   │                       │          │          │                    │
     │                   │                       │◀─────────┘          │                    │
     │                   │                       │ Simulation entity   │                    │
     │                   │                       │ status=PENDING      │                    │
     │                   │                       │                     │                    │
     │                   │                       │ predict(simulation) │                    │
     │                   │                       │────────────────────▶│                    │
     │                   │                       │                     │                    │
     │                   │                       │                     │ POST /predict      │
     │                   │                       │                     │ {beam_length,      │
     │                   │                       │                     │  beam_width, ...}  │
     │                   │                       │                     │───────────────────▶│
     │                   │                       │                     │                    │
     │                   │                       │                     │   Neural Network   │
     │                   │                       │                     │   Processing...    │
     │                   │                       │                     │                    │
     │                   │                       │                     │◀───────────────────│
     │                   │                       │                     │ {max_displacement, │
     │                   │                       │                     │  max_stress,       │
     │                   │                       │                     │  weight,           │
     │                   │                       │                     │  safety_status}    │
     │                   │                       │                     │                    │
     │                   │                       │◀────────────────────│                    │
     │                   │                       │ AIModelResponse     │                    │
     │                   │                       │                     │                    │
     │                   │                       │ applyAIResults()    │                    │
     │                   │                       │──────────┐          │                    │
     │                   │                       │          │          │                    │
     │                   │                       │◀─────────┘          │                    │
     │                   │                       │ Set SimulationResult│                    │
     │                   │                       │ status=COMPLETED    │                    │
     │                   │                       │                     │                    │
     │                   │                       │ save(simulation)    │                    │
     │                   │                       │──────────┐          │                    │
     │                   │                       │          │          │                    │
     │                   │                       │◀─────────┘          │                    │
     │                   │                       │                     │                    │
     │                   │◀──────────────────────│                     │                    │
     │                   │   SimulationResponse  │                     │                    │
     │                   │                       │                     │                    │
     │◀──────────────────│                       │                     │                    │
     │  201 Created      │                       │                     │                    │
     │  {id, name,       │                       │                     │                    │
     │   result: {...}}  │                       │                     │                    │
     │                   │                       │                     │                    │
```

---

## 4. Consultation de Simulation (Contrôle d'Accès)

```
┌──────────┐     ┌────────────────┐     ┌─────────────────┐     ┌────────────────┐     ┌───────────────────┐
│  Client  │     │SimulController │     │SimulationService│     │SimulationRepo  │     │SharedSimulationRepo│
└────┬─────┘     └───────┬────────┘     └────────┬────────┘     └───────┬────────┘     └─────────┬─────────┘
     │                   │                       │                      │                        │
     │ GET /api/v1/simulations/{id}              │                      │                        │
     │ Authorization: Bearer <token>             │                      │                        │
     │──────────────────▶│                       │                      │                        │
     │                   │                       │                      │                        │
     │                   │ getSimulation(id,     │                      │                        │
     │                   │   currentUserId)      │                      │                        │
     │                   │──────────────────────▶│                      │                        │
     │                   │                       │                      │                        │
     │                   │                       │ findById(id)         │                        │
     │                   │                       │─────────────────────▶│                        │
     │                   │                       │                      │                        │
     │                   │                       │◀─────────────────────│                        │
     │                   │                       │   Optional<Simulation>                        │
     │                   │                       │                      │                        │
     │                   │                       │ ┌──────────────────────────────────────────┐  │
     │                   │                       │ │ ACCESS CONTROL CHECK:                    │  │
     │                   │                       │ │                                          │  │
     │                   │                       │ │ 1. isOwner = simulation.user.id          │  │
     │                   │                       │ │             == currentUserId             │  │
     │                   │                       │ │                                          │  │
     │                   │                       │ │ 2. isPublic = simulation.isPublic        │  │
     │                   │                       │ │                                          │  │
     │                   │                       │ │ 3. isShared = check SharedSimulationRepo │  │
     │                   │                       │ └──────────────────────────────────────────┘  │
     │                   │                       │                      │                        │
     │                   │                       │ findBySimulationIdAndSharedWithId(           │
     │                   │                       │   simulationId, currentUserId)               │
     │                   │                       │──────────────────────────────────────────────▶│
     │                   │                       │                      │                        │
     │                   │                       │◀──────────────────────────────────────────────│
     │                   │                       │   Optional<SharedSimulation>                  │
     │                   │                       │                      │                        │
     │                   │                       │ if (isOwner || isPublic || isShared)          │
     │                   │                       │   → return simulation                         │
     │                   │                       │ else                  │                        │
     │                   │                       │   → throw AccessDeniedException               │
     │                   │                       │                      │                        │
     │                   │◀──────────────────────│                      │                        │
     │                   │   SimulationResponse  │                      │                        │
     │                   │                       │                      │                        │
     │◀──────────────────│                       │                      │                        │
     │  200 OK           │                       │                      │                        │
     │  {simulation}     │                       │                      │                        │
     │                   │                       │                      │                        │
```

---

## 5. Partage de Simulation

```
┌──────────┐     ┌────────────────────┐     ┌─────────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│  Client  │     │SharedSimController │     │SharedSimulService   │     │NotificationService│     │SimpMessagingTemplate│
└────┬─────┘     └─────────┬──────────┘     └──────────┬──────────┘     └─────────┬─────────┘     └─────────┬─────────┘
     │                     │                           │                          │                         │
     │ POST /api/v1/shares │                           │                          │                         │
     │ {simulationId,      │                           │                          │                         │
     │  sharedWithId,      │                           │                          │                         │
     │  permission, message}                           │                          │                         │
     │────────────────────▶│                           │                          │                         │
     │                     │                           │                          │                         │
     │                     │ shareSimulation(request,  │                          │                         │
     │                     │   currentUserId)          │                          │                         │
     │                     │──────────────────────────▶│                          │                         │
     │                     │                           │                          │                         │
     │                     │                           │ Validate:                │                         │
     │                     │                           │ - Simulation exists      │                         │
     │                     │                           │ - User is owner          │                         │
     │                     │                           │ - Target user exists     │                         │
     │                     │                           │ - Not already shared     │                         │
     │                     │                           │                          │                         │
     │                     │                           │ Create SharedSimulation  │                         │
     │                     │                           │──────────┐               │                         │
     │                     │                           │          │               │                         │
     │                     │                           │◀─────────┘               │                         │
     │                     │                           │                          │                         │
     │                     │                           │ save(sharedSimulation)   │                         │
     │                     │                           │──────────┐               │                         │
     │                     │                           │          │               │                         │
     │                     │                           │◀─────────┘               │                         │
     │                     │                           │                          │                         │
     │                     │                           │ notificationService.     │                         │
     │                     │                           │  createNotification()    │                         │
     │                     │                           │─────────────────────────▶│                         │
     │                     │                           │                          │                         │
     │                     │                           │                          │ save(notification)      │
     │                     │                           │                          │──────────┐              │
     │                     │                           │                          │          │              │
     │                     │                           │                          │◀─────────┘              │
     │                     │                           │                          │                         │
     │                     │                           │                          │ sendToUser(             │
     │                     │                           │                          │   sharedWithId,         │
     │                     │                           │                          │   notification)         │
     │                     │                           │                          │────────────────────────▶│
     │                     │                           │                          │                         │
     │                     │                           │                          │   WebSocket STOMP       │
     │                     │                           │                          │   /user/{id}/notifications
     │                     │                           │                          │                         │
     │                     │                           │◀─────────────────────────│                         │
     │                     │                           │                          │                         │
     │                     │◀──────────────────────────│                          │                         │
     │                     │   SharedSimulationResponse│                          │                         │
     │                     │                           │                          │                         │
     │◀────────────────────│                           │                          │                         │
     │  201 Created        │                           │                          │                         │
     │  {shareId, ...}     │                           │                          │                         │
     │                     │                           │                          │                         │
```

---

## 6. Demande d'Amitié

```
┌──────────┐     ┌──────────────────┐     ┌─────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│  Client  │     │FriendController  │     │FriendshipService│     │NotificationService│     │SimpMessagingTemplate│
└────┬─────┘     └────────┬─────────┘     └────────┬────────┘     └─────────┬─────────┘     └─────────┬─────────┘
     │                    │                        │                        │                         │
     │ POST /api/v1/friends/request                │                        │                         │
     │ {friendId}         │                        │                        │                         │
     │───────────────────▶│                        │                        │                         │
     │                    │                        │                        │                         │
     │                    │ sendFriendRequest(     │                        │                         │
     │                    │   currentUserId,       │                        │                         │
     │                    │   friendId)            │                        │                         │
     │                    │───────────────────────▶│                        │                         │
     │                    │                        │                        │                         │
     │                    │                        │ Check existing:        │                         │
     │                    │                        │ - Not already friends  │                         │
     │                    │                        │ - No pending request   │                         │
     │                    │                        │ - Not self-request     │                         │
     │                    │                        │                        │                         │
     │                    │                        │ Create Friendship      │                         │
     │                    │                        │ status = PENDING       │                         │
     │                    │                        │──────────┐             │                         │
     │                    │                        │          │             │                         │
     │                    │                        │◀─────────┘             │                         │
     │                    │                        │                        │                         │
     │                    │                        │ save(friendship)       │                         │
     │                    │                        │──────────┐             │                         │
     │                    │                        │          │             │                         │
     │                    │                        │◀─────────┘             │                         │
     │                    │                        │                        │                         │
     │                    │                        │ notificationService.   │                         │
     │                    │                        │  createNotification(   │                         │
     │                    │                        │   FRIEND_REQUEST,      │                         │
     │                    │                        │   friendId)            │                         │
     │                    │                        │───────────────────────▶│                         │
     │                    │                        │                        │                         │
     │                    │                        │                        │ save & send WebSocket   │
     │                    │                        │                        │────────────────────────▶│
     │                    │                        │                        │                         │
     │                    │                        │◀───────────────────────│                         │
     │                    │                        │                        │                         │
     │                    │◀───────────────────────│                        │                         │
     │                    │   FriendshipDTO        │                        │                         │
     │                    │                        │                        │                         │
     │◀───────────────────│                        │                        │                         │
     │  200 OK            │                        │                        │                         │
     │  {friendship}      │                        │                        │                         │
     │                    │                        │                        │                         │
```

---

## 7. Acceptation d'Amitié

```
┌──────────┐     ┌──────────────────┐     ┌─────────────────┐     ┌───────────────────┐
│  Client  │     │FriendController  │     │FriendshipService│     │FriendshipRepository│
└────┬─────┘     └────────┬─────────┘     └────────┬────────┘     └─────────┬─────────┘
     │                    │                        │                        │
     │ POST /api/v1/friends/accept/{senderId}      │                        │
     │───────────────────▶│                        │                        │
     │                    │                        │                        │
     │                    │ acceptFriendRequest(   │                        │
     │                    │   senderId,            │                        │
     │                    │   currentUserId)       │                        │
     │                    │───────────────────────▶│                        │
     │                    │                        │                        │
     │                    │                        │ findByUserIdAndFriendId│
     │                    │                        │  (senderId,            │
     │                    │                        │   currentUserId)       │
     │                    │                        │───────────────────────▶│
     │                    │                        │                        │
     │                    │                        │◀───────────────────────│
     │                    │                        │   Friendship (PENDING) │
     │                    │                        │                        │
     │                    │                        │ friendship.setStatus(  │
     │                    │                        │   ACCEPTED)            │
     │                    │                        │──────────┐             │
     │                    │                        │          │             │
     │                    │                        │◀─────────┘             │
     │                    │                        │                        │
     │                    │                        │ save(friendship)       │
     │                    │                        │───────────────────────▶│
     │                    │                        │                        │
     │                    │                        │◀───────────────────────│
     │                    │                        │                        │
     │                    │                        │ Create reciprocal      │
     │                    │                        │ Friendship (ACCEPTED)  │
     │                    │                        │ user=currentUser       │
     │                    │                        │ friend=sender          │
     │                    │                        │──────────┐             │
     │                    │                        │          │             │
     │                    │                        │◀─────────┘             │
     │                    │                        │                        │
     │                    │                        │ save(reciprocal)       │
     │                    │                        │───────────────────────▶│
     │                    │                        │                        │
     │                    │                        │◀───────────────────────│
     │                    │                        │                        │
     │                    │                        │ notificationService.   │
     │                    │                        │  notify FRIEND_ACCEPTED│
     │                    │                        │  to senderId           │
     │                    │                        │                        │
     │                    │◀───────────────────────│                        │
     │                    │   FriendshipDTO        │                        │
     │                    │                        │                        │
     │◀───────────────────│                        │                        │
     │  200 OK            │                        │                        │
     │  {friendship}      │                        │                        │
     │                    │                        │                        │
```

---

## 8. Envoi de Message Chat

```
┌──────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  Client  │     │ChatController│     │ ChatService │     │ChatMessageRepo   │     │SimpMessagingTemplate│
└────┬─────┘     └──────┬───────┘     └──────┬──────┘     └────────┬─────────┘     └─────────┬─────────┘
     │                  │                    │                     │                         │
     │ POST /api/v1/chat/send                │                     │                         │
     │ {recipientId, content,                │                     │                         │
     │  simulationId?}  │                    │                     │                         │
     │─────────────────▶│                    │                     │                         │
     │                  │                    │                     │                         │
     │                  │ sendMessage(       │                     │                         │
     │                  │   senderId,        │                     │                         │
     │                  │   recipientId,     │                     │                         │
     │                  │   content,         │                     │                         │
     │                  │   simulationId)    │                     │                         │
     │                  │───────────────────▶│                     │                         │
     │                  │                    │                     │                         │
     │                  │                    │ Validate:           │                         │
     │                  │                    │ - Sender exists     │                         │
     │                  │                    │ - Recipient exists  │                         │
     │                  │                    │ - Content not empty │                         │
     │                  │                    │                     │                         │
     │                  │                    │ Create ChatMessage  │                         │
     │                  │                    │ isRead = false      │                         │
     │                  │                    │──────────┐          │                         │
     │                  │                    │          │          │                         │
     │                  │                    │◀─────────┘          │                         │
     │                  │                    │                     │                         │
     │                  │                    │ save(message)       │                         │
     │                  │                    │────────────────────▶│                         │
     │                  │                    │                     │                         │
     │                  │                    │◀────────────────────│                         │
     │                  │                    │   ChatMessage saved │                         │
     │                  │                    │                     │                         │
     │                  │                    │ Convert to DTO      │                         │
     │                  │                    │──────────┐          │                         │
     │                  │                    │          │          │                         │
     │                  │                    │◀─────────┘          │                         │
     │                  │                    │   ChatMessageDTO    │                         │
     │                  │                    │                     │                         │
     │                  │                    │ messagingTemplate.  │                         │
     │                  │                    │  convertAndSendToUser                         │
     │                  │                    │  (recipientId,      │                         │
     │                  │                    │   "/queue/messages",│                         │
     │                  │                    │   messageDTO)       │                         │
     │                  │                    │────────────────────────────────────────────▶│
     │                  │                    │                     │                         │
     │                  │                    │                     │   WebSocket STOMP       │
     │                  │                    │                     │   Real-time delivery    │
     │                  │                    │                     │   to recipient          │
     │                  │                    │                     │                         │
     │                  │◀───────────────────│                     │                         │
     │                  │   ChatMessageDTO   │                     │                         │
     │                  │                    │                     │                         │
     │◀─────────────────│                    │                     │                         │
     │  200 OK          │                    │                     │                         │
     │  {message}       │                    │                     │                         │
     │                  │                    │                     │                         │
```

---

## 9. Validation JWT

```
┌──────────┐     ┌──────────────┐     ┌─────────────────┐     ┌──────────────┐     ┌──────────────┐
│  Client  │     │JwtAuthFilter │     │JwtTokenProvider │     │UserRepository│     │ Controller   │
└────┬─────┘     └──────┬───────┘     └────────┬────────┘     └──────┬───────┘     └──────┬───────┘
     │                  │                      │                     │                    │
     │ ANY /api/v1/**   │                      │                     │                    │
     │ Authorization:   │                      │                     │                    │
     │ Bearer <token>   │                      │                     │                    │
     │─────────────────▶│                      │                     │                    │
     │                  │                      │                     │                    │
     │                  │ Extract token from   │                     │                    │
     │                  │ Authorization header │                     │                    │
     │                  │─────────┐            │                     │                    │
     │                  │         │            │                     │                    │
     │                  │◀────────┘            │                     │                    │
     │                  │ "Bearer xyz..."      │                     │                    │
     │                  │ → token = "xyz..."   │                     │                    │
     │                  │                      │                     │                    │
     │                  │ validateToken(token) │                     │                    │
     │                  │─────────────────────▶│                     │                    │
     │                  │                      │                     │                    │
     │                  │                      │ Parse JWT with      │                    │
     │                  │                      │ secret key (HS384)  │                    │
     │                  │                      │─────────┐           │                    │
     │                  │                      │         │           │                    │
     │                  │                      │◀────────┘           │                    │
     │                  │                      │                     │                    │
     │                  │                      │ Check expiration    │                    │
     │                  │                      │─────────┐           │                    │
     │                  │                      │         │           │                    │
     │                  │                      │◀────────┘           │                    │
     │                  │                      │ not expired         │                    │
     │                  │                      │                     │                    │
     │                  │◀─────────────────────│                     │                    │
     │                  │   true               │                     │                    │
     │                  │                      │                     │                    │
     │                  │ getEmailFromToken()  │                     │                    │
     │                  │─────────────────────▶│                     │                    │
     │                  │                      │                     │                    │
     │                  │                      │ Extract 'sub' claim │                    │
     │                  │                      │─────────┐           │                    │
     │                  │                      │         │           │                    │
     │                  │                      │◀────────┘           │                    │
     │                  │                      │                     │                    │
     │                  │◀─────────────────────│                     │                    │
     │                  │   "user@email.com"   │                     │                    │
     │                  │                      │                     │                    │
     │                  │ findByEmail(email)   │                     │                    │
     │                  │─────────────────────────────────────────▶│                    │
     │                  │                      │                     │                    │
     │                  │◀─────────────────────────────────────────│                    │
     │                  │   User entity        │                     │                    │
     │                  │                      │                     │                    │
     │                  │ Set SecurityContext  │                     │                    │
     │                  │ Authentication = user│                     │                    │
     │                  │─────────┐            │                     │                    │
     │                  │         │            │                     │                    │
     │                  │◀────────┘            │                     │                    │
     │                  │                      │                     │                    │
     │                  │ filterChain.doFilter()                     │                    │
     │                  │ (continue to controller)                   │                    │
     │                  │─────────────────────────────────────────────────────────────▶│
     │                  │                      │                     │                    │
     │                  │                      │                     │                    │
     │                  │                      │                     │ @AuthenticationPrincipal
     │                  │                      │                     │ user = currentUser │
     │                  │                      │                     │                    │
     │◀──────────────────────────────────────────────────────────────────────────────────│
     │  Response from   │                      │                     │                    │
     │  controller      │                      │                     │                    │
     │                  │                      │                     │                    │
```

---

## Légende

| Symbole | Signification |
|---------|---------------|
| `─────▶` | Appel synchrone |
| `◀─────` | Retour synchrone |
| `──────┐` | Traitement interne |
| `│     │` | Boucle/traitement |
| `◀─────┘` | Fin de traitement |
| `PK` | Primary Key |
| `FK` | Foreign Key |

---

## Notes Techniques

### Authentification JWT
- **Algorithme**: HS384 (HMAC avec SHA-384)
- **Access Token**: Validité 15 minutes
- **Refresh Token**: Validité 7 jours
- **Claims**: subject (email), issued at, expiration

### WebSocket STOMP
- **Endpoint**: `/ws`
- **Destinations utilisateur**: `/user/{userId}/notifications`, `/user/{userId}/messages`
- **Broker**: Simple in-memory broker

### Transactions
- Toutes les opérations de service sont transactionnelles
- Rollback automatique en cas d'exception

---

**Auteur:** Analyse automatique du backend SimStruct  
**Date:** Décembre 2025  
**Version:** 1.0
