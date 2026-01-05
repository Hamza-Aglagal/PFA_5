"""
Model Unit Tests for SimStruct AI
Tests the neural network architecture and inference

Author: SimStruct AI Team
Target: Test model initialization, architecture, and inference
"""

import pytest
import numpy as np
import sys
import os

# Add src to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Try to import torch, skip tests if not available
try:
    import torch
    import torch.nn as nn
    from api import SimpleNeuralNetwork
    TORCH_AVAILABLE = True
except (ImportError, OSError) as e:
    TORCH_AVAILABLE = False
    torch = None
    nn = None
    SimpleNeuralNetwork = None

# Skip all tests if torch is not available
pytestmark = pytest.mark.skipif(not TORCH_AVAILABLE, reason="PyTorch not available")


# ========== MODEL ARCHITECTURE TESTS ==========
class TestModelArchitecture:
    """Tests for neural network architecture"""
    
    def test_model_initialization(self):
        """Test that model initializes correctly"""
        model = SimpleNeuralNetwork()
        assert model is not None
        assert isinstance(model, nn.Module)
    
    def test_model_has_correct_layers(self):
        """Test that model has the expected layers"""
        model = SimpleNeuralNetwork()
        
        assert hasattr(model, 'layer1')
        assert hasattr(model, 'layer2')
        assert hasattr(model, 'layer3')
        assert hasattr(model, 'relu')
    
    def test_layer1_dimensions(self):
        """Test that layer1 has correct input/output dimensions"""
        model = SimpleNeuralNetwork()
        assert model.layer1.in_features == 11
        assert model.layer1.out_features == 64
    
    def test_layer2_dimensions(self):
        """Test that layer2 has correct input/output dimensions"""
        model = SimpleNeuralNetwork()
        assert model.layer2.in_features == 64
        assert model.layer2.out_features == 32
    
    def test_layer3_dimensions(self):
        """Test that layer3 has correct input/output dimensions"""
        model = SimpleNeuralNetwork()
        assert model.layer3.in_features == 32
        assert model.layer3.out_features == 4
    
    def test_model_parameter_count(self):
        """Test that model has expected parameter count"""
        model = SimpleNeuralNetwork()
        total_params = sum(p.numel() for p in model.parameters())
        
        # Expected: (11*64 + 64) + (64*32 + 32) + (32*4 + 4)
        # = 704 + 64 + 2048 + 32 + 128 + 4 = 2980
        expected_params = (11*64 + 64) + (64*32 + 32) + (32*4 + 4)
        assert total_params == expected_params
    
    def test_relu_activation(self):
        """Test that ReLU activation is properly defined"""
        model = SimpleNeuralNetwork()
        assert isinstance(model.relu, nn.ReLU)


# ========== MODEL FORWARD PASS TESTS ==========
class TestModelForward:
    """Tests for model forward pass"""
    
    def test_forward_pass_shape(self):
        """Test that forward pass produces correct output shape"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        # Create sample input (batch_size=1, features=11)
        input_tensor = torch.randn(1, 11)
        
        with torch.no_grad():
            output = model(input_tensor)
        
        assert output.shape == (1, 4)
    
    def test_forward_pass_batch(self):
        """Test forward pass with batch of inputs"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        # Create batch input (batch_size=5, features=11)
        input_tensor = torch.randn(5, 11)
        
        with torch.no_grad():
            output = model(input_tensor)
        
        assert output.shape == (5, 4)
    
    def test_forward_pass_consistency(self):
        """Test that same input produces same output (deterministic)"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        input_tensor = torch.randn(1, 11)
        
        with torch.no_grad():
            output1 = model(input_tensor)
            output2 = model(input_tensor)
        
        assert torch.allclose(output1, output2)
    
    def test_forward_pass_different_inputs(self):
        """Test that different inputs produce different outputs"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        input1 = torch.randn(1, 11)
        input2 = torch.randn(1, 11) + 10  # Different input
        
        with torch.no_grad():
            output1 = model(input1)
            output2 = model(input2)
        
        assert not torch.allclose(output1, output2)
    
    def test_forward_pass_output_type(self):
        """Test that output is a torch tensor"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        input_tensor = torch.randn(1, 11)
        
        with torch.no_grad():
            output = model(input_tensor)
        
        assert isinstance(output, torch.Tensor)
        assert output.dtype == torch.float32
    
    def test_forward_pass_no_nan(self):
        """Test that output contains no NaN values"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        input_tensor = torch.randn(1, 11)
        
        with torch.no_grad():
            output = model(input_tensor)
        
        assert not torch.isnan(output).any()
    
    def test_forward_pass_no_inf(self):
        """Test that output contains no Inf values"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        input_tensor = torch.randn(1, 11)
        
        with torch.no_grad():
            output = model(input_tensor)
        
        assert not torch.isinf(output).any()


# ========== MODEL TRAINING MODE TESTS ==========
class TestModelModes:
    """Tests for model training/evaluation modes"""
    
    def test_model_eval_mode(self):
        """Test that model can be set to evaluation mode"""
        model = SimpleNeuralNetwork()
        model.eval()
        assert not model.training
    
    def test_model_train_mode(self):
        """Test that model can be set to training mode"""
        model = SimpleNeuralNetwork()
        model.train()
        assert model.training
    
    def test_model_default_mode(self):
        """Test model default mode is training"""
        model = SimpleNeuralNetwork()
        assert model.training


# ========== MODEL STATE DICT TESTS ==========
class TestModelStateDict:
    """Tests for model state dictionary"""
    
    def test_state_dict_keys(self):
        """Test that state dict has expected keys"""
        model = SimpleNeuralNetwork()
        state_dict = model.state_dict()
        
        expected_keys = [
            'layer1.weight', 'layer1.bias',
            'layer2.weight', 'layer2.bias',
            'layer3.weight', 'layer3.bias'
        ]
        
        for key in expected_keys:
            assert key in state_dict
    
    def test_state_dict_load(self):
        """Test that state dict can be saved and loaded"""
        model1 = SimpleNeuralNetwork()
        model2 = SimpleNeuralNetwork()
        
        # Ensure different initial weights
        with torch.no_grad():
            model1.layer1.weight.fill_(1.0)
        
        # Load state from model1 to model2
        model2.load_state_dict(model1.state_dict())
        
        # Check weights are now equal
        assert torch.allclose(model1.layer1.weight, model2.layer1.weight)


# ========== MODEL GRADIENT TESTS ==========
class TestModelGradients:
    """Tests for model gradient computation"""
    
    def test_gradients_computed(self):
        """Test that gradients can be computed"""
        model = SimpleNeuralNetwork()
        model.train()
        
        input_tensor = torch.randn(1, 11, requires_grad=True)
        output = model(input_tensor)
        loss = output.sum()
        loss.backward()
        
        # Check that gradients exist
        for param in model.parameters():
            assert param.grad is not None
    
    def test_no_grad_context(self):
        """Test that no gradients in no_grad context"""
        model = SimpleNeuralNetwork()
        model.eval()
        
        input_tensor = torch.randn(1, 11)
        
        with torch.no_grad():
            output = model(input_tensor)
        
        # Output should not require grad
        assert not output.requires_grad
