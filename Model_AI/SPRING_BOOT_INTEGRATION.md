# 🔗 Intégration API Python ↔ Backend Spring Boot

## Vue d'ensemble

L'API Python (FastAPI) et le Backend Spring Boot communiquent via HTTP/REST.

```
┌─────────────────┐      HTTP/REST       ┌──────────────────┐
│   Frontend      │ ←──────────────────→ │  Spring Boot     │
│   (Angular)     │                      │   Backend        │
└─────────────────┘                      └────────┬─────────┘
                                                  │
                                                  │ HTTP/REST
                                                  │
                                         ┌────────▼─────────┐
                                         │  FastAPI Python  │
                                         │  (AI Model)      │
                                         └──────────────────┘
```

---

## 📍 Configuration des URLs

### API Python
- **URL locale**: `http://localhost:8000`
- **URL Docker**: `http://ai-service:8000`

### Backend Spring Boot
- **URL locale**: `http://localhost:8080`
- **URL Docker**: `http://backend:8080`

---

## 🔧 Implémentation côté Spring Boot

### 1. Ajouter la dépendance dans `pom.xml`

```xml
<!-- WebClient pour appels HTTP asynchrones -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
```

### 2. Créer le DTO pour la requête

```java
package com.simstruct.backend.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BuildingPredictionRequest {
    private Double numFloors;
    private Double floorHeight;
    private Integer numBeams;
    private Integer numColumns;
    private Double beamSection;
    private Double columnSection;
    private Double concreteStrength;
    private Double steelGrade;
    private Double windLoad;
    private Double liveLoad;
    private Double deadLoad;
}
```

### 3. Créer le DTO pour la réponse

```java
package com.simstruct.backend.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PredictionResponse {
    private Double maxDeflection;
    private Double maxStress;
    private Double stabilityIndex;
    private Double seismicResistance;
    private String status;
}
```

### 4. Créer le service d'intégration

```java
package com.simstruct.backend.service;

import com.simstruct.backend.dto.BuildingPredictionRequest;
import com.simstruct.backend.dto.PredictionResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Slf4j
@Service
public class AIPredictionService {

    private final WebClient webClient;

    // L'URL de l'API Python est configurable via application.properties
    public AIPredictionService(
            @Value("${ai.service.url:http://localhost:8000}") String aiServiceUrl) {
        this.webClient = WebClient.builder()
                .baseUrl(aiServiceUrl)
                .build();
    }

    /**
     * Appelle l'API Python pour obtenir une prédiction
     * 
     * @param request Les paramètres du bâtiment
     * @return La prédiction du modèle AI
     */
    public Mono<PredictionResponse> getPrediction(BuildingPredictionRequest request) {
        log.info("Calling AI API for prediction: {}", request);
        
        return webClient.post()
                .uri("/predict")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(PredictionResponse.class)
                .doOnSuccess(response -> 
                    log.info("AI prediction received: {}", response))
                .doOnError(error -> 
                    log.error("Error calling AI API: {}", error.getMessage()));
    }

    /**
     * Vérifie si l'API AI est accessible
     * 
     * @return true si l'API est en bonne santé
     */
    public Mono<Boolean> checkHealth() {
        return webClient.get()
                .uri("/health")
                .retrieve()
                .bodyToMono(String.class)
                .map(response -> response.contains("healthy"))
                .onErrorReturn(false);
    }
}
```

### 5. Créer le contrôleur REST

```java
package com.simstruct.backend.controller;

import com.simstruct.backend.dto.BuildingPredictionRequest;
import com.simstruct.backend.dto.PredictionResponse;
import com.simstruct.backend.service.AIPredictionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import javax.validation.Valid;

@Slf4j
@RestController
@RequestMapping("/api/predictions")
@RequiredArgsConstructor
@Tag(name = "AI Predictions", description = "Endpoints pour les prédictions AI")
public class PredictionController {

    private final AIPredictionService aiPredictionService;

    /**
     * Obtenir une prédiction structurale
     */
    @PostMapping
    @Operation(summary = "Obtenir une prédiction AI")
    public Mono<ResponseEntity<PredictionResponse>> predict(
            @Valid @RequestBody BuildingPredictionRequest request) {
        
        log.info("Received prediction request: {}", request);
        
        return aiPredictionService.getPrediction(request)
                .map(ResponseEntity::ok)
                .onErrorReturn(ResponseEntity.internalServerError().build());
    }

    /**
     * Vérifier la santé de l'API AI
     */
    @GetMapping("/health")
    @Operation(summary = "Vérifier la santé de l'API AI")
    public Mono<ResponseEntity<String>> checkAIHealth() {
        return aiPredictionService.checkHealth()
                .map(healthy -> healthy 
                    ? ResponseEntity.ok("AI Service is healthy")
                    : ResponseEntity.status(503).body("AI Service is unavailable"));
    }
}
```

### 6. Configuration dans `application.properties`

```properties
# Configuration de l'API AI
ai.service.url=http://localhost:8000

# Pour Docker (décommentez en production)
# ai.service.url=http://ai-service:8000

# Timeout pour les appels à l'API AI (en secondes)
spring.webflux.timeout=30
```

