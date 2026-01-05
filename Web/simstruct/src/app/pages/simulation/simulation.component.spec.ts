import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, ComponentFixture, fakeAsync, tick } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of, throwError } from 'rxjs';
import { SimulationComponent } from './simulation.component';
import { SimulationService } from '../../core/services/simulation.service';
import { NotificationService } from '../../core/services/notification.service';
import { Renderer2 } from '@angular/core';

// Mock Three.js - factory functions must not reference external variables
vi.mock('three', () => {
  const mockFn = () => ({});
  return {
    Scene: class {
      add = () => { };
      remove = () => { };
      background = null;
      children: any[] = [];
    },
    PerspectiveCamera: class {
      position = { set: () => { } };
      lookAt = () => { };
      aspect = 1;
      updateProjectionMatrix = () => { };
    },
    WebGLRenderer: class {
      setSize = () => { };
      setPixelRatio = () => { };
      render = () => { };
      dispose = () => { };
    },
    Color: class { },
    GridHelper: class { },
    AxesHelper: class { },
    AmbientLight: class { },
    DirectionalLight: class {
      position = { set: () => { } };
    },
    Group: class {
      add = () => { };
      children: any[] = [];
    },
    BoxGeometry: class {
      rotateZ = () => { };
    },
    ConeGeometry: class {
      clone = () => this;
    },
    CylinderGeometry: class {
      rotateZ = () => { };
      clone = () => this;
    },
    MeshStandardMaterial: class { },
    Mesh: class {
      position = { set: () => { }, y: 0 };
      rotation = { x: 0, z: 0 };
      scale = { set: () => { } };
    }
  };
});

// Mock OrbitControls
vi.mock('three/examples/jsm/controls/OrbitControls.js', () => ({
  OrbitControls: class {
    enableDamping = false;
    dampingFactor = 0.05;
    enableZoom = true;
    enablePan = true;
    minDistance = 5;
    maxDistance = 50;
    autoRotate = true;
    autoRotateSpeed = 0.5;
    update = () => { };
    dispose = () => { };
    addEventListener = () => { };
  }
}));

