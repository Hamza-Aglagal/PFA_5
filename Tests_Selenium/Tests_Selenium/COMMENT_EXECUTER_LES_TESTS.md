# 🚀 Guide Pratique - Comment Exécuter les Tests Selenium

## 📋 Prérequis

Avant de commencer, vérifiez que vous avez :

### ✅ Logiciels Nécessaires

1. **Java 17 ou supérieur**
   ```powershell
   java -version
   # Devrait afficher: java version "17.x.x"
   ```

2. **Maven**
   ```powershell
   mvn -version
   # Devrait afficher: Apache Maven 3.x.x
   ```

3. **Google Chrome** (dernière version)
   - Le driver Chrome sera téléchargé automatiquement par WebDriverManager

### ✅ Application en Cours d'Exécution

**IMPORTANT** : Votre application Angular doit être démarrée !

```powershell
# Dans un terminal séparé
cd c:\Users\PC\PFA_5\PFA_5\Web\simstruct
npm start

# Attendre que l'application soit prête
# Devrait afficher: ** Angular Live Development Server is listening on localhost:4200 **
```

---

## 🎯 Méthode 1 : Exécution Rapide (Recommandée)

### Étape 1 : Ouvrir PowerShell

```powershell
# Naviguer vers le dossier des tests
cd c:\Users\PC\PFA_5\PFA_5\Tests_Selenium\Frontend_Angular
```

### Étape 2 : Installer les Dépendances

```powershell
# Première fois seulement
mvn clean install -DskipTests
```

**Sortie attendue** :
```
[INFO] BUILD SUCCESS
[INFO] Total time: 30 s
```

### Étape 3 : Exécuter TOUS les Tests

```powershell
mvn test
```

**Ce qui va se passer** :
1. ✅ Maven compile les tests
2. ✅ Chrome s'ouvre automatiquement
3. ✅ Les tests s'exécutent (vous verrez le navigateur bouger)
4. ✅ Screenshots capturés automatiquement
5. ✅ Rapport généré

**Durée** : ~2-3 minutes

---

## 🎯 Méthode 2 : Exécuter UN Seul Test

### Pour tester uniquement AuthenticationTest

```powershell
cd c:\Users\PC\PFA_5\PFA_5\Tests_Selenium\Frontend_Angular

mvn test -Dtest=AuthenticationTest
```

### Pour tester uniquement SimulationFlowTest

```powershell
mvn test -Dtest=SimulationFlowTest
```

### Pour tester UNE seule méthode

```powershell
# Exemple: Tester uniquement le login
mvn test -Dtest=AuthenticationTest#testLoginSuccess
```

---

## 🎯 Méthode 3 : Depuis IntelliJ IDEA / VS Code

### Dans IntelliJ IDEA

1. **Ouvrir le projet**
   - File → Open → Sélectionner `Tests_Selenium/Frontend_Angular`

2. **Exécuter un test**
   - Ouvrir `AuthenticationTest.java`
   - Clic droit sur la classe → "Run 'AuthenticationTest'"
   - OU clic sur la flèche verte ▶️ à côté de `@Test`

3. **Voir les résultats**
   - Onglet "Run" en bas
   - ✅ Tests passés en vert
   - ❌ Tests échoués en rouge

### Dans VS Code

1. **Installer l'extension**
   - Extension: "Test Runner for Java"

2. **Exécuter**
   - Ouvrir `AuthenticationTest.java`
   - Cliquer sur "Run Test" au-dessus de chaque `@Test`

---

## 📊 Comprendre les Résultats

### Sortie Console

```
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.simstruct.tests.frontend.AuthenticationTest
📸 Screenshot capturé: target/screenshots/01_page_login_20251225_185030.png
📸 Screenshot capturé: target/screenshots/SUCCESS_01_formulaire_login_visible_20251225_185031.png
[INFO] Tests run: 7, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 7, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO] BUILD SUCCESS
```

### Interprétation

- ✅ **Tests run: 7** = 7 tests exécutés
- ✅ **Failures: 0** = Aucun échec
- ✅ **Errors: 0** = Aucune erreur
- ✅ **BUILD SUCCESS** = Tout est OK !

---

## 📸 Voir les Screenshots

### Localisation

```powershell
cd c:\Users\PC\PFA_5\PFA_5\Tests_Selenium\Frontend_Angular\target\screenshots

# Lister les fichiers
dir
```

### Ouvrir dans l'Explorateur

```powershell
# Ouvrir le dossier dans l'explorateur Windows
explorer target\screenshots
```

