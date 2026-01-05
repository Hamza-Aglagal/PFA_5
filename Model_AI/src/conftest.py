"""
Shared fixtures for SimStruct AI Model tests
Provides reusable test components across all test modules
"""

import pytest
import numpy as np
from unittest.mock import MagicMock, patch
import sys
import os

# Add src to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


# ========== FIXTURES FOR NEURAL NETWORK ==========
class MockScaler:
    """Mock scaler for testing without loading real models"""
    
    def transform(self, X):
        """Return normalized data (simple normalization for testing)"""
        return np.array(X, dtype=np.float32)
    
    def inverse_transform(self, X):
        """Return denormalized data"""
        return np.array(X, dtype=np.float32)


@pytest.fixture
def mock_model():
    """Create a mock neural network model for testing"""
    try:
        from api import SimpleNeuralNetwork
        model = SimpleNeuralNetwork()
        model.eval()
        return model
    except Exception:
        return MagicMock()


@pytest.fixture
def mock_scalers():
    """Create mock scalers for testing"""
    return {
        'scaler_X': MockScaler(),
        'scaler_Y': MockScaler()
    }


# ========== FIXTURES FOR API CLIENT ==========
@pytest.fixture
def client():
    """Create a test client for the FastAPI app"""
    from fastapi.testclient import TestClient
    # Patch the model loading to use mocks
    with patch('api.model') as mock_model_global, \
         patch('api.scaler_X') as mock_scaler_x, \
         patch('api.scaler_Y') as mock_scaler_y:
        
        # Setup mock model
        try:
            from api import SimpleNeuralNetwork
            test_model = SimpleNeuralNetwork()
            test_model.eval()
            mock_model_global.return_value = test_model
            mock_model_global.parameters = test_model.parameters
            mock_model_global.__call__ = test_model.__call__
        except Exception:
            pass
        
        # Setup mock scalers
        mock_scaler_x.transform = MockScaler().transform
        mock_scaler_y.inverse_transform = MockScaler().inverse_transform
        
        from api import app
        with TestClient(app) as test_client:
            yield test_client


@pytest.fixture
def client_with_loaded_model():
    """Create a test client with a fully loaded mock model"""
    from fastapi.testclient import TestClient
    import api
    
    # Save original values
    original_model = api.model
    original_scaler_x = api.scaler_X
    original_scaler_y = api.scaler_Y
    
    # Set mock values
    try:
        from api import SimpleNeuralNetwork
        api.model = SimpleNeuralNetwork()
        api.model.eval()
    except Exception:
        api.model = MagicMock()
    
    api.scaler_X = MockScaler()
    api.scaler_Y = MockScaler()
    
    from api import app
    with TestClient(app) as test_client:
        yield test_client
    
    # Restore original values
    api.model = original_model
    api.scaler_X = original_scaler_x
    api.scaler_Y = original_scaler_y


@pytest.fixture
def client_without_model():
    """Create a test client without model loaded (for error testing)"""
    from fastapi.testclient import TestClient
    import api
    
    # Save original values
    original_model = api.model
    original_scaler_x = api.scaler_X
    original_scaler_y = api.scaler_Y
    
    # Set None values
    api.model = None
    api.scaler_X = None
    api.scaler_Y = None
    
    from api import app
    with TestClient(app) as test_client:
        yield test_client
    
    # Restore original values
    api.model = original_model
    api.scaler_X = original_scaler_x
    api.scaler_Y = original_scaler_y


# ========== FIXTURES FOR BUILDING DATA ==========
@pytest.fixture
def valid_building_data():
    """Valid building input data for testing"""
    return {
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


@pytest.fixture
def small_building_data():
    """Small building data (2 floors)"""
    return {
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


@pytest.fixture
def large_building_data():
    """Large building data (20 floors)"""
    return {
        "numFloors": 20,
        "floorHeight": 4.0,
        "numBeams": 250,
        "numColumns": 80,
        "beamSection": 50,
        "columnSection": 80,
        "concreteStrength": 60,
        "steelGrade": 460,
        "windLoad": 2.5,
        "liveLoad": 4.5,
        "deadLoad": 7.0
    }


@pytest.fixture
def boundary_min_data():
    """Building data with minimum allowed values"""
    return {
        "numFloors": 1,
        "floorHeight": 2.5,
        "numBeams": 10,
        "numColumns": 4,
        "beamSection": 20,
        "columnSection": 30,
        "concreteStrength": 20,
        "steelGrade": 235,
        "windLoad": 0.5,
        "liveLoad": 1.5,
        "deadLoad": 3.0
    }


@pytest.fixture
def boundary_max_data():
    """Building data with maximum allowed values"""
    return {
        "numFloors": 50,
        "floorHeight": 6.0,
        "numBeams": 500,
        "numColumns": 200,
        "beamSection": 100,
        "columnSection": 150,
        "concreteStrength": 90,
        "steelGrade": 460,
        "windLoad": 3.0,
        "liveLoad": 5.0,
        "deadLoad": 8.0
    }


# ========== FIXTURES FOR DATASET GENERATOR ==========
@pytest.fixture
def dataset_generator():
    """Create a dataset generator instance for testing"""
    from professional_dataset_generator import ProfessionalStructuralDataGenerator
    return ProfessionalStructuralDataGenerator(seed=42)


@pytest.fixture
def sample_params():
    """Sample parameters for structural response calculation"""
    return {
        'numFloors': 10,
        'floorHeight': 3.5,
        'numBeams': 120,
        'numColumns': 36,
        'beamSection': 30,
        'columnSection': 40,
        'concreteStrength': 35,
        'steelGrade': 355,
        'windLoad': 1.5,
        'liveLoad': 3.0,
        'deadLoad': 5.0
    }


# ========== UTILITY FIXTURES ==========
@pytest.fixture
def temp_output_dir(tmp_path):
    """Create a temporary output directory for test files"""
    output_dir = tmp_path / "data"
    output_dir.mkdir()
    return str(output_dir)
