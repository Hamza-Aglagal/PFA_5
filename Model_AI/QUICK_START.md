# 🚀 Guide de Démarrage Rapide - API SimStruct AI

## Étape 1: Démarrer l'API

### Option A: Double-clic sur le fichier batch (le plus simple)
1. Ouvrez le dossier `Model_AI/src`
2. Double-cliquez sur `start_api.bat`
3. Attendez que le message apparaisse: "Application startup complete"

### Option B: Ligne de commande PowerShell
```powershell
cd "Model_AI\src"
..\venv\Scripts\Activate.ps1
uvicorn api:app --reload --host 0.0.0.0 --port 8000
```

L'API sera accessible sur: **http://localhost:8000**

## Étape 2: Vérifier que l'API fonctionne

### Option A: Navigateur web
Ouvrez votre navigateur et allez sur:
- http://localhost:8000/docs (Documentation interactive Swagger)
- http://localhost:8000/health (Test de santé)

### Option B: Script de test
1. Ouvrez un **nouveau** terminal/PowerShell
2. Double-cliquez sur `run_tests.bat`

OU

```powershell
cd "Model_AI\src"
..\venv\Scripts\Activate.ps1
python test_api.py
```

## Étape 3: Faire une prédiction

### Via l'interface Swagger (le plus simple)
1. Allez sur http://localhost:8000/docs
2. Cliquez sur `POST /predict`
3. Cliquez sur "Try it out"
4. Modifiez les valeurs si nécessaire
5. Cliquez sur "Execute"
6. Voir le résultat dans "Response body"

### Via PowerShell
```powershell
.\test_api_manual.ps1
```

### Via curl
```bash
curl -X POST "http://localhost:8000/predict" ^
  -H "Content-Type: application/json" ^
  -d "{\"numFloors\": 10, \"floorHeight\": 3.5, \"numBeams\": 120, \"numColumns\": 36, \"beamSection\": 30, \"columnSection\": 40, \"concreteStrength\": 35, \"steelGrade\": 355, \"windLoad\": 1.5, \"liveLoad\": 3.0, \"deadLoad\": 5.0}"
```

### Via Python
```python
import requests

response = requests.post(
    "http://localhost:8000/predict",
    json={
        "numFloors": 10,
        "floorHeight": 3.5,
        "numBeams": 120,
        "numColumns": 36,
        "beamSection": 30,
        "columnSection": 40,
        "concreteStrength": 35,
        "steelGrade": 355,
        "windLoad": 1.5,
        "liveLoad": 3.0,
        "deadLoad": 5.0
    }
)

print(response.json())
```

## 📁 Fichiers créés

```
Model_AI/
├── src/
│   ├── api.py                      # Code principal de l'API
│   ├── test_api.py                 # Tests automatiques
│   ├── test_api_manual.ps1         # Tests PowerShell
│   ├── start_api.bat               # Démarrer l'API (Windows)
│   └── run_tests.bat               # Lancer les tests (Windows)
├── models/
│   ├── structural_model.pt         # Modèle Deep Learning
│   ├── scalers.pkl                 # Normalisateurs
│   └── model_info.pkl              # Informations du modèle
└── API_README.md                   # Documentation complète
```

## ✅ Checklist de vérification

- [ ] L'API démarre sans erreur
- [ ] http://localhost:8000 affiche la page d'accueil
- [ ] http://localhost:8000/docs affiche la documentation
- [ ] http://localhost:8000/health retourne `"status": "healthy"`
- [ ] POST /predict retourne une prédiction valide

## 🔧 Dépannage

### Problème: "Model not loaded"
- Vérifiez que `models/structural_model.pt` existe
- Vérifiez que `models/scalers.pkl` existe
- Redémarrez l'API

### Problème: "Port 8000 already in use"
Changez le port dans la commande:
```powershell
uvicorn api:app --reload --port 8001
```

### Problème: "Module not found"
Installez les dépendances:
```powershell
pip install fastapi uvicorn requests
```

## 📊 Exemple de résultat

```json
{
  "maxDeflection": -264865.81,
  "maxStress": 42.58,
  "stabilityIndex": 100.31,
  "seismicResistance": 82.54,
  "status": "Excellent"
}
```

## 🎯 Prochaines étapes

1. ✅ Modèle Deep Learning entraîné
2. ✅ API REST créée et testée
3. 🔄 Intégration avec le frontend (Angular)
4. 🔄 Déploiement Docker
5. 🔄 Tests d'intégration complets

## 📞 Besoin d'aide ?

Consultez:
- `API_README.md` - Documentation complète
- http://localhost:8000/docs - Documentation interactive
- `notebooks/02_model_training.ipynb` - Entraînement du modèle
