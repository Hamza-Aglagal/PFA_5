# SimStruct Technical Architecture

## 1. Executive Summary

This document outlines the technical architecture for the SimStruct backend system - a structural engineering simulation platform. The architecture is designed for production-readiness, scalability, maintainability, and security.

---

## 2. Technology Stack

### 2.1 Core Technologies

| Layer | Technology | Version | Justification |
|-------|------------|---------|---------------|
| **Runtime** | Java | 17 LTS | Long-term support, modern features, industry standard |
| **Framework** | Spring Boot | 3.2.x | Production-ready, extensive ecosystem, excellent documentation |
| **Database** | PostgreSQL | 16.x | ACID compliance, JSON support, excellent performance, free |
| **ORM** | Spring Data JPA + Hibernate | 6.x | Abstraction, productivity, type-safe queries |
| **Migration** | Flyway | 9.x | Version control for database, rollback support |
| **Security** | Spring Security + JWT | 6.x | Industry standard, flexible, well-maintained |
| **Build Tool** | Maven | 3.9.x | Mature, widely supported, extensive plugins |
| **Container** | Docker + Docker Compose | Latest | Consistent environments, easy deployment |

### 2.2 Additional Libraries

| Library | Purpose | Justification |
|---------|---------|---------------|
| **Lombok** | Reduce boilerplate | Cleaner code, less error-prone |
| **MapStruct** | DTO mapping | Compile-time mapping, type-safe |
| **Jackson** | JSON processing | Spring default, excellent performance |
| **SpringDoc OpenAPI** | API documentation | Auto-generated Swagger docs |
| **JJWT** | JWT handling | Industry standard JWT library |
| **BCrypt** | Password hashing | Secure, adaptive hashing |
| **Spring WebSocket** | Real-time communication | Native Spring support |
| **Spring Validation** | Input validation | Declarative validation |
| **Spring AOP** | Cross-cutting concerns | Logging, auditing, transactions |
| **Apache PDFBox** | PDF generation | Open source, feature-rich |
| **Spring Cache + Redis** | Caching | Performance optimization |
| **Spring Actuator** | Monitoring | Health checks, metrics |

### 2.3 Development Tools

| Tool | Purpose |
|------|---------|
| **Spring DevTools** | Hot reload during development |
| **H2 Database** | In-memory database for testing |
| **JUnit 5** | Unit testing |
| **Mockito** | Mocking framework |
| **TestContainers** | Integration testing with real DB |

---

## 3. Architecture Patterns

### 3.1 Layered Architecture

The application follows a clean **Layered Architecture** (N-Tier) pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│         (REST Controllers, WebSocket Handlers)               │
├─────────────────────────────────────────────────────────────┤
│                     SERVICE LAYER                            │
│         (Business Logic, Transaction Management)             │
├─────────────────────────────────────────────────────────────┤
│                   REPOSITORY LAYER                           │
│         (Data Access, JPA Repositories)                      │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│         (Entities, Value Objects, Enums)                     │
├─────────────────────────────────────────────────────────────┤
│                   INFRASTRUCTURE LAYER                       │
│         (Database, External Services, Cache)                 │
└─────────────────────────────────────────────────────────────┘
```

**Justification:**
- Clear separation of concerns
- Easy to understand and maintain
- Well-suited for medium-complexity applications
- Testable at each layer
- Industry-standard approach

### 3.2 Design Patterns Used

| Pattern | Where Used | Purpose |
|---------|------------|---------|
| **Repository Pattern** | Data Access | Abstract database operations |
| **Service Pattern** | Business Logic | Encapsulate business rules |
| **DTO Pattern** | API Communication | Never expose entities directly |
| **Factory Pattern** | Object Creation | Complex object instantiation |
| **Builder Pattern** | DTOs, Entities | Readable object construction |
| **Strategy Pattern** | Calculations | Different structural analysis algorithms |
| **Observer Pattern** | Notifications | Event-driven notifications |
| **Singleton Pattern** | Services | Spring-managed beans |

### 3.3 API Design Principles

1. **RESTful Conventions**
   - Use nouns for resources (`/simulations`, `/users`)
   - HTTP verbs for actions (GET, POST, PUT, DELETE)
   - Consistent URL structure
   - Proper HTTP status codes

2. **Consistent Response Format**
```json
{
  "success": true,
  "data": { ... },
  "error": null
}

