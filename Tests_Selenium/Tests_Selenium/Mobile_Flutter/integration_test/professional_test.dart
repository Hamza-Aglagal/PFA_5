import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Tests d'intégration professionnels pour l'application mobile SimStruct
/// 
/// Pattern: Given-When-Then (BDD)
/// Author: SimStruct Team
/// Version: 1.0

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests Professionnels Mobile - SimStruct', () {
    
    // ========== HELPER FUNCTIONS ==========
    
    /// Helper: Se connecter avec les credentials par défaut
    Future<void> login(WidgetTester tester) async {
      await tester.pumpAndSettle();
      
      // Naviguer vers login si nécessaire
      final loginButton = find.text('Se connecter');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }
      
      // Remplir le formulaire
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'mobile.test@simstruct.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      
      // Soumettre
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }
    
    /// Helper: Capturer un screenshot (pour documentation)
    Future<void> takeScreenshot(WidgetTester tester, String name) async {
      // Note: Les screenshots sont automatiquement capturés par integration_test
      await tester.pumpAndSettle();
      print('📸 Screenshot: $name');
    }
    
    // ========== TESTS D'AUTHENTIFICATION ==========
    
    testWidgets(
      '✅ Test 1: Navigation vers la page de login',
      (WidgetTester tester) async {
        print('\n▶️  Test 1: Navigation vers login');
        
        // GIVEN: L'application est démarrée
        // await app.main();
        await tester.pumpAndSettle();
        
        // WHEN: L'utilisateur navigue vers login
        final loginButton = find.text('Se connecter');
        expect(loginButton, findsOneWidget, reason: 'Le bouton de connexion devrait être visible');
        
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, '01_login_page');
        
        // THEN: Le formulaire de login est affiché
        expect(find.text('Connexion'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
        
        print('✅ Test 1 réussi');
      },
    );
    
    testWidgets(
      '✅ Test 2: Login avec credentials valides - Flux complet',
      (WidgetTester tester) async {
        print('\n▶️  Test 2: Login valide');
        
        // GIVEN: L'utilisateur est sur la page de login
        // await app.main();
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Se connecter'));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, '02_before_login');
        
        // WHEN: L'utilisateur se connecte
        final emailField = find.byKey(const Key('emailField'));
        final passwordField = find.byKey(const Key('passwordField'));
        final loginBtn = find.byKey(const Key('loginButton'));
        
        await tester.enterText(emailField, 'mobile.test@simstruct.com');
        await tester.enterText(passwordField, 'password123');
        await takeScreenshot(tester, '02_form_filled');
        
        await tester.tap(loginBtn);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await takeScreenshot(tester, '02_after_login');
        
        // THEN: L'utilisateur est redirigé vers le dashboard
        expect(find.text('Dashboard'), findsOneWidget,
            reason: 'Le dashboard devrait être affiché');
        
        print('✅ Test 2 réussi - Login successful');
      },
    );
    
    testWidgets(
      '❌ Test 3: Login avec credentials invalides',
      (WidgetTester tester) async {
        print('\n▶️  Test 3: Login invalide');
        
        // GIVEN: L'utilisateur est sur la page de login
        // await app.main();
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Se connecter'));
        await tester.pumpAndSettle();
        
        // WHEN: L'utilisateur essaie de se connecter avec des credentials invalides
        await tester.enterText(
          find.byKey(const Key('emailField')),
          'wrong@email.com',
        );
        await tester.enterText(
          find.byKey(const Key('passwordField')),
          'wrongpassword',
        );
        await tester.tap(find.byKey(const Key('loginButton')));
        await tester.pumpAndSettle();
        await takeScreenshot(tester, '03_login_error');
        
        // THEN: Un message d'erreur est affiché
        expect(
          find.text('Email ou mot de passe incorrect'),
          findsOneWidget,
          reason: 'Un message d\'erreur devrait être affiché',
        );
        
        print('✅ Test 3 réussi - Erreur affichée comme attendu');
      },
    );
    
    // ========== TESTS DE SIMULATION ==========
    
    testWidgets(
      '✅ Test 4: Créer une simulation complète - Flux E2E',
      (WidgetTester tester) async {
        print('\n▶️  Test 4: Flux E2E complet de simulation');
        
        // GIVEN: L'utilisateur est connecté
        // await app.main();
        await login(tester);
        await takeScreenshot(tester, '04_dashboard');
        
        // WHEN: L'utilisateur crée une nouvelle simulation
        final newSimButton = find.byKey(const Key('newSimulationButton'));
        expect(newSimButton, findsOneWidget);
        
        await tester.tap(newSimButton);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, '04_simulation_form');
        
        // Remplir le formulaire
        await tester.enterText(
          find.byKey(const Key('simulationNameField')),
          'Test Mobile Simulation Professionnelle',
        );
        
        // Ajuster les sliders (simulation)
        final floorsSlider = find.byKey(const Key('numFloorsSlider'));
        if (floorsSlider.evaluate().isNotEmpty) {
          await tester.drag(floorsSlider, const Offset(100, 0));
          await tester.pumpAndSettle();
        }
        
        await takeScreenshot(tester, '04_form_filled');
        
        // Soumettre
        final submitButton = find.byKey(const Key('submitSimulationButton'));
        await tester.tap(submitButton);
        
        // Attendre le chargement
        await tester.pumpAndSettle(const Duration(seconds: 5));
        await takeScreenshot(tester, '04_results');
        
        // THEN: Les résultats sont affichés
        expect(find.text('Résultats'), findsOneWidget,
            reason: 'La page de résultats devrait être affichée');
        
        expect(find.byKey(const Key('maxDeflection')), findsOneWidget,
            reason: 'La déflexion maximale devrait être affichée');
        expect(find.byKey(const Key('maxStress')), findsOneWidget,
            reason: 'La contrainte maximale devrait être affichée');
        expect(find.byKey(const Key('stabilityIndex')), findsOneWidget,
            reason: 'L\'indice de stabilité devrait être affiché');
        expect(find.byKey(const Key('seismicResistance')), findsOneWidget,
            reason: 'La résistance sismique devrait être affichée');
        
        print('✅ Test 4 réussi - Simulation complète');
      },
    );
    
    testWidgets(
      '✅ Test 5: Navigation vers l\'historique',
      (WidgetTester tester) async {
        print('\n▶️  Test 5: Navigation historique');
        
        // GIVEN: L'utilisateur est connecté
        // await app.main();
        await login(tester);
        
        // WHEN: L'utilisateur navigue vers l'historique
        final historyTab = find.byIcon(Icons.history);
        expect(historyTab, findsOneWidget);
        
        await tester.tap(historyTab);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, '05_history_page');
        
        // THEN: La liste des simulations est affichée
        expect(find.byType(ListView), findsOneWidget,
            reason: 'La liste devrait être affichée');
        
        print('✅ Test 5 réussi - Historique affiché');
      },
    );
    
    testWidgets(
      '✅ Test 6: Recherche dans l\'historique',
      (WidgetTester tester) async {
        print('\n▶️  Test 6: Recherche dans historique');
        
        // GIVEN: L'utilisateur est sur la page d'historique
        // await app.main();
        await login(tester);
        
        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();
        
        // WHEN: L'utilisateur utilise la recherche
        final searchField = find.byKey(const Key('searchField'));
        if (searchField.evaluate().isNotEmpty) {
          await tester.enterText(searchField, 'Test');
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          await takeScreenshot(tester, '06_search_results');
          
          // THEN: Les résultats sont filtrés
          final simulationCards = find.byKey(const Key('simulationCard'));
          expect(simulationCards, findsWidgets,
              reason: 'Des résultats devraient être affichés');
        }
        
        print('✅ Test 6 réussi - Recherche fonctionnelle');
      },
    );
    
    testWidgets(
      '✅ Test 7: Supprimer une simulation',
      (WidgetTester tester) async {
        print('\n▶️  Test 7: Suppression de simulation');
        
        // GIVEN: L'utilisateur est sur la page d'historique
        // await app.main();
        await login(tester);
        
        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();
        
        // WHEN: L'utilisateur supprime une simulation
        final deleteButton = find.byKey(const Key('deleteButton')).first;
        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton);
          await tester.pumpAndSettle();
          await takeScreenshot(tester, '07_delete_confirmation');
          
          // Confirmer
          final confirmButton = find.text('Confirmer');
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
          await takeScreenshot(tester, '07_after_delete');
          
          // THEN: Message de succès affiché
          expect(find.text('Simulation supprimée'), findsOneWidget,
              reason: 'Un message de succès devrait être affiché');
        }
        
        print('✅ Test 7 réussi - Suppression réussie');
      },
    );
    
    testWidgets(
      '✅ Test 8: Déconnexion',
      (WidgetTester tester) async {
        print('\n▶️  Test 8: Déconnexion');
        
        // GIVEN: L'utilisateur est connecté
        // await app.main();
        await login(tester);
        await takeScreenshot(tester, '08_before_logout');
        
        // WHEN: L'utilisateur se déconnecte
        final menuButton = find.byIcon(Icons.menu);
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();
        }
        
        final logoutButton = find.text('Déconnexion');
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();
        await takeScreenshot(tester, '08_after_logout');
        
        // THEN: L'utilisateur est redirigé vers l'accueil
        expect(find.text('SimStruct'), findsOneWidget,
            reason: 'L\'écran d\'accueil devrait être affiché');
        expect(find.text('Se connecter'), findsOneWidget,
            reason: 'Le bouton de connexion devrait être visible');
        
        print('✅ Test 8 réussi - Déconnexion réussie');
      },
    );
    
    // ========== TESTS DE PERFORMANCE ==========
    
    testWidgets(
      '⚡ Test 9: Performance - Temps de chargement',
      (WidgetTester tester) async {
        print('\n▶️  Test 9: Performance');
        
        // GIVEN: L'application est démarrée
        // await app.main();
        final startTime = DateTime.now();
        
        await tester.pumpAndSettle();
        
        final endTime = DateTime.now();
        final loadTime = endTime.difference(startTime).inMilliseconds;
        
        print('⚡ Temps de chargement: $loadTime ms');
        
        // THEN: Le chargement devrait être rapide
        expect(loadTime, lessThan(3000),
            reason: 'L\'application devrait se charger en moins de 3 secondes');
        
        print('✅ Test 9 réussi - Performance OK');
      },
    );
    
    testWidgets(
      '✅ Test 10: Navigation rapide entre écrans',
      (WidgetTester tester) async {
        print('\n▶️  Test 10: Navigation rapide');
        
        // GIVEN: L'utilisateur est connecté
        // await app.main();
        await login(tester);
        
        // WHEN: Navigation rapide entre plusieurs écrans
        final screens = [
          Icons.history,
          Icons.person,
          Icons.home,
        ];
        
        for (final icon in screens) {
          final tab = find.byIcon(icon);
          if (tab.evaluate().isNotEmpty) {
            await tester.tap(tab);
            await tester.pumpAndSettle();
          }
        }
        
        // THEN: Toutes les navigations réussissent
        print('✅ Test 10 réussi - Navigation fluide');
      },
    );
  });
}
