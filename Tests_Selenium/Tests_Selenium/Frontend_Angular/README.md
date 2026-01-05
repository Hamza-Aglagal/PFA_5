# 🌐 Tests Selenium - Frontend Angular

Tests end-to-end pour l'application web Angular.

## 📦 Prérequis

```xml
<!-- pom.xml -->
<dependencies>
    <!-- Selenium WebDriver -->
    <dependency>
        <groupId>org.seleniumhq.selenium</groupId>
        <artifactId>selenium-java</artifactId>
        <version>4.16.1</version>
        <scope>test</scope>
    </dependency>
    
    <!-- JUnit 5 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.1</version>
        <scope>test</scope>
    </dependency>
    
    <!-- WebDriverManager -->
    <dependency>
        <groupId>io.github.bonigarcia</groupId>
        <artifactId>webdrivermanager</artifactId>
        <version>5.6.3</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## 🚀 Exécution

```bash
# Démarrer l'application Angular
cd ../../Web/simstruct
npm start

# Dans un autre terminal, exécuter les tests
cd ../../Tests_Selenium/Frontend_Angular
mvn test
```

## 📊 Tests Implémentés

- ✅ Test de connexion
- ✅ Test d'inscription
- ✅ Test de création de simulation
- ✅ Test de visualisation des résultats
- ✅ Test de l'historique
- ✅ Test de déconnexion