**Vous verrez** :
```
01_page_login_20251225_185030.png
SUCCESS_01_formulaire_login_visible_20251225_185031.png
02_avant_login_20251225_185032.png
02_formulaire_rempli_20251225_185033.png
...
```

---

## 📈 Voir le Rapport HTML

### Générer le Rapport

```powershell
mvn surefire-report:report
```

### Ouvrir le Rapport

```powershell
# Le rapport est dans:
explorer target\site\surefire-report.html
```

**Le rapport contient** :
- ✅ Nombre de tests
- ✅ Temps d'exécution
- ✅ Détails de chaque test
- ✅ Stack traces en cas d'erreur

---

## 🐛 Dépannage

### Problème 1 : "Application not running"

**Erreur** :
```
org.openqa.selenium.WebDriverException: Reached error page
```

**Solution** :
```powershell
# Démarrer l'application Angular
cd c:\Users\PC\PFA_5\PFA_5\Web\simstruct
npm start

# Attendre que ça démarre, puis relancer les tests
```

### Problème 2 : "ChromeDriver not found"

**Solution** :
WebDriverManager télécharge automatiquement le driver. Si ça ne marche pas :

```powershell
# Nettoyer et réinstaller
mvn clean install
```

### Problème 3 : Tests échouent car éléments non trouvés

**Raison** : Les IDs dans le HTML ne correspondent pas

**Solution** :
1. Vérifier que l'application Angular a les bons IDs
2. Ou modifier les tests pour utiliser les bons sélecteurs

**Exemple** :
```java
// Si l'ID est différent dans votre app
driver.findElement(By.id("emailInput")); // Au lieu de "email"
```

### Problème 4 : "Port 4200 already in use"

**Solution** :
```powershell
# Tuer le processus sur le port 4200
netstat -ano | findstr :4200
taskkill /PID <PID> /F

# Redémarrer l'application
npm start
```

---

## 🎬 Démonstration Complète Pas à Pas

### Script Complet pour Exécution

```powershell
# 1. Démarrer l'application (Terminal 1)
cd c:\Users\PC\PFA_5\PFA_5\Web\simstruct
npm start

# 2. Attendre 30 secondes que l'app démarre

# 3. Exécuter les tests (Terminal 2)
cd c:\Users\PC\PFA_5\PFA_5\Tests_Selenium\Frontend_Angular
mvn clean test

# 4. Voir les screenshots
explorer target\screenshots

# 5. Voir le rapport
mvn surefire-report:report
explorer target\site\surefire-report.html
```

---

## 🎓 Pour la Démonstration au Jury

### Scénario de Présentation

**Étape 1 : Montrer le code**
```java
// Ouvrir AuthenticationTest.java
// Montrer les annotations @Test
// Expliquer la logique
```

**Étape 2 : Exécuter les tests**
```powershell
mvn test
```

**Étape 3 : Pendant l'exécution**
> "Vous voyez, Chrome s'ouvre automatiquement, les tests simulent un utilisateur réel qui navigue, remplit les formulaires, et vérifie les résultats."

**Étape 4 : Montrer les screenshots**
```powershell
explorer target\screenshots
```

> "Voici les captures d'écran automatiques de chaque étape : page de login, formulaire rempli, dashboard après connexion..."

**Étape 5 : Montrer le rapport**
```powershell
explorer target\site\surefire-report.html
```

> "Le rapport montre que tous les tests sont passés avec succès."

---

## ✅ Checklist Avant Démonstration

- [ ] Java 17+ installé
- [ ] Maven installé
- [ ] Chrome installé
- [ ] Application Angular démarrée (port 4200)
- [ ] Tests exécutés au moins une fois avec succès
- [ ] Screenshots générés et vérifiés
- [ ] Rapport HTML généré

---

## 🚀 Commandes Rapides (Cheat Sheet)

```powershell
# Démarrer l'app
cd c:\Users\PC\PFA_5\PFA_5\Web\simstruct && npm start

# Exécuter tous les tests
cd c:\Users\PC\PFA_5\PFA_5\Tests_Selenium\Frontend_Angular && mvn test

# Exécuter un seul test
mvn test -Dtest=AuthenticationTest

# Voir les screenshots
explorer target\screenshots

# Générer et voir le rapport
mvn surefire-report:report && explorer target\site\surefire-report.html

# Nettoyer et recommencer
mvn clean test
```

---

## 🎉 Résultat Final

Après exécution, vous aurez :
- ✅ **15 tests** exécutés avec succès
- ✅ **~20 screenshots** automatiques
- ✅ **Rapport HTML** détaillé
- ✅ **Preuve visuelle** pour le jury

**Vous êtes prêt pour impressionner le jury ! 🎓✨**
