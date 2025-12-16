"""
API FastAPI pour prédire les réponses structurales
API simple pour utiliser le modèle Deep Learning entraîné
"""

# Import des bibliothèques nécessaires
from fastapi import FastAPI, HTTPException  # Framework web pour créer l'API
from pydantic import BaseModel, Field      # Pour valider les données d'entrée
import torch                                # PyTorch pour le modèle
import torch.nn as nn                       # Composants du réseau de neurones
import pickle                               # Pour charger les scalers
import numpy as np                          # Pour les calculs mathématiques
from typing import Dict                     # Pour les types de retour
import os                                   # Pour gérer les chemins de fichiers

# Créer l'application FastAPI
app = FastAPI(
    title="SimStruct AI API",
    description="API pour prédire les réponses structurales des bâtiments",
    version="1.0.0"
)


# ========== DÉFINIR LA STRUCTURE DU RÉSEAU DE NEURONES ==========
# C'est la même architecture que dans le notebook
class SimpleNeuralNetwork(nn.Module):
    """
    Réseau de neurones pour l'analyse structurale
    Architecture: 11 -> 64 -> 32 -> 4
    """
    
    def __init__(self):
        super(SimpleNeuralNetwork, self).__init__()
        
        # Couche 1: 11 entrées -> 64 neurones
        self.layer1 = nn.Linear(11, 64)
        
        # Couche 2: 64 neurones -> 32 neurones
        self.layer2 = nn.Linear(64, 32)
        
        # Couche 3: 32 neurones -> 4 sorties
        self.layer3 = nn.Linear(32, 4)
        
        # Fonction d'activation ReLU
        self.relu = nn.ReLU()
    
    def forward(self, x):
        """
        Passage avant dans le réseau
        """
        x = self.relu(self.layer1(x))  # Passer par couche 1 + ReLU
        x = self.relu(self.layer2(x))  # Passer par couche 2 + ReLU
        x = self.layer3(x)              # Passer par couche 3 (sortie)
        return x