{
  "success": false,
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": {
      "email": "must not be blank"
    }
  }
}
```

3. **Pagination Format**
```json
{
  "content": [...],
  "page": 0,
  "size": 20,
  "totalElements": 100,
  "totalPages": 5,
  "last": false
}
```

4. **API Versioning**
   - URL-based versioning: `/api/v1/...`
   - Allows gradual migration
   - Clear version identification

---

## 4. Database Design Strategy

### 4.1 Database Selection: PostgreSQL

**Why PostgreSQL over alternatives:**

| Feature | PostgreSQL | MySQL | MongoDB |
|---------|------------|-------|---------|
| ACID Compliance | ✅ Full | ✅ Full | ⚠️ Limited |
| JSON Support | ✅ Excellent | ⚠️ Limited | ✅ Native |
| Complex Queries | ✅ Excellent | ✅ Good | ⚠️ Limited |
| Referential Integrity | ✅ Strong | ✅ Strong | ❌ No FK |
| Free & Open Source | ✅ | ✅ | ⚠️ Paid features |
| Performance | ✅ Excellent | ✅ Good | ✅ Excellent |
| Scalability | ✅ Good | ✅ Good | ✅ Excellent |

**Decision:** PostgreSQL for its robust feature set, excellent ACID compliance, and strong JSON support for storing complex simulation results.

### 4.2 Design Principles

1. **UUID Primary Keys**
   - Non-sequential (security)
   - No need for auto-increment sequences
   - Easy distributed system migration
   - URL-safe

2. **Soft Deletes**
   - `deleted_at` column for recoverable entities
   - Data retention compliance
   - Audit trail preservation
   - Entity: User, Simulation

3. **Timestamps**
   - `created_at` on all entities
   - `updated_at` on mutable entities
   - UTC timezone

4. **Indexing Strategy**
   - Primary keys (automatic)
   - Foreign keys
   - Frequently queried columns
   - Composite indexes for complex queries

5. **Normalization**
   - 3NF for most tables
   - Denormalization only for read-heavy operations

### 4.3 Entity Relationships

```
User (1) ─────────────< (N) Simulation
User (1) ─────────────< (N) Notification
User (1) ─────────────< (N) RefreshToken
User (N) ────Friendship────< (N) User
User (1) ─────────────< (N) Invitation
User (N) ──Conversation──< (N) User
Simulation (1) ────────< (1) SimulationResult
Simulation (N) ─SharedSim─< (N) User
Conversation (1) ─────< (N) ChatMessage
```

---

## 5. Security Architecture

### 5.1 Authentication Strategy: JWT

**Why JWT over Session-based:**

| Feature | JWT | Session |
|---------|-----|---------|
| Stateless | ✅ | ❌ |
| Scalable | ✅ Easy | ⚠️ Requires sticky sessions |
| Mobile-friendly | ✅ | ⚠️ |
| Cross-domain | ✅ | ❌ |
| Performance | ✅ No DB lookup | ⚠️ Session store required |

**JWT Structure:**
```
Header: { alg: "HS512", typ: "JWT" }
Payload: {
  sub: "user-uuid",
  email: "user@example.com",
  role: "USER",
  iat: timestamp,
  exp: timestamp
}
Signature: HMACSHA512(header + payload, secret)
```

**Token Strategy:**
- Access Token: 15 minutes expiry
- Refresh Token: 7 days expiry
- Tokens stored in `localStorage` (client)
- Refresh tokens stored in DB (revocable)

### 5.2 Password Security

- **Algorithm:** BCrypt with strength 12
- **Why BCrypt:** Adaptive, resistant to brute-force
- **Salt:** Automatic per-password salt
- **Never store plain passwords**

### 5.3 Security Measures

| Measure | Implementation |
|---------|----------------|
| **CORS** | Whitelist allowed origins |
| **CSRF** | Disabled (stateless JWT) |
| **XSS** | Input sanitization, proper encoding |
| **SQL Injection** | Parameterized queries (JPA) |
| **Rate Limiting** | 100 req/min for auth endpoints |
| **Input Validation** | Bean Validation (@Valid) |
| **HTTPS** | Enforced in production |
| **Secrets** | Environment variables |

### 5.4 Authorization

- **Role-based Access Control (RBAC)**
  - USER: Standard access
  - PRO: Enhanced features
  - ADMIN: Full access

- **Resource-based Authorization**
  - Users can only access their own resources
  - Shared resources check permission levels

---

## 6. Real-time Communication Strategy

### 6.1 WebSocket vs Alternatives

| Technology | Use Case | Decision |
|------------|----------|----------|
| **WebSocket** | Bidirectional, low latency | ✅ Chat, Notifications |
| **SSE** | Server-to-client only | ❌ Chat needs bidirectional |
| **Long Polling** | Fallback | ❌ Inefficient |

### 6.2 WebSocket Architecture

```
┌─────────────┐         ┌─────────────────────────┐
│   Client    │ ──WS──> │   WebSocket Handler     │
└─────────────┘         └───────────┬─────────────┘
                                    │
                        ┌───────────▼─────────────┐
                        │   Message Broker        │
                        │   (Spring STOMP)        │
                        └───────────┬─────────────┘
                                    │
                        ┌───────────▼─────────────┐
                        │   User Sessions         │
                        │   (In-Memory)           │
                        └─────────────────────────┘