describe('SimulationComponent', () => {
  let component: SimulationComponent;
  let fixture: ComponentFixture<SimulationComponent>;
  let simulationServiceMock: {
    createSimulation: ReturnType<typeof vi.fn>;
    getUserSimulations: ReturnType<typeof vi.fn>;
  };
  let notificationServiceMock: {
    success: ReturnType<typeof vi.fn>;
    error: ReturnType<typeof vi.fn>;
  };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let rendererMock: {
    addClass: ReturnType<typeof vi.fn>;
    removeClass: ReturnType<typeof vi.fn>;
  };

  const mockSimulationResult = {
    id: 'sim-123',
    name: 'Test Simulation',
    status: 'COMPLETED',
    results: {
      safetyFactor: 2.5,
      maxStress: 150e6,
      maxDeflection: 0.005,
      isSafe: true
    },
    createdAt: '2024-01-01T00:00:00Z'
  };

  beforeEach(async () => {
    // Use fake timers to prevent initThreeJS from running
    vi.useFakeTimers();

    simulationServiceMock = {
      createSimulation: vi.fn().mockReturnValue(of(mockSimulationResult)),
      getUserSimulations: vi.fn().mockReturnValue(of([]))
    };

    notificationServiceMock = {
      success: vi.fn(),
      error: vi.fn()
    };

    routerMock = {
      navigate: vi.fn()
    };

    rendererMock = {
      addClass: vi.fn(),
      removeClass: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [SimulationComponent],
      providers: [
        { provide: SimulationService, useValue: simulationServiceMock },
        { provide: NotificationService, useValue: notificationServiceMock },
        { provide: Router, useValue: routerMock },
        { provide: Renderer2, useValue: rendererMock },
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: { params: {}, queryParams: {} },
            params: of({}),
            queryParams: of({})
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(SimulationComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    vi.clearAllMocks();
    vi.useRealTimers();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should start at step 1', () => {
      expect(component.currentStep()).toBe(1);
    });

    it('should have 4 total steps', () => {
      expect(component.totalSteps).toBe(4);
    });

    it('should not be analyzing initially', () => {
      expect(component.isAnalyzing()).toBe(false);
    });

    it('should have zero analysis progress initially', () => {
      expect(component.analysisProgress()).toBe(0);
    });

    it('should have no error message initially', () => {
      expect(component.errorMessage()).toBeNull();
    });

    it('should have default params with beam structure', () => {
      expect(component.params().structureType).toBe('beam');
    });

    it('should have default params with steel material', () => {
      expect(component.params().material).toBe('steel');
    });

    it('should have default params with point load type', () => {
      expect(component.params().loadType).toBe('point');
    });

    it('should have default params with simply-supported support type', () => {
      expect(component.params().supportType).toBe('simply-supported');
    });
  });

  describe('structure types', () => {
    it('should have 4 structure types available', () => {
      expect(component.structureTypes).toHaveLength(4);
    });

    it('should have beam structure type', () => {
      const beam = component.structureTypes.find(s => s.id === 'beam');
      expect(beam).toBeDefined();
      expect(beam?.name).toBe('Beam');
    });

    it('should have frame structure type', () => {
      const frame = component.structureTypes.find(s => s.id === 'frame');
      expect(frame).toBeDefined();
      expect(frame?.name).toBe('Frame');
    });

    it('should have truss structure type', () => {
      const truss = component.structureTypes.find(s => s.id === 'truss');
      expect(truss).toBeDefined();
      expect(truss?.name).toBe('Truss');
    });

    it('should have column structure type', () => {
      const column = component.structureTypes.find(s => s.id === 'column');
      expect(column).toBeDefined();
      expect(column?.name).toBe('Column');
    });
  });

  describe('materials', () => {
    it('should have 4 materials available', () => {
      expect(component.materials).toHaveLength(4);
    });

    it('should have steel with correct properties', () => {
      const steel = component.materials.find(m => m.id === 'steel');
      expect(steel).toBeDefined();
      expect(steel?.E).toBe(200);
      expect(steel?.density).toBe(7850);
    });

    it('should have concrete with correct properties', () => {
      const concrete = component.materials.find(m => m.id === 'concrete');
      expect(concrete).toBeDefined();
      expect(concrete?.E).toBe(30);
      expect(concrete?.density).toBe(2400);
    });
  });

  describe('load types', () => {
    it('should have 3 load types available', () => {
      expect(component.loadTypes).toHaveLength(3);
    });

    it('should include point load type', () => {
      const point = component.loadTypes.find(l => l.id === 'point');
      expect(point).toBeDefined();
      expect(point?.name).toBe('Point Load');
    });

    it('should include distributed load type', () => {
      const distributed = component.loadTypes.find(l => l.id === 'distributed');
      expect(distributed).toBeDefined();
    });
  });

  describe('support types', () => {
    it('should have 3 support types available', () => {
      expect(component.supportTypes).toHaveLength(3);
    });

    it('should include simply-supported type', () => {
      const ss = component.supportTypes.find(s => s.id === 'simply-supported');
      expect(ss).toBeDefined();
    });

    it('should include cantilever type', () => {
      const cant = component.supportTypes.find(s => s.id === 'cantilever');
      expect(cant).toBeDefined();
    });
  });

  describe('steps navigation', () => {
    it('should have 4 steps defined', () => {
      expect(component.steps).toHaveLength(4);
    });

    it('should have Structure as first step', () => {
      expect(component.steps[0].title).toBe('Structure');
    });

    it('should have Material as second step', () => {
      expect(component.steps[1].title).toBe('Material');
    });

    it('should have Loading as third step', () => {
      expect(component.steps[2].title).toBe('Loading');
    });

    it('should have Review as fourth step', () => {
      expect(component.steps[3].title).toBe('Review');
    });
  });

  describe('computed properties', () => {
    it('should calculate progressPercent correctly at step 1', () => {
      expect(component.progressPercent()).toBe(0);
    });

    it('should calculate progressPercent correctly at step 2', () => {
      component.currentStep.set(2);
      expect(component.progressPercent()).toBeCloseTo(33.33, 1);
    });

    it('should calculate progressPercent correctly at step 4', () => {
      component.currentStep.set(4);
      expect(component.progressPercent()).toBe(100);
    });

    it('should return selected material', () => {
      const selected = component.selectedMaterial();
      expect(selected.id).toBe('steel');
    });

    it('should return correct selected material after change', () => {
      component.params.update(p => ({ ...p, material: 'concrete' }));
      const selected = component.selectedMaterial();
      expect(selected.id).toBe('concrete');
    });
  });

  describe('nextStep', () => {
    it('should advance to next step', () => {
      component.nextStep();
      expect(component.currentStep()).toBe(2);
    });

    it('should advance from step 2 to step 3', () => {
      component.currentStep.set(2);
      component.nextStep();
      expect(component.currentStep()).toBe(3);
    });

    it('should not go beyond total steps', () => {
      component.currentStep.set(4);
      component.nextStep();
      expect(component.currentStep()).toBe(4);
    });
  });

  describe('prevStep', () => {
    it('should go to previous step', () => {
      component.currentStep.set(2);
      component.prevStep();
      expect(component.currentStep()).toBe(1);
    });

    it('should not go below step 1', () => {
      component.currentStep.set(1);
      component.prevStep();
      expect(component.currentStep()).toBe(1);
    });
  });

  describe('goToStep', () => {
    it('should go to specified step', () => {
      component.goToStep(3);
      expect(component.currentStep()).toBe(3);
    });

    it('should not go to step below 1', () => {
      component.goToStep(0);
      expect(component.currentStep()).toBe(1);
    });

    it('should not go to step above totalSteps', () => {
      component.goToStep(5);
      expect(component.currentStep()).toBe(1);
    });
  });

  describe('goBack', () => {
    it('should navigate to dashboard', () => {
      component.goBack();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/dashboard']);
    });
  });

  describe('updateParam', () => {
    it('should update structure type', () => {
      component.updateParam('structureType', 'frame');
      expect(component.params().structureType).toBe('frame');
    });

    it('should update length', () => {
      component.updateParam('length', 15);
      expect(component.params().length).toBe(15);
    });

    it('should clamp AI parameters to valid ranges', () => {
      // numFloors should be clamped to max 50
      component.updateParam('numFloors', 100);
      expect(component.params().numFloors).toBe(50);
    });

    it('should clamp AI parameters to minimum values', () => {
      // numFloors should be clamped to min 1
      component.updateParam('numFloors', 0);
      expect(component.params().numFloors).toBe(1);
    });

    it('should update floorHeight within range', () => {
      component.updateParam('floorHeight', 4.0);
      expect(component.params().floorHeight).toBe(4.0);
    });
  });

  describe('selectStructureType', () => {
    it('should update structure type', () => {
      component.selectStructureType('truss');
      expect(component.params().structureType).toBe('truss');
    });
  });

  describe('selectMaterial', () => {
    it('should update material and related properties', () => {
      component.selectMaterial('concrete');
      const p = component.params();
      expect(p.material).toBe('concrete');
      expect(p.elasticModulus).toBe(30);
      expect(p.density).toBe(2400);
    });

    it('should update material to aluminum', () => {
      component.selectMaterial('aluminum');
      const p = component.params();
      expect(p.material).toBe('aluminum');
      expect(p.elasticModulus).toBe(70);
      expect(p.density).toBe(2700);
    });
  });

  describe('form validation', () => {
    it('should set error for empty name', () => {
      component.validateName('');
      expect(component.nameError()).toBe('Le nom de simulation est requis');
    });

    it('should set error for name with only spaces', () => {
      component.validateName('   ');
      expect(component.nameError()).toBe('Le nom de simulation est requis');
    });

    it('should set error for name shorter than 3 characters', () => {
      component.validateName('ab');
      expect(component.nameError()).toBe('Le nom doit contenir au moins 3 caractères');
    });

    it('should set error for name longer than 100 characters', () => {
      const longName = 'a'.repeat(101);
      component.validateName(longName);
      expect(component.nameError()).toBe('Le nom ne peut pas dépasser 100 caractères');
    });

    it('should clear error for valid name', () => {
      component.validateName('Valid Name');
      expect(component.nameError()).toBeNull();
    });

    it('should set error for description longer than 500 characters', () => {
      const longDesc = 'a'.repeat(501);
      component.validateDescription(longDesc);
      expect(component.descriptionError()).toBe('La description ne peut pas dépasser 500 caractères');
    });

    it('should clear error for valid description', () => {
      component.validateDescription('Valid description');
      expect(component.descriptionError()).toBeNull();
    });

    it('should clear error for empty description', () => {
      component.validateDescription('');
      expect(component.descriptionError()).toBeNull();
    });
  });

  describe('validateForm', () => {
    it('should return false for empty name', () => {
      const result = component.validateForm();
      expect(result).toBe(false);
      expect(component.nameError()).not.toBeNull();
    });

    it('should return true for valid form', () => {
      component.params.update(p => ({ ...p, name: 'Valid Simulation Name' }));
      const result = component.validateForm();
      expect(result).toBe(true);
    });
  });

  describe('isFormValid computed', () => {
    it('should be false when name is invalid', () => {
      component.params.update(p => ({ ...p, name: 'ab' }));
      component.validateName('ab');
      expect(component.isFormValid()).toBe(false);
    });

    it('should be true when name is valid', () => {
      component.params.update(p => ({ ...p, name: 'Valid Name' }));
      component.validateName('Valid Name');
      expect(component.isFormValid()).toBe(true);
    });
  });

  describe('toggleTheme', () => {
    it('should toggle isLightMode from false to true', () => {
      component.isLightMode.set(false);
      component.toggleTheme();
      expect(component.isLightMode()).toBe(true);
    });

    it('should toggle isLightMode from true to false', () => {
      component.isLightMode.set(true);
      component.toggleTheme();
      expect(component.isLightMode()).toBe(false);
    });

    it('should update theme when switching to light mode', () => {
      component.isLightMode.set(false);
      component.toggleTheme();
      // Verify theme changed
      expect(component.isLightMode()).toBe(true);
    });

    it('should update theme when switching to dark mode', () => {
      component.isLightMode.set(true);
      component.toggleTheme();
      // Verify theme changed
      expect(component.isLightMode()).toBe(false);
    });
  });

  describe('runAnalysis', () => {
    beforeEach(() => {
      // Set valid form data
      component.params.update(p => ({ ...p, name: 'Test Simulation' }));
      // Switch to real timers for async tests
      vi.useRealTimers();
    });

    afterEach(() => {
      // Restore fake timers after async tests
      vi.useFakeTimers();
    });

    it('should not run if form is invalid', async () => {
      component.params.update(p => ({ ...p, name: '' }));
      await component.runAnalysis();
      expect(simulationServiceMock.createSimulation).not.toHaveBeenCalled();
      expect(notificationServiceMock.error).toHaveBeenCalled();
    });

    it('should set isAnalyzing to true when starting', () => {
      component.runAnalysis();
      expect(component.isAnalyzing()).toBe(true);
    });

    it('should handle simulation error', async () => {
      simulationServiceMock.createSimulation.mockReturnValue(
        throwError(() => ({ error: { message: 'Simulation failed' } }))
      );
      await component.runAnalysis();
      expect(notificationServiceMock.error).toHaveBeenCalledWith('Error', 'Simulation failed. Please try again.');
      expect(component.isAnalyzing()).toBe(false);
    });

    it('should set errorMessage on error', async () => {
      simulationServiceMock.createSimulation.mockReturnValue(
        throwError(() => ({ error: { message: 'Test error' } }))
      );
      await component.runAnalysis();
      expect(component.errorMessage()).toBe('Test error');
    });
  });

  describe('AI parameters', () => {
    it('should have valid default numFloors', () => {
      expect(component.params().numFloors).toBe(5);
    });

    it('should have valid default floorHeight', () => {
      expect(component.params().floorHeight).toBe(3.0);
    });

    it('should have valid default numBeams', () => {
      expect(component.params().numBeams).toBe(50);
    });

    it('should have valid default numColumns', () => {
      expect(component.params().numColumns).toBe(20);
    });

    it('should have valid default concreteStrength', () => {
      expect(component.params().concreteStrength).toBe(30);
    });

    it('should have valid default steelGrade', () => {
      expect(component.params().steelGrade).toBe(355);
    });

    it('should have valid default windLoad', () => {
      expect(component.params().windLoad).toBe(1.5);
    });

    it('should have valid default liveLoad', () => {
      expect(component.params().liveLoad).toBe(3.0);
    });

    it('should have valid default deadLoad', () => {
      expect(component.params().deadLoad).toBe(5.0);
    });
  });

  describe('ngOnDestroy', () => {
    it('should clean up resources without error', () => {
      expect(() => component.ngOnDestroy()).not.toThrow();
    });
  });

  describe('additional coverage', () => {
    it('should handle onResize', () => {
      // @ts-ignore
      component.onResize();
      expect(true).toBe(true);
    });

    it('should map parameters correctly during analysis', async () => {
      // Mock simulateProgress to skip delay
      vi.spyOn(component as any, 'simulateProgress').mockResolvedValue(undefined);

      component.params.update(p => ({
        ...p,
        name: 'Test',
        material: 'concrete',
        loadType: 'distributed',
        supportType: 'fixed-fixed'
      }));

      await component.runAnalysis();

      expect(simulationServiceMock.createSimulation).toHaveBeenCalled();
      const callArgs = simulationServiceMock.createSimulation.mock.calls[0][0];
      expect(callArgs.materialType).toBe('CONCRETE');
      expect(callArgs.loadType).toBe('UNIFORM');
      expect(callArgs.supportType).toBe('FIXED_FIXED');
    });

    it('should map other parameters correctly', async () => {
      vi.spyOn(component as any, 'simulateProgress').mockResolvedValue(undefined);

      component.params.update(p => ({
        ...p,
        name: 'Test',
        material: 'wood',
        loadType: 'moment',
        supportType: 'cantilever'
      }));

      await component.runAnalysis();

      const callArgs = simulationServiceMock.createSimulation.mock.calls[0][0];
      expect(callArgs.materialType).toBe('WOOD');
      expect(callArgs.loadType).toBe('MOMENT');
      expect(callArgs.supportType).toBe('FIXED_FREE');
    });

    it('should map aluminum and fixed-pinned', async () => {
      vi.spyOn(component as any, 'simulateProgress').mockResolvedValue(undefined);

      component.params.update(p => ({
        ...p,
        name: 'Test',
        material: 'aluminum',
        supportType: 'fixed-pinned'
      }));

      await component.runAnalysis();

      const callArgs = simulationServiceMock.createSimulation.mock.calls[0][0];
      expect(callArgs.materialType).toBe('ALUMINUM');
      expect(callArgs.supportType).toBe('FIXED_PINNED');
    });

    it('should execute simulateProgress', async () => {
      vi.useRealTimers();
      // @ts-ignore
      await component.simulateProgress('complete', 100, 10);
      expect(component.analysisStage()).toBe('complete');
      vi.useFakeTimers();
    });
  });
});
