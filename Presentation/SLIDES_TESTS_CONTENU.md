# 🧪 PARTIE TESTS & QUALITÉ
**Module détaillé (10-15 slides)**

---

# SLIDE 1: INTRODUCTION

**Titre:** Stratégie d'Assurance Qualité
**Message Clé:** "La qualité n'est pas une option, c'est la fondation."

** Contenu:**
1.  **Tests Unitaires & Intégration** : Validation fonctionnelle.
2.  **Audit Continu (SonarQube)** : Validation technique et sécurité.
3.  **Approche par Composant** : Chaque brique est validée avant assemblage.

> "Notre stratégie repose sur deux piliers : tester le comportement avec des tests unitaires, et surveiller la santé du code avec SonarQube."

---

# SLIDE 2: LE RÔLE DE SONARQUBE (Audit)

**Titre:** Audit Automatisé avec SonarQube

**Pourquoi SonarQube ?**
Il agit comme un auditeur impartial qui analyse le code statique.
*   🚦 **Quality Gate** : C'est notre "Douane". Si ça ne passe pas, on ne livre pas.
*   🛡️ **Règles de Sécurité** : Détection des failles (Injections, XSS).
*   🧹 **Code Smells** : Détection du code "sale" ou dupliqué.

**Nos Critères de Validation (Quality Gate)** :
*   Couverture > 60%
*   Aucune vulnérabilité critique
*   Duplication < 3%

> "Avant même de lancer les tests, SonarQube vérifie si le code respecte nos standards de sécurité et de maintenabilité. C'est notre première ligne de défense."

---

# SLIDE 3: PROJET BACKEND - TEST UNITAIRES

**Titre:** Backend (Java) - Validation Logique

**Outils:**
*   **JUnit 5** : Le moteur de test.
*   **Mockito** : Pour simuler la base de données (Isolation).

**Exemple de Code (Authentification):**
```java
@Test
void testLogin_Success() {
    // 1. Simulation BDD
    when(repo.findByEmail("test@emsi.ma")).thenReturn(user);
    
    // 2. Exécution du Service
    AuthResponse response = authService.login(request);
    
    // 3. Vérification
    assertNotNull(response.getToken());
}
```

> "Sur le Backend, nous utilisons Mockito pour tester la logique pure sans dépendre de la base de données, ce qui rend les tests instantanés."

---

# SLIDE 4: PROJET BACKEND - RÉSULTATS

**Titre:** Backend - Preuves de Qualité

**1. Résultat des Tests (JaCoCo):**
*   **Couverture Globale:** 65% (Objectif atteint ✅)
*   **Sécurité:** 100% couvert

**[INSÉRER SCREENSHOT: Rapport JaCoCo (Tableau vert)]**
*(Montrez le tableau avec les pourcentages verts)*

**2. Audit SonarQube:**
*   **Statut:** ✅ PASSED
*   **Dette Technique:** Faible (A)

**[INSÉRER SCREENSHOT: Dashboard SonarQube Backend]**
*(Celui avec le gros 'Passed' vert et '0 Bugs')*

> "Comme vous le voyez, nous avons atteint 65% de couverture, validant toute la couche sécurité et service. SonarQube confirme qu'il n'y a aucun bug critique."

---

# SLIDE 5: PROJET WEB - VALIDATION UI

**Titre:** Frontend (Angular) - Tests de Composants

**Outils:**
*   **Vitest** : Exécution rapide des tests.
*   **Intégration** : Validation des appels API.

**Exemple de Code (Login Component):**
```typescript
it('doit afficher une erreur si login échoue', () => {
    // Simulation erreur API
    authService.login.mockReturnValue(throwError('Erreur 401'));
    
    // Action clic bouton
    component.onSubmit();
    
    // Vérification affichage erreur
    expect(component.errorMessage).toBe('Identifiants invalides');
});
```

> "Côté Web, nous vérifions que l'interface réagit correctement, par exemple en affichant bien les messages d'erreur à l'utilisateur."

---

# SLIDE 6: PROJET WEB - RÉSULTATS

**Titre:** Web - Métriques Qualité

**1. Résultat des Tests (LCOV):**
*   **Couverture:** > 60%
*   **Composants Validés:** Guards, Services, Pages critiques.

**[INSÉRER SCREENSHOT: Rapport LCOV (Liste fichiers)]**

**2. Audit SonarQube:**
*   **Statut:** ✅ PASSED
*   **Maintenabilité:** Notation A

**[INSÉRER SCREENSHOT: Dashboard SonarQube Web]**

> "Nos tests couvrent majoritairement les services et la sécurité du frontend (Guards). Le code est certifié maintenable par SonarQube."

---

# SLIDE 7: INTELLIGENCE ARTIFICIELLE

**Titre:** Modèle IA - Validation de Précision

**Outils & Stratégie:**
*   **pytest** : Pour les tests unitaires Python.
*   **Validation Physique** : Vérifier que les prédictions sont réalistes.

**Exemple de Test:**
```python
def test_prediction_coherence():
    res = model.predict(poutre_standard)
    # Vérification: La déflexion ne peut pas être négative
    assert res['deflexion'] >= 0  
    # Vérification: Précision > 90%
    assert res['precision'] > 0.90
```

> "Pour l'IA, on teste la cohérence physique. Une poutre ne peut pas avoir une déformation négative. C'est ce que nos tests valident automatiquement."

**[INSÉRER SCREENSHOT: Rapport pytest ou SonarQube Python]**

---

# SLIDE 8: MOBILE (FLUTTER)

**Titre:** Mobile - Tests d'Interface

**Outils:**
*   **flutter_test** : Framework natif.
*   **Widget Testing** : Vérifie que les boutons et champs sont là.

**Exemple de Test:**
```dart
testWidgets('Login Page a un bouton', (tester) async {
  await tester.pumpWidget(LoginPage());
  expect(find.text('Connexion'), findsOneWidget);
});
```

> "Sur le mobile, nous nous assurons qu'aucune mise à jour ne casse l'affichage des écrans principaux."

**[INSÉRER SCREENSHOT: Terminal Resultat Test Flutter]**

---

# SLIDE 9: CONCLUSION

**Titre:** Bilan Qualité Global

**Ce qu'il faut retenir :**
1.  ✅ **4 Projets Sécurisés** (Backend, Web, Mobile, IA).
2.  ✅ **Quality Gate Respecté** partout (Pas de dette technique).
3.  ✅ **Réduction des Risques** grâce aux tests automatiques.

> "En conclusion, SimStruct n'est pas seulement fonctionnel, c'est un produit construit sur des bases saines et durables."