---

## 🐳 Configuration Docker Compose

Ajoutez le service AI dans votre `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Service AI Python
  ai-service:
    build:
      context: ./Model_AI
      dockerfile: Dockerfile
    container_name: simstruct-ai
    ports:
      - "8000:8000"
    networks:
      - simstruct-network
    environment:
      - PYTHONUNBUFFERED=1
    volumes:
      - ./Model_AI/models:/app/models
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Backend Spring Boot
  backend:
    build:
      context: ./Backend/simstruct-backend
      dockerfile: Dockerfile
    container_name: simstruct-backend
    ports:
      - "8080:8080"
    depends_on:
      - postgres
      - ai-service
    networks:
      - simstruct-network
    environment:
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/simstruct
      - AI_SERVICE_URL=http://ai-service:8000
  
  # PostgreSQL
  postgres:
    image: postgres:15
    container_name: simstruct-postgres
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=simstruct
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=admin123
    networks:
      - simstruct-network
    volumes:
      - postgres-data:/var/lib/postgresql/data

networks:
  simstruct-network:
    driver: bridge

volumes:
  postgres-data:
```

---

## 📝 Créer le Dockerfile pour l'API AI

Créez `Model_AI/Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copier les requirements
COPY requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code source
COPY src/ ./src/
COPY models/ ./models/

# Exposer le port
EXPOSE 8000

# Démarrer l'API
CMD ["uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 🧪 Tester l'intégration

### 1. Tester localement (sans Docker)

**Terminal 1 - Démarrer l'API Python:**
```bash
cd Model_AI/src
start_api.bat
```

**Terminal 2 - Démarrer Spring Boot:**
```bash
cd Backend/simstruct-backend
mvnw spring-boot:run
```

**Terminal 3 - Tester:**
```bash
curl -X POST http://localhost:8080/api/predictions \
  -H "Content-Type: application/json" \
  -d '{
    "numFloors": 10,
    "floorHeight": 3.5,
    "numBeams": 120,
    "numColumns": 36,
    "beamSection": 30,
    "columnSection": 40,
    "concreteStrength": 35,
    "steelGrade": 355,
    "windLoad": 1.5,
    "liveLoad": 3.0,
    "deadLoad": 5.0
  }'
```

### 2. Tester avec Docker

```bash
# Construire et démarrer tous les services
docker-compose up --build

# Dans un autre terminal, tester
curl -X POST http://localhost:8080/api/predictions \
  -H "Content-Type: application/json" \
  -d '{"numFloors": 10, ...}'
```

---

## 🔍 Gestion des erreurs

### Côté Spring Boot

```java
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(WebClientException.class)
    public ResponseEntity<String> handleWebClientException(WebClientException ex) {
        log.error("Error calling AI service: {}", ex.getMessage());
        return ResponseEntity.status(503)
            .body("AI service is temporarily unavailable");
    }
}
```

### Fallback en cas d'erreur

```java
public Mono<PredictionResponse> getPredictionWithFallback(
        BuildingPredictionRequest request) {
    return getPrediction(request)
        .onErrorResume(error -> {
            log.warn("AI service unavailable, using fallback");
            return Mono.just(createFallbackResponse());
        });
}

private PredictionResponse createFallbackResponse() {
    return new PredictionResponse(
        0.0, 0.0, 0.0, 0.0, 
        "Service temporarily unavailable"
    );
}
```

---

## 📊 Exemple de flux complet

```
1. Frontend Angular envoie une requête:
   POST http://localhost:4200/api/simulations
   
2. Spring Boot reçoit la requête:
   POST http://localhost:8080/api/simulations
   
3. Spring Boot sauvegarde en base de données
   
4. Spring Boot appelle l'API Python:
   POST http://localhost:8000/predict
   
5. API Python retourne la prédiction
   
6. Spring Boot met à jour la simulation avec les résultats
   
7. Spring Boot retourne la réponse au Frontend
```

---

## ✅ Checklist d'intégration

- [ ] API Python fonctionne (`http://localhost:8000/docs`)
- [ ] Backend Spring Boot fonctionne (`http://localhost:8080`)
- [ ] WebClient configuré dans Spring Boot
- [ ] DTOs créés (BuildingPredictionRequest, PredictionResponse)
- [ ] Service AIPredictionService créé
- [ ] Contrôleur PredictionController créé
- [ ] application.properties configuré
- [ ] Dockerfile créé pour l'API Python
- [ ] docker-compose.yml mis à jour
- [ ] Tests d'intégration réussis

---

## 🎯 Points importants

1. **Timeout**: Configurez un timeout approprié (30s recommandé)
2. **Retry**: Ajoutez une logique de retry en cas d'échec temporaire
3. **Circuit Breaker**: Utilisez Resilience4j pour gérer les pannes
4. **Monitoring**: Ajoutez des logs et métriques
5. **Cache**: Considérez un cache pour les prédictions fréquentes

---

*Guide d'intégration - SimStruct AI Project - 14 Décembre 2025*