```

**Endpoints:**
- `/ws` - WebSocket connection endpoint
- `/topic/notifications/{userId}` - User notifications
- `/topic/chat/{conversationId}` - Chat messages
- `/app/chat.send` - Send message

### 6.3 Scalability Considerations

For single-server deployment (current scope):
- In-memory session management
- Simple broadcast to subscribed users

For future scaling:
- Redis pub/sub for message distribution
- Sticky sessions or distributed session store

---

## 7. File Storage Strategy

### 7.1 Current Scope: Local Storage

**For MVP:**
- Store generated PDF reports locally
- Directory: `/var/simstruct/reports/`
- Filename: `{simulationId}_{timestamp}.pdf`
- Cleanup: Files older than 24 hours

### 7.2 Future: Cloud Storage

When scaling:
- Amazon S3 or compatible (MinIO)
- CDN for report downloads
- Pre-signed URLs for secure access

---

## 8. Caching Strategy

### 8.1 Cache Layers

1. **Application Cache (Spring Cache)**
   - Method-level caching
   - User profile data
   - Simulation counts
   - TTL: 5 minutes

2. **Future: Redis Cache**
   - Session data
   - Rate limiting counters
   - Distributed cache

### 8.2 What to Cache

| Data | Cache Duration | Reason |
|------|----------------|--------|
| User profile | 5 min | Frequently accessed |
| Public simulations | 2 min | List queries |
| Simulation count | 5 min | Dashboard stat |
| Friend list | 2 min | Community queries |

### 8.3 Cache Invalidation

- Invalidate on data modification
- Time-based expiration (TTL)
- Manual invalidation endpoints (admin)

---

## 9. Error Handling Strategy

### 9.1 Global Exception Handler

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    // Handle validation errors
    // Handle business exceptions
    // Handle security exceptions
    // Handle unexpected errors
}
```

### 9.2 Exception Hierarchy

```
BaseException
├── ValidationException
├── AuthenticationException
├── AuthorizationException
├── ResourceNotFoundException
├── BusinessException
│   ├── SimulationException
│   ├── FriendshipException
│   └── InvitationException
└── InternalException
```

### 9.3 Error Response Format

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Simulation not found",
    "details": null,
    "timestamp": "2024-12-02T10:30:00Z",
    "path": "/api/v1/simulations/123"
  }
}
```

### 9.4 HTTP Status Code Mapping

| Error Type | HTTP Status |
|------------|-------------|
| Validation Error | 400 Bad Request |
| Authentication | 401 Unauthorized |
| Authorization | 403 Forbidden |
| Not Found | 404 Not Found |
| Conflict | 409 Conflict |
| Business Error | 422 Unprocessable Entity |
| Server Error | 500 Internal Server Error |

---

## 10. Logging Strategy

### 10.1 Log Levels

| Level | Usage |
|-------|-------|
| ERROR | Application errors, exceptions |
| WARN | Recoverable issues, deprecations |
| INFO | Business events, state changes |
| DEBUG | Detailed flow information |
| TRACE | Very detailed debugging |

### 10.2 What to Log

- API requests (method, path, duration)
- Authentication events
- Business operations (create, update, delete)
- Errors with stack traces
- Performance metrics

### 10.3 Log Format

```
2024-12-02 10:30:00.123 INFO [simstruct] [request-id] --- ClassName : Message
```

### 10.4 Log Storage

- Development: Console
- Production: File rotation (100MB, 30 days)
- Future: ELK Stack (Elasticsearch, Logstash, Kibana)

---

## 11. Testing Strategy

### 11.1 Test Pyramid

```
         ╱╲
        ╱  ╲       E2E Tests (5%)
       ╱────╲
      ╱      ╲     Integration Tests (15%)
     ╱────────╲
    ╱          ╲   Unit Tests (80%)
   ╱────────────╲
