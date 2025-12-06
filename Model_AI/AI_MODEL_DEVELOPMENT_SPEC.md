# 🧠 Spécification Complète du Modèle IA Deep Learning
## Simulation de Stabilité des Structures Civiles

**Document destiné au développeur du modèle IA**  
**Version:** 1.0  
**Date:** 25 novembre 2025  
**Projet:** PFA - École Supérieure d'Ingénierie

---

## 📋 Table des Matières

1. [Contexte et Objectifs](#1-contexte-et-objectifs)
2. [Spécifications Techniques](#2-spécifications-techniques)
3. [Données d'Entrée (Features)](#3-données-dentrée-features)
4. [Sorties du Modèle (Targets)](#4-sorties-du-modèle-targets)
5. [Architecture du Modèle Recommandée](#5-architecture-du-modèle-recommandée)
6. [Dataset et Génération de Données](#6-dataset-et-génération-de-données)
7. [Pipeline d'Entraînement](#7-pipeline-dentraînement)
8. [API d'Inférence (FastAPI)](#8-api-dinférence-fastapi)
9. [Critères de Performance](#9-critères-de-performance)
10. [Livrables Attendus](#10-livrables-attendus)
11. [Ressources et Références](#11-ressources-et-références)

---

## 1. Contexte et Objectifs

### 1.1 Problématique
Les méthodes classiques d'analyse structurelle (Méthode des Éléments Finis - FEM) sont:
- Coûteuses en temps de calcul (minutes à heures)
- Nécessitent des logiciels spécialisés (ANSYS, ABAQUS, SAP2000)
- Requièrent une expertise avancée

### 1.2 Objectif du Modèle IA
Développer un modèle de Deep Learning capable de:
- **Prédire la stabilité** d'une structure civile (STABLE/WARNING/UNSTABLE)
- **Estimer les contraintes maximales** (stress en MPa)
- **Calculer les déformations** (déplacement en mm)
- **Fournir un facteur de sécurité** (Safety Factor)
- **Temps de réponse < 3 secondes** (vs minutes/heures pour FEM)

### 1.3 Cas d'Usage
Application mobile/web pour ingénieurs et étudiants en génie civil permettant:
- Saisie des paramètres structurels via formulaire guidé
- Simulation instantanée côté serveur
- Visualisation 3D des résultats
- Export PDF des rapports

---

## 2. Spécifications Techniques

### 2.1 Stack Technologique Requis

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Langage | Python | 3.10+ |
| Framework IA | PyTorch | 2.0+ |
| API REST | FastAPI | 0.100+ |
| Gestion modèles | MLflow | 2.0+ |
| Conteneurisation | Docker | latest |
| GPU (optionnel) | CUDA | 11.8+ |

### 2.2 Environnement de Développement

```bash
# Créer l'environnement virtuel
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou: .\venv\Scripts\activate  # Windows

# Dépendances à installer
pip install torch torchvision
pip install fastapi uvicorn
pip install numpy pandas scikit-learn
pip install mlflow dvc
pip install pytest pytest-cov
pip install pydantic
```

### 2.3 Structure de Projet Recommandée

```
Model_AI/
├── README.md
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .env.example
│
├── data/
│   ├── raw/                  # Données brutes FEM
│   ├── processed/            # Données prétraitées
│   ├── train/
│   ├── validation/
│   └── test/
│
├── src/
│   ├── __init__.py
│   ├── config.py             # Configuration
│   ├── preprocessing/
│   │   ├── __init__.py
│   │   ├── normalizer.py     # Normalisation des entrées
│   │   └── feature_engineering.py
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   ├── base_model.py     # Classe de base
│   │   ├── stability_predictor.py
│   │   └── stress_regressor.py
│   │
│   ├── training/
│   │   ├── __init__.py
│   │   ├── trainer.py
│   │   ├── loss_functions.py
│   │   └── metrics.py
│   │
│   └── inference/
│       ├── __init__.py
│       └── predictor.py
│
├── api/
│   ├── __init__.py
│   ├── main.py               # FastAPI app
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── predict.py
│   │   └── health.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── input_schema.py
│   │   └── output_schema.py
│   └── middleware/
│       └── logging.py
│
├── tests/
│   ├── __init__.py
│   ├── test_model.py
│   ├── test_api.py
│   └── test_preprocessing.py
│
├── notebooks/
│   ├── 01_data_exploration.ipynb
│   ├── 02_model_training.ipynb
│   └── 03_evaluation.ipynb
│
├── models/
│   └── best_model.pt         # Modèle exporté
│
└── scripts/
    ├── train.py
    ├── evaluate.py
    └── generate_dataset.py
```

---

## 3. Données d'Entrée (Features)

### 3.1 Types de Structures Supportés

| Type | Valeur | Description |
|------|--------|-------------|
| Poutre | `BEAM` | Élément horizontal simple |
| Pont | `BRIDGE` | Structure de franchissement |
| Bâtiment | `BUILDING` | Structure multi-étages |
| Colonne | `COLUMN` | Élément vertical porteur |
| Treillis | `TRUSS` | Structure triangulée |

**Encodage recommandé:** One-Hot Encoding (5 dimensions)

### 3.2 Paramètres Géométriques (Dimensions)

| Paramètre | Type | Unité | Plage Valide | Description |
|-----------|------|-------|--------------|-------------|
| `length` | float | m | 0.1 - 100.0 | Longueur de la structure |
| `width` | float | m | 0.1 - 50.0 | Largeur de la structure |
| `height` | float | m | 0.1 - 100.0 | Hauteur de la structure |
| `thickness` | float | m | 0.01 - 1.0 | Épaisseur (optionnel) |

**Valeurs typiques du dataset:**
- Longueur: 2.0 - 50.0 m
- Largeur: 0.2 - 15.0 m
- Hauteur: 0.3 - 30.0 m
- Épaisseur: 0.01 - 0.5 m

### 3.3 Propriétés des Matériaux

| Paramètre | Type | Unité | Plage Valide | Description |
|-----------|------|-------|--------------|-------------|
| `material_type` | string | - | voir tableau | Type de matériau |
| `youngs_modulus` | float | MPa | 1,000 - 250,000 | Module d'Young (E) |
| `poissons_ratio` | float | - | 0.0 - 0.5 | Coefficient de Poisson (ν) |
| `density` | float | kg/m³ | 400 - 8,000 | Masse volumique (ρ) |
| `yield_strength` | float | MPa | 10 - 500 | Limite élastique (σy) |

**Matériaux Prédéfinis:**

| Matériau | E (MPa) | ν | ρ (kg/m³) | σy (MPa) |
|----------|---------|---|-----------|----------|
| Acier S235 | 210,000 | 0.30 | 7,850 | 235 |
| Acier S355 | 210,000 | 0.30 | 7,850 | 355 |
| Béton C25/30 | 31,000 | 0.20 | 2,400 | 25 |
| Béton C30/37 | 33,000 | 0.20 | 2,400 | 30 |
| Bois (Sapin) | 11,000 | 0.30 | 450 | 40 |
| Aluminium | 70,000 | 0.33 | 2,700 | 280 |

**Encodage recommandé:** 
- `material_type`: One-Hot Encoding ou Embedding (6+ catégories)
- Propriétés numériques: Normalisation Min-Max ou Z-Score

### 3.4 Paramètres de Chargement

| Paramètre | Type | Unité | Plage Valide | Description |
|-----------|------|-------|--------------|-------------|
| `dead_load` | float | kN | 0 - 10,000 | Charges permanentes (poids propre) |
| `live_load` | float | kN | 0 - 5,000 | Charges d'exploitation |
| `wind_load` | float | kN | 0 - 500 | Charges de vent (latéral) |
| `seismic_load` | float | kN | 0 - 1,000 | Charges sismiques |
| `distribution_type` | string | - | voir ci-dessous | Type de distribution |

**Types de distribution:**
- `uniform`: Charge uniformément répartie
- `concentrated`: Charge ponctuelle
- `distributed`: Charge linéairement répartie

### 3.5 Conditions aux Limites (Appuis)

| Type d'Appui | Valeur | DDL Bloqués | Description |
|--------------|--------|-------------|-------------|
| Encastré | `fixed` | x, y, z, rx, ry, rz | Tous les DDL bloqués |
| Articulé | `pinned` | x, y, z | Translations bloquées |
| Rouleau | `roller` | y ou z | 1 translation bloquée |
| Libre | `free` | aucun | Aucune contrainte |

**Configurations courantes:**
- `fixed-fixed`: Encastré aux deux extrémités
- `fixed-free`: Console (cantilever)
- `pinned-pinned`: Appui simple aux deux extrémités
- `fixed-pinned`: Encastré-articulé

**Encodage recommandé:** One-Hot Encoding (4 catégories)

---

## 4. Sorties du Modèle (Targets)

### 4.1 Sorties Principales

| Sortie | Type | Unité | Plage | Description |
|--------|------|-------|-------|-------------|
| `stability` | catégoriel | - | 3 classes | Verdict de stabilité |
| `max_stress` | float | MPa | 0 - 500+ | Contrainte maximale (Von Mises) |
| `max_deformation` | float | mm | 0 - 500+ | Déplacement maximal |
| `safety_factor` | float | - | 0.5 - 10+ | Facteur de sécurité |
| `ai_confidence` | float | - | 0.0 - 1.0 | Confiance de la prédiction |

### 4.2 Classification de Stabilité

| Classe | Label | Condition | Description |
|--------|-------|-----------|-------------|
| 0 | `STABLE` | SF > 2.5 | Structure sûre |
| 1 | `WARNING` | 1.5 < SF ≤ 2.5 | Attention requise |
| 2 | `UNSTABLE` | SF ≤ 1.5 | Structure à risque |

**Formule du Safety Factor:**
$$SF = \frac{\sigma_y}{\sigma_{max}}$$

Où:
- $\sigma_y$ = Limite élastique du matériau (Yield Strength)
- $\sigma_{max}$ = Contrainte maximale calculée

### 4.3 Sorties Secondaires (Optionnelles)

| Sortie | Type | Description |
|--------|------|-------------|
| `stress_distribution` | array[float] | Distribution des contraintes (N points) |
| `deformation_data` | array[float] | Déformations aux nœuds (N points) |
| `critical_points` | array[object] | Points critiques avec coordonnées |
| `recommendations` | array[string] | Recommandations textuelles |

---

## 5. Architecture du Modèle Recommandée

### 5.1 Approche Multi-Tâches (Recommandée)

```
                    ┌─────────────────┐
                    │   Input Layer   │
                    │  (N features)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Shared Layers  │
                    │   (FC + ReLU)   │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
   ┌─────▼─────┐      ┌──────▼──────┐     ┌──────▼──────┐
   │ Stability │      │    Stress   │     │ Deformation │
   │  Branch   │      │   Branch    │     │   Branch    │
   │ (Classif) │      │ (Regression)│     │ (Regression)│
   └─────┬─────┘      └──────┬──────┘     └──────┬──────┘
         │                   │                   │
   ┌─────▼─────┐      ┌──────▼──────┐     ┌──────▼──────┐
   │  Softmax  │      │   Linear    │     │   Linear    │
   │ (3 class) │      │   Output    │     │   Output    │
   └───────────┘      └─────────────┘     └─────────────┘
```

### 5.2 Architecture Détaillée (PyTorch)

```python
import torch
import torch.nn as nn

class StructuralStabilityModel(nn.Module):
    def __init__(self, input_dim, hidden_dims=[256, 128, 64], dropout=0.3):
        super().__init__()
        
        # Shared Feature Extractor
        layers = []
        prev_dim = input_dim
        for hidden_dim in hidden_dims:
            layers.extend([
                nn.Linear(prev_dim, hidden_dim),
                nn.BatchNorm1d(hidden_dim),
                nn.ReLU(),
                nn.Dropout(dropout)
            ])
            prev_dim = hidden_dim
        self.shared = nn.Sequential(*layers)
        
        # Stability Classification Head (3 classes)
        self.stability_head = nn.Sequential(
            nn.Linear(hidden_dims[-1], 32),
            nn.ReLU(),
            nn.Linear(32, 3)  # STABLE, WARNING, UNSTABLE
        )
        
        # Stress Regression Head
        self.stress_head = nn.Sequential(
            nn.Linear(hidden_dims[-1], 32),
            nn.ReLU(),
            nn.Linear(32, 1)  # max_stress (MPa)
        )
        
        # Deformation Regression Head
        self.deformation_head = nn.Sequential(
            nn.Linear(hidden_dims[-1], 32),
            nn.ReLU(),
            nn.Linear(32, 1)  # max_deformation (mm)
        )
        
        # Safety Factor Regression Head
        self.safety_head = nn.Sequential(
            nn.Linear(hidden_dims[-1], 32),
            nn.ReLU(),
            nn.Linear(32, 1)  # safety_factor
        )
    
    def forward(self, x):
        # Shared features
        features = self.shared(x)
        
        # Task-specific outputs
        stability_logits = self.stability_head(features)
        max_stress = torch.relu(self.stress_head(features))  # Stress >= 0
        max_deformation = torch.relu(self.deformation_head(features))  # Deformation >= 0
        safety_factor = torch.relu(self.safety_head(features)) + 0.5  # SF >= 0.5
        
        return {
            'stability': stability_logits,
            'max_stress': max_stress,
            'max_deformation': max_deformation,
            'safety_factor': safety_factor
        }
```

### 5.3 Fonction de Perte Multi-Tâches

```python
class MultiTaskLoss(nn.Module):
    def __init__(self, classification_weight=1.0, regression_weight=1.0):
        super().__init__()
        self.ce_loss = nn.CrossEntropyLoss()
        self.mse_loss = nn.MSELoss()
        self.cls_w = classification_weight
        self.reg_w = regression_weight
    
    def forward(self, outputs, targets):
        # Classification loss
        stability_loss = self.ce_loss(outputs['stability'], targets['stability'])
        
        # Regression losses
        stress_loss = self.mse_loss(outputs['max_stress'], targets['max_stress'])
        deform_loss = self.mse_loss(outputs['max_deformation'], targets['max_deformation'])
        safety_loss = self.mse_loss(outputs['safety_factor'], targets['safety_factor'])
        
        # Total loss
        total_loss = (
            self.cls_w * stability_loss +
            self.reg_w * (stress_loss + deform_loss + safety_loss)
        )
        
        return {
            'total': total_loss,
            'stability': stability_loss,
            'stress': stress_loss,
            'deformation': deform_loss,
            'safety': safety_loss
        }
```

---

## 6. Dataset et Génération de Données

### 6.1 Source des Données

Les données doivent être générées via des simulations FEM (Éléments Finis). Options:

| Outil | Licence | Recommandation |
|-------|---------|----------------|
| **OpenSees** | Open Source | ⭐ Recommandé (gratuit, Python API) |
| **FEniCS** | Open Source | Bon pour structures simples |
| **ANSYS** | Commercial | Si disponible |
| **ABAQUS** | Commercial | Si disponible |

### 6.2 Script de Génération de Données

```python
# scripts/generate_dataset.py
import numpy as np
import pandas as pd
from openseespy.opensees import *
import random

def generate_beam_simulation(params):
    """
    Génère une simulation FEM pour une poutre simple.
    Retourne les résultats (stress, deformation, stability).
    """
    wipe()
    model('basic', '-ndm', 2, '-ndf', 3)
    
    # Paramètres
    L = params['length']
    W = params['width']
    H = params['height']
    E = params['youngs_modulus'] * 1e6  # MPa to Pa
    nu = params['poissons_ratio']
    rho = params['density']
    P = params['total_load'] * 1000  # kN to N
    
    # Calcul section
    A = W * H
    I = W * H**3 / 12
    
    # Nœuds
    node(1, 0.0, 0.0)
    node(2, L, 0.0)
    
    # Conditions aux limites
    if params['support_type'] == 'fixed-fixed':
        fix(1, 1, 1, 1)
        fix(2, 1, 1, 1)
    elif params['support_type'] == 'pinned-pinned':
        fix(1, 1, 1, 0)
        fix(2, 0, 1, 0)
    elif params['support_type'] == 'fixed-free':
        fix(1, 1, 1, 1)
    
    # Matériau élastique
    uniaxialMaterial('Elastic', 1, E)
    
    # Section
    section('Elastic', 1, E, A, I)
    
    # Élément
    geomTransf('Linear', 1)
    element('elasticBeamColumn', 1, 1, 2, A, E, I, 1)
    
    # Chargement
    timeSeries('Linear', 1)
    pattern('Plain', 1, 1)
    load(2, 0.0, -P, 0.0)
    
    # Analyse
    system('BandGeneral')
    numberer('Plain')
    constraints('Plain')
    integrator('LoadControl', 1.0)
    algorithm('Linear')
    analysis('Static')
    analyze(1)
    
    # Résultats
    disp = nodeDisp(2, 2)  # Déplacement vertical
    reactions = nodeReaction(1)
    
    # Calcul contrainte maximale (poutre simplement chargée)
    M_max = P * L / 4 if params['support_type'] == 'pinned-pinned' else P * L
    sigma_max = M_max * (H/2) / I / 1e6  # Convertir en MPa
    
    # Safety Factor
    sigma_y = params.get('yield_strength', 235)  # MPa
    safety_factor = sigma_y / abs(sigma_max) if sigma_max != 0 else 10
    
    # Stabilité
    if safety_factor > 2.5:
        stability = 'STABLE'
    elif safety_factor > 1.5:
        stability = 'WARNING'
    else:
        stability = 'UNSTABLE'
    
    wipe()
    
    return {
        'max_stress': abs(sigma_max),
        'max_deformation': abs(disp) * 1000,  # m to mm
        'safety_factor': min(safety_factor, 10),
        'stability': stability
    }

def generate_dataset(n_samples=10000):
    """Génère un dataset de simulations."""
    data = []
    
    structure_types = ['BEAM', 'COLUMN', 'BRIDGE', 'TRUSS', 'BUILDING']
    materials = {
        'STEEL_S235': {'E': 210000, 'nu': 0.3, 'rho': 7850, 'sigma_y': 235},
        'STEEL_S355': {'E': 210000, 'nu': 0.3, 'rho': 7850, 'sigma_y': 355},
        'CONCRETE_C25': {'E': 31000, 'nu': 0.2, 'rho': 2400, 'sigma_y': 25},
        'CONCRETE_C30': {'E': 33000, 'nu': 0.2, 'rho': 2400, 'sigma_y': 30},
        'WOOD': {'E': 11000, 'nu': 0.3, 'rho': 450, 'sigma_y': 40},
        'ALUMINUM': {'E': 70000, 'nu': 0.33, 'rho': 2700, 'sigma_y': 280},
    }
    support_types = ['fixed-fixed', 'pinned-pinned', 'fixed-free', 'fixed-pinned']
    
    for i in range(n_samples):
        # Génération aléatoire des paramètres
        struct_type = random.choice(structure_types)
        material_name = random.choice(list(materials.keys()))
        material = materials[material_name]
        
        params = {
            'structure_type': struct_type,
            'material_type': material_name,
            'length': np.random.uniform(2.0, 50.0),
            'width': np.random.uniform(0.2, 2.0),
            'height': np.random.uniform(0.3, 3.0),
            'thickness': np.random.uniform(0.01, 0.5),
            'youngs_modulus': material['E'],
            'poissons_ratio': material['nu'],
            'density': material['rho'],
            'yield_strength': material['sigma_y'],
            'dead_load': np.random.uniform(5, 500),
            'live_load': np.random.uniform(2, 300),
            'wind_load': np.random.uniform(0, 80),
            'seismic_load': np.random.uniform(0, 120),
            'support_type': random.choice(support_types),
            'distribution_type': random.choice(['uniform', 'concentrated', 'distributed']),
        }
        
        params['total_load'] = params['dead_load'] + params['live_load']
        
        try:
            results = generate_beam_simulation(params)
            params.update(results)
            data.append(params)
        except Exception as e:
            print(f"Erreur simulation {i}: {e}")
            continue
        
        if (i + 1) % 1000 == 0:
            print(f"Généré {i + 1}/{n_samples} échantillons")
    
    df = pd.DataFrame(data)
    return df

if __name__ == '__main__':
    print("Génération du dataset...")
    df = generate_dataset(n_samples=50000)
    
    # Sauvegarde
    df.to_csv('data/raw/fem_simulations.csv', index=False)
    print(f"Dataset sauvegardé: {len(df)} échantillons")
    
    # Statistiques
    print("\n=== Statistiques ===")
    print(df.describe())
    print(f"\nDistribution stabilité:\n{df['stability'].value_counts()}")
```

### 6.3 Taille Recommandée du Dataset

| Type | Quantité | Usage |
|------|----------|-------|
| Training | 40,000 | 80% |
| Validation | 5,000 | 10% |
| Test | 5,000 | 10% |
| **Total** | **50,000** | |

### 6.4 Équilibrage des Classes

Pour la classification de stabilité, assurer une distribution équilibrée:
- STABLE: ~40%
- WARNING: ~35%
- UNSTABLE: ~25%

Utiliser des techniques de:
- Oversampling (SMOTE)
- Undersampling
- Class weights dans la loss function

---

## 7. Pipeline d'Entraînement

### 7.1 Prétraitement des Données

```python
# src/preprocessing/normalizer.py
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder
import joblib

class DataPreprocessor:
    def __init__(self):
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()
        self.structure_encoder = OneHotEncoder(sparse=False, handle_unknown='ignore')
        self.material_encoder = OneHotEncoder(sparse=False, handle_unknown='ignore')
        self.support_encoder = OneHotEncoder(sparse=False, handle_unknown='ignore')
        
    def fit(self, df):
        # Colonnes numériques
        numeric_cols = [
            'length', 'width', 'height', 'thickness',
            'youngs_modulus', 'poissons_ratio', 'density', 'yield_strength',
            'dead_load', 'live_load', 'wind_load', 'seismic_load'
        ]
        
        self.scaler.fit(df[numeric_cols])
        
        # Colonnes catégorielles
        self.structure_encoder.fit(df[['structure_type']])
        self.material_encoder.fit(df[['material_type']])
        self.support_encoder.fit(df[['support_type']])
        
        # Labels
        self.label_encoder.fit(['STABLE', 'WARNING', 'UNSTABLE'])
        
        return self
    
    def transform(self, df):
        # Numériques
        numeric_cols = [
            'length', 'width', 'height', 'thickness',
            'youngs_modulus', 'poissons_ratio', 'density', 'yield_strength',
            'dead_load', 'live_load', 'wind_load', 'seismic_load'
        ]
        numeric_features = self.scaler.transform(df[numeric_cols])
        
        # Catégorielles (One-Hot)
        structure_features = self.structure_encoder.transform(df[['structure_type']])
        material_features = self.material_encoder.transform(df[['material_type']])
        support_features = self.support_encoder.transform(df[['support_type']])
        
        # Concaténation
        X = np.hstack([
            numeric_features,
            structure_features,
            material_features,
            support_features
        ])
        
        return X
    
    def transform_labels(self, df):
        return self.label_encoder.transform(df['stability'])
    
    def save(self, path):
        joblib.dump(self, path)
    
    @staticmethod
    def load(path):
        return joblib.load(path)
```

### 7.2 Script d'Entraînement Complet

```python
# scripts/train.py
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
import mlflow
import mlflow.pytorch

from src.models.stability_predictor import StructuralStabilityModel
from src.preprocessing.normalizer import DataPreprocessor
from src.training.loss_functions import MultiTaskLoss

def train():
    # Configuration
    config = {
        'batch_size': 64,
        'epochs': 100,
        'learning_rate': 1e-3,
        'hidden_dims': [256, 128, 64],
        'dropout': 0.3,
        'early_stopping_patience': 10
    }
    
    # MLflow tracking
    mlflow.set_experiment("structural-stability")
    
    with mlflow.start_run():
        mlflow.log_params(config)
        
        # Chargement données
        df = pd.read_csv('data/raw/fem_simulations.csv')
        
        # Prétraitement
        preprocessor = DataPreprocessor()
        preprocessor.fit(df)
        X = preprocessor.transform(df)
        y_stability = preprocessor.transform_labels(df)
        y_stress = df['max_stress'].values
        y_deformation = df['max_deformation'].values
        y_safety = df['safety_factor'].values
        
        # Split
        X_train, X_temp, y_stab_train, y_stab_temp = train_test_split(
            X, y_stability, test_size=0.2, stratify=y_stability, random_state=42
        )
        X_val, X_test, y_stab_val, y_stab_test = train_test_split(
            X_temp, y_stab_temp, test_size=0.5, stratify=y_stab_temp, random_state=42
        )
        
        # Tensors
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        
        train_dataset = TensorDataset(
            torch.FloatTensor(X_train),
            torch.LongTensor(y_stab_train),
            torch.FloatTensor(y_stress[:len(X_train)]).unsqueeze(1),
            torch.FloatTensor(y_deformation[:len(X_train)]).unsqueeze(1),
            torch.FloatTensor(y_safety[:len(X_train)]).unsqueeze(1)
        )
        
        train_loader = DataLoader(train_dataset, batch_size=config['batch_size'], shuffle=True)
        
        # Modèle
        input_dim = X.shape[1]
        model = StructuralStabilityModel(
            input_dim=input_dim,
            hidden_dims=config['hidden_dims'],
            dropout=config['dropout']
        ).to(device)
        
        # Optimizer et Loss
        optimizer = torch.optim.Adam(model.parameters(), lr=config['learning_rate'])
        scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=5)
        criterion = MultiTaskLoss()
        
        # Training loop
        best_val_loss = float('inf')
        patience_counter = 0
        
        for epoch in range(config['epochs']):
            model.train()
            total_loss = 0
            
            for batch in train_loader:
                X_batch, y_stab, y_stress, y_deform, y_safe = [b.to(device) for b in batch]
                
                optimizer.zero_grad()
                
                outputs = model(X_batch)
                
                targets = {
                    'stability': y_stab,
                    'max_stress': y_stress,
                    'max_deformation': y_deform,
                    'safety_factor': y_safe
                }
                
                losses = criterion(outputs, targets)
                losses['total'].backward()
                optimizer.step()
                
                total_loss += losses['total'].item()
            
            avg_loss = total_loss / len(train_loader)
            
            # Validation
            model.eval()
            # ... validation code ...
            
            # Logging
            mlflow.log_metric("train_loss", avg_loss, step=epoch)
            print(f"Epoch {epoch+1}/{config['epochs']} - Loss: {avg_loss:.4f}")
            
            # Early stopping
            if avg_loss < best_val_loss:
                best_val_loss = avg_loss
                patience_counter = 0
                torch.save(model.state_dict(), 'models/best_model.pt')
            else:
                patience_counter += 1
                if patience_counter >= config['early_stopping_patience']:
                    print("Early stopping!")
                    break
            
            scheduler.step(avg_loss)
        
        # Sauvegarde finale
        preprocessor.save('models/preprocessor.pkl')
        mlflow.pytorch.log_model(model, "model")
        
        print("Entraînement terminé!")

if __name__ == '__main__':
    train()
```

---

## 8. API d'Inférence (FastAPI)

### 8.1 Schémas d'Entrée/Sortie

```python
# api/schemas/input_schema.py
from pydantic import BaseModel, Field, validator
from typing import Optional, List
from enum import Enum

class StructureType(str, Enum):
    BEAM = "BEAM"
    BRIDGE = "BRIDGE"
    BUILDING = "BUILDING"
    COLUMN = "COLUMN"
    TRUSS = "TRUSS"

class SupportType(str, Enum):
    FIXED_FIXED = "fixed-fixed"
    PINNED_PINNED = "pinned-pinned"
    FIXED_FREE = "fixed-free"
    FIXED_PINNED = "fixed-pinned"

class DistributionType(str, Enum):
    UNIFORM = "uniform"
    CONCENTRATED = "concentrated"
    DISTRIBUTED = "distributed"

class DimensionsInput(BaseModel):
    length: float = Field(..., ge=0.1, le=100.0, description="Longueur en mètres")
    width: float = Field(..., ge=0.1, le=50.0, description="Largeur en mètres")
    height: float = Field(..., ge=0.1, le=100.0, description="Hauteur en mètres")
    thickness: Optional[float] = Field(None, ge=0.01, le=1.0, description="Épaisseur en mètres")

class MaterialInput(BaseModel):
    name: str = Field(..., description="Nom du matériau")
    youngs_modulus: float = Field(..., ge=1000, le=250000, description="Module d'Young en MPa")
    poissons_ratio: float = Field(..., ge=0.0, le=0.5, description="Coefficient de Poisson")
    density: float = Field(..., ge=400, le=8000, description="Densité en kg/m³")
    yield_strength: Optional[float] = Field(235, ge=10, le=500, description="Limite élastique en MPa")

class LoadsInput(BaseModel):
    dead_load: float = Field(..., ge=0, description="Charge permanente en kN")
    live_load: float = Field(..., ge=0, description="Charge d'exploitation en kN")
    wind_load: Optional[float] = Field(0, ge=0, description="Charge de vent en kN")
    seismic_load: Optional[float] = Field(0, ge=0, description="Charge sismique en kN")
    distribution_type: DistributionType = DistributionType.UNIFORM

class BoundaryConditionsInput(BaseModel):
    support_type: SupportType = SupportType.FIXED_FIXED

class SimulationRequest(BaseModel):
    structure_type: StructureType
    dimensions: DimensionsInput
    material: MaterialInput
    loads: LoadsInput
    boundary_conditions: BoundaryConditionsInput

    class Config:
        schema_extra = {
            "example": {
                "structure_type": "BEAM",
                "dimensions": {
                    "length": 10.0,
                    "width": 0.3,
                    "height": 0.5,
                    "thickness": 0.02
                },
                "material": {
                    "name": "STEEL_S235",
                    "youngs_modulus": 210000,
                    "poissons_ratio": 0.3,
                    "density": 7850,
                    "yield_strength": 235
                },
                "loads": {
                    "dead_load": 50,
                    "live_load": 30,
                    "wind_load": 10,
                    "seismic_load": 5,
                    "distribution_type": "uniform"
                },
                "boundary_conditions": {
                    "support_type": "fixed-fixed"
                }
            }
        }
```

```python
# api/schemas/output_schema.py
from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum

class StabilityVerdict(str, Enum):
    STABLE = "STABLE"
    WARNING = "WARNING"
    UNSTABLE = "UNSTABLE"

class Severity(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class Coordinates(BaseModel):
    x: float
    y: float
    z: float

class CriticalPoint(BaseModel):
    node_id: int
    coordinates: Coordinates
    stress: float
    deformation: float
    severity: Severity

class SimulationResponse(BaseModel):
    stability: StabilityVerdict
    max_stress: float = Field(..., description="Contrainte maximale en MPa")
    max_deformation: float = Field(..., description="Déformation maximale en mm")
    safety_factor: float = Field(..., description="Facteur de sécurité")
    ai_confidence: float = Field(..., ge=0.0, le=1.0, description="Confiance de la prédiction")
    processing_time_ms: int = Field(..., description="Temps de traitement en ms")
    critical_points: Optional[List[CriticalPoint]] = None
    stress_distribution: Optional[List[float]] = None
    deformation_data: Optional[List[float]] = None
    recommendations: Optional[List[str]] = None
    warnings: Optional[List[str]] = None

    class Config:
        schema_extra = {
            "example": {
                "stability": "STABLE",
                "max_stress": 125.5,
                "max_deformation": 2.3,
                "safety_factor": 1.87,
                "ai_confidence": 0.94,
                "processing_time_ms": 156,
                "recommendations": [
                    "La structure est conforme aux normes.",
                    "Considérer un renforcement pour les charges sismiques élevées."
                ],
                "warnings": []
            }
        }
```

### 8.2 Application FastAPI Complète

```python
# api/main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import torch
import numpy as np
import time
import logging

from api.schemas.input_schema import SimulationRequest
from api.schemas.output_schema import SimulationResponse, StabilityVerdict
from src.models.stability_predictor import StructuralStabilityModel
from src.preprocessing.normalizer import DataPreprocessor

# Configuration logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialisation FastAPI
app = FastAPI(
    title="SimStruct AI Engine",
    description="API de prédiction de stabilité structurelle par Deep Learning",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Chargement du modèle au démarrage
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = None
preprocessor = None

@app.on_event("startup")
async def load_model():
    global model, preprocessor
    logger.info("Chargement du modèle IA...")
    
    try:
        # Charger le préprocesseur
        preprocessor = DataPreprocessor.load('models/preprocessor.pkl')
        
        # Charger le modèle
        input_dim = 27  # Ajuster selon les features
        model = StructuralStabilityModel(input_dim=input_dim)
        model.load_state_dict(torch.load('models/best_model.pt', map_location=device))
        model.to(device)
        model.eval()
        
        logger.info(f"Modèle chargé sur {device}")
    except Exception as e:
        logger.error(f"Erreur chargement modèle: {e}")
        raise

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "device": str(device)
    }

@app.post("/api/v1/predict", response_model=SimulationResponse)
async def predict(request: SimulationRequest):
    """
    Prédit la stabilité structurelle à partir des paramètres fournis.
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Modèle non chargé")
    
    start_time = time.time()
    
    try:
        # Préparer les features
        features = prepare_features(request)
        
        # Inférence
        with torch.no_grad():
            X = torch.FloatTensor(features).unsqueeze(0).to(device)
            outputs = model(X)
        
        # Post-traitement
        stability_probs = torch.softmax(outputs['stability'], dim=1)
        stability_idx = stability_probs.argmax().item()
        confidence = stability_probs.max().item()
        
        stability_map = {0: StabilityVerdict.STABLE, 1: StabilityVerdict.WARNING, 2: StabilityVerdict.UNSTABLE}
        
        max_stress = outputs['max_stress'].item()
        max_deformation = outputs['max_deformation'].item()
        safety_factor = outputs['safety_factor'].item()
        
        # Générer recommandations
        recommendations = generate_recommendations(stability_idx, safety_factor, max_stress)
        warnings = generate_warnings(stability_idx, safety_factor)
        
        processing_time = int((time.time() - start_time) * 1000)
        
        return SimulationResponse(
            stability=stability_map[stability_idx],
            max_stress=round(max_stress, 2),
            max_deformation=round(max_deformation, 2),
            safety_factor=round(safety_factor, 2),
            ai_confidence=round(confidence, 2),
            processing_time_ms=processing_time,
            recommendations=recommendations,
            warnings=warnings
        )
        
    except Exception as e:
        logger.error(f"Erreur prédiction: {e}")
        raise HTTPException(status_code=500, detail=str(e))

def prepare_features(request: SimulationRequest) -> np.ndarray:
    """Convertit la requête en vecteur de features."""
    # Implémenter la conversion
    # ... 
    pass

def generate_recommendations(stability: int, sf: float, stress: float) -> list:
    """Génère des recommandations basées sur les résultats."""
    recs = []
    if stability == 0:
        recs.append("La structure est stable et conforme aux normes de sécurité.")
    elif stability == 1:
        recs.append("Attention: le facteur de sécurité est limite. Renforcement recommandé.")
    else:
        recs.append("URGENT: La structure nécessite un renforcement immédiat.")
    
    if sf < 2.0:
        recs.append("Considérer l'utilisation d'un matériau plus résistant.")
    
    return recs

def generate_warnings(stability: int, sf: float) -> list:
    """Génère des avertissements."""
    warnings = []
    if stability == 2:
        warnings.append("⚠️ Structure potentiellement dangereuse!")
    if sf < 1.2:
        warnings.append("⚠️ Facteur de sécurité critique!")
    return warnings

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 8.3 Dockerfile

```dockerfile
# Dockerfile
FROM python:3.10-slim

WORKDIR /app

# Dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Code source
COPY src/ ./src/
COPY api/ ./api/
COPY models/ ./models/

# Port
EXPOSE 8000

# Commande de démarrage
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 9. Critères de Performance

### 9.1 Objectifs de Précision

| Métrique | Seuil Minimum | Objectif |
|----------|---------------|----------|
| Accuracy (Classification) | 90% | **≥ 95%** |
| Précision (Weighted) | 88% | ≥ 93% |
| Recall (Weighted) | 88% | ≥ 93% |
| F1-Score (Weighted) | 88% | ≥ 93% |
| MAE Stress | < 15 MPa | < 10 MPa |
| MAE Deformation | < 5 mm | < 3 mm |
| Écart vs FEM | < 15% | **< 10%** |

### 9.2 Objectifs de Performance

| Métrique | Seuil | Description |
|----------|-------|-------------|
| Temps d'inférence | < 3s | 90ème percentile |
| Latence API | < 500ms | Médiane |
| Throughput | 100 req/s | Charge simultanée |
| Utilisation GPU | < 80% | En production |

### 9.3 Tests à Effectuer

```python
# tests/test_model.py
import pytest
import torch
import numpy as np

def test_model_accuracy():
    """Vérifier accuracy >= 95%"""
    # Charger modèle et données test
    # ...
    accuracy = calculate_accuracy(model, test_loader)
    assert accuracy >= 0.95, f"Accuracy {accuracy} < 0.95"

def test_inference_time():
    """Vérifier temps < 3s pour p90"""
    times = []
    for _ in range(100):
        start = time.time()
        _ = model(sample_input)
        times.append(time.time() - start)
    
    p90 = np.percentile(times, 90)
    assert p90 < 3.0, f"P90 latency {p90}s > 3s"

def test_fem_comparison():
    """Vérifier écart < 10% vs FEM"""
    for sample in fem_validation_set:
        pred = model(sample['input'])
        fem_result = sample['fem_output']
        
        stress_error = abs(pred['stress'] - fem_result['stress']) / fem_result['stress']
        assert stress_error < 0.10, f"Stress error {stress_error*100}% > 10%"
```

---

## 10. Livrables Attendus

### 10.1 Code Source

- [ ] Code modèle PyTorch (`src/models/`)
- [ ] Pipeline de prétraitement (`src/preprocessing/`)
- [ ] Scripts d'entraînement (`scripts/train.py`)
- [ ] Scripts de génération dataset (`scripts/generate_dataset.py`)
- [ ] API FastAPI (`api/`)
- [ ] Tests unitaires (`tests/`)

### 10.2 Artefacts

- [ ] Modèle exporté (`models/best_model.pt`)
- [ ] Préprocesseur sérialisé (`models/preprocessor.pkl`)
- [ ] Dockerfile et docker-compose.yml
- [ ] Requirements.txt

### 10.3 Documentation

- [ ] README.md avec instructions d'installation
- [ ] Documentation API (Swagger auto-généré)
- [ ] Rapport d'entraînement (métriques, courbes)
- [ ] Architecture du modèle (diagramme)

### 10.4 Métriques

- [ ] Rapport MLflow avec expériences
- [ ] Matrices de confusion
- [ ] Courbes ROC/AUC
- [ ] Comparaison FEM vs IA

---

## 11. Ressources et Références

### 11.1 Documentation

- [PyTorch Documentation](https://pytorch.org/docs/stable/index.html)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [OpenSees Documentation](https://opensees.berkeley.edu/wiki/)

### 11.2 Articles Scientifiques

- "Deep Learning for Structural Health Monitoring" - Journal of Engineering Mechanics
- "Neural Network-based Surrogate Models for FEM" - Computer Methods in Applied Mechanics
- "Machine Learning in Structural Engineering" - Automation in Construction

### 11.3 Datasets Publics

- [PEER Ground Motion Database](https://ngawest2.berkeley.edu/)
- [UCI Machine Learning Repository - Steel Plates Faults](https://archive.ics.uci.edu/)

### 11.4 Contact

Pour toute question technique, contacter l'équipe projet.

---

## Checklist de Développement

- [ ] Setup environnement Python 3.10+
- [ ] Installer dépendances (requirements.txt)
- [ ] Générer/acquérir dataset FEM (50k+ échantillons)
- [ ] Implémenter prétraitement des données
- [ ] Développer architecture du modèle
- [ ] Entraîner et valider le modèle
- [ ] Atteindre accuracy ≥ 95%
- [ ] Développer API FastAPI
- [ ] Conteneuriser avec Docker
- [ ] Tests unitaires (couverture ≥ 80%)
- [ ] Documentation complète
- [ ] Livraison et validation

---

**Bonne chance pour le développement! 🚀**
