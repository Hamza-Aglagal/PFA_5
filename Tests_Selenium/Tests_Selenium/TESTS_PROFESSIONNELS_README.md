# 🎓 Tests Selenium Professionnels - SimStruct

## 📋 Vue d'Ensemble

Suite de tests Selenium **professionnels** et **détaillés** utilisant les meilleures pratiques de l'industrie.

## 🏗️ Architecture des Tests

### Pattern Utilisés

1. **Page Object Model (POM)**
   - Séparation entre la logique de test et les éléments de la page
   - Réutilisabilité et maintenabilité maximales
   - Encapsulation des interactions avec l'UI

2. **Factory Pattern**
   - Création centralisée des WebDrivers
   - Support multi-navigateurs (Chrome, Firefox, Edge, Headless)

3. **Template Method Pattern**
   - Classe de base `BaseTest` pour le cycle de vie commun
   - Hooks `@BeforeEach`, `@AfterEach`, `@BeforeAll`, `@AfterAll`

4. **Builder Pattern** (implicite)
   - Method chaining dans les Page Objects
   - Exemple: `loginPage.enterEmail().enterPassword().clickLogin()`

## 📁 Structure du Projet

```
src/test/java/com/simstruct/tests/
├── config/
│   ├── WebDriverConfig.java      # Configuration des drivers (Factory)
│   └── TestConfig.java            # Configuration centralisée (URLs, credentials, etc.)
│
├── pages/                         # Page Objects (POM)
│   ├── BasePage.java              # Classe de base pour tous les PO
│   ├── LoginPage.java             # Page de login
│   ├── DashboardPage.java         # Page dashboard
│   ├── SimulationPage.java        # Page de simulation
│   ├── ResultsPage.java           # Page de résultats
│   ├── HistoryPage.java           # Page historique
│   ├── ProfilePage.java           # Page profil
│   ├── RegisterPage.java          # Page inscription
│   └── ForgotPasswordPage.java    # Page mot de passe oublié
│
├── base/
│   └── BaseTest.java              # Classe de base pour tous les tests
│
├── professional/                  # Tests professionnels
│   ├── AuthenticationProfessionalTest.java
│   └── SimulationFlowProfessionalTest.java
│
└── frontend/
    └── ScreenshotUtil.java        # Utilitaire screenshots
```

## 🎯 Tests Implémentés

### 1. AuthenticationProfessionalTest (7 tests)

| # | Test | Type | Tags |
|---|------|------|------|
| 1 | Page de login s'affiche | Smoke | `@smoke`, `@authentication` |
| 2 | Login avec credentials valides | Critical | `@critical`, `@authentication` |
| 3 | Login avec email invalide | Negative | `@negative`, `@authentication` |
| 4 | Login avec mot de passe invalide | Negative | `@negative`, `@authentication` |
| 5 | Validation formulaire vide | Validation | `@validation`, `@authentication` |
| 6 | Flux Login → Logout complet | Smoke | `@smoke`, `@authentication` |
| 7 | Navigation vers inscription | Navigation | `@navigation`, `@authentication` |

### 2. SimulationFlowProfessionalTest (6 tests)

| # | Test | Type | Tags |
|---|------|------|------|
| 1 | Navigation vers nouvelle simulation | Smoke | `@smoke`, `@simulation` |
| 2 | Flux E2E complet de simulation | Critical | `@critical`, `@simulation`, `@e2e` |
| 3 | Simulation avec données personnalisées | Functional | `@simulation`, `@custom-data` |
| 4 | Retour au dashboard depuis résultats | Navigation | `@navigation`, `@simulation` |
| 5 | Scénario: Petit immeuble (5 étages) | Scenario | `@scenario`, `@simulation` |
| 6 | Scénario: Grand immeuble (20 étages) | Scenario | `@scenario`, `@simulation` |

**Total: 13 tests professionnels**

## 🔧 Configuration

### TestConfig.java - Constantes Centralisées

```java
// URLs
BASE_URL = "http://localhost:4200"
API_URL = "http://localhost:8080/api/v1"
AI_API_URL = "http://localhost:8000"

// Credentials
TEST_EMAIL = "test@simstruct.com"
TEST_PASSWORD = "password123"

// Timeouts
DEFAULT_TIMEOUT = 10 secondes
LONG_TIMEOUT = 30 secondes

// Données de simulation par défaut
SimulationData.DEFAULT_NUM_FLOORS = 10
SimulationData.DEFAULT_FLOOR_HEIGHT = 3.5
// ... etc
```

### WebDriverConfig.java - Support Multi-Navigateurs

```java
// Créer un driver Chrome
WebDriver driver = WebDriverConfig.createDriver(BrowserType.CHROME);

// Créer un driver headless (CI/CD)
WebDriver driver = WebDriverConfig.createDriver(BrowserType.CHROME_HEADLESS);

// Créer un driver Firefox
WebDriver driver = WebDriverConfig.createDriver(BrowserType.FIREFOX);
```

## 🎨 Bonnes Pratiques Implémentées

### 1. **Given-When-Then** (BDD Style)

```java
@Test
public void testLogin() {
    // GIVEN: L'utilisateur est sur la page de login
    loginPage.open();
    
    // WHEN: L'utilisateur se connecte
    DashboardPage dashboard = loginPage.login(email, password);
    
    // THEN: L'utilisateur est redirigé vers le dashboard
    assertThat(dashboard.isOnDashboard()).isTrue();
}
```

