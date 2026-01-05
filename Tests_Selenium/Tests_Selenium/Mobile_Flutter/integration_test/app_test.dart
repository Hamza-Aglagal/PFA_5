import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import de l'app principale
// import 'package:simstruct_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SimStruct Mobile - Tests d\'intégration', () {
    
    testWidgets('Test 1: Navigation vers la page de login', (WidgetTester tester) async {
      // Démarrer l'application
      // await app.main();
      await tester.pumpAndSettle();

      // Vérifier que nous sommes sur la page d'accueil
      expect(find.text('SimStruct'), findsOneWidget);

      // Naviguer vers login
      final loginButton = find.text('Se connecter');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Vérifier qu'on est sur la page de login
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email et Password
    });

    testWidgets('Test 2: Login avec credentials valides', (WidgetTester tester) async {
      // await app.main();
      await tester.pumpAndSettle();

      // Naviguer vers login
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      // Remplir le formulaire
      final emailField = find.byKey(const Key('emailField'));
      final passwordField = find.byKey(const Key('passwordField'));
      final loginBtn = find.byKey(const Key('loginButton'));

      await tester.enterText(emailField, 'test@simstruct.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Soumettre
      await tester.tap(loginBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Vérifier la redirection vers le dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('Test 3: Login avec credentials invalides', (WidgetTester tester) async {
      // await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      final emailField = find.byKey(const Key('emailField'));
      final passwordField = find.byKey(const Key('passwordField'));
      final loginBtn = find.byKey(const Key('loginButton'));

      await tester.enterText(emailField, 'wrong@email.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Vérifier le message d'erreur
      expect(find.text('Email ou mot de passe incorrect'), findsOneWidget);
    });

    testWidgets('Test 4: Créer une nouvelle simulation', (WidgetTester tester) async {
      // await app.main();
      await tester.pumpAndSettle();

      // Se connecter d'abord
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('emailField')), 'test@simstruct.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Naviguer vers nouvelle simulation
      final newSimButton = find.byKey(const Key('newSimulationButton'));
      await tester.tap(newSimButton);
      await tester.pumpAndSettle();

      // Remplir le formulaire
      await tester.enterText(
        find.byKey(const Key('simulationNameField')), 
        'Test Flutter Simulation'
      );

      // Ajuster les sliders
      final floorsSlider = find.byKey(const Key('numFloorsSlider'));
      await tester.drag(floorsSlider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Soumettre
      final submitButton = find.byKey(const Key('submitSimulationButton'));
      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Vérifier qu'on est sur la page de résultats
      expect(find.text('Résultats'), findsOneWidget);
      expect(find.byKey(const Key('maxDeflection')), findsOneWidget);
      expect(find.byKey(const Key('maxStress')), findsOneWidget);
    });

    testWidgets('Test 5: Voir l\'historique des simulations', (WidgetTester tester) async {
      // await app.main();
      await tester.pumpAndSettle();

      // Se connecter
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('emailField')), 'test@simstruct.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Naviguer vers l'historique
      final historyTab = find.byIcon(Icons.history);
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Vérifier la présence de la liste
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byKey(const Key('simulationCard')), findsWidgets);
    });

    testWidgets('Test 6: Rechercher dans l\'historique', (WidgetTester tester) async {
      // await app.main();
      await tester.pumpAndSettle();

      // Se connecter et aller à l'historique
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('emailField')), 'test@simstruct.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Utiliser la recherche
      final searchField = find.byKey(const Key('searchField'));
      await tester.enterText(searchField, 'Test');
      await tester.pumpAndSettle();

      // Vérifier que les résultats sont filtrés
      final simulationCards = find.byKey(const Key('simulationCard'));
      expect(simulationCards, findsWidgets);
    });

    testWidgets('Test 7: Supprimer une simulation', (WidgetTester tester) async {
      // await app.main();
      await tester.pumpAndSettle();

      // Se connecter et aller à l'historique
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('emailField')), 'test@simstruct.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Cliquer sur le bouton supprimer
      final deleteButton = find.byKey(const Key('deleteButton')).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Confirmer la suppression
      final confirmButton = find.text('Confirmer');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Vérifier le message de succès
      expect(find.text('Simulation supprimée'), findsOneWidget);
    });

    testWidgets('Test 8: Déconnexion', (WidgetTester tester) async {
      // await app.main();
      await tester.pumpAndSettle();

      // Se connecter
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('emailField')), 'test@simstruct.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Ouvrir le menu
      final menuButton = find.byIcon(Icons.menu);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Cliquer sur déconnexion
      final logoutButton = find.text('Déconnexion');
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      // Vérifier qu'on est de retour à l'accueil
      expect(find.text('SimStruct'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    });
  });
}
