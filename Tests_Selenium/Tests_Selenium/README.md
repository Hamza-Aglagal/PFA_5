# 🧪 Tests Selenium/E2E - SimStruct

Ce dossier contient tous les tests end-to-end (E2E) pour le projet SimStruct.

## 📁 Structure

```
Tests_Selenium/
├── README.md                    # Ce fichier
├── Frontend_Angular/            # Tests E2E Frontend
├── Backend_SpringBoot/          # Tests d'intégration Backend
├── AI_Model/                    # Tests API AI
├── Mobile_Flutter/              # Tests Flutter
└── Documentation/               # Guides et rapports
```

## 🚀 Technologies Utilisées

| Composant | Framework de Test |
|-----------|-------------------|
| **Frontend Angular** | Selenium WebDriver + Java |
| **Backend Spring Boot** | RestAssured + Selenium |
| **AI Model** | Selenium + Python |
| **Mobile Flutter** | Flutter Integration Tests |

## 📊 Couverture des Tests

- ✅ Tests de navigation
- ✅ Tests de formulaires
- ✅ Tests d'authentification
- ✅ Tests de simulation complète
- ✅ Tests d'API
- ✅ Tests de bout en bout

## 🔧 Installation

Voir les README spécifiques dans chaque dossier.

## 📝 Exécution

```bash
# Frontend
cd Frontend_Angular
mvn test

# Backend
cd Backend_SpringBoot
mvn test

# AI Model
cd AI_Model
python -m pytest

# Mobile
cd Mobile_Flutter
flutter test integration_test/
```

## 📈 Rapports

Les rapports de tests sont générés dans le dossier `Documentation/reports/`
