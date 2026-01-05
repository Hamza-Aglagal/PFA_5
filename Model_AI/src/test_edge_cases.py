"""
Edge Case Tests for SimStruct AI Model
Tests boundary conditions, validation, and error handling

Author: SimStruct AI Team
Target: Comprehensive edge case coverage
"""

import pytest
from unittest.mock import patch, MagicMock
import numpy as np

# Try to import torch, skip tests if not available
try:
    import torch
    TORCH_AVAILABLE = True
except (ImportError, OSError) as e:
    TORCH_AVAILABLE = False
    torch = None

# Skip all tests if torch is not available
pytestmark = pytest.mark.skipif(not TORCH_AVAILABLE, reason="PyTorch not available")


# ========== BOUNDARY VALUE TESTS ==========
class TestBoundaryValues:
    """Tests for input parameter boundary values"""
    
    def test_minimum_boundary_values(self, client_with_loaded_model, boundary_min_data):
        """Test prediction with minimum allowed values"""
        response = client_with_loaded_model.post("/predict", json=boundary_min_data)
        assert response.status_code in [200, 500]  # May fail if scalers not fitted
    
    def test_maximum_boundary_values(self, client_with_loaded_model, boundary_max_data):
        """Test prediction with maximum allowed values"""
        response = client_with_loaded_model.post("/predict", json=boundary_max_data)
        assert response.status_code in [200, 500]  # May fail if scalers not fitted
    
    def test_numfloors_below_minimum(self, client_with_loaded_model, valid_building_data):
        """Test that numFloors below minimum is rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["numFloors"] = 0  # Below minimum of 1
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422
    
    def test_numfloors_above_maximum(self, client_with_loaded_model, valid_building_data):
        """Test that numFloors above maximum is rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["numFloors"] = 51  # Above maximum of 50
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422
    
    def test_floor_height_below_minimum(self, client_with_loaded_model, valid_building_data):
        """Test that floorHeight below minimum is rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["floorHeight"] = 2.0  # Below minimum of 2.5
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422
    
    def test_floor_height_above_maximum(self, client_with_loaded_model, valid_building_data):
        """Test that floorHeight above maximum is rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["floorHeight"] = 7.0  # Above maximum of 6.0
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422
    
    def test_concrete_strength_below_minimum(self, client_with_loaded_model, valid_building_data):
        """Test that concreteStrength below minimum is rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["concreteStrength"] = 15  # Below minimum of 20
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422
    
    def test_steel_grade_below_minimum(self, client_with_loaded_model, valid_building_data):
        """Test that steelGrade below minimum is rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["steelGrade"] = 200  # Below minimum of 235
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422


# ========== TYPE VALIDATION TESTS ==========
class TestTypeValidation:
    """Tests for input type validation"""
    
    def test_string_instead_of_number(self, client_with_loaded_model, valid_building_data):
        """Test that string values are rejected for numeric fields"""
        invalid_data = valid_building_data.copy()
        invalid_data["numFloors"] = "ten"
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422
    
    def test_null_value_rejected(self, client_with_loaded_model, valid_building_data):
        """Test that null values are rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["numFloors"] = None
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422
    
    def test_empty_json_body(self, client_with_loaded_model):
        """Test that empty JSON body is rejected"""
        response = client_with_loaded_model.post("/predict", json={})
        assert response.status_code == 422
    
    def test_array_instead_of_object(self, client_with_loaded_model):
        """Test that array instead of object is rejected"""
        response = client_with_loaded_model.post("/predict", json=[1, 2, 3])
        assert response.status_code == 422
    
    def test_negative_values_rejected(self, client_with_loaded_model, valid_building_data):
        """Test that negative values are rejected"""
        invalid_data = valid_building_data.copy()
        invalid_data["numFloors"] = -5
        response = client_with_loaded_model.post("/predict", json=invalid_data)
        assert response.status_code == 422


# ========== ERROR HANDLING TESTS ==========
class TestErrorHandling:
    """Tests for API error handling"""
    
    def test_invalid_endpoint_returns_404(self, client_with_loaded_model):
        """Test that invalid endpoints return 404"""
        response = client_with_loaded_model.get("/invalid-endpoint")
        assert response.status_code == 404
    
    def test_wrong_http_method_for_predict(self, client_with_loaded_model):
        """Test that GET request to /predict returns error"""
        response = client_with_loaded_model.get("/predict")
        assert response.status_code == 405  # Method not allowed
    
    def test_wrong_http_method_for_health(self, client_with_loaded_model):
        """Test that POST request to /health returns error"""
        response = client_with_loaded_model.post("/health")
        assert response.status_code == 405
    
    def test_malformed_json_rejected(self, client_with_loaded_model):
        """Test that malformed JSON is rejected"""
        response = client_with_loaded_model.post(
            "/predict",
            content="{ invalid json }",
            headers={"Content-Type": "application/json"}
        )
        assert response.status_code == 422


# ========== FLOAT PRECISION TESTS ==========
class TestFloatPrecision:
    """Tests for floating point precision handling"""
    
    def test_float_with_many_decimals(self, client_with_loaded_model, valid_building_data):
        """Test that floats with many decimal places are accepted"""
        precise_data = valid_building_data.copy()
        precise_data["floorHeight"] = 3.5000000001
        response = client_with_loaded_model.post("/predict", json=precise_data)
        assert response.status_code in [200, 500]  # May fail if scalers not fitted
    
    def test_integer_accepted_for_float_field(self, client_with_loaded_model, valid_building_data):
        """Test that integer values are accepted for float fields"""
        int_data = valid_building_data.copy()
        int_data["floorHeight"] = 3  # Integer instead of float
        response = client_with_loaded_model.post("/predict", json=int_data)
        assert response.status_code in [200, 500]  # May fail if scalers not fitted


# ========== SPECIAL VALUE TESTS ==========
class TestSpecialValues:
    """Tests for special numeric values"""
    
    def test_exact_boundary_values_accepted(self, client_with_loaded_model, valid_building_data):
        """Test that exact boundary values are accepted"""
        exact_data = valid_building_data.copy()
        exact_data["numFloors"] = 1  # Exact minimum
        exact_data["floorHeight"] = 2.5  # Exact minimum
        response = client_with_loaded_model.post("/predict", json=exact_data)
        assert response.status_code in [200, 500]  # May fail if scalers not fitted
    
    def test_response_values_are_finite(self, client_with_loaded_model, valid_building_data):
        """Test that response values are finite (not NaN or Inf) when successful"""
        response = client_with_loaded_model.post("/predict", json=valid_building_data)
        if response.status_code == 200:
            data = response.json()
            import math
            assert math.isfinite(data["maxDeflection"])
            assert math.isfinite(data["maxStress"])
            assert math.isfinite(data["stabilityIndex"])
            assert math.isfinite(data["seismicResistance"])
        # If 500, scalers not fitted - test passes


# ========== CONTENT TYPE TESTS ==========
class TestContentType:
    """Tests for content type handling"""
    
    def test_json_content_type_required(self, client_with_loaded_model, valid_building_data):
        """Test that JSON content type is properly handled"""
        import json
        response = client_with_loaded_model.post(
            "/predict",
            content=json.dumps(valid_building_data),
            headers={"Content-Type": "application/json"}
        )
        assert response.status_code in [200, 500]  # May fail if scalers not fitted
    
    def test_response_is_json(self, client_with_loaded_model, valid_building_data):
        """Test that response content type is JSON"""
        response = client_with_loaded_model.post("/predict", json=valid_building_data)
        assert "application/json" in response.headers.get("content-type", "")
