# 📊 Documentation des Tests Selenium

## Vue d'ensemble

Ce dossier contient la documentation et les rapports des tests E2E.

## 📁 Structure

```
Documentation/
├── README.md                    # Ce fichier
├── guides/                      # Guides d'utilisation
│   ├── frontend_testing.md
│   ├── backend_testing.md
│   ├── ai_testing.md
│   └── mobile_testing.md
├── reports/                     # Rapports de tests
│   ├── frontend/
│   ├── backend/
│   ├── ai/
│   └── mobile/
└── screenshots/                 # Captures d'écran des tests
```

## 📈 Métriques de Tests

### Frontend Angular
- **Total tests**: 15
- **Tests d'authentification**: 7
- **Tests de simulation**: 8
- **Couverture**: ~80% des flux utilisateur

### Backend Spring Boot
- **Total tests**: 10
- **Tests API**: 10
- **Couverture**: ~70% des endpoints

### AI Model
- **Total tests**: 12
- **Tests Selenium**: 5
- **Tests API**: 7
- **Couverture**: 100% des endpoints

### Mobile Flutter
- **Total tests**: 8
- **Tests d'intégration**: 8
- **Couverture**: ~75% des écrans

## 🚀 Exécution Complète

```bash
# Script pour exécuter tous les tests
cd Tests_Selenium

# Frontend
cd Frontend_Angular && mvn test && cd ..

# Backend
cd Backend_SpringBoot && mvn test && cd ..

# AI
cd AI_Model && pytest test_ai_selenium.py -v && cd ..

# Mobile
cd Mobile_Flutter && flutter test integration_test/ && cd ..
```

## 📊 Rapports

Les rapports HTML sont générés automatiquement après chaque exécution dans le dossier `reports/`.

## ✅ Checklist de Tests

- [x] Tests d'authentification (login/register)
- [x] Tests de création de simulation
- [x] Tests de visualisation des résultats
- [x] Tests de l'historique
- [x] Tests de recherche et filtrage
- [x] Tests de suppression
- [x] Tests de validation des formulaires
- [x] Tests d'API
- [x] Tests de performance
- [x] Tests de sécurité (JWT)
