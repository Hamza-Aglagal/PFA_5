# SimStruct Spring Boot Project Structure

## Overview

This document provides the complete package structure and file organization for the SimStruct backend. Follow this structure exactly when implementing the project.

---

## Root Project Structure

```
simstruct-backend/
├── .github/
│   └── workflows/
│       └── ci.yml
├── .mvn/
│   └── wrapper/
│       ├── maven-wrapper.jar
│       └── maven-wrapper.properties
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── simstruct/
│   │   │           └── backend/
│   │   │               ├── SimStructApplication.java
│   │   │               ├── common/
│   │   │               ├── config/
│   │   │               ├── security/
│   │   │               └── modules/
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       ├── messages/
│   │       └── templates/
│   └── test/
│       └── java/
│           └── com/
│               └── simstruct/
│                   └── backend/
│                       ├── SimStructApplicationTests.java
│                       └── modules/
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── docs/
│   ├── API_DOCUMENTATION.md
│   └── DEPLOYMENT.md
├── scripts/
│   └── init-db.sql
├── .gitignore
├── mvnw
├── mvnw.cmd
├── pom.xml
└── README.md
```

---

## Detailed Package Structure

### com.simstruct.backend

```
com.simstruct.backend/
│
├── SimStructApplication.java              # Main application entry point
│
├── common/                                 # Shared utilities and base classes
│   ├── entity/
│   │   ├── BaseEntity.java                # Abstract base with id, timestamps
│   │   └── SoftDeletableEntity.java       # Base with soft delete support
│   │
│   ├── dto/
│   │   ├── ApiResponse.java               # Standard API response wrapper
│   │   ├── ErrorDetails.java              # Error information structure
│   │   ├── PageResponse.java              # Pagination wrapper
│   │   └── ValidationError.java           # Validation error details
│   │
│   ├── exception/
│   │   ├── BaseException.java             # Base exception class
│   │   ├── ResourceNotFoundException.java
│   │   ├── UnauthorizedException.java
│   │   ├── ForbiddenException.java
│   │   ├── ConflictException.java
│   │   ├── ValidationException.java
│   │   └── GlobalExceptionHandler.java    # @ControllerAdvice
│   │
│   ├── util/
│   │   ├── DateTimeUtil.java
│   │   ├── SlugUtil.java
│   │   └── ValidationUtil.java
│   │
│   └── constant/
│       ├── ErrorCodes.java
│       └── AppConstants.java
│
├── config/                                 # Application configuration
│   ├── WebConfig.java                     # CORS, interceptors
│   ├── JpaConfig.java                     # JPA/Hibernate config
│   ├── CacheConfig.java                   # Redis cache config
│   ├── AsyncConfig.java                   # Async execution config
│   ├── OpenApiConfig.java                 # Swagger/OpenAPI config
│   └── properties/
│       ├── JwtProperties.java             # @ConfigurationProperties
│       └── AppProperties.java
│
├── security/                               # Security layer
│   ├── SecurityConfig.java                # Main security configuration
│   ├── JwtAuthenticationFilter.java       # JWT filter
│   ├── JwtAuthenticationEntryPoint.java   # Unauthorized handler
│   ├── JwtAccessDeniedHandler.java        # Forbidden handler
│   │
│   ├── jwt/
│   │   ├── JwtService.java                # JWT generation/validation
│   │   ├── JwtTokenProvider.java          # Token utilities
│   │   └── TokenType.java                 # Enum: ACCESS, REFRESH
│   │
│   ├── userdetails/
│   │   ├── CustomUserDetails.java         # UserDetails implementation
│   │   └── CustomUserDetailsService.java
│   │
│   └── util/
│       └── SecurityUtils.java             # Get current user utilities
│
└── modules/                                # Feature modules (Domain-Driven)
    │
    ├── auth/                              # Authentication module
    │   ├── controller/
    │   │   └── AuthController.java
    │   ├── dto/
    │   │   ├── request/
    │   │   │   ├── LoginRequest.java
    │   │   │   ├── RegisterRequest.java
    │   │   │   ├── RefreshTokenRequest.java
    │   │   │   ├── ForgotPasswordRequest.java
    │   │   │   └── ResetPasswordRequest.java
    │   │   └── response/
    │   │       └── AuthResponse.java
    │   ├── entity/
    │   │   └── RefreshToken.java
    │   ├── repository/
    │   │   └── RefreshTokenRepository.java
    │   ├── service/
    │   │   ├── AuthService.java           # Interface
    │   │   └── impl/
    │   │       └── AuthServiceImpl.java
    │   └── mapper/
    │       └── AuthMapper.java            # MapStruct
    │
    ├── user/                              # User management module
    │   ├── controller/
    │   │   └── UserController.java
    │   ├── dto/
    │   │   ├── request/
    │   │   │   ├── UpdateUserRequest.java
    │   │   │   └── ChangePasswordRequest.java
    │   │   └── response/
    │   │       ├── UserResponse.java
    │   │       └── UserStatsResponse.java
    │   ├── entity/
    │   │   ├── User.java
    │   │   └── UserRole.java              # Enum
    │   ├── repository/
    │   │   └── UserRepository.java
    │   ├── service/
    │   │   ├── UserService.java
    │   │   └── impl/
    │   │       └── UserServiceImpl.java
    │   └── mapper/
    │       └── UserMapper.java
    │
    ├── simulation/                        # Core simulation module
    │   ├── controller/
    │   │   └── SimulationController.java
    │   ├── dto/
    │   │   ├── request/
    │   │   │   ├── CreateSimulationRequest.java
    │   │   │   └── UpdateSimulationRequest.java
    │   │   └── response/
    │   │       ├── SimulationResponse.java
    │   │       ├── SimulationListResponse.java
    │   │       └── SimulationResultResponse.java
    │   ├── entity/
    │   │   ├── Simulation.java
    │   │   ├── SimulationResult.java
    │   │   ├── MaterialType.java          # Enum
    │   │   ├── LoadType.java              # Enum
    │   │   ├── SupportType.java           # Enum
    │   │   └── SimulationStatus.java      # Enum
    │   ├── repository/
    │   │   ├── SimulationRepository.java
    │   │   └── SimulationResultRepository.java
    │   ├── service/
    │   │   ├── SimulationService.java
    │   │   ├── CalculationService.java
    │   │   ├── ReportService.java
    │   │   └── impl/
    │   │       ├── SimulationServiceImpl.java
    │   │       ├── CalculationServiceImpl.java
    │   │       └── ReportServiceImpl.java
    │   ├── mapper/
    │   │   └── SimulationMapper.java
    │   └── calculation/                   # Calculation engine
    │       ├── BeamCalculator.java        # Interface
    │       ├── SimplySupportedBeamCalculator.java
    │       ├── CantileverBeamCalculator.java
    │       ├── FixedBeamCalculator.java
    │       └── CalculationResult.java     # Internal DTO
    │
    ├── friendship/                        # Friends module
    │   ├── controller/
    │   │   └── FriendshipController.java
    │   ├── dto/
    │   │   └── response/
    │   │       └── FriendResponse.java
    │   ├── entity/
    │   │   ├── Friendship.java
    │   │   └── FriendshipStatus.java      # Enum
    │   ├── repository/
    │   │   └── FriendshipRepository.java
    │   ├── service/
    │   │   ├── FriendshipService.java
    │   │   └── impl/
    │   │       └── FriendshipServiceImpl.java
    │   └── mapper/
    │       └── FriendshipMapper.java
    │
    ├── invitation/                        # Email invitations module
    │   ├── controller/
    │   │   └── InvitationController.java
    │   ├── dto/
    │   │   ├── request/
    │   │   │   └── SendInvitationRequest.java
    │   │   └── response/
    │   │       └── InvitationResponse.java
    │   ├── entity/
    │   │   ├── Invitation.java
    │   │   └── InvitationStatus.java      # Enum
    │   ├── repository/
    │   │   └── InvitationRepository.java
    │   ├── service/
    │   │   ├── InvitationService.java
    │   │   ├── EmailService.java
    │   │   └── impl/
    │   │       ├── InvitationServiceImpl.java
    │   │       └── EmailServiceImpl.java
    │   └── mapper/
    │       └── InvitationMapper.java
    │
    ├── share/                             # Shared simulations module
    │   ├── controller/
    │   │   └── SharedSimulationController.java
    │   ├── dto/
    │   │   ├── request/
    │   │   │   └── ShareSimulationRequest.java
    │   │   └── response/
    │   │       └── SharedSimulationResponse.java
    │   ├── entity/
    │   │   ├── SharedSimulation.java
    │   │   └── SharePermission.java       # Enum
    │   ├── repository/
    │   │   └── SharedSimulationRepository.java
    │   ├── service/
    │   │   ├── SharedSimulationService.java
    │   │   └── impl/
    │   │       └── SharedSimulationServiceImpl.java
    │   └── mapper/
    │       └── SharedSimulationMapper.java
    │
    ├── notification/                      # Notifications module
    │   ├── controller/
    │   │   └── NotificationController.java
    │   ├── dto/
    │   │   └── response/
    │   │       └── NotificationResponse.java
    │   ├── entity/
    │   │   ├── Notification.java
    │   │   ├── NotificationType.java      # Enum
    │   │   └── NotificationCategory.java  # Enum
    │   ├── repository/
    │   │   └── NotificationRepository.java
    │   ├── service/
    │   │   ├── NotificationService.java
    │   │   └── impl/
    │   │       └── NotificationServiceImpl.java
    │   └── mapper/
    │       └── NotificationMapper.java
    │
    └── chat/                              # Real-time chat module
        ├── controller/
        │   ├── ChatController.java        # REST endpoints
        │   └── ChatWebSocketController.java # WebSocket handlers
        ├── dto/
        │   ├── request/
        │   │   └── SendMessageRequest.java
        │   └── response/
        │       ├── ConversationResponse.java
        │       ├── ChatMessageResponse.java
        │       └── ParticipantResponse.java
        ├── entity/
        │   ├── Conversation.java
        │   └── ChatMessage.java
        ├── repository/
        │   ├── ConversationRepository.java
        │   └── ChatMessageRepository.java
        ├── service/
        │   ├── ChatService.java
        │   └── impl/
        │       └── ChatServiceImpl.java
        ├── mapper/
        │   └── ChatMapper.java
        └── websocket/
            ├── WebSocketConfig.java
            ├── WebSocketEventListener.java
            ├── WebSocketAuthInterceptor.java
            └── ChatMessageHandler.java
```

