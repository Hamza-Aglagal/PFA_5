# SIMSTRUCT - Structural Engineering Simulation Platform

## 🏗️ Project Overview
SIMSTRUCT is a comprehensive structural engineering simulation platform for civil engineering students and professionals. It provides tools for beam analysis, load calculations, and structural safety assessments.

## 🚀 Features
- **User Authentication**: JWT-based secure authentication
- **Structural Simulations**: Beam analysis with various support types
- **Real-time Results**: Instant calculation of deflection, stress, and safety factors
- **History Management**: Save and manage simulation history
- **Community Sharing**: Share simulations with other users
- **3D Visualization**: Three.js powered structural visualization

## 🛠️ Tech Stack

### Backend
- **Framework**: Spring Boot 3.4.12
- **Language**: Java 17
- **Database**: H2 (dev) / PostgreSQL (prod)
- **Security**: Spring Security with JWT
- **Build**: Maven

### Frontend
- **Framework**: Angular 21
- **UI**: Custom SCSS with modern design
- **3D Visualization**: Three.js
- **State Management**: Angular Signals

### Mobile
- **Framework**: Flutter
- **Language**: Dart

## 📦 Docker Setup

### Quick Start
```bash
# Build and run all services
docker-compose up --build

# Run in detached mode
docker-compose up -d --build

# Stop all services
docker-compose down
```

### Access Points
- **Frontend**: http://localhost:4200
- **Backend API**: http://localhost:8080/api/v1
- **H2 Console**: http://localhost:8080/h2-console

## 🔧 Development Setup

### Backend
```bash
cd Backend/simstruct-backend
./mvnw spring-boot:run
```

### Frontend
```bash
cd Web/simstruct
npm install
npm start
```

## 📡 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh token

### Simulations
- `POST /api/v1/simulations` - Create simulation
- `GET /api/v1/simulations` - Get user simulations
- `GET /api/v1/simulations/{id}` - Get simulation by ID
- `DELETE /api/v1/simulations/{id}` - Delete simulation

## 👨‍💻 Author
- **Hamza Aglagal** - EMSI 5 PFA Project

## 📄 License
This project is for educational purposes - EMSI 5th Year Final Project (PFA)
