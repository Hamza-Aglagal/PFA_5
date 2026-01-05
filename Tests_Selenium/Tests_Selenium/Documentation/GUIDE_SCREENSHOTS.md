# 📸 Guide des Screenshots pour Tests Selenium

## 🎯 Objectif

Capturer automatiquement des screenshots pendant l'exécution des tests Selenium pour :
- 📊 **Documenter** visuellement les tests
- 🐛 **Déboguer** plus facilement les échecs
- 🎓 **Présenter** au jury avec des preuves visuelles

## 🛠️ Utilisation

### 1. Classe ScreenshotUtil

La classe `ScreenshotUtil.java` fournit 3 méthodes :

```java
// Capture un screenshot basique
captureScreenshot(driver, "nom_du_screenshot");

// Capture en cas de succès (préfixe SUCCESS_)
captureSuccessScreenshot(driver, "nom_du_test");

// Capture en cas d'échec (préfixe FAILURE_)
captureFailureScreenshot(driver, "nom_du_test", "message_erreur");
```

### 2. Dans vos Tests

```java
import static com.simstruct.tests.frontend.ScreenshotUtil.*;

@Test
public void testLogin() {
    driver.get("http://localhost:4200/login");
    
    // 📸 Capture: Page de login
    captureScreenshot(driver, "page_login");
    
    // Remplir le formulaire
    driver.findElement(By.id("email")).sendKeys("test@test.com");
    
    // 📸 Capture: Formulaire rempli
    captureScreenshot(driver, "formulaire_rempli");
    
    // Soumettre
    driver.findElement(By.id("loginBtn")).click();
    
    // 📸 Capture: Résultat
    captureSuccessScreenshot(driver, "login_success");
}
```

### 3. Captures Automatiques en Cas d'Échec

Ajoutez dans `@AfterEach` :

```java
@AfterEach
public void teardown(TestInfo testInfo) {
    if (testInfo.getTestMethod().isPresent()) {
        String testName = testInfo.getTestMethod().get().getName();
        
        // Capturer en cas d'échec
        if (/* test a échoué */) {
            captureFailureScreenshot(driver, testName, "Test failed");
        }
    }
    
    if (driver != null) {
        driver.quit();
    }
}
```

## 📁 Organisation des Screenshots

Les screenshots sont sauvegardés dans :
```
Frontend_Angular/target/screenshots/
├── 01_page_login_20251225_185030.png
├── 02_formulaire_rempli_20251225_185031.png
├── 02_dashboard_apres_login_20251225_185032.png
├── SUCCESS_02_login_success_20251225_185033.png
└── FAILURE_03_login_invalide_20251225_185034.png
```

**Format du nom** : `nom_screenshot_YYYYMMDD_HHMMSS.png`

## 🎨 Bonnes Pratiques

### ✅ À Faire

1. **Capturer aux moments clés** :
   - Avant une action importante
   - Après une action importante
   - En cas d'erreur

2. **Nommer clairement** :
   ```java
   captureScreenshot(driver, "01_page_login");
   captureScreenshot(driver, "02_formulaire_rempli");
   captureScreenshot(driver, "03_dashboard");
   ```

3. **Préfixer par numéro** pour l'ordre chronologique

### ❌ À Éviter

1. Trop de screenshots (ralentit les tests)
2. Noms génériques ("screenshot1", "test")
3. Oublier de créer le dossier de destination

## 📊 Exemples par Type de Test

### Test d'Authentification

```java
@Test
public void testLoginFlow() {
    // 1. Page de login
    driver.get(BASE_URL + "/login");
    captureScreenshot(driver, "auth_01_page_login");
    
    // 2. Formulaire rempli
    fillLoginForm("user@test.com", "password");
    captureScreenshot(driver, "auth_02_formulaire_rempli");
    
    // 3. Après soumission
    submitForm();
    captureScreenshot(driver, "auth_03_apres_soumission");
    
    // 4. Dashboard
    wait.until(ExpectedConditions.urlContains("/dashboard"));
    captureSuccessScreenshot(driver, "auth_04_dashboard");
}
```

### Test de Simulation

```java
@Test
public void testCreateSimulation() {
    // 1. Page de simulation
    driver.get(BASE_URL + "/simulation");
    captureScreenshot(driver, "sim_01_page_simulation");
    
    // 2. Formulaire rempli
    fillSimulationForm();
    captureScreenshot(driver, "sim_02_formulaire_rempli");
    
    // 3. Modal de chargement
    submitSimulation();
    captureScreenshot(driver, "sim_03_modal_chargement");
    
    // 4. Résultats
    wait.until(ExpectedConditions.urlContains("/results"));
    captureSuccessScreenshot(driver, "sim_04_resultats");
}
```

## 🎓 Pour la Présentation au Jury

### Montrer les Screenshots

1. **Ouvrir le dossier** `target/screenshots/`
2. **Trier par nom** pour voir l'ordre chronologique
3. **Montrer le flux complet** d'un test

### Exemple de Narration

> "Voici les screenshots automatiques capturés pendant l'exécution des tests :
> 
> 1. **Page de login** - L'utilisateur arrive sur la page
> 2. **Formulaire rempli** - Les credentials sont saisis
> 3. **Dashboard** - Connexion réussie, redirection
> 4. **Nouvelle simulation** - Navigation vers le formulaire
> 5. **Résultats** - Affichage des prédictions du modèle AI
> 
> Tous ces screenshots sont générés automatiquement à chaque exécution des tests."

## 🔧 Configuration Avancée

### Qualité des Screenshots

Modifier dans `ScreenshotUtil.java` :

```java
// Pour des screenshots en JPEG (plus légers)
File sourceFile = screenshot.getScreenshotAs(OutputType.FILE);

// Pour base64 (intégration dans rapports HTML)
String base64 = screenshot.getScreenshotAs(OutputType.BASE64);
```

### Résolution

```java
ChromeOptions options = new ChromeOptions();
options.addArguments("--window-size=1920,1080");
driver = new ChromeDriver(options);
```

## ✅ Checklist

- [x] ScreenshotUtil.java créé
- [x] Dépendance Commons IO ajoutée au pom.xml
- [x] Import dans les tests
- [x] Captures aux moments clés
- [x] Nommage cohérent
- [x] Dossier target/screenshots/ créé automatiquement

## 📈 Résultat

Après exécution des tests, vous aurez :
- ✅ Screenshots de **chaque étape** importante
- ✅ **Preuve visuelle** du bon fonctionnement
- ✅ **Documentation automatique** pour le jury
- ✅ **Aide au débogage** en cas d'échec

**Parfait pour impressionner le jury avec des preuves visuelles ! 📸🎓**
