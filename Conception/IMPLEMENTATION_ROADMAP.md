# SimStruct Backend Implementation Roadmap

## Overview

This document outlines the complete implementation roadmap for the SimStruct backend system. The implementation is divided into 6 phases, progressing from foundation to production-ready deployment.

**Total Estimated Duration:** 8-10 weeks  
**Team Size Assumption:** 1-2 developers

---

## Phase Overview

| Phase | Name | Duration | Description |
|-------|------|----------|-------------|
| 1 | Foundation | 1-2 weeks | Project setup, database, base architecture |
| 2 | Authentication | 1 week | JWT auth, user management |
| 3 | Core Business Logic | 2-3 weeks | Simulations, calculations |
| 4 | Social Features | 1-2 weeks | Friends, sharing, invitations |
| 5 | Real-Time Features | 1 week | WebSocket, chat, notifications |
| 6 | Production Prep | 1 week | Testing, optimization, deployment |

---

## Phase 1: Foundation (Week 1-2)

### 1.1 Project Initialization

**Goal:** Set up the Spring Boot project with proper structure and dependencies.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 1.1.1 | Create Spring Boot project using Spring Initializr | Manual | Critical |
| 1.1.2 | Configure Maven dependencies (see pom.xml spec) | Manual | Critical |
| 1.1.3 | Set up package structure following SPRING_BOOT_PROJECT_STRUCTURE.md | Manual | Critical |
| 1.1.4 | Configure application.yml for dev/prod profiles | Manual | Critical |
| 1.1.5 | Set up .gitignore and version control | Manual | High |

#### Dependencies to Add:
- Spring Boot Starter Web
- Spring Boot Starter Data JPA
- Spring Boot Starter Security
- Spring Boot Starter Validation
- Spring Boot Starter WebSocket
- PostgreSQL Driver
- Lombok
- MapStruct
- JJWT (JWT library)
- SpringDoc OpenAPI (Swagger)

### 1.2 Database Setup

**Goal:** Configure PostgreSQL and implement base entity classes.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 1.2.1 | Create Docker Compose file for PostgreSQL | Manual | Critical |
| 1.2.2 | Run DATABASE_SCHEMA.sql to create tables | Manual | Critical |
| 1.2.3 | Configure JPA/Hibernate properties | Manual | Critical |
| 1.2.4 | Create BaseEntity abstract class with audit fields | Guided | High |
| 1.2.5 | Configure Hibernate envers for audit logging | Guided | Medium |

#### Docker Compose (docker-compose.yml):
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:16-alpine
    container_name: simstruct-db
    environment:
      POSTGRES_DB: simstruct
      POSTGRES_USER: simstruct
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./DATABASE_SCHEMA.sql:/docker-entrypoint-initdb.d/init.sql

volumes:
  postgres_data:
