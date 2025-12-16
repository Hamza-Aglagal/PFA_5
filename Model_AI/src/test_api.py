"""
Script pour tester l'API
Simple et facile à comprendre
"""

import requests  # Pour faire des requêtes HTTP
import json      # Pour formater les données JSON

# ========== CONFIGURATION ==========
# URL de l'API (changez si l'API tourne sur un autre port)
API_URL = "http://localhost:8000"


# ========== FONCTION POUR TESTER LA SANTÉ ==========
def test_health():
    """
    Teste si l'API fonctionne
    """
    print("\n" + "="*60)
    print("TEST 1: Vérification de la santé de l'API")
    print("="*60)
    
    try:
        # Faire une requête GET sur /health
        response = requests.get(f"{API_URL}/health")
        
        # Afficher le résultat
        print(f"Status Code: {response.status_code}")
        print(f"Réponse: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
        
        if response.status_code == 200:
            print("✅ API est en bonne santé!")
        else:
            print("❌ Problème avec l'API")
    
    except Exception as e:
        print(f"❌ Erreur: {e}")
        print("Assurez-vous que l'API est démarrée!")


# ========== FONCTION POUR TESTER LES INFOS DU MODÈLE ==========
def test_model_info():
    """
    Récupère les informations sur le modèle
    """
    print("\n" + "="*60)
    print("TEST 2: Informations sur le modèle")
    print("="*60)
    
    try:
        response = requests.get(f"{API_URL}/model-info")
        
        print(f"Status Code: {response.status_code}")
        print(f"Réponse: {json.dumps(response.json(), indent=2, ensure_ascii=False)}")
    
    except Exception as e:
        print(f"❌ Erreur: {e}")


# ========== FONCTION POUR TESTER UNE PRÉDICTION ==========
def test_prediction():
    """
    Teste une prédiction avec un exemple de bâtiment
    """
    print("\n" + "="*60)
    print("TEST 3: Prédiction pour un bâtiment")
    print("="*60)
    
    # Exemple de bâtiment (10 étages, construction standard)
    building_data = {
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
    
    print("\n📋 Données du bâtiment:")
    print(json.dumps(building_data, indent=2, ensure_ascii=False))
    
    try:
        # Faire une requête POST sur /predict
        response = requests.post(
            f"{API_URL}/predict",
            json=building_data
        )
        
        print(f"\n📊 Résultat de la prédiction:")
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(json.dumps(result, indent=2, ensure_ascii=False))
            
            # Afficher de manière plus lisible
            print("\n" + "-"*60)
            print(f"Déflexion maximale:      {result['maxDeflection']:.2f} mm")
            print(f"Contrainte maximale:     {result['maxStress']:.2f} MPa")
            print(f"Indice de stabilité:     {result['stabilityIndex']:.2f}")
            print(f"Résistance sismique:     {result['seismicResistance']:.2f}")
            print(f"Statut:                  {result['status']}")
            print("-"*60)
            print("✅ Prédiction réussie!")
        else:
            print(f"❌ Erreur: {response.json()}")
    
    except Exception as e:
        print(f"❌ Erreur: {e}")


# ========== TESTER DIFFÉRENTS TYPES DE BÂTIMENTS ==========
def test_multiple_buildings():
    """
    Teste plusieurs types de bâtiments
    """
    print("\n" + "="*60)
    print("TEST 4: Prédictions pour différents bâtiments")
    print("="*60)
    
    # Définir plusieurs bâtiments
    buildings = [
        {
            "name": "Petit immeuble résidentiel",
            "data": {
                "numFloors": 5,
                "floorHeight": 3.0,
                "numBeams": 60,
                "numColumns": 16,
                "beamSection": 25,
                "columnSection": 35,
                "concreteStrength": 30,
                "steelGrade": 355,
                "windLoad": 1.0,
                "liveLoad": 2.5,
                "deadLoad": 4.0
            }
        },
        {
            "name": "Grand immeuble de bureaux",
            "data": {
                "numFloors": 15,
                "floorHeight": 4.0,
                "numBeams": 200,
                "numColumns": 64,
                "beamSection": 40,
                "columnSection": 60,
                "concreteStrength": 50,
                "steelGrade": 420,
                "windLoad": 2.0,
                "liveLoad": 4.0,
                "deadLoad": 6.0
            }
        },
        {
            "name": "Petite maison (2 étages)",
            "data": {
                "numFloors": 2,
                "floorHeight": 3.0,
                "numBeams": 20,
                "numColumns": 8,
                "beamSection": 20,
                "columnSection": 30,
                "concreteStrength": 25,
                "steelGrade": 355,
                "windLoad": 0.8,
                "liveLoad": 2.0,
                "deadLoad": 3.5
            }
        }
    ]
    
    # Tester chaque bâtiment
    for i, building in enumerate(buildings, 1):
        print(f"\n{i}. {building['name']}")
        print("-" * 60)
        
        try:
            response = requests.post(
                f"{API_URL}/predict",
                json=building['data']
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"  Déflexion max:         {result['maxDeflection']:.2f} mm")
                print(f"  Contrainte max:        {result['maxStress']:.2f} MPa")
                print(f"  Stabilité:             {result['stabilityIndex']:.2f}")
                print(f"  Résistance sismique:   {result['seismicResistance']:.2f}")
                print(f"  Statut:                {result['status']}")
                print("  ✅ OK")
            else:
                print(f"  ❌ Erreur: {response.status_code}")
        
        except Exception as e:
            print(f"  ❌ Erreur: {e}")


# ========== EXÉCUTER TOUS LES TESTS ==========
if __name__ == "__main__":
    print("🚀 Démarrage des tests de l'API SimStruct AI")
    
    # Test 1: Santé
    test_health()
    
    # Test 2: Infos du modèle
    test_model_info()
    
    # Test 3: Une prédiction
    test_prediction()
    
    # Test 4: Plusieurs bâtiments
    test_multiple_buildings()
    
    print("\n" + "="*60)
    print("✅ Tous les tests sont terminés!")
    print("="*60)