# ========== DÉFINIR LE FORMAT DES DONNÉES D'ENTRÉE ==========
class BuildingInput(BaseModel):
    """
    Structure des données d'entrée pour un bâtiment
    Tous les paramètres sont obligatoires
    """
    numFloors: float = Field(..., description="Nombre d'étages", ge=1, le=50)
    floorHeight: float = Field(..., description="Hauteur de chaque étage (m)", ge=2.5, le=6.0)
    numBeams: int = Field(..., description="Nombre de poutres", ge=10, le=500)
    numColumns: int = Field(..., description="Nombre de colonnes", ge=4, le=200)
    beamSection: float = Field(..., description="Section de poutre (cm)", ge=20, le=100)
    columnSection: float = Field(..., description="Section de colonne (cm)", ge=30, le=150)
    concreteStrength: float = Field(..., description="Résistance du béton (MPa)", ge=20, le=90)
    steelGrade: float = Field(..., description="Grade d'acier (MPa)", ge=235, le=460)
    windLoad: float = Field(..., description="Charge de vent (kN/m²)", ge=0.5, le=3.0)
    liveLoad: float = Field(..., description="Charge vive (kN/m²)", ge=1.5, le=5.0)
    deadLoad: float = Field(..., description="Charge morte (kN/m²)", ge=3.0, le=8.0)
    
    class Config:
        # Exemple de données pour la documentation automatique
        schema_extra = {
            "example": {
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
        }


# ========== DÉFINIR LE FORMAT DE LA RÉPONSE ==========
class PredictionOutput(BaseModel):
    """
    Structure de la réponse de prédiction
    """
    maxDeflection: float = Field(..., description="Déflexion maximale (mm)")
    maxStress: float = Field(..., description="Contrainte maximale (MPa)")
    stabilityIndex: float = Field(..., description="Indice de stabilité (0-100)")
    seismicResistance: float = Field(..., description="Résistance sismique (0-100)")
    status: str = Field(..., description="Statut de la prédiction")


# ========== CHARGER LE MODÈLE AU DÉMARRAGE ==========
# Variables globales pour stocker le modèle et les scalers
model = None
scaler_X = None
scaler_Y = None

@app.on_event("startup")
async def load_model():
    """
    Cette fonction s'exécute au démarrage de l'API
    Elle charge le modèle et les scalers
    """
    global model, scaler_X, scaler_Y
    
    # Chemin vers le dossier models
    model_dir = os.path.join(os.path.dirname(__file__), "..", "models")
    
    try:
        # Charger le modèle PyTorch
        model_path = os.path.join(model_dir, "structural_model.pt")
        model = SimpleNeuralNetwork()  # Créer l'architecture
        model.load_state_dict(torch.load(model_path))  # Charger les poids
        model.eval()  # Mettre en mode évaluation
        print("✅ Modèle chargé avec succès")
        
        # Charger les scalers (pour normaliser les données)
        scaler_path = os.path.join(model_dir, "scalers.pkl")
        with open(scaler_path, 'rb') as f:
            scalers = pickle.load(f)
            scaler_X = scalers['scaler_X']  # Scaler pour les entrées
            scaler_Y = scalers['scaler_Y']  # Scaler pour les sorties
        print("✅ Scalers chargés avec succès")
        
    except Exception as e:
        print(f"❌ Erreur lors du chargement: {e}")
        raise


# ========== ROUTE PRINCIPALE (PAGE D'ACCUEIL) ==========
@app.get("/")
async def root():
    """
    Route d'accueil de l'API
    Retourne des informations sur l'API
    """
    return {
        "message": "Bienvenue sur l'API SimStruct AI",
        "version": "1.0.0",
        "endpoints": {
            "predict": "/predict",
            "health": "/health",
            "docs": "/docs"
        }
    }


# ========== VÉRIFIER LA SANTÉ DE L'API ==========
@app.get("/health")
async def health_check():
    """
    Vérifier si l'API fonctionne correctement
    Vérifie que le modèle est chargé
    """
    if model is None or scaler_X is None or scaler_Y is None:
        return {
            "status": "unhealthy",
            "message": "Modèle non chargé"
        }
    
    return {
        "status": "healthy",
        "message": "API opérationnelle",
        "model_loaded": True
    }


# ========== ROUTE DE PRÉDICTION ==========
@app.post("/predict", response_model=PredictionOutput)
async def predict(building: BuildingInput):
    """
    Faire une prédiction pour un bâtiment
    
    Args:
        building: Paramètres du bâtiment (BuildingInput)
    
    Returns:
        PredictionOutput: Les prédictions du modèle
    """
    
    # Vérifier que le modèle est chargé
    if model is None or scaler_X is None or scaler_Y is None:
        raise HTTPException(
            status_code=500,
            detail="Modèle non chargé. Redémarrez l'API."
        )
    
    try:
        # Étape 1: Convertir les données d'entrée en array numpy
        # L'ordre doit être le même que lors de l'entraînement
        input_data = np.array([[
            building.numFloors,
            building.floorHeight,
            building.numBeams,
            building.numColumns,
            building.beamSection,
            building.columnSection,
            building.concreteStrength,
            building.steelGrade,
            building.windLoad,
            building.liveLoad,
            building.deadLoad
        ]])
        
        # Étape 2: Normaliser les données (comme lors de l'entraînement)
        input_scaled = scaler_X.transform(input_data)
        
        # Étape 3: Convertir en tensor PyTorch
        input_tensor = torch.tensor(input_scaled, dtype=torch.float32)
        
        # Étape 4: Faire la prédiction (sans calcul de gradient)
        with torch.no_grad():
            prediction_scaled = model(input_tensor)
        
        # Étape 5: Convertir la prédiction en numpy
        prediction_scaled_np = prediction_scaled.numpy()
        
        # Étape 6: Dénormaliser les prédictions (revenir à l'échelle originale)
        prediction = scaler_Y.inverse_transform(prediction_scaled_np)
        
        # Étape 7: Extraire les valeurs
        max_deflection = float(prediction[0, 0])
        max_stress = float(prediction[0, 1])
        stability_index = float(prediction[0, 2])
        seismic_resistance = float(prediction[0, 3])
        
        # Étape 8: Déterminer le statut
        # Si la stabilité et la résistance sismique sont bonnes (>70), statut OK
        if stability_index >= 70 and seismic_resistance >= 70:
            status = "Excellent"
        elif stability_index >= 50 and seismic_resistance >= 50:
            status = "Bon"
        elif stability_index >= 30 and seismic_resistance >= 30:
            status = "Acceptable"
        else:
            status = "Faible"
        
        # Étape 9: Retourner les résultats
        return PredictionOutput(
            maxDeflection=max_deflection,
            maxStress=max_stress,
            stabilityIndex=stability_index,
            seismicResistance=seismic_resistance,
            status=status
        )
    
    except Exception as e:
        # En cas d'erreur, retourner un message d'erreur HTTP
        raise HTTPException(
            status_code=500,
            detail=f"Erreur lors de la prédiction: {str(e)}"
        )


# ========== INFORMATIONS SUR LE MODÈLE ==========
@app.get("/model-info")
async def model_info():
    """
    Retourne des informations sur le modèle
    """
    if model is None:
        raise HTTPException(status_code=500, detail="Modèle non chargé")
    
    # Compter les paramètres du modèle
    total_params = sum(p.numel() for p in model.parameters())
    
    return {
        "architecture": "SimpleNeuralNetwork",
        "input_features": 11,
        "output_features": 4,
        "hidden_layers": [64, 32],
        "total_parameters": total_params,
        "activation": "ReLU",
        "input_parameters": [
            "numFloors", "floorHeight", "numBeams", "numColumns",
            "beamSection", "columnSection", "concreteStrength", "steelGrade",
            "windLoad", "liveLoad", "deadLoad"
        ],
        "output_parameters": [
            "maxDeflection", "maxStress", "stabilityIndex", "seismicResistance"
        ]
    }


# ========== POINT D'ENTRÉE POUR EXÉCUTION DIRECTE ==========
if __name__ == "__main__":
    # Importer uvicorn pour lancer le serveur
    import uvicorn
    
    # Lancer l'API sur le port 8000
    # host="0.0.0.0" permet d'accéder depuis d'autres machines
    # reload=True recharge automatiquement si le code change
    uvicorn.run(
        "api:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