```

### 1.3 Base Architecture

**Goal:** Implement common patterns and utilities.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 1.3.1 | Create ApiResponse wrapper class | Guided | Critical |
| 1.3.2 | Create ErrorDetails and ErrorResponse classes | Guided | Critical |
| 1.3.3 | Implement GlobalExceptionHandler | Guided | Critical |
| 1.3.4 | Create PageResponse wrapper for pagination | Guided | High |
| 1.3.5 | Configure CORS for Angular/Flutter | Manual | High |
| 1.3.6 | Set up request logging interceptor | Guided | Medium |

### 1.4 Deliverables Checklist - Phase 1

- [ ] Spring Boot project compiles and runs
- [ ] PostgreSQL running in Docker with all tables created
- [ ] Base entity classes implemented
- [ ] Global exception handling working
- [ ] Swagger UI accessible at /swagger-ui.html
- [ ] Health endpoint responding

---

## Phase 2: Authentication (Week 3)

### 2.1 Security Configuration

**Goal:** Implement JWT-based authentication system.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 2.1.1 | Create SecurityConfig class | Guided | Critical |
| 2.1.2 | Implement JwtService (generate/validate tokens) | Guided | Critical |
| 2.1.3 | Create JwtAuthenticationFilter | Guided | Critical |
| 2.1.4 | Configure password encoder (BCrypt) | Guided | High |
| 2.1.5 | Implement CustomUserDetailsService | Guided | High |

### 2.2 User Module

**Goal:** Implement User entity, repository, service, and controller.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 2.2.1 | Create User entity with JPA annotations | Guided | Critical |
| 2.2.2 | Create UserRepository interface | Guided | Critical |
| 2.2.3 | Create UserService with CRUD operations | Guided | Critical |
| 2.2.4 | Create DTOs (UserResponse, UpdateUserRequest, etc.) | Guided | Critical |
| 2.2.5 | Create UserController with endpoints | Guided | Critical |
| 2.2.6 | Implement UserMapper (MapStruct) | Guided | High |

### 2.3 Auth Module

**Goal:** Implement registration, login, and token management.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 2.3.1 | Create RefreshToken entity and repository | Guided | Critical |
| 2.3.2 | Create AuthService with login/register logic | Guided | Critical |
| 2.3.3 | Create AuthController with all auth endpoints | Guided | Critical |
| 2.3.4 | Implement refresh token rotation | Guided | High |
| 2.3.5 | Create password reset flow (with email) | Guided | Medium |
| 2.3.6 | Add rate limiting to auth endpoints | Guided | Medium |

### 2.4 Deliverables Checklist - Phase 2

- [ ] User registration works
- [ ] User login returns JWT tokens
- [ ] Token refresh works
- [ ] Protected endpoints require valid JWT
- [ ] User profile CRUD operations work
- [ ] Password change works
- [ ] Logout revokes refresh token

---

## Phase 3: Core Business Logic (Week 4-6)

### 3.1 Simulation Entity

**Goal:** Implement Simulation domain model.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 3.1.1 | Create enum types (MaterialType, LoadType, etc.) | Guided | Critical |
| 3.1.2 | Create Simulation entity | Guided | Critical |
| 3.1.3 | Create SimulationResult entity | Guided | Critical |
| 3.1.4 | Create SimulationRepository with custom queries | Guided | Critical |
| 3.1.5 | Create SimulationResultRepository | Guided | High |

### 3.2 Calculation Engine

**Goal:** Implement beam analysis calculation logic.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 3.2.1 | Create CalculationService interface | Guided | Critical |
| 3.2.2 | Implement deflection calculation | Guided | Critical |
| 3.2.3 | Implement bending moment calculation | Guided | Critical |
| 3.2.4 | Implement shear force calculation | Guided | Critical |
| 3.2.5 | Implement stress calculation | Guided | Critical |
| 3.2.6 | Implement safety factor calculation | Guided | Critical |
| 3.2.7 | Implement recommendation generator | Guided | High |
| 3.2.8 | Add unit tests for all calculations | Guided | High |

#### Calculation Formulas Reference:

**Simply Supported Beam with Point Load:**
```
Max Deflection: δ = (P × L³) / (48 × E × I)
Max Bending Moment: M = (P × L) / 4
Max Shear Force: V = P / 2
```

**Simply Supported Beam with Distributed Load:**
```
Max Deflection: δ = (5 × w × L⁴) / (384 × E × I)
Max Bending Moment: M = (w × L²) / 8
Max Shear Force: V = (w × L) / 2
```

**Cantilever with Point Load:**
```
Max Deflection: δ = (P × L³) / (3 × E × I)
Max Bending Moment: M = P × L
Max Shear Force: V = P
```

### 3.3 Simulation Service

**Goal:** Implement full simulation CRUD operations.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 3.3.1 | Create SimulationService interface | Guided | Critical |
| 3.3.2 | Implement createSimulation (with auto-calculation) | Guided | Critical |
| 3.3.3 | Implement getSimulation (with results) | Guided | Critical |
| 3.3.4 | Implement getUserSimulations (paginated) | Guided | Critical |
| 3.3.5 | Implement updateSimulation | Guided | Critical |
| 3.3.6 | Implement deleteSimulation (soft delete) | Guided | High |
| 3.3.7 | Implement toggleFavorite | Guided | High |
| 3.3.8 | Implement cloneSimulation | Guided | High |
| 3.3.9 | Implement getPublicSimulations | Guided | High |

### 3.4 Simulation Controller

**Goal:** Implement REST endpoints for simulations.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 3.4.1 | Create SimulationController | Guided | Critical |
| 3.4.2 | Implement all CRUD endpoints | Guided | Critical |
| 3.4.3 | Add request validation | Guided | High |
| 3.4.4 | Implement filtering and search | Guided | High |
| 3.4.5 | Create DTOs and mappers | Guided | High |

### 3.5 Report Generation

**Goal:** Implement PDF and Excel report generation.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 3.5.1 | Add Apache POI and iText dependencies | Manual | High |
| 3.5.2 | Create ReportService interface | Guided | High |
| 3.5.3 | Implement PDF report generation | Guided | High |
| 3.5.4 | Implement Excel report generation | Guided | Medium |
| 3.5.5 | Add report download endpoint | Guided | High |

### 3.6 Deliverables Checklist - Phase 3

- [ ] All simulation CRUD operations work
- [ ] Calculations produce correct results (verified with test cases)
- [ ] Favorites functionality works
- [ ] Public simulations browsing works
- [ ] Clone simulation works
- [ ] PDF report downloads correctly
- [ ] Search and filtering work
- [ ] Pagination works correctly

---

## Phase 4: Social Features (Week 7-8)

### 4.1 Friendship Module

**Goal:** Implement friend connections.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 4.1.1 | Create Friendship entity | Guided | Critical |
| 4.1.2 | Create FriendshipRepository with custom queries | Guided | Critical |
| 4.1.3 | Create FriendshipService | Guided | Critical |
| 4.1.4 | Implement send friend request | Guided | Critical |
| 4.1.5 | Implement accept/reject request | Guided | Critical |
| 4.1.6 | Implement remove friend | Guided | High |
| 4.1.7 | Create FriendshipController | Guided | Critical |

### 4.2 Invitation Module

**Goal:** Implement email invitations for non-users.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 4.2.1 | Create Invitation entity | Guided | High |
| 4.2.2 | Create InvitationRepository | Guided | High |
| 4.2.3 | Create InvitationService | Guided | High |
| 4.2.4 | Implement email service for invitations | Guided | High |
| 4.2.5 | Create InvitationController | Guided | High |
| 4.2.6 | Add invitation expiry handling | Guided | Medium |

### 4.3 Shared Simulations Module

**Goal:** Implement simulation sharing between friends.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 4.3.1 | Create SharedSimulation entity | Guided | Critical |
| 4.3.2 | Create SharedSimulationRepository | Guided | Critical |
| 4.3.3 | Create SharedSimulationService | Guided | Critical |
| 4.3.4 | Implement share simulation | Guided | Critical |
| 4.3.5 | Implement unshare simulation | Guided | High |
| 4.3.6 | Update simulation access checks | Guided | High |
| 4.3.7 | Create SharedSimulationController | Guided | Critical |

### 4.4 Deliverables Checklist - Phase 4

- [ ] Friend requests can be sent
- [ ] Friend requests can be accepted/rejected
- [ ] Friends list displays correctly
- [ ] Friends can be removed
- [ ] Invitations can be sent via email
- [ ] Invitations can be accepted/declined
- [ ] Simulations can be shared with friends
- [ ] Shared simulations appear in recipient's list
- [ ] Sharing can be revoked

---

## Phase 5: Real-Time Features (Week 9)

### 5.1 WebSocket Configuration

**Goal:** Set up STOMP over WebSocket.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 5.1.1 | Create WebSocketConfig class | Guided | Critical |
| 5.1.2 | Configure STOMP message broker | Guided | Critical |
| 5.1.3 | Implement WebSocket authentication | Guided | Critical |
| 5.1.4 | Create WebSocket session manager | Guided | High |

### 5.2 Notification Module

**Goal:** Implement real-time notifications.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 5.2.1 | Create Notification entity | Guided | Critical |
| 5.2.2 | Create NotificationRepository | Guided | Critical |
| 5.2.3 | Create NotificationService | Guided | Critical |
| 5.2.4 | Implement push notification via WebSocket | Guided | Critical |
| 5.2.5 | Create NotificationController | Guided | Critical |
| 5.2.6 | Add notification triggers to other services | Guided | High |

#### Notification Triggers:
- Friend request received
- Friend request accepted
- Simulation shared
- Simulation completed (if async)
- Invitation accepted

### 5.3 Chat Module

**Goal:** Implement real-time messaging.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 5.3.1 | Create Conversation entity | Guided | Critical |
| 5.3.2 | Create ChatMessage entity | Guided | Critical |
| 5.3.3 | Create repositories | Guided | Critical |
| 5.3.4 | Create ChatService | Guided | Critical |
| 5.3.5 | Implement WebSocket message handler | Guided | Critical |
| 5.3.6 | Create ChatController for REST endpoints | Guided | Critical |
| 5.3.7 | Implement typing indicators | Guided | Medium |
| 5.3.8 | Implement read receipts | Guided | Medium |

### 5.4 Deliverables Checklist - Phase 5

- [ ] WebSocket connection established successfully
- [ ] Real-time notifications delivered
- [ ] Notification count updates in real-time
- [ ] Chat messages delivered in real-time
- [ ] Chat history persists correctly
- [ ] Typing indicators work
- [ ] Read receipts update correctly
- [ ] Connection reconnects after disconnect

---

## Phase 6: Production Preparation (Week 10)

### 6.1 Testing

**Goal:** Achieve comprehensive test coverage.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 6.1.1 | Write unit tests for all services | Guided | Critical |
| 6.1.2 | Write integration tests for controllers | Guided | Critical |
| 6.1.3 | Write repository tests | Guided | High |
| 6.1.4 | Add security tests | Guided | High |
| 6.1.5 | Target 80% code coverage | Guided | High |

### 6.2 Performance Optimization

**Goal:** Optimize for production workloads.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 6.2.1 | Add Redis caching | Guided | High |
| 6.2.2 | Implement query optimization | Guided | High |
| 6.2.3 | Add connection pooling (HikariCP config) | Manual | High |
| 6.2.4 | Implement pagination for all list endpoints | Guided | High |
| 6.2.5 | Add database indexes (verify) | Manual | Medium |

### 6.3 Security Hardening

**Goal:** Ensure production-grade security.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 6.3.1 | Security audit and fix vulnerabilities | Manual | Critical |
| 6.3.2 | Add rate limiting | Guided | High |
| 6.3.3 | Configure HTTPS | Manual | Critical |
| 6.3.4 | Add security headers | Guided | High |
| 6.3.5 | Implement audit logging | Guided | Medium |

### 6.4 Docker & Deployment

**Goal:** Containerize and prepare for deployment.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 6.4.1 | Create Dockerfile for Spring Boot app | Manual | Critical |
| 6.4.2 | Create docker-compose.yml for full stack | Manual | Critical |
| 6.4.3 | Set up environment variable management | Manual | Critical |
| 6.4.4 | Create deployment documentation | Manual | High |
| 6.4.5 | Set up CI/CD pipeline (GitHub Actions) | Manual | High |

#### Dockerfile:
```dockerfile
FROM eclipse-temurin:17-jdk-alpine as build
WORKDIR /app
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 6.5 Documentation

