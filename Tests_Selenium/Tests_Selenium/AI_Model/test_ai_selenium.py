"""
Tests Selenium pour l'API AI Model
Utilise Selenium pour tester l'interface Swagger et les endpoints
"""

import pytest
import requests
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options

API_URL = "http://localhost:8000"
SWAGGER_URL = f"{API_URL}/docs"


class TestAIModelSelenium:
    """Tests E2E pour l'API AI avec Selenium"""

    @pytest.fixture(scope="class")
    def driver(self):
        """Setup du driver Selenium"""
        chrome_options = Options()
        chrome_options.add_argument("--start-maximized")
        chrome_options.add_argument("--disable-notifications")
        
        driver = webdriver.Chrome(options=chrome_options)
        yield driver
        driver.quit()

    @pytest.fixture(scope="class")
    def wait(self, driver):
        """WebDriverWait instance"""
        return WebDriverWait(driver, 10)

    def test_01_swagger_ui_loads(self, driver, wait):
        """Test 1: Vérifier que Swagger UI se charge"""
        driver.get(SWAGGER_URL)
        
        # Attendre que le titre soit chargé
        title_element = wait.until(
            EC.presence_of_element_located((By.CLASS_NAME, "title"))
        )
        
        assert "SimStruct AI API" in title_element.text

    def test_02_health_endpoint_visible(self, driver, wait):
        """Test 2: Vérifier que l'endpoint /health est visible"""
        driver.get(SWAGGER_URL)
        
        # Chercher l'endpoint /health
        health_endpoint = wait.until(
            EC.presence_of_element_located(
                (By.XPATH, "//span[contains(text(), '/health')]")
            )
        )
        
        assert health_endpoint.is_displayed()

    def test_03_model_info_endpoint_visible(self, driver, wait):
        """Test 3: Vérifier que l'endpoint /model-info est visible"""
        driver.get(SWAGGER_URL)
        
        model_info_endpoint = wait.until(
            EC.presence_of_element_located(
                (By.XPATH, "//span[contains(text(), '/model-info')]")
            )
        )
        
        assert model_info_endpoint.is_displayed()

    def test_04_predict_endpoint_visible(self, driver, wait):
        """Test 4: Vérifier que l'endpoint /predict est visible"""
        driver.get(SWAGGER_URL)
        
        predict_endpoint = wait.until(
            EC.presence_of_element_located(
                (By.XPATH, "//span[contains(text(), '/predict')]")
            )
        )
        
        assert predict_endpoint.is_displayed()

    def test_05_expand_predict_endpoint(self, driver, wait):
        """Test 5: Développer l'endpoint /predict"""
        driver.get(SWAGGER_URL)
        
        # Cliquer sur /predict pour l'ouvrir
        predict_button = wait.until(
            EC.element_to_be_clickable(
                (By.XPATH, "//span[contains(text(), '/predict')]")
            )
        )
        predict_button.click()
        
        # Vérifier que le bouton "Try it out" est visible
        try_it_out = wait.until(
            EC.presence_of_element_located(
                (By.XPATH, "//button[contains(text(), 'Try it out')]")
            )
        )
        
        assert try_it_out.is_displayed()


class TestAIModelAPI:
    """Tests directs de l'API (sans Selenium)"""

    def test_01_health_check(self):
        """Test 1: Health check"""
        response = requests.get(f"{API_URL}/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["model_loaded"] is True

    def test_02_model_info(self):
        """Test 2: Informations du modèle"""
        response = requests.get(f"{API_URL}/model-info")
        
        assert response.status_code == 200
        data = response.json()
        assert data["input_features"] == 11
        assert data["output_features"] == 4
        assert data["total_parameters"] == 2980
        assert data["architecture"] == "SimpleNeuralNetwork"

    def test_03_predict_valid_input(self):
        """Test 3: Prédiction avec données valides"""
        payload = {
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
        
        response = requests.post(f"{API_URL}/predict", json=payload)
        
        assert response.status_code == 200
        data = response.json()
        
        # Vérifier les clés
        assert "maxDeflection" in data
        assert "maxStress" in data
        assert "stabilityIndex" in data
        assert "seismicResistance" in data
        assert "status" in data
        
        # Vérifier les plages de valeurs
        assert data["maxDeflection"] > 0
        assert data["maxStress"] > 0
        assert 0 <= data["stabilityIndex"] <= 100
        assert 0 <= data["seismicResistance"] <= 100
        assert data["status"] in ["Excellent", "Bon", "Acceptable", "Faible"]

    def test_04_predict_invalid_input_missing_field(self):
        """Test 4: Prédiction avec champ manquant"""
        payload = {
            "numFloors": 10,
            "floorHeight": 3.5
            # Champs manquants
        }
        
        response = requests.post(f"{API_URL}/predict", json=payload)
        assert response.status_code == 422  # Validation error

    def test_05_predict_invalid_input_out_of_range(self):
        """Test 5: Prédiction avec valeurs hors plage"""
        payload = {
            "numFloors": 100,  # Max = 50
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
        
        response = requests.post(f"{API_URL}/predict", json=payload)
        assert response.status_code == 422

    def test_06_predict_multiple_scenarios(self):
        """Test 6: Prédictions multiples"""
        scenarios = [
            {
                "name": "Petit immeuble",
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
                "name": "Grand immeuble",
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
            }
        ]
        
        for scenario in scenarios:
            response = requests.post(f"{API_URL}/predict", json=scenario["data"])
            assert response.status_code == 200
            data = response.json()
            assert "maxDeflection" in data
            print(f"✅ {scenario['name']}: {data['status']}")

    def test_07_performance_test(self):
        """Test 7: Test de performance (temps de réponse)"""
        payload = {
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
        
        start_time = time.time()
        response = requests.post(f"{API_URL}/predict", json=payload)
        end_time = time.time()
        
        response_time = (end_time - start_time) * 1000  # en ms
        
        assert response.status_code == 200
        assert response_time < 500  # Moins de 500ms
        print(f"⚡ Temps de réponse: {response_time:.2f}ms")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
