# 📘 Guide Complet de Révision - Qualité & Tests (SimStruct)
**Tout ce qu'il faut savoir pour la présentation et les questions du jury**

---

## 📅 TABLES DES MATIÈRES
1.  **La Philosophie (Pourquoi on teste)**
2.  **Stratégie Globale (Quoi on teste)**
3.  **Détails par Projet (Comment on teste)**
    *   Backend (Java)
    *   Web (Angular)
    *   IA (Python)
    *   Mobile (Flutter)
4.  **Vocabulaire & Concepts**
5.  **Questions/Réponses du Jury (Q&A)**
6.  **Annexe : Où trouver les preuves (Rapports)**

---

## 1. 🧠 COMPRENDRE LA PHILOSOPHIE

**L'argument "Management" :**
Nous ne testons pas "pour faire plaisir au prof", mais pour **réduire le risque**.
*   **Coût de l'erreur :** Un bug détecté par le développeur coûte 0€. Un bug détecté par le client en production peut coûter des milliers d'euros (perte de confiance, données corrompues).
*   **Assurance Qualité (SQA) :** SonarQube agit comme une "douane". Si le code n'est pas bon, il ne passe pas.

---

## 2. 🎯 STRATÉGIE GLOBALE

Nous utilisons la **Pyramide des Tests** :
1.  **Tests Unitaires (70%)** : On teste chaque brique isolément (rapide).
2.  **Tests d'Intégration (20%)** : On teste que les briques s'emboîtent bien.
3.  **Tests E2E (10%)** : On teste comme un utilisateur humain.

| Projet | Tests Principaux | Outil | Objectif Qualité |
|--------|------------------|-------|------------------|
| **Backend** | Unitaires | JUnit 5 | Logique métier solide |
| **Web** | UI / Composants | Vitest | Interface réactive |
| **IA** | Précision | pytest | Prédictions > 90% |
| **Mobile** | Widgets | flutter_test | Rendu visuel correct |

---

## 3. 🛠️ DÉTAILS PAR PROJET (Technique)

### A. Backend (Spring Boot)
*   **Outils :** `JUnit 5` (Moteur), `Mockito` (Simulateur), `JaCoCo` (Rapporteur).
*   **Technique "Mocking" :** Pour tester le `AuthService`, on ne touche pas la vraie base de données. On "Mock" (simule) le `UserRepository`.
*   **Exemple de code à expliquer :**
    ```java
    // On dit au simulateur : "Si on cherche 'test@email.com', renvoie cet utilisateur fictif"
    when(userRepository.findByEmail("test@email.com")).thenReturn(mockUser);
    
    // On teste la méthode de connexion
    AuthResponse result = authService.login(request);
    
    // On vérifie qu'on a bien reçu un token
    assertNotNull(result.getAccessToken());
    ```

### B. Frontend Web (Angular)
*   **Outils :** `Vitest` (Plus rapide que Karma, standard moderne).
*   **Ce qu'on teste :**
    *   Le clic sur le bouton "Login" appelle-t-il bien le service ?
    *   Si l'API renvoie une erreur, le message d'erreur s'affiche-t-il ?

### C. Modèle IA (Python)
*   **Outils :** `pytest`.
*   **Spécificité :** On ne teste pas que le code ne plante pas, on teste que **le résultat est physiquement cohérent** (ex: une poutre ne peut pas avoir une déflexion négative infinie).

---

## 4. 📚 VOCABULAIRE CLÉ

*   **Mock** : Un objet faux/simulé qui remplace une dépendance réelle (ex: fausse base de données).
*   **Code Coverage (Couverture)** : Le % de votre code qui est exécuté par vos tests.
    *   *SimStruct Backend : 65%* (Excellent score pour un projet étudiant).
    *   *SimStruct Web : 62%*.
*   **Quality Gate** : Les critères stricts de SonarQube. Si Couverture < 60% = ❌ ÉCHEC.
*   **Regression** : Quand une nouveauté casse une vieille fonctionnalité qui marchait avant. Les tests automatiques empêchent ça.

---

## 5. ❓ QUESTIONS DU JURY (Q&A)

**Q1: Pourquoi n'avez-vous pas 100% de couverture ?**
> **Réponse Pro:** "Le 100% est un idéal théorique souvent contre-productif (trop de maintenance). Nous suivons la loi de Pareto : tester les 20% du code qui font 80% du risque (la logique métier critique). Avec 65%, nous sommes au-dessus des standards industriels (souvent 50-60%)."

**Q2: Quelle différence entre Tests Unitaires et Tests d'Intégration ?**
> **Réponse Simple:** "Unitaire = Je teste si la serrure fonctionne. Intégration = Je teste si la clé ouvre la porte."
> **Réponse Technique:** "Unitaire isole la fonction (Mock de la BDD). Intégration teste la chaîne complète (Service + Vraie BDD)."

**Q3: Comment SonarQube vous aide-t-il ?**
> **Réponse:** "C'est un auditeur impartial. Il nous signale les 'Code Smells' (code sale), les duplications et surtout les failles de sécurité potentielles. On ne merge pas si Sonar est rouge."

---

## 6. 📂 ANNEXE : PREUVES ET RAPPORTS

Pour montrer vos résultats lors de la présentation :

**1. Backend (JaCoCo Report)**
*   Ouvrir : `Backend/simstruct-backend/target/site/jacoco/index.html`
*   *Preuve : Tables vertes, couverture 65%.*

**2. Web (LCOV Report)**
*   Ouvrir : `Web/simstruct/coverage/lcov-report/index.html`
*   *Preuve : Liste des composants testés.*

**3. Commandes pour générer les autres rapports :**
```bash
# Pour l'IA
cd Model_AI && pytest --cov=src --cov-report=html

# Pour le Mobile
cd Mobile/simstruct_mobile && flutter test --coverage
```
