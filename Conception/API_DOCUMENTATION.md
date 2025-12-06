# SimStruct API Documentation

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [API Conventions](#api-conventions)
4. [Endpoints](#endpoints)
   - [Auth API](#auth-api)
   - [User API](#user-api)
   - [Simulation API](#simulation-api)
   - [Friends API](#friends-api)
   - [Invitations API](#invitations-api)
   - [Shared Simulations API](#shared-simulations-api)
   - [Notifications API](#notifications-api)
   - [Chat API](#chat-api)
5. [WebSocket Events](#websocket-events)
6. [Error Codes](#error-codes)

---

## Overview

### Base URL
```
Production: https://api.simstruct.com/api/v1
Development: http://localhost:8080/api/v1
```

### API Version
Current Version: `v1`

### Content Type
All requests must include:
```
Content-Type: application/json
Accept: application/json
```

---

## Authentication

### JWT Bearer Token

All authenticated endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <access_token>
```

### Token Lifecycle
- Access Token: Valid for 15 minutes
- Refresh Token: Valid for 7 days

---

## API Conventions

### Standard Response Format

**Success Response:**
```json
{
    "success": true,
    "data": { ... },
    "error": null
}
```

**Error Response:**
```json
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

### Pagination

Paginated endpoints accept:
- `page` (default: 0) - Zero-based page index
- `size` (default: 20, max: 100) - Items per page
- `sort` - Sort field and direction (e.g., `createdAt,desc`)

**Paginated Response:**
```json
{
    "success": true,
    "data": {
        "content": [ ... ],
        "page": 0,
        "size": 20,
        "totalElements": 150,
        "totalPages": 8,
        "last": false
    }
}
```

### HTTP Status Codes
| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Validation Error |
| 429 | Rate Limited |
| 500 | Internal Server Error |

---

## Endpoints

---

## Auth API

### Register

Create a new user account.

```
POST /auth/register
```

**Request Body:**
```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "SecurePass123!"
}
```

**Validation Rules:**
- `name`: Required, 2-100 characters
- `email`: Required, valid email format, unique
- `password`: Required, min 8 characters, must contain uppercase, lowercase, number

**Success Response (201):**
```json
{
    "success": true,
    "data": {
        "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
        "tokenType": "Bearer",
        "expiresIn": 900,
        "user": {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "email": "john@example.com",
            "name": "John Doe",
            "role": "USER",
            "avatarUrl": null,
            "emailVerified": false,
            "createdAt": "2024-01-15T10:30:00Z"
        }
    }
}
```

**Error Responses:**
- `409 Conflict`: Email already registered
- `422 Validation Error`: Invalid input

---

### Login

Authenticate and receive tokens.

```
POST /auth/login
```

**Request Body:**
```json
{
    "email": "john@example.com",
    "password": "SecurePass123!"
}
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
        "tokenType": "Bearer",
        "expiresIn": 900,
        "user": {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "email": "john@example.com",
            "name": "John Doe",
            "role": "USER",
            "avatarUrl": "https://cdn.simstruct.com/avatars/user123.jpg",
            "emailVerified": true,
            "createdAt": "2024-01-15T10:30:00Z"
        }
    }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid credentials

---

### Refresh Token

Get new access token using refresh token.

```
POST /auth/refresh
```

**Request Body:**
```json
{
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refreshToken": "bmV3IHJlZnJlc2ggdG9rZW4...",
        "tokenType": "Bearer",
        "expiresIn": 900
    }
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid or expired refresh token

---

### Logout

Revoke refresh token and invalidate session.

```
POST /auth/logout
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

**Success Response (204):** No Content

---

### Forgot Password

Request password reset email.

```
POST /auth/forgot-password
```

**Request Body:**
```json
{
    "email": "john@example.com"
}
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "message": "Password reset email sent if account exists"
    }
}
```

**Note:** Always returns success to prevent email enumeration.

---

### Reset Password

Reset password using token from email.

```
POST /auth/reset-password
```

**Request Body:**
```json
{
    "token": "reset-token-from-email",
    "newPassword": "NewSecurePass123!"
}
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "message": "Password reset successfully"
    }
}
```

**Error Responses:**
- `400 Bad Request`: Invalid or expired token

---

## User API

### Get Current User

Get authenticated user's profile.

```
GET /users/me
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "email": "john@example.com",
        "name": "John Doe",
        "role": "USER",
        "avatarUrl": "https://cdn.simstruct.com/avatars/user123.jpg",
        "phone": "+1234567890",
        "company": "ACME Engineering",
        "jobTitle": "Structural Engineer",
        "bio": "Passionate about building safe structures",
        "emailVerified": true,
        "createdAt": "2024-01-15T10:30:00Z"
    }
}
```

---

### Update User Profile

Update authenticated user's profile.

```
PUT /users/me
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "name": "John Smith",
    "phone": "+1234567890",
    "company": "ACME Engineering",
    "jobTitle": "Senior Structural Engineer",
    "bio": "Building the future, one beam at a time"
}
```

**Validation Rules:**
- `name`: Optional, 2-100 characters
- `phone`: Optional, valid phone format
- `company`: Optional, max 100 characters
- `jobTitle`: Optional, max 100 characters
- `bio`: Optional, max 500 characters

**Success Response (200):** Returns updated user object

---

### Change Password

Change authenticated user's password.

```
PUT /users/me/password
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "currentPassword": "OldPassword123!",
    "newPassword": "NewSecurePass123!"
}
```

**Success Response (204):** No Content

**Error Responses:**
- `400 Bad Request`: Current password incorrect
- `422 Validation Error`: New password doesn't meet requirements

---

### Delete Account

Soft delete user account.

```
DELETE /users/me
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

### Get User Statistics

Get authenticated user's statistics.

```
GET /users/me/stats
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "totalSimulations": 45,
        "monthlySimulations": 12,
        "completedSimulations": 42,
        "sharedSimulations": 8,
        "storageUsed": 256.5
    }
}
```

---

## Simulation API

### Create Simulation

Create a new beam simulation.

```
POST /simulations
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "name": "Bridge Support Beam Analysis",
    "description": "Analysis of main support beam for pedestrian bridge",
    "beamLength": 10.0,
    "beamHeight": 0.5,
    "beamWidth": 0.3,
    "materialType": "STEEL",
    "elasticModulus": 200000000000,
    "loadType": "DISTRIBUTED",
    "loadMagnitude": 50000,
    "loadPosition": null,
    "supportType": "SIMPLY_SUPPORTED",
    "isPublic": false
}
```

**Validation Rules:**
- `name`: Required, 1-200 characters
- `description`: Optional, max 1000 characters
- `beamLength`: Required, positive number (meters)
- `beamHeight`: Required, positive number (meters)
- `beamWidth`: Required, positive number (meters)
- `materialType`: Required, enum (CONCRETE, STEEL, WOOD, ALUMINUM, COMPOSITE)
- `elasticModulus`: Required, positive number (Pa)
- `loadType`: Required, enum (POINT, DISTRIBUTED, MOMENT, TRIANGULAR, TRAPEZOIDAL, UNIFORM)
- `loadMagnitude`: Required, positive number (N or N/m)
- `loadPosition`: Optional, 0 to beamLength (for point loads)
- `supportType`: Required, enum (SIMPLY_SUPPORTED, FIXED_FIXED, FIXED_FREE, FIXED_PINNED, CONTINUOUS, FIXED, PINNED)

**Success Response (201):**
```json
{
    "success": true,
    "data": {
        "id": "660e8400-e29b-41d4-a716-446655440001",
        "name": "Bridge Support Beam Analysis",
        "description": "Analysis of main support beam for pedestrian bridge",
        "beamLength": 10.0,
        "beamHeight": 0.5,
        "beamWidth": 0.3,
        "materialType": "STEEL",
        "elasticModulus": 200000000000,
        "loadType": "DISTRIBUTED",
        "loadMagnitude": 50000,
        "loadPosition": null,
        "supportType": "SIMPLY_SUPPORTED",
        "isPublic": false,
        "isFavorite": false,
        "status": "COMPLETED",
        "createdAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-01-15T10:30:00Z",
        "results": {
            "maxDeflection": 0.0125,
            "maxBendingMoment": 625000,
            "maxShearForce": 250000,
            "maxStress": 150000000,
            "safetyFactor": 2.33,
            "recommendations": [
                "Beam design is safe with adequate safety factor",
                "Consider adding intermediate supports for improved deflection control"
            ],
            "status": "SAFE"
        }
    }
}
```

---

### Get My Simulations

Get paginated list of user's simulations.

```
GET /simulations?page=0&size=20&sort=createdAt,desc
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page`: Page number (default: 0)
- `size`: Page size (default: 20, max: 100)
- `sort`: Sort field and direction
- `search`: Search by name (optional)
- `status`: Filter by status (optional)
- `materialType`: Filter by material (optional)

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "content": [
            {
                "id": "660e8400-e29b-41d4-a716-446655440001",
                "name": "Bridge Support Beam Analysis",
                "description": "Analysis of main support beam",
                "materialType": "STEEL",
                "supportType": "SIMPLY_SUPPORTED",
                "isPublic": false,
                "isFavorite": true,
                "status": "COMPLETED",
                "createdAt": "2024-01-15T10:30:00Z",
                "updatedAt": "2024-01-15T10:30:00Z"
            }
        ],
        "page": 0,
        "size": 20,
        "totalElements": 45,
        "totalPages": 3,
        "last": false
    }
}
```

---

### Get Simulation by ID

Get detailed simulation with results.

```
GET /simulations/{id}
Authorization: Bearer <access_token>
```

**Success Response (200):** Returns full simulation object with results

**Error Responses:**
- `404 Not Found`: Simulation not found or not accessible

---

### Update Simulation

Update simulation metadata.

```
PUT /simulations/{id}
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "name": "Updated Beam Analysis",
    "description": "Updated description",
    "isPublic": true
}
```

**Success Response (200):** Returns updated simulation

**Error Responses:**
- `403 Forbidden`: Not the owner
- `404 Not Found`: Simulation not found

---

### Delete Simulation

Soft delete a simulation.

```
DELETE /simulations/{id}
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

**Error Responses:**
- `403 Forbidden`: Not the owner
- `404 Not Found`: Simulation not found

---

### Toggle Favorite

Add or remove simulation from favorites.

```
POST /simulations/{id}/favorite
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "id": "660e8400-e29b-41d4-a716-446655440001",
        "isFavorite": true
    }
}
```

---

### Get Favorites

Get user's favorite simulations.

```
GET /simulations/favorites?page=0&size=20
Authorization: Bearer <access_token>
```

**Success Response (200):** Paginated list of favorite simulations

---

### Get Public Simulations

Browse public simulation gallery.

```
GET /simulations/public?page=0&size=20
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page`, `size`, `sort`: Standard pagination
- `search`: Search by name
- `materialType`: Filter by material
- `supportType`: Filter by support type

**Success Response (200):** Paginated list with owner info

---

### Clone Simulation

Create a copy of a simulation (public or shared with user).

```
POST /simulations/{id}/clone
Authorization: Bearer <access_token>
```

**Success Response (201):**
```json
{
    "success": true,
    "data": {
        "id": "770e8400-e29b-41d4-a716-446655440002",
        "name": "Bridge Support Beam Analysis (Copy)",
        "...": "...rest of simulation data..."
    }
}
```

---

### Generate Report

Download simulation report in PDF or Excel format.

```
GET /simulations/{id}/report?format=pdf
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `format`: `pdf` or `excel` (default: pdf)

**Success Response (200):**
- Content-Type: `application/pdf` or `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
- Content-Disposition: `attachment; filename="simulation-report.pdf"`

---

### Share Simulation

Generate a shareable link for the simulation.

```
POST /simulations/{id}/share
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "shareUrl": "https://simstruct.com/shared/abc123xyz",
        "expiresAt": "2024-02-15T10:30:00Z"
    }
}
```

---

## Friends API

### Get Friends

Get list of accepted friends.

```
GET /friends
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": "880e8400-e29b-41d4-a716-446655440003",
            "friendshipId": "990e8400-e29b-41d4-a716-446655440004",
            "name": "Jane Smith",
            "email": "jane@example.com",
            "avatarUrl": "https://cdn.simstruct.com/avatars/jane.jpg",
            "company": "Smith Engineering",
            "status": "ACCEPTED",
            "isInitiator": true,
            "connectedAt": "2024-01-10T08:00:00Z"
        }
    ]
}
```

---

### Get Pending Requests

Get friend requests received by user.

```
GET /friends/requests/pending
Authorization: Bearer <access_token>
```

**Success Response (200):** List of pending friend requests

---

### Get Sent Requests

Get friend requests sent by user.

```
GET /friends/requests/sent
Authorization: Bearer <access_token>
```

**Success Response (200):** List of sent friend requests

---

### Send Friend Request

Send a friend request to another user.

```
POST /friends/request/{userId}
Authorization: Bearer <access_token>
```

**Success Response (201):**
```json
{
    "success": true,
    "data": {
        "friendshipId": "990e8400-e29b-41d4-a716-446655440004",
        "status": "PENDING",
        "message": "Friend request sent successfully"
    }
}
```

**Error Responses:**
- `404 Not Found`: User not found
- `409 Conflict`: Request already exists or already friends

---

### Accept Friend Request

Accept a pending friend request.

```
PUT /friends/{friendshipId}/accept
Authorization: Bearer <access_token>
```

**Success Response (200):** Returns friend object with ACCEPTED status

**Error Responses:**
- `403 Forbidden`: Not the request recipient
- `404 Not Found`: Request not found

---

### Reject Friend Request

Reject a pending friend request.

```
DELETE /friends/{friendshipId}/reject
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

### Remove Friend

Remove an existing friend.

```
DELETE /friends/{friendshipId}
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

## Invitations API

### Get Sent Invitations

Get invitations sent by user to non-users.

```
GET /invitations/sent
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": "aa0e8400-e29b-41d4-a716-446655440005",
            "senderName": "John Doe",
            "senderEmail": "john@example.com",
            "recipientEmail": "newuser@example.com",
            "message": "Join SimStruct to collaborate on structural projects!",
            "status": "PENDING",
            "isExpired": false,
            "expiresAt": "2024-02-15T10:30:00Z",
            "createdAt": "2024-01-15T10:30:00Z"
        }
    ]
}
```

---

### Get Received Invitations

Get invitations received by user's email (for recently registered users).

```
GET /invitations/received
Authorization: Bearer <access_token>
```

**Success Response (200):** List of invitations

---

### Send Invitation

Send invitation email to a non-user.

```
POST /invitations
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "email": "newuser@example.com",
    "message": "Join SimStruct to collaborate on structural projects!"
}
```

**Validation Rules:**
- `email`: Required, valid email, not already registered
- `message`: Optional, max 500 characters

**Success Response (201):** Returns invitation object

**Error Responses:**
- `409 Conflict`: Email already registered (suggest sending friend request instead)

---

### Accept Invitation

Accept an invitation (creates friendship).

```
PUT /invitations/{id}/accept
Authorization: Bearer <access_token>
```

**Success Response (200):** Returns updated invitation with ACCEPTED status

---

### Decline Invitation

Decline an invitation.

```
PUT /invitations/{id}/decline
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

### Cancel Invitation

Cancel a sent invitation.

```
DELETE /invitations/{id}
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

## Shared Simulations API

### Get Simulations Shared With Me

Get simulations shared by others with the current user.

```
GET /shared-simulations/with-me?page=0&size=20
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "content": [
            {
                "id": "bb0e8400-e29b-41d4-a716-446655440006",
                "simulationId": "660e8400-e29b-41d4-a716-446655440001",
                "simulationName": "Bridge Support Beam Analysis",
                "simulationDescription": "Analysis of main support beam",
                "ownerName": "Jane Smith",
                "ownerEmail": "jane@example.com",
                "sharedWithName": "John Doe",
                "sharedWithEmail": "john@example.com",
                "permission": "VIEW",
                "message": "Take a look at this beam analysis",
                "sharedAt": "2024-01-15T10:30:00Z"
            }
        ],
        "page": 0,
        "size": 20,
        "totalElements": 8,
        "totalPages": 1,
        "last": true
    }
}
```

---

### Share Simulation

Share a simulation with a friend.

```
POST /shared-simulations
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "simulationId": "660e8400-e29b-41d4-a716-446655440001",
    "sharedWithId": "880e8400-e29b-41d4-a716-446655440003",
    "permission": "VIEW",
    "message": "Check out this beam analysis!"
}
```

**Validation Rules:**
- `simulationId`: Required, must own the simulation
- `sharedWithId`: Required, must be a friend
- `permission`: Required, enum (VIEW, COMMENT, EDIT)
- `message`: Optional, max 500 characters

**Success Response (201):** Returns shared simulation object

**Error Responses:**
- `403 Forbidden`: Not the simulation owner
- `404 Not Found`: Simulation or user not found
- `409 Conflict`: Already shared with this user

---

### Unshare Simulation

Remove sharing access.

```
DELETE /shared-simulations/{id}
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

## Notifications API

### Get Notifications

Get paginated notifications.

```
GET /notifications?page=0&size=20
Authorization: Bearer <access_token>
```

**Query Parameters:**
- Standard pagination
- `category`: Filter by category (optional)

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "content": [
            {
                "id": "cc0e8400-e29b-41d4-a716-446655440007",
                "type": "SUCCESS",
                "category": "SIMULATION",
                "title": "Simulation Completed",
                "message": "Your beam analysis 'Bridge Support' has been completed successfully.",
                "actionUrl": "/simulations/660e8400-e29b-41d4-a716-446655440001",
                "data": {
                    "simulationId": "660e8400-e29b-41d4-a716-446655440001"
                },
                "isRead": false,
                "createdAt": "2024-01-15T10:30:00Z"
            }
        ],
        "page": 0,
        "size": 20,
        "totalElements": 25,
        "totalPages": 2,
        "last": false
    }
}
```

---

### Get Unread Notifications

Get only unread notifications.

```
GET /notifications/unread?page=0&size=20
Authorization: Bearer <access_token>
```

**Success Response (200):** Paginated list of unread notifications

---

### Get Unread Count

Get count of unread notifications.

```
GET /notifications/count
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "count": 5
    }
}
```

---

### Mark as Read

Mark a specific notification as read.

```
PUT /notifications/{id}/read
Authorization: Bearer <access_token>
```

**Success Response (200):** Returns notification with isRead: true

---

### Mark All as Read

Mark all notifications as read.

```
PUT /notifications/read-all
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "updatedCount": 5
    }
}
```

---

### Delete Notification

Delete a specific notification.

```
DELETE /notifications/{id}
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

### Clear All Notifications

Delete all notifications for user.

```
DELETE /notifications
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

## Chat API

### Get Conversations

Get all user's conversations.

```
GET /chat/conversations
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": "dd0e8400-e29b-41d4-a716-446655440008",
            "otherParticipant": {
                "id": "880e8400-e29b-41d4-a716-446655440003",
                "name": "Jane Smith",
                "avatarUrl": "https://cdn.simstruct.com/avatars/jane.jpg"
            },
            "lastMessage": {
                "id": "ee0e8400-e29b-41d4-a716-446655440009",
                "senderId": "880e8400-e29b-41d4-a716-446655440003",
                "senderName": "Jane Smith",
                "content": "Thanks for sharing that simulation!",
                "sentAt": "2024-01-15T11:30:00Z",
                "isRead": true
            },
            "unreadCount": 0,
            "createdAt": "2024-01-10T08:00:00Z",
            "lastMessageAt": "2024-01-15T11:30:00Z"
        }
    ]
}
```

---

### Get Messages

Get messages for a conversation.

```
GET /chat/conversations/{id}/messages?page=0&size=50
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "content": [
            {
                "id": "ee0e8400-e29b-41d4-a716-446655440009",
                "senderId": "880e8400-e29b-41d4-a716-446655440003",
                "senderName": "Jane Smith",
                "content": "Thanks for sharing that simulation!",
                "sentAt": "2024-01-15T11:30:00Z",
                "isRead": true
            },
            {
                "id": "ff0e8400-e29b-41d4-a716-446655440010",
                "senderId": "550e8400-e29b-41d4-a716-446655440000",
                "senderName": "John Doe",
                "content": "No problem! Let me know if you have questions.",
                "sentAt": "2024-01-15T11:25:00Z",
                "isRead": true
            }
        ],
        "page": 0,
        "size": 50,
        "totalElements": 15,
        "totalPages": 1,
        "last": true
    }
}
```

---

### Get Unread Count

Get total unread message count across all conversations.

```
GET /chat/unread-count
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "count": 3
    }
}
```

---

### Start Conversation

Create or get existing conversation with a user.

```
POST /chat/conversations/{userId}
Authorization: Bearer <access_token>
```

**Success Response (200/201):** Returns conversation object

**Error Responses:**
- `403 Forbidden`: Not friends with user
- `404 Not Found`: User not found

---

### Send Message

Send a message in a conversation.

```
POST /chat/conversations/{id}/messages
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
    "content": "Hello! How's the project going?"
}
```

**Validation Rules:**
- `content`: Required, 1-5000 characters

**Success Response (201):**
```json
{
    "success": true,
    "data": {
        "id": "110e8400-e29b-41d4-a716-446655440011",
        "senderId": "550e8400-e29b-41d4-a716-446655440000",
        "senderName": "John Doe",
        "content": "Hello! How's the project going?",
        "sentAt": "2024-01-15T12:00:00Z",
        "isRead": false
    }
}
```

---

### Mark Conversation as Read

Mark all messages in conversation as read.

```
PUT /chat/conversations/{id}/read
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
    "success": true,
    "data": {
        "updatedCount": 3
    }
}
```

---

### Delete Conversation

Delete a conversation (for current user only).

```
DELETE /chat/conversations/{id}
Authorization: Bearer <access_token>
```

**Success Response (204):** No Content

---

## WebSocket Events

### Connection

Connect to WebSocket endpoint:
```
ws://localhost:8080/ws
```

**Headers Required:**
```
Authorization: Bearer <access_token>
```

### Subscribe to Topics

**Personal Notifications:**
```javascript
stompClient.subscribe('/user/queue/notifications', callback);
```

**Chat Messages:**
```javascript
stompClient.subscribe('/user/queue/messages', callback);
```

**Typing Indicators:**
```javascript
stompClient.subscribe('/topic/chat/{conversationId}/typing', callback);
```

### Send Messages

**Send Chat Message:**
```javascript
stompClient.send('/app/chat.send', {}, JSON.stringify({
    conversationId: 'dd0e8400-e29b-41d4-a716-446655440008',
    content: 'Hello!'
}));
```

**Send Typing Indicator:**
```javascript
stompClient.send('/app/chat.typing', {}, JSON.stringify({
    conversationId: 'dd0e8400-e29b-41d4-a716-446655440008',
    isTyping: true
}));
```

### Event Payloads

**New Message Event:**
```json
{
    "type": "NEW_MESSAGE",
    "data": {
        "conversationId": "dd0e8400-e29b-41d4-a716-446655440008",
        "message": {
            "id": "110e8400-e29b-41d4-a716-446655440011",
            "senderId": "880e8400-e29b-41d4-a716-446655440003",
            "content": "Hello!",
            "sentAt": "2024-01-15T12:00:00Z"
        }
    }
}
```

**Notification Event:**
```json
{
    "type": "NOTIFICATION",
    "data": {
        "id": "cc0e8400-e29b-41d4-a716-446655440007",
        "type": "INFO",
        "category": "COMMUNITY",
        "title": "New Friend Request",
        "message": "Jane Smith sent you a friend request",
        "createdAt": "2024-01-15T12:00:00Z"
    }
}
```

---

## Error Codes

### Authentication Errors
| Code | Message | HTTP Status |
|------|---------|-------------|
| AUTH_001 | Invalid credentials | 401 |
| AUTH_002 | Token expired | 401 |
| AUTH_003 | Invalid token | 401 |
| AUTH_004 | Token revoked | 401 |
| AUTH_005 | Refresh token required | 400 |

### User Errors
| Code | Message | HTTP Status |
|------|---------|-------------|
| USER_001 | User not found | 404 |
| USER_002 | Email already registered | 409 |
| USER_003 | Invalid current password | 400 |
| USER_004 | Account deleted | 404 |

### Simulation Errors
| Code | Message | HTTP Status |
|------|---------|-------------|
| SIM_001 | Simulation not found | 404 |
| SIM_002 | Not simulation owner | 403 |
| SIM_003 | Invalid parameters | 422 |
| SIM_004 | Calculation failed | 500 |

### Friendship Errors
| Code | Message | HTTP Status |
|------|---------|-------------|
| FRIEND_001 | Cannot send request to self | 400 |
| FRIEND_002 | Request already exists | 409 |
| FRIEND_003 | Already friends | 409 |
| FRIEND_004 | Request not found | 404 |
| FRIEND_005 | Not authorized to respond | 403 |

### Share Errors
| Code | Message | HTTP Status |
|------|---------|-------------|
| SHARE_001 | Cannot share with non-friend | 403 |
| SHARE_002 | Already shared | 409 |
| SHARE_003 | Share not found | 404 |

### Validation Errors
| Code | Message | HTTP Status |
|------|---------|-------------|
| VAL_001 | Required field missing | 422 |
| VAL_002 | Invalid email format | 422 |
| VAL_003 | Password too weak | 422 |
| VAL_004 | Value out of range | 422 |

---

## Rate Limiting

| Endpoint Category | Limit |
|-------------------|-------|
| Auth endpoints | 10 requests/minute |
| Standard endpoints | 100 requests/minute |
| File upload/download | 20 requests/minute |
| WebSocket messages | 60 messages/minute |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705321800
```

---

## Changelog

### v1.0.0 (2024-01-15)
- Initial API release
- Authentication with JWT
- Full simulation CRUD
- Friends and invitations
- Shared simulations
- Real-time chat and notifications

---

*End of API Documentation*