**Goal:** Complete all documentation.

#### Tasks:

| # | Task | Type | Priority |
|---|------|------|----------|
| 6.5.1 | Update API documentation (Swagger) | Manual | High |
| 6.5.2 | Create README.md | Manual | High |
| 6.5.3 | Document environment variables | Manual | High |
| 6.5.4 | Create deployment guide | Manual | High |
| 6.5.5 | Document database schema changes | Manual | Medium |

### 6.6 Deliverables Checklist - Phase 6

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code coverage > 80%
- [ ] No critical security vulnerabilities
- [ ] Redis caching implemented
- [ ] Docker images build successfully
- [ ] Full stack runs with docker-compose
- [ ] CI/CD pipeline works
- [ ] All documentation complete

---

## Post-Launch Tasks

### Monitoring & Observability
- [ ] Set up application monitoring (Micrometer + Prometheus)
- [ ] Configure Grafana dashboards
- [ ] Set up alerting
- [ ] Implement distributed tracing (Zipkin/Jaeger)

### Future Enhancements
- [ ] AI-powered recommendations (Phase 2)
- [ ] Advanced 3D visualization API
- [ ] Multi-language support
- [ ] Mobile push notifications
- [ ] Export to CAD formats

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Calculation accuracy issues | High | Medium | Extensive unit testing, validation against known results |
| WebSocket scalability | Medium | Low | Use Redis pub/sub for horizontal scaling |
| Security vulnerabilities | High | Low | Regular security audits, dependency updates |
| Performance under load | Medium | Medium | Load testing, caching, query optimization |
| Database connection exhaustion | Medium | Low | Connection pooling, monitoring |

---

## Success Criteria

### Minimum Viable Product (MVP)
- [ ] User authentication (register, login, logout)
- [ ] Full simulation CRUD
- [ ] Calculation engine working correctly
- [ ] Basic community features (friends, sharing)
- [ ] PDF report generation

### Production Ready
- [ ] All features implemented and tested
- [ ] Real-time chat and notifications
- [ ] 80% test coverage
- [ ] Deployed with Docker
- [ ] Performance optimized
- [ ] Security hardened

---

## Appendix: Task Type Legend

| Type | Description |
|------|-------------|
| Manual | Requires manual configuration or setup, not code generation |
| Guided | Can be implemented with code templates/guidance from STEP_BY_STEP_GUIDE.md |

---

*End of Implementation Roadmap*