```

### 11.2 Test Types

| Type | Scope | Tools |
|------|-------|-------|
| Unit | Individual methods | JUnit 5, Mockito |
| Integration | Service + Repository | TestContainers |
| API | REST endpoints | MockMvc |
| WebSocket | Real-time features | Spring Test |

### 11.3 Test Coverage Goals

- Minimum: 70% line coverage
- Target: 85% line coverage
- Critical paths: 100% coverage

---

## 12. Monitoring & Observability

### 12.1 Health Checks

Spring Actuator endpoints:
- `/actuator/health` - Application health
- `/actuator/info` - Application info
- `/actuator/metrics` - Performance metrics

### 12.2 Metrics to Track

| Metric | Purpose |
|--------|---------|
| Request count | Traffic patterns |
| Response time | Performance |
| Error rate | Reliability |
| Active users | Usage |
| Database connections | Resource usage |
| Memory usage | Capacity |

### 12.3 Alerting (Future)

- High error rate (>1%)
- Response time degradation (>2s avg)
- Database connection pool exhaustion
- Memory threshold exceeded

---

## 13. Deployment Architecture

### 13.1 Docker Compose Setup

```yaml
services:
  app:
    build: .
    ports: ["8080:8080"]
    depends_on: [db]
    
  db:
    image: postgres:16
    volumes: [postgres_data:/var/lib/postgresql/data]
    
  redis:  # Future
    image: redis:7
```

### 13.2 Environment Configuration

| Environment | Database | Debug | Cache |
|-------------|----------|-------|-------|
| Development | H2/PostgreSQL | Full | Disabled |
| Testing | H2/TestContainers | Limited | Disabled |
| Production | PostgreSQL | Minimal | Enabled |

### 13.3 Environment Variables

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=simstruct
DB_USERNAME=app_user
DB_PASSWORD=secure_password

# JWT
JWT_SECRET=your-256-bit-secret
JWT_ACCESS_EXPIRATION=900000
JWT_REFRESH_EXPIRATION=604800000

# Application
SERVER_PORT=8080
CORS_ALLOWED_ORIGINS=http://localhost:4200,http://localhost:3000
```

---

## 14. Performance Considerations

### 14.1 Database Optimization

- Connection pooling (HikariCP, 10 connections)
- Query optimization with indexes
- Pagination for list endpoints
- Lazy loading for relationships

### 14.2 API Optimization

- Response compression (gzip)
- Efficient serialization (Jackson)
- Caching common queries
- Rate limiting

### 14.3 Simulation Processing

- Synchronous processing (current)
- Future: Async processing with message queue
- Progress tracking via WebSocket

---

## 15. Future Scalability Path

### Phase 1 (Current): Single Server
- Docker Compose deployment
- Local file storage
- In-memory sessions

### Phase 2: Horizontal Scaling
- Load balancer
- Multiple app instances
- Redis for sessions/cache
- S3 for file storage

### Phase 3: Microservices (If Needed)
- Auth Service
- Simulation Service
- Notification Service
- Chat Service

---

## 16. Summary of Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Architecture | Layered (N-Tier) | Simplicity, maintainability |
| Database | PostgreSQL | Robustness, JSON support |
| Auth | JWT | Stateless, scalable |
| Real-time | WebSocket (STOMP) | Bidirectional, native Spring |
| API Style | REST | Industry standard |
| Versioning | URL-based (/api/v1) | Clear, simple |
| Error Handling | Global handler | Consistency |
| Caching | Spring Cache | Simplicity |
| Testing | JUnit + TestContainers | Comprehensive |
| Deployment | Docker Compose | Portability |
