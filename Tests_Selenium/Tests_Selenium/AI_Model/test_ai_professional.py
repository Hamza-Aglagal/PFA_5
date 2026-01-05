"""
Tests Professionnels pour l'API du Modèle AI
Utilise pytest et requests pour tester l'API FastAPI

Pattern: Given-When-Then (BDD)
Author: SimStruct Team
Version: 1.0
"""

import pytest
import requests
import time
import json
from typing import Dict, Any

# Configuration
API_URL = "http://localhost:8000"
TIMEOUT = 10


class TestAIModelProfessional:
    """Suite de tests professionnels pour l'API du modèle AI"""
    
    @pytest.fixture(scope="class", autouse=True)
    def setup_class(cls):
        """Setup avant tous les tests"""
        print("\n" + "="*60)
        print("  Tests Professionnels - API Modèle AI SimStruct")
        print("  URL: " + API_URL)
        print("="*60 + "\n")
    
    # ========== TESTS DE SANTÉ ET CONFIGURATION ==========
    
    def test_01_health_check(self):
        """
        ✅ Test 1: Vérifier que l'API est opérationnelle
        
        GIVEN: L'API est démarrée
        WHEN: Appel de l'endpoint /health
        THEN: L'API retourne un statut healthy
        """
        print("🏥 Test de santé de l'API...")
        
        # WHEN
        response = requests.get(f"{API_URL}/health", timeout=TIMEOUT)
        
        # THEN
        assert response.status_code == 200, "L'API devrait retourner 200"
        
        data = response.json()
        assert data["status"] == "healthy", "Le statut devrait être 'healthy'"
        assert data["model_loaded"] is True, "Le modèle devrait être chargé"
        
        print("✅ API opérationnelle")
        print(f"   Status: {data['status']}")
        print(f"   Modèle chargé: {data['model_loaded']}")
    
    def test_02_model_info(self):
        """
        ✅ Test 2: Vérifier les informations du modèle
        
        GIVEN: Le modèle est chargé
        WHEN: Appel de /model-info
        THEN: Les informations correctes sont retournées
        """
        print("📊 Récupération des informations du modèle...")
        
        # WHEN
        response = requests.get(f"{API_URL}/model-info", timeout=TIMEOUT)
        
        # THEN
        assert response.status_code == 200
        
        data = response.json()
        
        # Vérifier l'architecture
        assert data["architecture"] == "SimpleNeuralNetwork"
        assert data["input_features"] == 11, "Le modèle devrait avoir 11 features d'entrée"
        assert data["output_features"] == 4, "Le modèle devrait avoir 4 features de sortie"
        assert data["total_parameters"] == 2980, "Le modèle devrait avoir 2980 paramètres"
        
        print("✅ Informations du modèle vérifiées")
        print(f"   Architecture: {data['architecture']}")
        print(f"   Features entrée: {data['input_features']}")
        print(f"   Features sortie: {data['output_features']}")
        print(f"   Paramètres: {data['total_parameters']}")
        print(f"   Layers: {data['layers']}")
    
    # ========== TESTS DE PRÉDICTION ==========
    
    def test_03_predict_valid_input(self):
        """
        ✅ Test 3: Prédiction avec données valides
        
        GIVEN: Des données de bâtiment valides
        WHEN: Appel de /predict
        THEN: Des résultats de prédiction sont retournés
        """
        print("🔮 Test de prédiction avec données valides...")
        
        # GIVEN
        building_data = {
            "numFloors": 10,
            "floorHeight": 3.5,
            "numBeams": 120,
            "numColumns": 36,
            "beamSection": 30.0,
            "columnSection": 40.0,
            "concreteStrength": 35.0,
            "steelGrade": 355.0,
            "windLoad": 1.5,
            "liveLoad": 3.0,
            "deadLoad": 5.0
        }
        
        # WHEN
        start_time = time.time()
        response = requests.post(
            f"{API_URL}/predict",
            json=building_data,
            timeout=TIMEOUT
        )
        end_time = time.time()
        response_time = (end_time - start_time) * 1000  # en ms
        
        # THEN
        assert response.status_code == 200, "La prédiction devrait réussir"
        
        result = response.json()
        
        # Vérifier la présence des clés
        assert "maxDeflection" in result
        assert "maxStress" in result
        assert "stabilityIndex" in result
        assert "seismicResistance" in result
        assert "status" in result
        
        # Vérifier les plages de valeurs
        assert result["maxDeflection"] > 0, "La déflexion devrait être positive"
        assert result["maxStress"] > 0, "La contrainte devrait être positive"
        assert 0 <= result["stabilityIndex"] <= 100, "L'indice de stabilité devrait être entre 0 et 100"
        assert 0 <= result["seismicResistance"] <= 100, "La résistance sismique devrait être entre 0 et 100"
        assert result["status"] in ["Excellent", "Bon", "Acceptable", "Faible"]
        
        print("✅ Prédiction réussie")
        print(f"   Déflexion max: {result['maxDeflection']:.2f} mm")
        print(f"   Contrainte max: {result['maxStress']:.2f} MPa")
        print(f"   Stabilité: {result['stabilityIndex']:.2f}")
        print(f"   Résistance sismique: {result['seismicResistance']:.2f}")
        print(f"   Statut: {result['status']}")
        print(f"   ⚡ Temps de réponse: {response_time:.2f} ms")
        
        # Vérifier la performance
        assert response_time < 500, f"Le temps de réponse devrait être < 500ms (actuel: {response_time:.2f}ms)"
    
    def test_04_predict_missing_field(self):
        """
        ❌ Test 4: Prédiction avec champ manquant
        
        GIVEN: Des données incomplètes
        WHEN: Appel de /predict
        THEN: Erreur 422 (Validation Error)
        """
        print("❌ Test avec champ manquant...")
        
        # GIVEN - Données incomplètes
        incomplete_data = {
            "numFloors": 10,
            "floorHeight": 3.5
            # Champs manquants
        }
        
        # WHEN
        response = requests.post(
            f"{API_URL}/predict",
            json=incomplete_data,
            timeout=TIMEOUT
        )
        
        # THEN
        assert response.status_code == 422, "Devrait retourner 422 (Validation Error)"
        
        print("✅ Erreur 422 retournée comme attendu")
    
    def test_05_predict_out_of_range(self):
        """
        ❌ Test 5: Prédiction avec valeurs hors limites
        
        GIVEN: Des valeurs hors des limites acceptées
        WHEN: Appel de /predict
        THEN: Erreur 422
        """
        print("❌ Test avec valeurs hors limites...")
        
        # GIVEN - numFloors > 50 (max)
        out_of_range_data = {
            "numFloors": 100,  # Max = 50
            "floorHeight": 3.5,
            "numBeams": 120,
            "numColumns": 36,
            "beamSection": 30.0,
            "columnSection": 40.0,
            "concreteStrength": 35.0,
            "steelGrade": 355.0,
            "windLoad": 1.5,
            "liveLoad": 3.0,
            "deadLoad": 5.0
        }
        
        # WHEN
        response = requests.post(
            f"{API_URL}/predict",
            json=out_of_range_data,
            timeout=TIMEOUT
        )
        
        # THEN
        assert response.status_code == 422
        
        print("✅ Validation échouée comme attendu")
    
    # ========== TESTS DE SCÉNARIOS RÉALISTES ==========
    
    @pytest.mark.parametrize("scenario", [
        {
            "name": "Petit immeuble (5 étages)",
            "data": {
                "numFloors": 5,
                "floorHeight": 3.0,
                "numBeams": 60,
                "numColumns": 16,
                "beamSection": 25.0,
                "columnSection": 35.0,
                "concreteStrength": 30.0,
                "steelGrade": 355.0,
                "windLoad": 1.0,
                "liveLoad": 2.5,
                "deadLoad": 4.0
            },
            "expected_status": ["Excellent", "Bon"]
        },
        {
            "name": "Immeuble moyen (10 étages)",
            "data": {
                "numFloors": 10,
                "floorHeight": 3.5,
                "numBeams": 120,
                "numColumns": 36,
                "beamSection": 30.0,
                "columnSection": 40.0,
                "concreteStrength": 35.0,
                "steelGrade": 355.0,
                "windLoad": 1.5,
                "liveLoad": 3.0,
                "deadLoad": 5.0
            },
            "expected_status": ["Excellent", "Bon", "Acceptable"]
        },
        {
            "name": "Grand immeuble (20 étages)",
            "data": {
                "numFloors": 20,
                "floorHeight": 4.0,
                "numBeams": 250,
                "numColumns": 80,
                "beamSection": 45.0,
                "columnSection": 65.0,
                "concreteStrength": 50.0,
                "steelGrade": 420.0,
                "windLoad": 2.0,
                "liveLoad": 4.0,
                "deadLoad": 6.5
            },
            "expected_status": ["Excellent", "Bon", "Acceptable"]
        }
    ])
    def test_06_realistic_scenarios(self, scenario):
        """
        ✅ Test 6: Scénarios réalistes de bâtiments
        
        GIVEN: Différents types de bâtiments
        WHEN: Prédiction pour chaque type
        THEN: Résultats cohérents
        """
        print(f"\n🏢 Scénario: {scenario['name']}")
        
        # WHEN
        response = requests.post(
            f"{API_URL}/predict",
            json=scenario["data"],
            timeout=TIMEOUT
        )
        
        # THEN
        assert response.status_code == 200
        
        result = response.json()
        
        assert result["status"] in scenario["expected_status"], \
            f"Le statut devrait être dans {scenario['expected_status']}"
        
        print(f"   ✅ Statut: {result['status']}")
        print(f"   Stabilité: {result['stabilityIndex']:.2f}")
        print(f"   Résistance sismique: {result['seismicResistance']:.2f}")
    
    # ========== TESTS DE PERFORMANCE ==========
    
    def test_07_performance_multiple_requests(self):
        """
        ⚡ Test 7: Performance avec requêtes multiples
        
        GIVEN: Une série de requêtes
        WHEN: Envoi de 10 requêtes consécutives
        THEN: Toutes les requêtes répondent en < 500ms
        """
        print("⚡ Test de performance (10 requêtes)...")
        
        building_data = {
            "numFloors": 10,
            "floorHeight": 3.5,
            "numBeams": 120,
            "numColumns": 36,
            "beamSection": 30.0,
            "columnSection": 40.0,
            "concreteStrength": 35.0,
            "steelGrade": 355.0,
            "windLoad": 1.5,
            "liveLoad": 3.0,
            "deadLoad": 5.0
        }
        
        response_times = []
        
        for i in range(10):
            start_time = time.time()
            response = requests.post(
                f"{API_URL}/predict",
                json=building_data,
                timeout=TIMEOUT
            )
            end_time = time.time()
            
            response_time = (end_time - start_time) * 1000
            response_times.append(response_time)
            
            assert response.status_code == 200
        
        avg_time = sum(response_times) / len(response_times)
        max_time = max(response_times)
        min_time = min(response_times)
        
        print(f"✅ Performance:")
        print(f"   Temps moyen: {avg_time:.2f} ms")
        print(f"   Temps min: {min_time:.2f} ms")
        print(f"   Temps max: {max_time:.2f} ms")
        
        assert avg_time < 500, f"Le temps moyen devrait être < 500ms (actuel: {avg_time:.2f}ms)"
        assert max_time < 1000, f"Le temps max devrait être < 1000ms (actuel: {max_time:.2f}ms)"
    
    def test_08_concurrent_requests(self):
        """
        ⚡ Test 8: Requêtes concurrentes
        
        GIVEN: Plusieurs requêtes simultanées
        WHEN: Envoi de 5 requêtes en parallèle
        THEN: Toutes les requêtes réussissent
        """
        print("⚡ Test de requêtes concurrentes...")
        
        import concurrent.futures
        
        building_data = {
            "numFloors": 10,
            "floorHeight": 3.5,
            "numBeams": 120,
            "numColumns": 36,
            "beamSection": 30.0,
            "columnSection": 40.0,
            "concreteStrength": 35.0,
            "steelGrade": 355.0,
            "windLoad": 1.5,
            "liveLoad": 3.0,
            "deadLoad": 5.0
        }
        
        def make_request():
            response = requests.post(
                f"{API_URL}/predict",
                json=building_data,
                timeout=TIMEOUT
            )
            return response.status_code
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            futures = [executor.submit(make_request) for _ in range(5)]
            results = [f.result() for f in concurrent.futures.as_completed(futures)]
        
        assert all(status == 200 for status in results), "Toutes les requêtes devraient réussir"
        
        print(f"✅ {len(results)} requêtes concurrentes réussies")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short", "-s"])