---

## pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.2</version>
        <relativePath/>
    </parent>
    
    <groupId>com.simstruct</groupId>
    <artifactId>simstruct-backend</artifactId>
    <version>1.0.0</version>
    <name>simstruct-backend</name>
    <description>SimStruct - Structural Engineering Simulation Platform Backend</description>
    
    <properties>
        <java.version>17</java.version>
        <jjwt.version>0.12.3</jjwt.version>
        <mapstruct.version>1.5.5.Final</mapstruct.version>
        <springdoc.version>2.3.0</springdoc.version>
        <poi.version>5.2.5</poi.version>
        <itext.version>8.0.2</itext.version>
    </properties>
    
    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-websocket</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-mail</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-cache</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        
        <!-- Database -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>${jjwt.version}</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>${jjwt.version}</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>${jjwt.version}</version>
            <scope>runtime</scope>
        </dependency>
        
        <!-- MapStruct -->
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
            <version>${mapstruct.version}</version>
        </dependency>
        
        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- OpenAPI/Swagger -->
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>${springdoc.version}</version>
        </dependency>
        
        <!-- Report Generation -->
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-ooxml</artifactId>
            <version>${poi.version}</version>
        </dependency>
        
        <dependency>
            <groupId>com.itextpdf</groupId>
            <artifactId>itext-core</artifactId>
            <version>${itext.version}</version>
            <type>pom</type>
        </dependency>
        
        <!-- Development Tools -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>postgresql</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                    <annotationProcessorPaths>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                            <version>${lombok.version}</version>
                        </path>
                        <path>
                            <groupId>org.mapstruct</groupId>
                            <artifactId>mapstruct-processor</artifactId>
                            <version>${mapstruct.version}</version>
                        </path>
                        <path>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok-mapstruct-binding</artifactId>
                            <version>0.2.0</version>
                        </path>
                    </annotationProcessorPaths>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.11</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## application.yml