### 2. **Method Chaining** (Fluent API)

```java
loginPage
    .enterEmail("test@test.com")
    .enterPassword("password")
    .clickLogin();
```

### 3. **Assertions Descriptives** (AssertJ)

```java
assertThat(loginPage.isOnLoginPage())
    .as("L'utilisateur devrait être sur la page de login")
    .isTrue();
```

### 4. **Tags pour Filtrage**

```java
@Tag("smoke")      // Tests de fumée
@Tag("critical")   // Tests critiques
@Tag("negative")   // Tests négatifs
@Tag("e2e")        // Tests end-to-end
```

### 5. **Screenshots Automatiques**

```java
captureScreenshot("01_page_login");
captureSuccessScreenshot("test_name");
captureFailureScreenshot("test_name", "error");
```

### 6. **Waits Explicites**

```java
// Dans BasePage.java
protected WebElement waitForElement(By by) {
    return wait.until(ExpectedConditions.visibilityOfElementLocated(by));
}
```

### 7. **Logging Console**

```java
System.out.println("\n📊 Résultats de la Simulation:");
System.out.println("   Déflexion maximale: " + maxDeflection);
System.out.println("   Statut: " + status);
```

## 🚀 Exécution

### Tous les tests

```bash
mvn test
```

### Tests par tag

```bash
# Tests smoke uniquement
mvn test -Dgroups="smoke"

# Tests critiques
mvn test -Dgroups="critical"

# Tests d'authentification
mvn test -Dgroups="authentication"

# Tests de simulation
mvn test -Dgroups="simulation"
```

### Tests par classe

```bash
# Tests d'authentification
mvn test -Dtest=AuthenticationProfessionalTest

# Tests de simulation
mvn test -Dtest=SimulationFlowProfessionalTest
```

### Avec navigateur spécifique

```bash
# Chrome (défaut)
mvn test

# Firefox
mvn test -Dbrowser=firefox

# Headless (CI/CD)
mvn test -Dbrowser=headless
```

## 📊 Rapports

### Console Output

```
========================================
  Démarrage des tests: AuthenticationProfessionalTest
========================================

▶️  Exécution: ✅ Test 1: Vérifier que la page de login s'affiche correctement
📸 Screenshot capturé: target/screenshots/01_login_page_loaded_20251225_190000.png
📸 Screenshot capturé: target/screenshots/SUCCESS_01_login_page_verified_20251225_190001.png
✅  Terminé: testLoginPageDisplays

▶️  Exécution: ✅ Test 2: Login avec credentials valides - Flux complet
📸 Screenshot capturé: target/screenshots/02_before_login_20251225_190002.png
...
✅  Terminé: testSuccessfulLogin

========================================
  Fin des tests: AuthenticationProfessionalTest
========================================
```

### Screenshots

Tous les screenshots sont dans `target/screenshots/` :
- Format: `nom_screenshot_YYYYMMDD_HHMMSS.png`
- Préfixes: `SUCCESS_` pour succès, `FAILURE_` pour échecs

### Rapport HTML

```bash
mvn surefire-report:report
explorer target/site/surefire-report.html
```

## 🎓 Pour la Présentation au Jury

### Points Forts à Mentionner

1. **Architecture Professionnelle**
   - Pattern Page Object Model
   - Séparation des responsabilités
   - Code maintenable et réutilisable

2. **Couverture Complète**
   - 13 tests professionnels
   - Tests positifs et négatifs
   - Scénarios réalistes

3. **Bonnes Pratiques**
   - Given-When-Then (BDD)
   - Assertions descriptives
   - Screenshots automatiques
   - Tags pour organisation

4. **Multi-Navigateurs**
   - Support Chrome, Firefox, Edge
   - Mode headless pour CI/CD

5. **Configuration Centralisée**
   - Facile à maintenir
   - Pas de duplication
   - Paramétrable

### Démonstration

```java
// Exemple de test professionnel
@Test
@DisplayName("✅ Test 2: Login avec credentials valides - Flux complet")
@Tag("critical")
public void testSuccessfulLogin() {
    // GIVEN: L'utilisateur est sur la page de login
    loginPage.open();
    
    // WHEN: L'utilisateur se connecte
    DashboardPage dashboard = loginPage
        .enterEmail(TestConfig.TEST_EMAIL)
        .enterPassword(TestConfig.TEST_PASSWORD)
        .clickLogin();
    
    // THEN: L'utilisateur est sur le dashboard
    assertThat(dashboard.isOnDashboard())
        .as("L'utilisateur devrait être sur le dashboard")
        .isTrue();
}
```

## ✅ Checklist Qualité

- [x] Pattern Page Object Model implémenté
- [x] Configuration centralisée
- [x] Support multi-navigateurs
- [x] Screenshots automatiques
- [x] Assertions descriptives
- [x] Tags pour organisation
- [x] Logging console
- [x] Given-When-Then structure
- [x] Method chaining
- [x] Waits explicites
- [x] Gestion des erreurs
- [x] Documentation complète
- [x] Tests positifs et négatifs
- [x] Scénarios réalistes

## 🎉 Conclusion

Cette suite de tests représente un **niveau professionnel** de tests Selenium avec :
- ✅ Architecture solide et maintenable
- ✅ Bonnes pratiques de l'industrie
- ✅ Couverture complète des fonctionnalités
- ✅ Documentation exhaustive

**Parfait pour impressionner le jury ! 🎓✨**
