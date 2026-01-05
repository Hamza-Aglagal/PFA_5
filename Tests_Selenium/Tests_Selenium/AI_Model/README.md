# 🤖 Tests Selenium - AI Model

Tests E2E pour l'API FastAPI du modèle AI.

## 📦 Prérequis

```bash
pip install selenium pytest requests
```

## 🚀 Exécution

```bash
# Démarrer l'API AI
cd ../../Model_AI/src
python api.py

# Dans un autre terminal, exécuter les tests
cd ../../Tests_Selenium/AI_Model
pytest test_ai_selenium.py -v
```

## 📊 Tests Implémentés

- ✅ Test de health check
- ✅ Test des infos du modèle
- ✅ Test de prédiction simple
- ✅ Test de prédictions multiples
- ✅ Test de validation des entrées
- ✅ Test de gestion d'erreurs