```yaml
spring:
  application:
    name: simstruct-backend
  
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
  
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:simstruct}
    username: ${DB_USERNAME:simstruct}
    password: ${DB_PASSWORD:}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      connection-timeout: 20000
  
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        jdbc:
          batch_size: 25
        order_inserts: true
        order_updates: true
    open-in-view: false
  
  mail:
    host: ${MAIL_HOST:smtp.gmail.com}
    port: ${MAIL_PORT:587}
    username: ${MAIL_USERNAME:}
    password: ${MAIL_PASSWORD:}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
  
  cache:
    type: redis
  
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
      password: ${REDIS_PASSWORD:}

server:
  port: ${SERVER_PORT:8080}
  servlet:
    context-path: /api/v1

# Custom application properties
app:
  jwt:
    secret: ${JWT_SECRET:your-256-bit-secret-key-here-must-be-at-least-256-bits}
    access-token-expiration: 900000     # 15 minutes in milliseconds
    refresh-token-expiration: 604800000 # 7 days in milliseconds
    issuer: simstruct
  
  cors:
    allowed-origins:
      - http://localhost:4200
      - http://localhost:3000
    allowed-methods:
      - GET
      - POST
      - PUT
      - DELETE
      - OPTIONS
    allowed-headers:
      - "*"
    allow-credentials: true
  
  security:
    password-reset-expiration: 3600000  # 1 hour
    max-login-attempts: 5
    lockout-duration: 900000            # 15 minutes

# Logging
logging:
  level:
    root: INFO
    com.simstruct: DEBUG
    org.springframework.security: INFO
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql: TRACE

# Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when_authorized

# OpenAPI
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: method
```

