# 📱 Tests Flutter Integration

Tests d'intégration pour l'application mobile Flutter.

## 📦 Prérequis

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

## 🚀 Exécution

```bash
# Démarrer l'application
cd ../../Mobile/simstruct_mobile
flutter run

# Exécuter les tests d'intégration
flutter test integration_test/
```

## 📊 Tests Implémentés

- ✅ Test de navigation
- ✅ Test d'authentification
- ✅ Test de création de simulation
- ✅ Test de visualisation des résultats
- ✅ Test de l'historique
