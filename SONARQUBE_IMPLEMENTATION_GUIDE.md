# 📊 Guide Complet d'Implémentation SonarQube - Projet SimStruct

**Date**: 16 Décembre 2025  
**Projet**: SimStruct - Plateforme d'Analyse Structurelle  
**Technologies**: Spring Boot, Angular, Flutter, Python  

---

## 📋 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Installation et Configuration SonarQube](#installation-et-configuration-sonarqube)
3. [Configuration des Projets](#configuration-des-projets)
4. [Quality Profiles et Quality Gates](#quality-profiles-et-quality-gates)
5. [Analyse par Composant](#analyse-par-composant)
6. [Correction des Issues](#correction-des-issues)
7. [Génération des Rapports](#génération-des-rapports)
8. [Template Rapport Académique](#template-rapport-académique)

---

## 🎯 Vue d'Ensemble

### Rôle de SonarQube dans le Projet

SonarQube assure la **qualité continue du code** en:
- 🐛 Détectant les bugs et vulnérabilités
- 🔒 Identifiant les failles de sécurité
- 📊 Mesurant la dette technique
- ✅ Vérifiant les standards de code
- 📈 Générant des métriques de qualité

### Architecture du Projet à Analyser

```
SimStruct/
├── Backend (Spring Boot/Java)     → Analyse Maven + SonarScanner
├── Web (Angular/TypeScript)       → Analyse SonarScanner
├── Mobile (Flutter/Dart)          → Analyse SonarScanner
└── AI Model (Python)              → Analyse SonarScanner
```

### Métriques Cibles

| Métrique | Objectif | Justification |
|----------|----------|---------------|
| Coverage | ≥ 60% | Standard académique/professionnel |
| Duplication | ≤ 3% | Code maintenable |
| Bugs | 0 Critical/Blocker | Fiabilité |
| Vulnerabilities | 0 Critical/Blocker | Sécurité |
| Code Smells | ≤ 50 par projet | Maintenabilité |

---

## 🚀 Installation et Configuration SonarQube

### ÉTAPE 1: Démarrage du Serveur SonarQube

#### 1.1 Lancer SonarQube

```powershell
# Naviguer vers le dossier SonarQube
cd C:\Users\Hamza\Downloads\sonarqube-25.11.0.114957\bin\windows-x86-64

# Démarrer le serveur
.\StartSonar.bat
```

#### 1.2 Vérifier le Démarrage

```powershell
# Attendre 2-3 minutes, puis vérifier les logs
Get-Content C:\Users\Hamza\Downloads\sonarqube-25.11.0.114957\logs\sonar.log -Tail 50
```

**Indicateur de succès**: Message "SonarQube is operational"

#### 1.3 Accéder à l'Interface Web

1. Ouvrir le navigateur: **http://localhost:9000**
2. Connexion initiale:
   - **Username**: `admin`
   - **Password**: `admin`
3. **IMPORTANT**: Changer le mot de passe (ex: `SimStruct2025!`)

### ÉTAPE 2: Configuration Initiale

#### 2.1 Configuration du Serveur

1. **Administration** → **Configuration** → **General Settings**
2. Paramètres recommandés:
   - **Server base URL**: `http://localhost:9000`
   - **Default language**: `en` ou `fr`
   - **Encoding**: `UTF-8`

#### 2.2 Installation des Plugins (si nécessaire)

**Administration** → **Marketplace**

Plugins recommandés à vérifier:
- ✅ **Java** (préinstallé)
- ✅ **TypeScript** (préinstallé)
- ✅ **Python** (préinstallé)
- ⚠️ **Dart/Flutter** (Community plugin - optionnel)

---

## 🔧 Configuration des Projets

### ÉTAPE 3: Création des Projets dans SonarQube

#### 3.1 Créer les 4 Projets

Pour chaque projet, suivre:

1. **Cliquer** sur **"Create Project"** → **"Manually"**
2. **Remplir les informations**:

##### 🎯 Projet 1: Backend (Spring Boot)

**Étape 1: Créer le projet**
- Cliquer sur **"Create Project"** → **"Manually"**
- **Project key**: `simstruct-backend`
- **Display name**: `SimStruct Backend (Spring Boot)`
- **Main branch**: `main`
- Cliquer sur **"Next"**

**Étape 2: Sélectionner la méthode d'analyse**
- Sélectionner **"Locally"** (Analyze your project)
- Cliquer sur **"Next"**

**Étape 3: Fournir un token**
- **Token name**: `simstruct-backend-token`
- Cliquer sur **"Generate"**
- **⚠️ COPIER LE TOKEN** (ex: `sqp_2123718fa820f7467110ec2f014973c9c006a7bc`)
- Cliquer sur **"Continue"**

**Étape 4: Choisir l'outil de build**
- Sélectionner **"Maven"** ✅
- Suivre les instructions affichées (vous les utiliserez à l'ÉTAPE 6)

**💾 Sauvegarder le token**:
```powershell
echo "BACKEND_TOKEN=sqp_2123718fa820f7467110ec2f014973c9c006a7bc" > "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens"
```

---

##### 🎯 Projet 2: Frontend Web (Angular)

**Étape 1: Créer le projet**
- Cliquer sur **"Create Project"** → **"Manually"**
- **Project key**: `simstruct-web`
- **Display name**: `SimStruct Web (Angular)`
- **Main branch**: `main`
- Cliquer sur **"Next"**

**Étape 2: Sélectionner la méthode d'analyse**
- Sélectionner **"Locally"**
- Cliquer sur **"Next"**

**Étape 3: Fournir un token**
- **Token name**: `simstruct-web-token`
- Cliquer sur **"Generate"**
- **⚠️ COPIER LE TOKEN**
- Cliquer sur **"Continue"**

**Étape 4: Choisir l'outil de build**
- Sélectionner **"Other (for JS, TS, Go, Python, PHP, ...)"** ✅
- Suivre les instructions (vous utiliserez sonar-scanner à l'ÉTAPE 7)

**💾 Sauvegarder le token**:
```powershell
echo "WEB_TOKEN=sqp_votre_token_copié" >> "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens"
```

---

##### 🎯 Projet 3: Mobile (Flutter)

**Étape 1: Créer le projet**
- Cliquer sur **"Create Project"** → **"Manually"**
- **Project key**: `simstruct-mobile`
- **Display name**: `SimStruct Mobile (Flutter)`
- **Main branch**: `main`
- Cliquer sur **"Next"**

**Étape 2: Sélectionner la méthode d'analyse**
- Sélectionner **"Locally"**
- Cliquer sur **"Next"**

**Étape 3: Fournir un token**
- **Token name**: `simstruct-mobile-token`
- Cliquer sur **"Generate"**
- **⚠️ COPIER LE TOKEN**
- Cliquer sur **"Continue"**

**Étape 4: Choisir l'outil de build**
- Sélectionner **"Other (for JS, TS, Go, Python, PHP, ...)"** ✅
- Suivre les instructions (vous utiliserez sonar-scanner à l'ÉTAPE 8)

**💾 Sauvegarder le token**:
```powershell
echo "MOBILE_TOKEN=sqp_votre_token_copié" >> "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens"
```

---

##### 🎯 Projet 4: AI Model (Python)

**Étape 1: Créer le projet**
- Cliquer sur **"Create Project"** → **"Manually"**
- **Project key**: `simstruct-ai`
- **Display name**: `SimStruct AI Model (Python)`
- **Main branch**: `main`
- Cliquer sur **"Next"**

**Étape 2: Sélectionner la méthode d'analyse**
- Sélectionner **"Locally"**
- Cliquer sur **"Next"**

**Étape 3: Fournir un token**
- **Token name**: `simstruct-ai-token`
- Cliquer on **"Generate"**
- **⚠️ COPIER LE TOKEN**
- Cliquer sur **"Continue"**

**Étape 4: Choisir l'outil de build**
- Sélectionner **"Other (for JS, TS, Go, Python, PHP, ...)"** ✅
- Suivre les instructions (vous utiliserez sonar-scanner à l'ÉTAPE 9)

**💾 Sauvegarder le token**:
```powershell
echo "AI_TOKEN=sqp_votre_token_copié" >> "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens"
```

---

##### 📋 Récapitulatif des Méthodes d'Analyse par Projet

| Projet | Tool de Build Sélectionné | Raison |
|--------|---------------------------|--------|
| Backend | **Maven** | Projet Spring Boot avec pom.xml |
| Web | **Other** | Angular utilise sonar-scanner |
| Mobile | **Other** | Flutter/Dart utilise sonar-scanner |
| AI | **Other** | Python utilise sonar-scanner |

#### 3.2 Générer les Tokens d'Authentification

**⚠️ IMPORTANT**: Vous devez générer un token séparé pour CHAQUE projet.

---

#### 3.2 Vérifier que Tous les Tokens sont Sauvegardés

```powershell
# Vérifier le contenu du fichier tokens
Get-Content "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens"
```

**Résultat attendu** (vous aurez vos propres tokens):
```
BACKEND_TOKEN=sqp_2123718fa820f7467110ec2f014973c9c006a7bc
WEB_TOKEN=sqp_abcdef1234567890abcdef1234567890abcdef12
MOBILE_TOKEN=sqp_fedcba0987654321fedcba0987654321fedcba09
AI_TOKEN=sqp_567890abcdef1234567890abcdef1234567890ab
```

**✅ Les 4 projets sont maintenant créés avec leurs tokens!**

---

## ⚙️ Quality Profiles et Quality Gates

### ÉTAPE 4: Configuration des Quality Profiles

#### 4.1 Quality Profile pour Java (Backend)

1. **Quality Profiles** → **Java** → **Copy** "Sonar way"
2. **Nom**: `SimStruct Java Profile`
3. **Activer les règles supplémentaires**:

**Security**:
- `squid:S2076` - SQL Injection
- `squid:S5131` - XSS vulnerabilities
- `squid:S4426` - Weak cryptography

**Spring Boot Specific**:
- `squid:S3305` - Injection of dependencies
- `squid:S1118` - Utility classes should not have public constructors
- `squid:S1186` - Methods should not be empty

**Code Complexity**:
- Cognitive Complexity: Max **15**
- Cyclomatic Complexity: Max **10**

4. **Définir comme profil par défaut** pour Java

#### 4.2 Quality Profile pour TypeScript (Web)

1. **Quality Profiles** → **TypeScript** → **Copy** "Sonar way"
2. **Nom**: `SimStruct TypeScript Profile`
3. **Règles importantes**:

```
- typescript:S1186 - Functions should not be empty
- typescript:S3776 - Cognitive Complexity of functions should not be too high
- typescript:S1481 - Unused local variables should be removed
- typescript:S125 - Sections of code should not be commented out
## ⚙️ Quality Profiles et Quality Gates

### ÉTAPE 4: Configuration des Quality Profiles

**🎯 Objectif**: Personnaliser les règles d'analyse pour chaque langage avant de lancer les analyses.

---

#### 4.1 Quality Profile pour Java (Backend Spring Boot)

##### Étape 1: Accéder aux Quality Profiles

1. Dans la barre de navigation en haut, cliquer sur **"Quality Profiles"**
2. Vous verrez la liste de tous les profils par langage (C, C++, Java, JavaScript, Python, etc.)

##### Étape 2: Copier le Profil Sonar Way pour Java

1. Localiser la ligne **"Java"** → **"Sonar way"** 
2. À droite de cette ligne, cliquer sur l'icône **⚙️ (Settings)** ou les **3 points verticaux** 
3. Dans le menu déroulant, sélectionner **"Copy"**
4. Une popup s'affiche:
   - **Name**: Entrer `SimStruct Java Profile`
   - Cliquer sur **"Copy"**

**✅ Résultat**: Un nouveau profil "SimStruct Java Profile" apparaît dans la liste

##### Étape 3: Activer des Règles Supplémentaires

1. Cliquer sur le nom **"SimStruct Java Profile"** (lien bleu)
2. Vous êtes maintenant dans la page du profil avec les onglets: **Rules**, **Projects**, **Inheritance**, etc.

**A. Activer les règles de sécurité**

3. Cliquer sur l'onglet **"Rules"** (si pas déjà sélectionné)
4. Dans la barre de recherche à gauche, chercher: **Security**
5. Activer ces règles importantes (cliquer sur **"Inactive"** puis **"Activate"**):

| Règle Key | Nom | Comment l'activer |
|-----------|-----|-------------------|
| `java:S2076` | OS commands should not be vulnerable to injection attacks | Chercher "S2076" → Activate |
| `java:S5131` | Endpoints should not be vulnerable to XSS attacks | Chercher "S5131" → Activate |
| `java:S4426` | Cryptographic keys should be robust | Chercher "S4426" → Activate |
| `java:S3330` | Cookie security should be enabled | Chercher "S3330" → Activate |
| `java:S2068` | Credentials should not be hard-coded | Chercher "S2068" → Activate |

**B. Activer des règles de qualité de code importantes**

6. Activer ces règles supplémentaires importantes pour la maintenabilité:

| Règle Key | Nom | Comment chercher |
|-----------|-----|------------------|
| `java:S1118` | Utility classes should not have public constructors | Chercher "S1118" |
| `java:S1186` | Methods should not be empty | Chercher "S1186" |
| `java:S3457` | String format should be used correctly | Chercher "S3457" |
| `java:S1172` | Unused method parameters should be removed | Chercher "S1172" |

**Note**: Pour chaque règle, taper le code dans la recherche (ex: "S1118"), puis si elle est **Inactive**, cliquer sur la règle → **"Activate"**

**C. Configurer la complexité**

8. Chercher: **Cognitive Complexity**
9. Cliquer sur la règle **"Cognitive Complexity of methods should not be too high"** (java:S3776)
10. Cliquer sur **"Change"** (à droite)
11. Modifier le seuil: **15** (au lieu de 25 par défaut)
12. Cliquer sur **"Save"**

13. Chercher: **Cyclomatic Complexity**
14. Règle **"Methods should not be too complex"** (java:S1541)
15. Modifier le seuil: **10**

##### Étape 4: Définir comme Profil par Défaut pour Java

1. Revenir sur **Quality Profiles** (menu du haut)
2. Ligne **"SimStruct Java Profile"**
3. Cliquer sur les **3 points** → **"Set as Default"**
4. Confirmation: Une étoile ⭐ apparaît à côté du profil

**✅ Tous les projets Java utiliseront maintenant ce profil!**

---

#### 4.2 Quality Profile pour TypeScript (Frontend Web Angular)

##### Étape 1: Copier le Profil Sonar Way pour TypeScript

1. **Quality Profiles** (menu du haut)
2. Localiser **"TypeScript"** → **"Sonar way"**
3. Cliquer sur **⚙️** ou **3 points** → **"Copy"**
4. **Name**: `SimStruct TypeScript Profile`
5. **Copy**

##### Étape 2: Activer les Règles TypeScript/Angular

1. Cliquer sur **"SimStruct TypeScript Profile"**
2. Onglet **"Rules"**

**Règles importantes à activer**:

| Règle Key | Nom | Priorité |
|-----------|-----|----------|
| `typescript:S1186` | Functions should not be empty | HIGH |
| `typescript:S3776` | Cognitive Complexity of functions should not be too high | HIGH |
| `typescript:S1481` | Unused local variables should be removed | MEDIUM |
| `typescript:S125` | Sections of code should not be commented out | MEDIUM |
| `typescript:S1135` | Track uses of "TODO" tags | INFO |
| `typescript:S3358` | Ternary operators should not be nested | MEDIUM |
| `typescript:S2814` | "const" should be preferred over "let" | MINOR |
| `typescript:S3504` | Unused private methods should be removed | MEDIUM |

**Pour chaque règle**:
- Taper le code (ex: **S1186**) dans la recherche
- Si **Inactive**, cliquer dessus → **"Activate"**
- Si déjà **Active**, vérifier la sévérité

##### Étape 3: Configurer la Complexité Cognitive

1. Chercher **S3776** (Cognitive Complexity)
2. **Change** → Seuil: **15**
3. **Save**

##### Étape 4: Définir comme Défaut

1. **Quality Profiles** → **SimStruct TypeScript Profile**
2. **3 points** → **"Set as Default"**

**✅ Profil TypeScript configuré!**

---

#### 4.3 Quality Profile pour Python (AI Model)

##### Étape 1: Copier Sonar Way pour Python

1. **Quality Profiles**
2. **"Python"** → **"Sonar way"** → **Copy**
3. **Name**: `SimStruct Python Profile`
4. **Copy**

##### Étape 2: Activer les Règles Python ML/AI

**Règles de qualité générale**:

| Règle Key | Nom | Importance |
|-----------|-----|------------|
| `python:S1192` | String literals should not be duplicated | MEDIUM |
| `python:S3776` | Cognitive Complexity of functions should not be too high | HIGH |
| `python:S1542` | Functions should not be too complex | HIGH |
| `python:S117` | Local variables should comply with naming convention | MINOR |
| `python:S1871` | Branches should not have same code | MAJOR |

**Règles de sécurité**:

| Règle Key | Nom |
|-----------|-----|
| `python:S5547` | Cipher algorithms should be robust |
| `python:S4507` | Development and debugging code should not be used in production |
| `python:S2245` | Pseudorandom number generators should not be used for security |
| `python:S5332` | Unencrypted HTTP connections should not be used |

**Pour activer**:
1. Rechercher le code de la règle (ex: **S1192**)
2. Si inactive → **Activate**
3. Vérifier la sévérité

##### Étape 3: Complexité pour Python

1. **S3776** → Seuil: **15**
2. **S1542** → Seuil: **10** (complexité cyclomatique)

##### Étape 4: Défaut

**Quality Profiles** → **SimStruct Python Profile** → **Set as Default**

**✅ Les 3 profils sont configurés!**

---

#### 4.4 Note sur Dart/Flutter (Mobile)

**⚠️ SonarQube Community n'a pas de profil Dart officiel.**

Pour le mobile Flutter:
- L'analyse sera basique (duplication, taille)
- Utiliser **flutter analyze** en complément
- Pas besoin de créer un profil personnalisé

---

### ÉTAPE 5: Configuration du Quality Gate

**🎯 Objectif**: Définir les critères de validation de qualité du code.

---

#### 5.1 Créer un Quality Gate Personnalisé

##### Étape 1: Accéder aux Quality Gates

1. Menu du haut → **"Quality Gates"**
2. Vous verrez le Quality Gate par défaut: **"Sonar way"**

##### Étape 2: Créer un Nouveau Quality Gate

1. En haut à droite, cliquer sur le bouton **"Create"** (bleu)
2. Une popup s'affiche:
   - **Name**: `SimStruct Quality Gate`
   - **Copy from**: Sélectionner **"Sonar way"** (optionnel pour partir d'une base)
3. Cliquer sur **"Create"**

**✅ Le nouveau Quality Gate "SimStruct Quality Gate" est créé et sélectionné**

---

#### 5.2 Ajouter les Conditions sur Overall Code

Vous êtes maintenant dans la page du Quality Gate avec les onglets: **Conditions**, **Projects**, etc.

##### Condition 1: Coverage (Couverture de Code)

1. Cliquer sur **"Add Condition"** (bouton bleu)
2. Une popup s'ouvre avec un menu déroulant
3. Chercher et sélectionner: **"Coverage"**
4. Configurer:
   - **On**: `Overall Code` (par défaut)
   - **Quality Gate fails when**: `is less than`
   - **Value**: `60`
5. Cliquer sur **"Add Condition"**

**✅ Condition ajoutée**: "Coverage is less than 60%"

##### Condition 2: Duplicated Lines

1. **Add Condition**
2. Sélectionner: **"Duplicated Lines (%)"**
3. Configurer:
   - **On**: `Overall Code`
   - **fails when**: `is greater than`
   - **Value**: `3`
4. **Add Condition**

##### Condition 3: Maintainability Rating

1. **Add Condition**
2. Sélectionner: **"Maintainability Rating"**
3. Configurer:
   - **On**: `Overall Code`
   - **fails when**: `is worse than`
   - **Value**: `A` (sélectionner dans le menu déroulant)
4. **Add Condition**

##### Condition 4: Reliability Rating

1. **Add Condition**
2. **"Reliability Rating"**
3. `Overall Code` / `is worse than` / `A`
4. **Add Condition**

##### Condition 5: Security Rating

1. **Add Condition**
2. **"Security Rating"**
3. `Overall Code` / `is worse than` / `A`
4. **Add Condition**

##### Condition 6: Security Hotspots Reviewed

1. **Add Condition**
2. **"Security Hotspots Reviewed"**
3. Configurer:
   - **On**: `Overall Code`
   - **fails when**: `is less than`
   - **Value**: `100`
4. **Add Condition**

**📊 Résumé des Conditions Overall Code**:
- ✅ Coverage < 60% → FAIL
- ✅ Duplications > 3% → FAIL
- ✅ Maintainability worse than A → FAIL
- ✅ Reliability worse than A → FAIL
- ✅ Security worse than A → FAIL
- ✅ Security Hotspots < 100% reviewed → FAIL

---

#### 5.3 Ajouter les Conditions sur New Code

Maintenant, ajouter des conditions spécifiques au nouveau code.

##### Condition 7: Coverage on New Code

1. **Add Condition**
2. **"Coverage"**
3. Configurer:
   - **On**: `New Code` ⚠️ IMPORTANT
   - **fails when**: `is less than`
   - **Value**: `80`
4. **Add Condition**

##### Condition 8: Duplicated Lines on New Code

1. **Add Condition**
2. **"Duplicated Lines (%)"**
3. **On**: `New Code`
4. `is greater than` / `3`
5. **Add Condition**

##### Conditions 9-11: Ratings on New Code

Répéter pour:
- **Maintainability Rating on New Code** → `is worse than` → `A`
- **Reliability Rating on New Code** → `is worse than` → `A`
- **Security Rating on New Code** → `is worse than` → `A`

**📊 Résumé des Conditions New Code**:
- ✅ Coverage on New Code < 80% → FAIL
- ✅ Duplications on New Code > 3% → FAIL
- ✅ Tous les ratings New Code doivent être A

**✅ Quality Gate "SimStruct Quality Gate" configuré avec 11 conditions!**

---

#### 5.4 Définir comme Quality Gate par Défaut (Optionnel)

1. En haut de la page du Quality Gate, cliquer sur **"Set as Default"**
2. Confirmation: "SimStruct Quality Gate is now the default quality gate"

**Note**: Si vous définissez comme défaut, tous les nouveaux projets l'utiliseront automatiquement.

---

#### 5.5 Assigner le Quality Gate aux Projets

**✅ SOLUTION SIMPLE**: Si vous avez défini "SimStruct Quality Gate" comme **Default** (Section 5.4), tous vos projets l'utilisent automatiquement!

**Si vous n'avez PAS défini comme Default**, assignez manuellement pour chaque projet:

##### Pour chaque projet:

1. **Projects** (menu du haut) → Cliquer sur le projet
2. **Project Settings** (icône ⚙️ en haut à droite)
3. **Quality Gate** (menu de gauche)
4. Menu déroulant → Sélectionner **"SimStruct Quality Gate"**
5. Sauvegarde automatique

**Répéter pour les 4 projets**:
- SimStruct-Backend
- SimStruct-Web
- SimStruct-Mobile
- SimStruct-AI

---

#### 5.6 Vérification de la Configuration Complète

##### ✅ Checkpoint 1: Vérifier les Quality Profiles

1. Menu du haut → **"Quality Profiles"**
2. Vérifier que chaque profil personnalisé a l'étoile ⭐ (Default):
   - ⭐ **SimStruct Java Profile** (Default) - XXX rules
   - ⭐ **SimStruct TypeScript Profile** (Default) - XXX rules
   - ⭐ **SimStruct Python Profile** (Default) - XXX rules

**📸 CAPTURE D'ÉCRAN**: Page Quality Profiles avec les 3 profils marqués comme Default

##### ✅ Checkpoint 2: Vérifier le Quality Gate et les Projets

1. Menu du haut → **"Quality Gates"**
2. Cliquer sur **"SimStruct Quality Gate"**
3. Vérifier les conditions (section en haut):
   - 📊 **6 conditions** sur Overall Code
   - 📊 **5 conditions** sur New Code
   - 📊 **Total: 11 conditions**

4. Cliquer sur l'onglet **"Projects"**
5. Vérifier que les 4 projets sont listés:
   - ✅ SimStruct-Backend
   - ✅ SimStruct-Web
   - ✅ SimStruct-Mobile
   - ✅ SimStruct-AI

**📸 CAPTURE D'ÉCRAN**: 
- Quality Gate avec liste des conditions
- Onglet Projects montrant les 4 projets

##### ✅ Checkpoint 3: Vérifier depuis chaque Projet

Pour chaque projet, vérifier le Quality Gate assigné:

1. **SimStruct-Backend**: Dashboard → En haut, vous devriez voir "Quality Gate: SimStruct Quality Gate"
2. **SimStruct-Web**: Idem
3. **SimStruct-Mobile**: Idem
4. **SimStruct-AI**: Idem

---

### 🔍 Vérification des Codes de Règles (Squids)

**❗Important**: SonarQube a évolué. Les anciens codes "squid:SXXXX" ont été remplacés par des codes spécifiques par langage:

- **Java**: `java:SXXXX` (anciennement `squid:SXXXX`)
- **TypeScript**: `typescript:SXXXX`
- **Python**: `python:SXXXX`
- **JavaScript**: `javascript:SXXXX`

**Comment vérifier qu'une règle existe dans votre SonarQube**:

1. **Quality Profiles** → Sélectionner un profil (ex: **SimStruct Java Profile**)
2. Cliquer sur l'onglet **"Rules"**
3. Dans la barre de recherche à gauche, taper le code de la règle sans le préfixe (ex: **S2076**)
4. Si la règle existe:
   - Elle s'affiche avec son titre complet
   - Vous pouvez voir son statut (Active/Inactive)
   - Vous pouvez cliquer dessus pour voir les détails
5. Si aucun résultat:
   - La règle n'existe pas dans votre version
   - Ou le code a changé

**Liste des règles validées dans ce guide**:

✅ **Java (Backend)**:
- `java:S2076` - OS commands should not be vulnerable to injection attacks
- `java:S5131` - Endpoints should not be vulnerable to XSS attacks
- `java:S4426` - Cryptographic keys should be robust
- `java:S3330` - Cookie security should be enabled
- `java:S2068` - Credentials should not be hard-coded
- `java:S3776` - Cognitive Complexity of methods should not be too high
- `java:S1541` - Methods should not be too complex (Cyclomatic)

✅ **TypeScript (Web)**:
- `typescript:S1186` - Functions should not be empty
- `typescript:S3776` - Cognitive Complexity of functions should not be too high
- `typescript:S1481` - Unused local variables should be removed
- `typescript:S125` - Sections of code should not be commented out

✅ **Python (AI)**:
- `python:S1192` - String literals should not be duplicated
- `python:S3776` - Cognitive Complexity of functions should not be too high
- `python:S1542` - Functions should not be too complex
- `python:S5547` - Cipher algorithms should be robust

**🔬 Comment tester une règle**:

Exemple pour vérifier `java:S2076`:
1. **Quality Profiles** → **SimStruct Java Profile**
2. **Rules** → Rechercher **"S2076"**
3. Résultat: "OS commands should not be vulnerable to injection attacks"
4. Status: **Active** (si vous l'avez activée)

**📸 CAPTURE D'ÉCRAN RECOMMANDÉE**: 
- Recherche d'une règle (ex: S2076) montrant qu'elle existe et est active

---

### 📋 Résumé de la Configuration (Quality Profiles & Gates)

**✅ Configuration Terminée**:

1. **3 Quality Profiles Créés et Actifs**:
   - ⭐ SimStruct Java Profile (Default) - Spring Boot Backend
   - ⭐ SimStruct TypeScript Profile (Default) - Angular Web
   - ⭐ SimStruct Python Profile (Default) - AI Model

2. **1 Quality Gate Créé**:
   - SimStruct Quality Gate avec 11 conditions (6 Overall + 5 New Code)

3. **4 Projets Assignés au Quality Gate**:
   - SimStruct-Backend
   - SimStruct-Web
   - SimStruct-Mobile
   - SimStruct-AI

**🎯 Prochaine Étape**: Exécuter les analyses SonarQube pour chaque projet (Section 6-9)

---

#### 5.3 Assigner le Quality Gate aux Projets

**⚠️ IMPORTANT**: Faire cette opération pour CHAQUE projet séparément.

---

##### 📊 Assigner Quality Gate au Projet 1: Backend

1. Aller sur **http://localhost:9000/projects**
2. Cliquer sur le projet **"SimStruct Backend (Spring Boot)"**
3. Cliquer sur **"Project Settings"** (en bas à gauche)
4. Cliquer sur **"Quality Gate"**
5. Dans le menu déroulant, sélectionner **"SimStruct Quality Gate"**
6. Cliquer sur **"Save"**

**✅ Confirmation**: Vous verrez "Quality Gate updated" en haut

---

##### 📊 Assigner Quality Gate au Projet 2: Frontend Web

1. Aller sur **http://localhost:9000/projects**
2. Cliquer sur le projet **"SimStruct Web (Angular)"**
3. Cliquer sur **"Project Settings"**
4. Cliquer sur **"Quality Gate"**
5. Sélectionner **"SimStruct Quality Gate"**
6. Cliquer sur **"Save"**

**✅ Confirmation**: "Quality Gate updated"

---

##### 📊 Assigner Quality Gate au Projet 3: Mobile

1. Aller sur **http://localhost:9000/projects**
2. Cliquer sur le projet **"SimStruct Mobile (Flutter)"**
3. Cliquer sur **"Project Settings"**
4. Cliquer sur **"Quality Gate"**
5. Sélectionner **"SimStruct Quality Gate"**
6. Cliquer sur **"Save"**

**✅ Confirmation**: "Quality Gate updated"

---

##### 📊 Assigner Quality Gate au Projet 4: AI Model

1. Aller sur **http://localhost:9000/projects**
2. Cliquer sur le projet **"SimStruct AI Model (Python)"**
3. Cliquer sur **"Project Settings"**
4. Cliquer sur **"Quality Gate"**
5. Sélectionner **"SimStruct Quality Gate"**
6. Cliquer sur **"Save"**

**✅ Confirmation**: "Quality Gate updated"

---

##### 🔍 Vérifier l'Attribution

Pour vérifier que tous les projets utilisent le bon Quality Gate:

1. Aller sur **Quality Gates** → **"SimStruct Quality Gate"**
2. Cliquer sur l'onglet **"Projects"**
3. Vous devriez voir les **4 projets** listés:
   - ✅ SimStruct Backend (Spring Boot)
   - ✅ SimStruct Web (Angular)
   - ✅ SimStruct Mobile (Flutter)
   - ✅ SimStruct AI Model (Python)

---

##### 🎯 Configuration "New Code" pour CHAQUE Projet

Maintenant, configurer la définition du "New Code" pour chaque projet:

**Projet 1 - Backend**:
1. http://localhost:9000/dashboard?id=simstruct-backend
2. **Project Settings** → **New Code**
3. Sélectionner **"Previous Version"**
4. **Save**

**Projet 2 - Frontend Web**:
1. http://localhost:9000/dashboard?id=simstruct-web
2. **Project Settings** → **New Code**
3. Sélectionner **"Previous Version"**
4. **Save**

**Projet 3 - Mobile**:
1. http://localhost:9000/dashboard?id=simstruct-mobile
2. **Project Settings** → **New Code**
3. Sélectionner **"Previous Version"**
4. **Save**

**Projet 4 - AI Model**:
1. http://localhost:9000/dashboard?id=simstruct-ai
2. **Project Settings** → **New Code**
3. Sélectionner **"Previous Version"**
4. **Save**

**✅ Configuration terminée pour tous les projets!**

---

## 🔍 Analyse par Composant

---

# ═══════════════════════════════════════════════════════════════
# PROJET 1: BACKEND (SPRING BOOT)
# ═══════════════════════════════════════════════════════════════

### ÉTAPE 6: Analyse du Backend SimStruct

#### 📋 Informations du Projet

| Propriété | Valeur |
|-----------|--------|
| **Project Key** | `simstruct-backend` |
| **Langage** | Java 17 |
| **Build Tool** | Maven |
| **Localisation** | `C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend` |

---

#### 6.1 Exécuter l'Analyse Maven

**🔑 Récupérer votre token**:
```powershell
Get-Content "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens"
```

**📍 Naviguer vers le projet**:
```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend"
```

**🚀 Lancer l'analyse**:
```powershell
mvn clean verify sonar:sonar -Dsonar.projectKey=simstruct-backend -Dsonar.projectName="SimStruct Backend" -Dsonar.host.url=http://localhost:9000 -Dsonar.token=VOTRE_BACKEND_TOKEN_ICI
```

**Alternative (multiligne avec backticks)**:
```powershell
mvn clean verify sonar:sonar `
  -Dsonar.projectKey=simstruct-backend `
  -Dsonar.projectName="SimStruct Backend" `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=VOTRE_BACKEND_TOKEN_ICI
```

**⏱️ Durée**: 2-5 minutes

**✅ Succès**: Message "ANALYSIS SUCCESSFUL"

---

#### 6.2 Vérifier les Résultats

1. **Dashboard**: http://localhost:9000/dashboard?id=simstruct-backend
2. Vérifier:
   - ✅ Quality Gate status (Passed/Failed)
   - 📊 Coverage %
   - 🐛 Bugs count
   - 🔒 Vulnerabilities count
   - 📈 Code Smells count

**📸 CAPTURE D'ÉCRAN**: Dashboard avec métriques

---

# ═══════════════════════════════════════════════════════════════
# PROJET 2: FRONTEND WEB (ANGULAR)
# ═══════════════════════════════════════════════════════════════

### ÉTAPE 7: Analyse du Frontend Web SimStruct

#### 📋 Informations du Projet

| Propriété | Valeur |
|-----------|--------|
| **Project Key** | `simstruct-web` |
| **Langage** | TypeScript |
| **Framework** | Angular 18 |
| **Localisation** | `C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct` |

---

#### 7.1 Installer SonarScanner (Si pas encore fait)

**Télécharger**: https://docs.sonarqube.org/latest/analyzing-source-code/scanners/sonarscanner/

**Ajouter au PATH**:
```powershell
$env:PATH += ";C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin"
```

#### 7.2 Créer le Fichier de Configuration

**Fichier**: `Web/simstruct/sonar-project.properties`

```properties
sonar.projectKey=simstruct-web
sonar.projectName=SimStruct Web
sonar.projectVersion=1.0.0
sonar.sources=src/app
sonar.exclusions=**/*.spec.ts,**/node_modules/**,**/dist/**
sonar.sourceEncoding=UTF-8
sonar.host.url=http://localhost:9000
```

#### 7.3 Exécuter l'Analyse

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"

sonar-scanner `
  -Dsonar.token=VOTRE_WEB_TOKEN_ICI
```

**⏱️ Durée**: 2-4 minutes

**✅ Vérifier**: http://localhost:9000/dashboard?id=simstruct-web

---

# ═══════════════════════════════════════════════════════════════
# PROJET 3: MOBILE (FLUTTER)
# ═══════════════════════════════════════════════════════════════

### ÉTAPE 8: Analyse du Mobile SimStruct

#### 📋 Informations du Projet

| Propriété | Valeur |
|-----------|--------|
| **Project Key** | `simstruct-mobile` |
| **Langage** | Dart |
| **Framework** | Flutter |
| **Localisation** | `C:\Users\Hamza\Documents\EMSI 5\PFA\Mobile\simstruct_mobile` |

---

#### 8.1 Créer le Fichier de Configuration

**Fichier**: `Mobile/simstruct_mobile/sonar-project.properties`

```properties
sonar.projectKey=simstruct-mobile
sonar.projectName=SimStruct Mobile
sonar.projectVersion=1.0.0
sonar.sources=lib
sonar.exclusions=**/*.g.dart,**/test/**,**/build/**
sonar.sourceEncoding=UTF-8
sonar.host.url=http://localhost:9000
```

#### 8.2 Exécuter l'Analyse

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Mobile\simstruct_mobile"

sonar-scanner `
  -Dsonar.token=VOTRE_MOBILE_TOKEN_ICI
```

**⏱️ Durée**: 1-3 minutes

**✅ Vérifier**: http://localhost:9000/dashboard?id=simstruct-mobile

---

# ═══════════════════════════════════════════════════════════════
# PROJET 4: AI MODEL (PYTHON)
# ═══════════════════════════════════════════════════════════════

### ÉTAPE 9: Analyse du AI Model SimStruct

#### 📋 Informations du Projet

| Propriété | Valeur |
|-----------|--------|
| **Project Key** | `simstruct-ai` |
| **Langage** | Python |
| **Framework** | Flask |
| **Localisation** | `C:\Users\Hamza\Documents\EMSI 5\PFA\Model_AI` |

---

#### 9.1 Créer le Fichier de Configuration

**Fichier**: `Model_AI/sonar-project.properties`

```properties
sonar.projectKey=simstruct-ai
sonar.projectName=SimStruct AI Model
sonar.projectVersion=1.0.0
sonar.sources=src
sonar.exclusions=**/__pycache__/**,**/venv/**,**/notebooks/**,**/data/**
sonar.python.version=3.9,3.10,3.11,3.12
sonar.sourceEncoding=UTF-8
sonar.host.url=http://localhost:9000
```

#### 9.2 Exécuter l'Analyse

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Model_AI"

sonar-scanner `
  -Dsonar.token=VOTRE_AI_TOKEN_ICI
```

**⏱️ Durée**: 1-2 minutes

**✅ Vérifier**: http://localhost:9000/dashboard?id=simstruct-ai

---

## 📊 Résumé des Analyses

**✅ Configuration terminée**:

| Projet | Status | Dashboard URL |
|--------|--------|---------------|
| Backend | ✅ | http://localhost:9000/dashboard?id=simstruct-backend |
| Web | ✅ | http://localhost:9000/dashboard?id=simstruct-web |
| Mobile | ✅ | http://localhost:9000/dashboard?id=simstruct-mobile |
| AI | ✅ | http://localhost:9000/dashboard?id=simstruct-ai |

**🎯 Prochaine Étape**: Analyser les résultats et corriger les issues (Section 10)
| `**/entity/**` | Entités JPA, annotations uniquement |
| `**/config/**` | Configuration Spring Boot, pas de logique à tester |
| `**/*Application.java` | Point d'entrée Spring Boot, code généré |
| `**/target/**` | Fichiers compilés et générés |

##### Étape 2: Ajouter le Plugin JaCoCo

Dans la section `<build><plugins>`, ajouter le plugin JaCoCo:

```xml
<build>
    <plugins>
        <!-- ========== Plugins Existants ========== -->
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
        
        <!-- ========== JaCoCo Plugin pour Code Coverage ========== -->
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.11</version>
            <configuration>
                <excludes>
                    <!-- Exclusions identiques à SonarQube -->
                    <exclude>**/dto/**</exclude>
                    <exclude>**/entity/**</exclude>
                    <exclude>**/config/**</exclude>
                    <exclude>**/*Application.class</exclude>
                </excludes>
            </configuration>
            <executions>
                <!-- Préparation de l'agent JaCoCo -->
                <execution>
                    <id>prepare-agent</id>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                
                <!-- Génération du rapport après les tests -->
                <execution>
                    <id>report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>
                
                <!-- Vérification des seuils de couverture -->
                <execution>
                    <id>jacoco-check</id>
                    <goals>
                        <goal>check</goal>
                    </goals>
                    <configuration>
                        <rules>
                            <rule>
                                <element>PACKAGE</element>
                                <limits>
                                    <limit>
                                        <counter>LINE</counter>
                                        <value>COVEREDRATIO</value>
                                        <minimum>0.60</minimum>
                                    </limit>
                                </limits>
                            </rule>
                        </rules>
                    </configuration>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

#### 6.2 Note: Token Déjà Créé

**✅ Vous avez déjà créé le token à l'ÉTAPE 3.1** lors de la création du projet.

Le token `simstruct-backend-token` a été sauvegardé dans:
```
C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens
```

Vous pouvez le récupérer avec:
```powershell
Get-Content "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens" | Select-String "BACKEND"
```

#### 6.3 Commande d'Analyse Fournie par SonarQube

**⚠️ IMPORTANT**: Après avoir sélectionné **"Maven"** dans l'interface SonarQube, la commande exacte suivante vous a été affichée:

```bash
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=simstruct-backend \
  -Dsonar.projectName='SimStruct Backend (Spring Boot)' \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=sqp_2123718fa820f7467110ec2f014973c9c006a7bc
```

**💡 C'est cette commande que vous devez exécuter!**

#### 6.4 Lancer l'Analyse du Backend

##### Option A: Utiliser la Commande SonarQube (RECOMMANDÉ)

Cette commande est celle affichée par SonarQube après sélection de Maven:

```powershell
# Étape 1: Naviguer vers le dossier backend
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend"

# Étape 2: Exécuter la commande fournie par SonarQube (format PowerShell)
mvn clean verify sonar:sonar `
  -Dsonar.projectKey=simstruct-backend `
  -Dsonar.projectName="SimStruct Backend (Spring Boot)" `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=sqp_2123718fa820f7467110ec2f014973c9c006a7bc
```

**📝 Notes sur la commande**:
- `mvn clean verify` - Nettoie, compile et teste le projet
- `sonar:sonar` - Lance l'analyse SonarQube
- `-Dsonar.projectKey` - Identifiant unique du projet
- `-Dsonar.projectName` - Nom affiché dans SonarQube
- `-Dsonar.host.url` - URL du serveur SonarQube
- `-Dsonar.token` - Token d'authentification

**⏱️ Durée estimée**: 2-5 minutes

##### Option B: Commande avec Variables d'Environnement

Si vous préférez ne pas exposer le token dans la commande:

```powershell
# Étape 1: Définir le token en variable d'environnement
$env:SONAR_TOKEN = "sqp_2123718fa820f7467110ec2f014973c9c006a7bc"

# Étape 2: Naviguer vers le backend
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend"

# Étape 3: Lancer l'analyse
mvn clean verify sonar:sonar `
  -Dsonar.projectKey=simstruct-backend `
  -Dsonar.projectName="SimStruct Backend (Spring Boot)" `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=$env:SONAR_TOKEN
```

##### Option C: Analyse Rapide sans Tests (Si erreurs de tests)

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend"

mvn clean verify sonar:sonar `
  -Dsonar.projectKey=simstruct-backend `
  -Dsonar.projectName="SimStruct Backend (Spring Boot)" `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=sqp_2123718fa820f7467110ec2f014973c9c006a7bc `
  -DskipTests=true
```

#### 6.5 Résultat Attendu dans le Terminal

Pendant l'exécution, vous verrez:

```
[INFO] Scanning for projects...
[INFO] 
[INFO] ------------------< com.simstruct:simstruct-backend >-------------------
[INFO] Building simstruct-backend 0.0.1-SNAPSHOT
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] 
[INFO] --- maven-clean-plugin:3.2.0:clean (default-clean) @ simstruct-backend ---
[INFO] Deleting C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend\target
...
[INFO] --- sonar-maven-plugin:3.x.x:sonar (default-cli) @ simstruct-backend ---
[INFO] User cache: C:\Users\Hamza\.sonar\cache
[INFO] SonarQube version: 25.11.0.114957
[INFO] Analyzing on SonarQube server 25.11.0
[INFO] Default locale: "en_US", source code encoding: "UTF-8"
[INFO] Load global settings
[INFO] Load project settings
...
[INFO] Analysis report uploaded in XXXms
[INFO] ANALYSIS SUCCESSFUL, you can browse http://localhost:9000/dashboard?id=simstruct-backend
[INFO] Note that you will be able to access the updated dashboard once the server has processed the submitted analysis report
[INFO] More about the report processing at http://localhost:9000/api/ce/task?id=AY...
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
```

**✅ Indicateur de succès**: Vous verrez `BUILD SUCCESS` et un lien vers le dashboard.

#### 6.6 Configuration "New Code" pour le Backend

1. Aller sur **http://localhost:9000/dashboard?id=simstruct-backend**
2. **Project Settings** → **New Code**
3. Sélectionner **"Previous Version"**
4. **Save**

**Pourquoi "Previous Version"?**
- ✅ Compare chaque analyse avec la précédente
- ✅ Focus sur vos derniers commits
- ✅ Montre l'amélioration continue

#### 6.7 Vérifier les Résultats Backend

Une fois l'analyse terminée (2-5 minutes):

1. **Dashboard**: http://localhost:9000/dashboard?id=simstruct-backend

**Métriques à vérifier:**

| Métrique | Objectif | Localisation |
|----------|----------|--------------|
| **Bugs** | 0 Critical/Blocker | Overview → Reliability |
| **Vulnerabilities** | 0 Critical/Blocker | Overview → Security |
| **Code Smells** | < 50 | Overview → Maintainability |
| **Coverage** | ≥ 60% | Overview → Coverage |
| **Duplications** | < 3% | Measures → Duplications |
| **Lines of Code** | ~1500-2000 | Overview → Size |

**Fichiers analysés attendus:**
- ✅ Controllers: `AuthController.java`, `SimulationController.java`, `CommunityController.java`, `NotificationController.java`
- ✅ Services: `AIModelService.java`, `SimulationService.java`, `AuthService.java`, `CommunityService.java`
- ✅ Repositories: Toutes les interfaces JPA
- ❌ DTOs: Exclus (AIPredictionResponse, BuildingPredictionRequest, SimulationRequest)
- ❌ Entities: Exclus
- ❌ Config: Exclus

#### 6.8 Captures d'Écran à Prendre (Backend)

Pour votre rapport final:

1. 📸 **Dashboard Overview** - Vue générale avec tous les ratings
2. 📸 **Issues Tab** - Liste des bugs/vulnérabilités trouvés
3. 📸 **Measures → Reliability** - Détails des bugs
4. 📸 **Measures → Security** - Vulnérabilités et hotspots
5. 📸 **Measures → Maintainability** - Code smells et dette technique
6. 📸 **Code Tab** - Exemple de code analysé avec highlighting

Sauvegarder dans: `C:\Users\Hamza\Documents\EMSI 5\PFA\LOGS\sonarqube-reports\backend\`

---

# ═══════════════════════════════════════════════════════════════
# PROJET 2: FRONTEND WEB (ANGULAR)
# ═══════════════════════════════════════════════════════════════

### ÉTAPE 7: Configuration et Analyse du Frontend Web SimStruct

```powershell
# Naviguer vers le dossier backend
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend"

# Nettoyer et compiler
mvn clean install

# Lancer les tests et générer le rapport JaCoCo
mvn test

# Lancer l'analyse SonarQube
mvn sonar:sonar `
  -Dsonar.token=VOTRE_TOKEN_BACKEND
```

**Remplacer** `VOTRE_TOKEN_BACKEND` par le token généré précédemment.

**Durée estimée**: 2-5 minutes

#### 6.3 Vérifier les Résultats Backend

1. Aller sur **http://localhost:9000**
2. Cliquer sur le projet **"SimStruct Backend"**
3. Vérifier les métriques:
   - Bugs
   - Vulnerabilities
   - Code Smells
   - Coverage
   - Duplications

---

### ÉTAPE 7: Configuration et Analyse du Frontend Web SimStruct

#### 📋 Informations du Projet Frontend Web

| Propriété | Valeur |
|-----------|--------|
| **Nom** | SimStruct Web (Angular) |
| **Project Key** | `simstruct-web` |
| **Langage** | TypeScript/JavaScript |
| **Framework** | Angular 18.x |
| **Build Tool** | npm/Angular CLI |
| **Localisation** | `C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct` |

#### 📦 Structure du Projet Frontend Web

```
Web/simstruct/
├── src/
│   ├── app/
│   │   ├── core/
│   │   │   ├── models/           # Interfaces TypeScript
│   │   │   ├── services/         # Services Angular (API, Auth, Simulation)
│   │   │   └── guards/           # Route guards
│   │   ├── features/
│   │   │   └── auth/             # Module d'authentification
│   │   ├── pages/
│   │   │   ├── simulation/       # Page simulation avec AI
│   │   │   ├── results/          # Affichage résultats
│   │   │   ├── history/          # Historique simulations
│   │   │   ├── community/        # Forum communautaire
│   │   │   └── profile/          # Profil utilisateur
│   │   ├── shared/
│   │   │   └── components/       # Composants réutilisables
│   │   └── app.component.ts
│   ├── assets/                   # Images, styles (EXCLUS)
│   ├── environments/             # Config env (EXCLUS)
│   └── styles.scss
├── node_modules/                 # Dépendances (EXCLUS)
├── dist/                         # Build output (EXCLUS)
├── angular.json
├── package.json
├── tsconfig.json
└── karma.conf.js                 # Configuration tests
```

#### 7.1 Créer le Fichier de Configuration SonarQube

**Fichier**: `Web/simstruct/sonar-project.properties` (NOUVEAU FICHIER)

Créer ce fichier à la racine du projet Angular:

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"
New-Item -ItemType File -Name "sonar-project.properties"
```

Contenu complet du fichier:

```properties
# ══════════════════════════════════════════════════════════════
# CONFIGURATION SONARQUBE - SIMSTRUCT WEB (ANGULAR)
# ══════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────
# IDENTIFICATION DU PROJET
# ────────────────────────────────────────────────────────────
sonar.projectKey=simstruct-web
sonar.projectName=SimStruct Web (Angular)
sonar.projectVersion=1.0.0

# ────────────────────────────────────────────────────────────
# CONFIGURATION DES SOURCES
# ────────────────────────────────────────────────────────────
# Dossier contenant le code source à analyser
sonar.sources=src/app

# Dossier contenant les tests
sonar.tests=src/app

# Inclusions de tests (seulement les fichiers .spec.ts)
sonar.test.inclusions=**/*.spec.ts

# ────────────────────────────────────────────────────────────
# ENCODAGE
# ────────────────────────────────────────────────────────────
sonar.sourceEncoding=UTF-8

# ────────────────────────────────────────────────────────────
# LANGAGE
# ────────────────────────────────────────────────────────────
sonar.language=ts

# ────────────────────────────────────────────────────────────
# EXCLUSIONS - Fichiers à NE PAS analyser
# ────────────────────────────────────────────────────────────
sonar.exclusions=\
    **/node_modules/**,\
    **/dist/**,\
    **/*.spec.ts,\
    **/*.module.ts,\
    **/environments/**,\
    **/assets/**,\
    **/*.css,\
    **/*.scss,\
    **/*.html,\
    **/main.ts,\
    **/polyfills.ts,\
    **/test.ts,\
    **/*.config.js,\
    **/*.conf.js

# ────────────────────────────────────────────────────────────
# EXCLUSIONS DE COUVERTURE
# ────────────────────────────────────────────────────────────
sonar.coverage.exclusions=\
    **/*.spec.ts,\
    **/*.module.ts,\
    **/main.ts,\
    **/polyfills.ts,\
    **/environments/**,\
    **/app.component.ts,\
    **/app.config.ts

# ────────────────────────────────────────────────────────────
# TYPESCRIPT CONFIGURATION
# ────────────────────────────────────────────────────────────
# Chemin vers tsconfig.json
sonar.typescript.tsconfigPath=tsconfig.json

# Rapport de couverture LCOV (si tests disponibles)
sonar.typescript.lcov.reportPaths=coverage/lcov.info

# ────────────────────────────────────────────────────────────
# PARAMÈTRES D'ANALYSE
# ────────────────────────────────────────────────────────────
sonar.verbose=true
sonar.log.level=INFO

# ────────────────────────────────────────────────────────────
# EXCLUSIONS SPÉCIFIQUES SIMSTRUCT
# ────────────────────────────────────────────────────────────
# Modèles TypeScript (interfaces simples)
sonar.issue.ignore.multicriteria=e1,e2,e3

sonar.issue.ignore.multicriteria.e1.ruleKey=typescript:S1186
sonar.issue.ignore.multicriteria.e1.resourceKey=**/models/**

sonar.issue.ignore.multicriteria.e2.ruleKey=typescript:S125
sonar.issue.ignore.multicriteria.e2.resourceKey=**/*.component.html

sonar.issue.ignore.multicriteria.e3.ruleKey=typescript:S1128
sonar.issue.ignore.multicriteria.e3.resourceKey=**/environments/**
```

**📝 Explication des Exclusions Web:**

| Exclusion | Raison |
|-----------|--------|
| `**/*.spec.ts` | Fichiers de tests unitaires |
| `**/*.module.ts` | Modules Angular (configuration) |
| `**/environments/**` | Fichiers de configuration d'environnement |
| `**/*.html` | Templates HTML (pas de logique) |
| `**/*.scss` | Styles CSS |
| `**/node_modules/**` | Bibliothèques externes |

#### 7.2 Configuration Optionnelle: Tests et Coverage

Si vous voulez mesurer la couverture de code (optionnel):

##### Installer les dépendances de test:

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"

npm install --save-dev karma-coverage
```

##### Modifier `karma.conf.js`:

Localiser la section `coverageReporter` et modifier:

```javascript
module.exports = function (config) {
  config.set({
    // ...configuration existante...
    
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-headless-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage')  // Ajouter cette ligne
    ],
    
    preprocessors: {
      'src/**/*.ts': ['coverage']
    },
    
    coverageReporter: {
      dir: require('path').join(__dirname, './coverage'),
      subdir: '.',
      reporters: [
        { type: 'html' },
        { type: 'text-summary' },
        { type: 'lcovonly' }  // Important pour SonarQube
      ]
    },
    
    // ...reste de la configuration...
  });
};
```

#### 7.3 Créer le Token SonarQube pour le Web

1. Aller sur **http://localhost:9000**
2. **My Account** → **Security** → **Generate Tokens**
3. Remplir:
   - **Name**: `simstruct-web-token`
   - **Type**: `User Token`
   - **Expires in**: `90 days`
4. Cliquer sur **Generate**
5. **COPIER LE TOKEN**

**💾 Sauvegarder:**
```powershell
echo "WEB_TOKEN=sqp_votre_token_ici" >> "C:\Users\Hamza\Documents\EMSI 5\PFA\.sonarqube-tokens"
```

#### 7.4 Lancer l'Analyse du Frontend Web

##### Option A: Analyse Complète avec Tests

```powershell
# Étape 1: Naviguer vers le dossier web
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"

# Étape 2: Installer les dépendances (si pas encore fait)
npm install

# Étape 3: Compiler le projet
npm run build

# Étape 4: Lancer les tests avec coverage
npm run test -- --no-watch --code-coverage

# Étape 5: Vérifier que le rapport LCOV est généré
Test-Path "coverage/lcov.info"
# Devrait retourner: True

# Étape 6: Lancer l'analyse SonarQube
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=VOTRE_TOKEN_WEB
```

##### Option B: Analyse Rapide sans Tests (Première fois)

```powershell
# Analyse sans couverture de code
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"

# Vérifier que sonar-project.properties existe
Test-Path "sonar-project.properties"

# Lancer l'analyse
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=VOTRE_TOKEN_WEB `
  -Dsonar.projectKey=simstruct-web `
  -Dsonar.projectName="SimStruct Web (Angular)"
```

#### 7.5 Configuration "New Code" pour le Web

1. Aller sur **http://localhost:9000/dashboard?id=simstruct-web**
2. **Project Settings** → **New Code**
3. Sélectionner **"Previous Version"**
4. **Save**

#### 7.6 Vérifier les Résultats Frontend Web

Dashboard: **http://localhost:9000/dashboard?id=simstruct-web**

**Métriques attendues:**

| Métrique | Objectif | Notes |
|----------|----------|-------|
| **Bugs** | 0 Critical/Blocker | Erreurs TypeScript |
| **Vulnerabilities** | 0 Critical/Blocker | Failles XSS, injection |
| **Code Smells** | < 50 | Complexité, duplications |
| **Coverage** | ≥ 60% | Si tests disponibles |
| **Duplications** | < 3% | Code dupliqué |
| **Lines of Code** | ~1200-1800 | TypeScript uniquement |

**Fichiers analysés attendus:**
- ✅ Services: `simulation.service.ts`, `api.service.ts`, `auth.service.ts`, `community.service.ts`
- ✅ Components: `simulation.component.ts`, `results.component.ts`, `history.component.ts`
- ✅ Guards: `auth.guard.ts`
- ❌ Specs: Exclus (*.spec.ts)
- ❌ Modules: Exclus (*.module.ts)
- ❌ HTML/CSS: Exclus

#### 7.7 Captures d'Écran à Prendre (Web)

Pour votre rapport:

1. 📸 **Dashboard Overview**
2. 📸 **Issues Tab** - TypeScript issues
3. 📸 **Measures → Maintainability**
4. 📸 **Code Tab** - Exemple de fichier TypeScript analysé

Sauvegarder dans: `C:\Users\Hamza\Documents\EMSI 5\PFA\LOGS\sonarqube-reports\web\`

---

# ═══════════════════════════════════════════════════════════════
# PROJET 3: MOBILE (FLUTTER)
# ═══════════════════════════════════════════════════════════════

### ÉTAPE 8: Configuration et Analyse du Mobile Flutter SimStruct

#### 7.1 Créer le Fichier de Configuration

**Fichier**: `Web/simstruct/sonar-project.properties`

```properties
# Project identification
sonar.projectKey=simstruct-web
sonar.projectName=SimStruct Web (Angular)
sonar.projectVersion=1.0

# Source configuration
sonar.sources=src/app
sonar.tests=src/app
sonar.test.inclusions=**/*.spec.ts

# Encoding
sonar.sourceEncoding=UTF-8

# Language
sonar.language=ts

# Exclusions
sonar.exclusions=\
    **/node_modules/**,\
    **/dist/**,\
    **/*.spec.ts,\
    **/*.module.ts,\
    **/environments/**,\
    **/assets/**,\
    **/*.css,\
    **/*.scss

# TypeScript specific
sonar.typescript.lcov.reportPaths=coverage/lcov.info

# Additional settings
sonar.coverage.exclusions=\
    **/*.spec.ts,\
    **/*.module.ts,\
    **/main.ts,\
    **/polyfills.ts,\
    **/environments/**
```

#### 7.2 Installer les Dépendances pour Coverage (Optionnel)

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"

# Installer karma-coverage
npm install --save-dev karma-coverage
```

Modifier `karma.conf.js` pour générer le rapport LCOV:

```javascript
module.exports = function (config) {
  config.set({
    // ...existing config
    
    coverageReporter: {
      type: 'lcov',
      dir: 'coverage/',
      subdir: '.'
    },
    
    // ...rest of config
  });
};
```

#### 7.3 Générer le Coverage (si vous avez des tests)

```powershell
# Lancer les tests avec coverage
npm run test -- --no-watch --code-coverage
```

#### 7.4 Lancer l'Analyse Frontend

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"

# Lancer SonarScanner
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=VOTRE_TOKEN_WEB
```

**Durée estimée**: 1-3 minutes

---

### ÉTAPE 8: Configuration et Analyse du Mobile (Flutter)

#### 8.1 Créer le Fichier de Configuration

**Fichier**: `Mobile/simstruct_mobile/sonar-project.properties`

```properties
# Project identification
sonar.projectKey=simstruct-mobile
sonar.projectName=SimStruct Mobile (Flutter)
sonar.projectVersion=1.0

# Source configuration
sonar.sources=lib
sonar.tests=test

# Encoding
sonar.sourceEncoding=UTF-8

# Exclusions
sonar.exclusions=\
    **/*.g.dart,\
    **/*.freezed.dart,\
    **/*.config.dart,\
    **/generated/**,\
    **/.dart_tool/**,\
    **/build/**,\
    **/android/**,\
    **/ios/**,\
    **/web/**,\
    **/windows/**,\
    **/test/**

# Dart/Flutter settings (best effort analysis)
sonar.sources.inclusions=**/*.dart

# Note: SonarQube n'a pas de support officiel pour Dart
# L'analyse sera basique (duplication, complexité)
```

#### 8.2 Lancer l'Analyse Mobile

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Mobile\simstruct_mobile"

# Lancer SonarScanner
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=VOTRE_TOKEN_MOBILE
```

**⚠️ Note**: L'analyse Dart sera limitée (duplication, taille de fichiers, complexité basique)

**Durée estimée**: 1-2 minutes

---

### ÉTAPE 9: Configuration et Analyse du AI Model (Python)

#### 9.1 Créer le Fichier de Configuration

**Fichier**: `Model_AI/sonar-project.properties`

```properties
# Project identification
sonar.projectKey=simstruct-ai
sonar.projectName=SimStruct AI Model (Python)
sonar.projectVersion=1.0

# Source configuration
sonar.sources=src
sonar.tests=src

# Python version
sonar.python.version=3.9,3.10,3.11,3.12

# Encoding
sonar.sourceEncoding=UTF-8

# Exclusions
sonar.exclusions=\
    **/__pycache__/**,\
    **/*.pyc,\
    **/venv/**,\
    **/env/**,\
    **/data/**,\
    **/models/*.pt,\
    **/models/*.pkl,\
    **/logs/**,\
    **/.pytest_cache/**,\
    **/notebooks/**,\
    **/professional_dataset_generator.py

# Test inclusions
sonar.test.inclusions=**/*test*.py

# Coverage (if using pytest-cov)
sonar.python.coverage.reportPaths=coverage.xml

# Additional Python settings
sonar.python.pylint.reportPaths=pylint-report.txt
```

**Note**: Le fichier `professional_dataset_generator.py` est exclu car c'est un script de génération de données, pas du code de production.

#### 9.2 Générer Coverage (Optionnel)

Si vous avez des tests Python:

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Model_AI"

# Installer pytest-cov si nécessaire
pip install pytest-cov

# Lancer les tests avec coverage
pytest --cov=src --cov-report=xml
```

#### 9.3 Lancer l'Analyse AI

```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Model_AI"

# Lancer SonarScanner
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat `
  -Dsonar.host.url=http://localhost:9000 `
  -Dsonar.token=VOTRE_TOKEN_AI
```

**Durée estimée**: 1-2 minutes

---

## 🔧 Correction des Issues

### ÉTAPE 10: Analyse et Priorisation des Issues

#### 10.1 Vue d'Ensemble des Issues

Pour chaque projet, accéder à **Issues** et filtrer par:

**Sévérité** (du plus critique au moins):
1. 🔴 **BLOCKER** - Empêche le fonctionnement
2. 🔴 **CRITICAL** - Vulnérabilité de sécurité ou bug majeur
3. 🟠 **MAJOR** - Impact significatif sur la qualité
4. 🟡 **MINOR** - Impact mineur
5. ℹ️ **INFO** - Suggestion d'amélioration

**Type**:
- 🐛 **BUG** - Erreur de code
- 🔒 **VULNERABILITY** - Faille de sécurité
- 🔥 **SECURITY HOTSPOT** - Code à risque
- 💩 **CODE SMELL** - Dette technique

#### 10.2 Stratégie de Correction

**Priorité 1** - À corriger IMMÉDIATEMENT:
- ✅ Tous les BLOCKER
- ✅ Tous les CRITICAL
- ✅ Toutes les VULNERABILITIES

**Priorité 2** - À corriger avant livrable:
- ✅ MAJOR bugs
- ✅ MAJOR code smells (les plus impactants)
- ✅ Security Hotspots (review + fix)

**Priorité 3** - Optionnel (selon temps):
- ⚠️ MINOR issues
- ⚠️ INFO suggestions

#### 10.3 Issues Communes et Solutions

##### Backend (Java/Spring Boot)

**Issue**: `S1118 - Utility classes should not have public constructors`
```java
// ❌ Avant
public class Utils {
    public static String format(String s) { ... }
}

// ✅ Après
public class Utils {
    private Utils() {
        throw new IllegalStateException("Utility class");
    }
    public static String format(String s) { ... }
}
```

**Issue**: `S2259 - Null pointer exceptions`
```java
// ❌ Avant
public void process(User user) {
    String name = user.getName().toUpperCase();
}

// ✅ Après
public void process(User user) {
    if (user != null && user.getName() != null) {
        String name = user.getName().toUpperCase();
    }
}
```

**Issue**: `S1192 - String literals should not be duplicated`
```java
// ❌ Avant
log.info("User not found");
throw new Exception("User not found");

// ✅ Après
private static final String USER_NOT_FOUND = "User not found";
log.info(USER_NOT_FOUND);
throw new Exception(USER_NOT_FOUND);
```

##### Frontend (TypeScript/Angular)

**Issue**: `S1186 - Functions should not be empty`
```typescript
// ❌ Avant
ngOnInit() {
}

// ✅ Après (soit implémenter, soit supprimer)
ngOnInit() {
    this.loadData();
}
```

**Issue**: `S3776 - Cognitive Complexity too high`
```typescript
// ❌ Avant - Fonction trop complexe
function validate(user: User): boolean {
    if (user) {
        if (user.name) {
            if (user.email) {
                if (user.email.includes('@')) {
                    // ... plus de conditions
                }
            }
        }
    }
}

// ✅ Après - Découper en fonctions
function validate(user: User): boolean {
    return hasValidUser(user) && hasValidEmail(user.email);
}

function hasValidUser(user: User): boolean {
    return user !== null && user.name !== null;
}

function hasValidEmail(email: string): boolean {
    return email !== null && email.includes('@');
}
```

##### Python (AI Model)

**Issue**: `S1192 - String literals should not be duplicated`
```python
# ❌ Avant
print("Model not found")
raise Exception("Model not found")

# ✅ Après
MODEL_NOT_FOUND = "Model not found"
print(MODEL_NOT_FOUND)
raise Exception(MODEL_NOT_FOUND)
```

**Issue**: `S125 - Remove commented out code`
```python
# ❌ Avant
def train_model(data):
    # old_model = load_old_model()
    # old_model.train(data)
    new_model = create_model()
    new_model.train(data)

# ✅ Après
def train_model(data):
    new_model = create_model()
    new_model.train(data)
```

#### 10.4 Workflow de Correction

Pour chaque issue:

1. **Comprendre** le problème (cliquer sur "Why is this an issue?")
2. **Évaluer** l'impact réel
3. **Corriger** le code
4. **Tester** localement
5. **Re-scanner** le projet
6. **Vérifier** que l'issue a disparu

#### 10.5 Marquer les False Positives

Si une issue est un faux positif:

1. Cliquer sur l'issue
2. **Change Status** → **Won't Fix** ou **False Positive**
3. Ajouter un **commentaire** justificatif

---

## 📊 Génération des Rapports

### ÉTAPE 11: Collecte des Métriques

#### 11.1 Dashboard Global

**URL**: http://localhost:9000/projects

Capturer:
- 📸 Screenshot du dashboard montrant les 4 projets
- 📸 Vue "Measures" pour chaque projet

#### 11.2 Métriques Détaillées par Projet

Pour **CHAQUE** projet, noter:

**Reliability (Fiabilité)**:
- Nombre de bugs
- Reliability Rating (A-E)
- Effort de correction estimé

**Security (Sécurité)**:
- Nombre de vulnérabilités
- Security Rating (A-E)
- Security Hotspots reviewed

**Maintainability (Maintenabilité)**:
- Code Smells
- Technical Debt (temps de correction)
- Maintainability Rating (A-E)

**Coverage (Couverture)**:
- % de couverture de code
- Lignes couvertes / Lignes totales
- Branches couvertes

**Duplications**:
- % de lignes dupliquées
- Nombre de blocs dupliqués

**Size (Taille)**:
- Lignes de code (LOC)
- Nombre de fichiers
- Nombre de fonctions/classes

#### 11.3 Export des Données

**Option 1: Export PDF (Plugin commercial requis)**

Si vous n'avez pas le plugin, utilisez l'option 2.

**Option 2: Screenshots + Données manuelles**

Pour chaque projet:

```powershell
# Créer un dossier pour les screenshots
New-Item -Path "C:\Users\Hamza\Documents\EMSI 5\PFA\LOGS\sonarqube-reports" -ItemType Directory -Force
```

Capturer:
1. **Overview** tab
2. **Issues** tab (groupé par sévérité)
3. **Measures** tab → **Reliability**
4. **Measures** tab → **Security**
5. **Measures** tab → **Maintainability**
6. **Measures** tab → **Coverage**
7. **Code** tab → **Duplications**

#### 11.4 Tableau Récapitulatif

Créer un fichier Excel ou Markdown avec:

**Fichier**: `LOGS/sonarqube-reports/METRICS_SUMMARY.md`

```markdown
# Résumé des Métriques SonarQube - Projet SimStruct

## Vue d'Ensemble

| Projet | LOC | Bugs | Vulnerabilities | Code Smells | Coverage | Duplications |
|--------|-----|------|-----------------|-------------|----------|--------------|
| Backend | XXXX | X | X | XX | XX% | X% |
| Web | XXXX | X | X | XX | XX% | X% |
| Mobile | XXXX | X | X | XX | XX% | X% |
| AI | XXXX | X | X | XX | XX% | X% |
| **TOTAL** | **XXXX** | **X** | **X** | **XX** | **XX%** | **X%** |

## Backend (Spring Boot)

### Métriques de Fiabilité
- Bugs: X (Rating: A/B/C/D/E)
- Effort: Xh Xmin

### Métriques de Sécurité
- Vulnerabilities: X (Rating: A/B/C/D/E)
- Security Hotspots: X reviewed (100%)

### Métriques de Maintenabilité
- Code Smells: XX
- Technical Debt: Xh Xmin
- Debt Ratio: X%

### Couverture
- Coverage: XX%
- Lines to cover: XXX
- Uncovered lines: XX

### Duplications
- Duplicated lines: X%
- Duplicated blocks: X

## [Répéter pour Web, Mobile, AI]
```

---

## 📄 Template Rapport Académique

### ÉTAPE 12: Rédaction du Rapport Final

**Fichier**: `LOGS/sonarqube-reports/RAPPORT_QUALITE_CODE_SONARQUBE.md`

```markdown
# 📊 Rapport d'Analyse de Qualité de Code
## Projet SimStruct - Analyse SonarQube

---

**Projet**: SimStruct - Plateforme d'Analyse Structurelle  
**Date de l'analyse**: [DATE]  
**Analysé par**: [VOTRE NOM]  
**Outil utilisé**: SonarQube v25.11.0  

---

## 1. Introduction

### 1.1 Contexte du Projet

SimStruct est une plateforme complète d'analyse structurelle composée de:
- Un **backend** en Spring Boot pour la logique métier
- Un **frontend web** en Angular pour l'interface utilisateur
- Une **application mobile** en Flutter pour l'accès mobile
- Un **modèle d'IA** en Python pour les analyses prédictives

### 1.2 Objectifs de l'Analyse

L'analyse SonarQube vise à:
- ✅ Évaluer la qualité du code source
- ✅ Identifier les bugs et vulnérabilités
- ✅ Mesurer la dette technique
- ✅ Garantir la maintenabilité du projet
- ✅ Assurer la conformité aux standards de développement

### 1.3 Méthodologie

**Outil**: SonarQube Community Edition v25.11.0  
**Scanner**: SonarScanner CLI v7.2.0  
**Date d'analyse**: [DATE]  
**Périmètre**: 4 composants (Backend, Web, Mobile, AI)  

---

## 2. Configuration de l'Analyse

### 2.1 Quality Profiles Utilisés

| Composant | Langage | Profile | Règles Actives |
|-----------|---------|---------|----------------|
| Backend | Java | SimStruct Java Profile | XXX règles |
| Web | TypeScript | SimStruct TypeScript Profile | XXX règles |
| Mobile | Dart | Default | XXX règles |
| AI | Python | SimStruct Python Profile | XXX règles |

### 2.2 Quality Gate

**Nom**: SimStruct Quality Gate

**Conditions**:
- Coverage ≥ 60%
- Duplications ≤ 3%
- Maintainability Rating = A
- Reliability Rating = A
- Security Rating = A
- Security Hotspots Reviewed = 100%

---

## 3. Résultats d'Analyse

### 3.1 Vue d'Ensemble Multi-Projets

![Dashboard Global](./screenshots/global-dashboard.png)

**Métriques Globales**:
- **Lignes de code totales**: XXXXX LOC
- **Nombre de fichiers**: XXX
- **Bugs totaux**: XX
- **Vulnérabilités totales**: XX
- **Code Smells totaux**: XXX
- **Dette technique totale**: XXh XXmin

### 3.2 Backend (Spring Boot)

#### Overview
![Backend Overview](./screenshots/backend-overview.png)

#### Métriques Clés

| Métrique | Valeur | Rating | Status |
|----------|--------|--------|--------|
| Reliability | X bugs | A/B/C | ✅/❌ |
| Security | X vulnerabilities | A/B/C | ✅/❌ |
| Maintainability | XX code smells | A/B/C | ✅/❌ |
| Coverage | XX% | - | ✅/❌ |
| Duplications | X% | - | ✅/❌ |

#### Issues Principales Identifiées

**Bugs** (X au total):
1. [Type de bug] - Fichier: [nom] - Ligne: [X] - Sévérité: [CRITICAL/MAJOR]
   - Description: ...
   - Correction appliquée: ...

**Vulnerabilities** (X au total):
1. [Type de vulnérabilité] - CWE-XXX
   - Description: ...
   - Impact: ...
   - Correction: ...

**Code Smells** (Top 5):
1. [Description] - [Nombre d'occurrences]
2. ...

#### Actions Correctives

- ✅ [Action 1] - Status: Corrigé
- ✅ [Action 2] - Status: Corrigé
- ⏳ [Action 3] - Status: En cours

### 3.3 Frontend Web (Angular)

[Même structure que Backend]

### 3.4 Mobile (Flutter)

[Même structure que Backend]

### 3.5 AI Model (Python)

[Même structure que Backend]

---

## 4. Analyse Comparative

### 4.1 Comparaison des Composants

| Composant | LOC | Bugs | Vulns | Code Smells | Coverage | Quality Gate |
|-----------|-----|------|-------|-------------|----------|--------------|
| Backend | XXX | X | X | XX | XX% | ✅/❌ |
| Web | XXX | X | X | XX | XX% | ✅/❌ |
| Mobile | XXX | X | X | XX | XX% | ✅/❌ |
| AI | XXX | X | X | XX | XX% | ✅/❌ |

### 4.2 Graphiques

[Insérer graphiques Excel/Charts]:
- Répartition des bugs par composant
- Évolution de la dette technique
- Taux de couverture par composant

---

## 5. Dette Technique

### 5.1 Calcul de la Dette

**Dette technique totale**: XXh XXmin

**Répartition par composant**:
- Backend: XXh XXmin (XX%)
- Web: XXh XXmin (XX%)
- Mobile: XXh XXmin (XX%)
- AI: XXh XXmin (XX%)

### 5.2 Ratio de Dette

**Formule**: Debt Ratio = (Cost to fix / Development cost) × 100

| Composant | Debt Ratio | Interprétation |
|-----------|------------|----------------|
| Backend | X% | Excellent/Bon/Moyen/Mauvais |
| Web | X% | ... |
| Mobile | X% | ... |
| AI | X% | ... |

---

## 6. Sécurité

### 6.1 Analyse des Vulnérabilités

**Nombre total**: X

**Par sévérité**:
- 🔴 BLOCKER: X
- 🔴 CRITICAL: X
- 🟠 MAJOR: X
- 🟡 MINOR: X

### 6.2 Security Hotspots

**Nombre total**: X  
**Reviewed**: X (XX%)

**Principaux hotspots**:
1. [Description] - [Fichier] - Status: [Reviewed/Safe/Fixed]

### 6.3 Standards de Sécurité

Conformité aux standards:
- ✅ OWASP Top 10
- ✅ CWE Top 25
- ✅ SANS Top 25

---

## 7. Maintenabilité

### 7.1 Complexité du Code

**Complexité cyclomatique moyenne**:
- Backend: XX (Acceptable si < 10)
- Web: XX
- Mobile: XX
- AI: XX

**Complexité cognitive moyenne**:
- Backend: XX (Acceptable si < 15)
- Web: XX
- Mobile: XX
- AI: XX

### 7.2 Duplication de Code

**Taux de duplication global**: X%

| Composant | Duplications | Blocs | Status |
|-----------|--------------|-------|--------|
| Backend | X% | XX | ✅/❌ |
| Web | X% | XX | ✅/❌ |
| Mobile | X% | XX | ✅/❌ |
| AI | X% | XX | ✅/❌ |

**Objectif**: < 3% ✅

---

## 8. Couverture de Tests

### 8.1 Taux de Couverture

| Composant | Coverage | Lines to Cover | Uncovered Lines | Status |
|-----------|----------|----------------|-----------------|--------|
| Backend | XX% | XXX | XX | ✅/❌ |
| Web | XX% | XXX | XX | ✅/❌ |
| Mobile | XX% | XXX | XX | ✅/❌ |
| AI | XX% | XXX | XX | ✅/❌ |

**Objectif global**: ≥ 60% ✅

### 8.2 Recommandations Tests

Pour améliorer la couverture:
- [ ] Ajouter tests unitaires pour [composants critiques]
- [ ] Implémenter tests d'intégration pour [API]
- [ ] Créer tests E2E pour [parcours utilisateur]

---

## 9. Actions Réalisées

### 9.1 Corrections Effectuées

**Total issues corrigées**: XX

**Par type**:
- Bugs: X/X (XX%)
- Vulnerabilities: X/X (XX%)
- Code Smells: X/X (XX%)

### 9.2 Évolution des Métriques

| Métrique | Avant | Après | Amélioration |
|----------|-------|-------|--------------|
| Bugs | XX | XX | -XX (-XX%) |
| Vulnerabilities | XX | XX | -XX (-XX%) |
| Code Smells | XXX | XXX | -XX (-XX%) |
| Coverage | XX% | XX% | +X% |
| Debt | XXh | XXh | -XXh (-XX%) |

### 9.3 Quality Gate Status

**Avant corrections**: ❌ Failed (X/4 projets)  
**Après corrections**: ✅ Passed (4/4 projets)

---

## 10. Recommandations

### 10.1 Court Terme (1-2 semaines)

1. **Priorité HAUTE**:
   - [ ] Corriger tous les bugs BLOCKER/CRITICAL restants
   - [ ] Traiter toutes les vulnérabilités de sécurité
   - [ ] Reviewer tous les Security Hotspots

2. **Priorité MOYENNE**:
   - [ ] Réduire la complexité des fonctions complexes
   - [ ] Augmenter la couverture de tests à 70%
   - [ ] Éliminer les duplications de code

### 10.2 Moyen Terme (1-3 mois)

1. **Amélioration Continue**:
   - [ ] Intégrer SonarQube dans le pipeline CI/CD
   - [ ] Mettre en place des Quality Gates stricts
   - [ ] Former l'équipe aux bonnes pratiques

2. **Optimisation**:
   - [ ] Refactoriser le code legacy
   - [ ] Améliorer la documentation
   - [ ] Réduire la dette technique à < 5%

### 10.3 Long Terme (3-6 mois)

1. **Excellence**:
   - [ ] Atteindre 80% de couverture de tests
   - [ ] Maintenir un Maintainability Rating = A
   - [ ] Zéro vulnérabilité de sécurité

---

## 11. Conclusion

### 11.1 Bilan Global

L'analyse SonarQube du projet SimStruct révèle:

**Points Forts** ✅:
- [Exemple: Architecture bien structurée]
- [Exemple: Faible taux de duplication]
- [Exemple: Respect des standards de sécurité]

**Points d'Amélioration** ⚠️:
- [Exemple: Couverture de tests insuffisante]
- [Exemple: Complexité élevée dans certains modules]
- [Exemple: Dette technique à réduire]

### 11.2 Quality Gate Final

**Status**: ✅ PASSED (4/4 composants)

| Composant | Status | Score |
|-----------|--------|-------|
| Backend | ✅ PASSED | A |
| Web | ✅ PASSED | A |
| Mobile | ✅ PASSED | B |
| AI | ✅ PASSED | A |

### 11.3 Perspectives

Le projet SimStruct présente une qualité de code **[Excellente/Bonne/Satisfaisante]** avec:
- Une base solide pour la maintenance future
- Des vulnérabilités identifiées et corrigées
- Une dette technique maîtrisée
- Des standards de développement respectés

L'intégration continue de SonarQube garantira le maintien de cette qualité.

---

## 12. Annexes

### Annexe A: Screenshots Détaillés
- Dashboard global
- Détails par projet
- Quality Gates
- Issues critiques

### Annexe B: Configuration SonarQube
- Quality Profiles
- Quality Gates
- Fichiers de configuration (pom.xml, sonar-project.properties)

### Annexe C: Définitions
- **Bug**: Erreur de code causant un comportement incorrect
- **Vulnerability**: Faille de sécurité exploitable
- **Code Smell**: Dette technique affectant la maintenabilité
- **Technical Debt**: Effort requis pour corriger les problèmes
- **Coverage**: Pourcentage de code testé

### Annexe D: Références
- Documentation SonarQube: https://docs.sonarqube.org/
- Standards OWASP: https://owasp.org/
- Clean Code Principles

---

**Fin du Rapport**

---

**Signataires**:
- Analysé par: [VOTRE NOM]
- Validé par: [ENCADRANT]
- Date: [DATE]
```

---

## ✅ Checklist de Vérification

### Avant de Générer le Rapport Final

- [ ] Les 4 projets sont analysés avec succès
- [ ] Tous les BLOCKER/CRITICAL sont corrigés
- [ ] Quality Gates sont PASSED pour les 4 projets
- [ ] Screenshots capturés pour chaque projet
- [ ] Métriques collectées et documentées
- [ ] Tableau récapitulatif rempli
- [ ] Actions correctives documentées
- [ ] Rapport final rédigé et relu
- [ ] Annexes complétées

---

## 🎯 Résumé des Commandes

### Démarrage SonarQube
```powershell
cd C:\Users\Hamza\Downloads\sonarqube-25.11.0.114957\bin\windows-x86-64
.\StartSonar.bat
```

### Analyse Backend
```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Backend\simstruct-backend"
mvn clean verify sonar:sonar -Dsonar.token=VOTRE_TOKEN
```

### Analyse Web
```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Web\simstruct"
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat -Dsonar.token=VOTRE_TOKEN
```

### Analyse Mobile
```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Mobile\simstruct_mobile"
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat -Dsonar.token=VOTRE_TOKEN
```

### Analyse AI
```powershell
cd "C:\Users\Hamza\Documents\EMSI 5\PFA\Model_AI"
C:\Users\Hamza\Downloads\sonar-scanner-cli-7.2.0.5079-windows-x64\bin\sonar-scanner.bat -Dsonar.token=VOTRE_TOKEN
```

---

## 📞 Support et Ressources

### Documentation SonarQube
- Official Docs: https://docs.sonarqube.org/
- Community: https://community.sonarsource.com/

### Durée Totale Estimée
- **Configuration**: 2-3 heures
- **Analyses**: 1 heure
- **Corrections**: 4-6 heures
- **Rapport**: 2 heures
- **TOTAL**: ~10-12 heures

---

**Document créé le**: 16 Décembre 2025  
**Version**: 1.0  
**Auteur**: GitHub Copilot pour SimStruct Project