---

## application-dev.yml

```yaml
spring:
  jpa:
    show-sql: true

logging:
  level:
    com.simstruct: DEBUG
    org.hibernate.SQL: DEBUG
```

---

## application-prod.yml

```yaml
spring:
  jpa:
    show-sql: false
  
  cache:
    redis:
      time-to-live: 3600000

logging:
  level:
    root: WARN
    com.simstruct: INFO
    org.springframework.security: WARN
    org.hibernate: WARN

server:
  error:
    include-stacktrace: never
```

---

## Test Structure

```
src/test/java/com/simstruct/backend/
├── SimStructApplicationTests.java
│
├── common/
│   └── BaseIntegrationTest.java         # Test config with @SpringBootTest
│
├── modules/
│   ├── auth/
│   │   ├── controller/
│   │   │   └── AuthControllerTest.java
│   │   └── service/
│   │       └── AuthServiceTest.java
│   │
│   ├── user/
│   │   ├── controller/
│   │   │   └── UserControllerTest.java
│   │   ├── repository/
│   │   │   └── UserRepositoryTest.java
│   │   └── service/
│   │       └── UserServiceTest.java
│   │
│   ├── simulation/
│   │   ├── controller/
│   │   │   └── SimulationControllerTest.java
│   │   ├── service/
│   │   │   ├── SimulationServiceTest.java
│   │   │   └── CalculationServiceTest.java
│   │   └── calculation/
│   │       ├── SimplySupportedBeamCalculatorTest.java
│   │       ├── CantileverBeamCalculatorTest.java
│   │       └── FixedBeamCalculatorTest.java
│   │
│   ├── friendship/
│   │   └── service/
│   │       └── FriendshipServiceTest.java
│   │
│   ├── share/
│   │   └── service/
│   │       └── SharedSimulationServiceTest.java
│   │
│   ├── notification/
│   │   └── service/
│   │       └── NotificationServiceTest.java
│   │
│   └── chat/
│       └── service/
│           └── ChatServiceTest.java
│
└── security/
    ├── JwtServiceTest.java
    └── SecurityConfigTest.java
```

---

## Docker Files

### Dockerfile

```dockerfile
# Build stage
FROM eclipse-temurin:17-jdk-alpine as build
WORKDIR /app

# Copy Maven wrapper
COPY mvnw .
COPY .mvn .mvn

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B

# Copy source and build
COPY src src
RUN ./mvnw package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/v1/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile
    container_name: simstruct-api
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=simstruct
      - DB_USERNAME=simstruct
      - DB_PASSWORD=${DB_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - MAIL_HOST=${MAIL_HOST}
      - MAIL_USERNAME=${MAIL_USERNAME}
      - MAIL_PASSWORD=${MAIL_PASSWORD}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - simstruct-network
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    container_name: simstruct-db
    environment:
      - POSTGRES_DB=simstruct
      - POSTGRES_USER=simstruct
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U simstruct -d simstruct"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - simstruct-network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: simstruct-cache
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - simstruct-network
    restart: unless-stopped

networks:
  simstruct-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

---

## .gitignore

```gitignore
# Compiled class files
*.class

# Log files
*.log

# Package files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# Maven
target/
!.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

# IDE
.idea/
*.iws
*.iml
*.ipr
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Environment files
.env
.env.local
.env.*.local

# Application
application-local.yml
application-local.properties

# Build
build/
out/

# Coverage
coverage/
*.lcov
```

---

## Environment Variables Template (.env.example)

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=simstruct
DB_USERNAME=simstruct
DB_PASSWORD=your_secure_password_here

# JWT
JWT_SECRET=your-256-bit-secret-key-here-must-be-at-least-256-bits-long

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Mail
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# Server
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=dev
```

---

## Module Responsibility Matrix

| Module | Entities | Primary Responsibility |
|--------|----------|------------------------|
| auth | RefreshToken | Authentication, token management |
| user | User | User profile, statistics |
| simulation | Simulation, SimulationResult | Core business logic, calculations |
| friendship | Friendship | Friend connections |
| invitation | Invitation | Email invitations to non-users |
| share | SharedSimulation | Simulation sharing between users |
| notification | Notification | Real-time notifications |
| chat | Conversation, ChatMessage | Real-time messaging |

---

*End of Project Structure Document*
