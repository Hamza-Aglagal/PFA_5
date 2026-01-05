# 🔧 Tests Selenium - Backend Spring Boot

Tests d'intégration pour l'API REST Spring Boot.

## 📦 Prérequis

```xml
<!-- pom.xml -->
<dependencies>
    <!-- RestAssured pour tests API -->
    <dependency>
        <groupId>io.rest-assured</groupId>
        <artifactId>rest-assured</artifactId>
        <version>5.4.0</version>
        <scope>test</scope>
    </dependency>
    
    <!-- Spring Boot Test -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## 🚀 Exécution

```bash
# Démarrer le backend
cd ../../Backend/simstruct-backend
./mvnw spring-boot:run

# Dans un autre terminal, exécuter les tests
cd ../../Tests_Selenium/Backend_SpringBoot
mvn test
```

## 📊 Tests Implémentés

- ✅ Test des endpoints d'authentification
- ✅ Test CRUD des simulations
- ✅ Test d'intégration avec l'API AI
- ✅ Test de sécurité JWT
- ✅ Test de validation des données
