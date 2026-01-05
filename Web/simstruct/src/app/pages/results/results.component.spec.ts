import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute, convertToParamMap } from '@angular/router';
import { of, throwError } from 'rxjs';
import { ResultsComponent } from './results.component';
import { SimulationService, SimulationResponse } from '../../core/services/simulation.service';
import { NotificationService } from '../../core/services/notification.service';

// Mock Three.js
vi.mock('three', () => ({
  Scene: vi.fn().mockImplementation(() => ({
    add: vi.fn(),
    remove: vi.fn(),
    background: null,
    children: []
  })),
  PerspectiveCamera: vi.fn().mockImplementation(() => ({
    position: { set: vi.fn() },
    lookAt: vi.fn(),
    aspect: 1,
    updateProjectionMatrix: vi.fn()
  })),
  WebGLRenderer: vi.fn().mockImplementation(() => ({
    setSize: vi.fn(),
    setPixelRatio: vi.fn(),
    render: vi.fn(),
    dispose: vi.fn()
  })),
  Color: vi.fn().mockImplementation(() => ({})),
  GridHelper: vi.fn().mockImplementation(() => ({})),
  BoxGeometry: vi.fn().mockImplementation(() => ({})),
  ConeGeometry: vi.fn().mockImplementation(() => ({})),
  MeshStandardMaterial: vi.fn().mockImplementation(() => ({})),
  Mesh: vi.fn().mockImplementation(() => ({
    position: { set: vi.fn(), y: 0 }
  })),
  Group: vi.fn().mockImplementation(() => ({
    add: vi.fn(),
    children: []
  })),
  AmbientLight: vi.fn().mockImplementation(() => ({})),
  DirectionalLight: vi.fn().mockImplementation(() => ({
    position: { set: vi.fn() }
  }))
}));

// Mock OrbitControls
vi.mock('three/examples/jsm/controls/OrbitControls.js', () => ({
  OrbitControls: vi.fn().mockImplementation(() => ({
    enableDamping: false,
    autoRotate: true,
    autoRotateSpeed: 0.5,
    update: vi.fn(),
    dispose: vi.fn()
  }))
}));

describe('ResultsComponent', () => {
  let component: ResultsComponent;
  let fixture: ComponentFixture<ResultsComponent>;
  let simulationServiceMock: {
    getSimulation: ReturnType<typeof vi.fn>;
    togglePublic: ReturnType<typeof vi.fn>;
  };
  let notificationServiceMock: {
    success: ReturnType<typeof vi.fn>;
    error: ReturnType<typeof vi.fn>;
  };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };

  const mockSimulation: SimulationResponse = {
    id: 'sim-123',
    name: 'Test Beam Simulation',
    description: 'A test simulation',
    beamLength: 10,
    beamWidth: 0.5,
    beamHeight: 0.8,
    materialType: 'STEEL',
    elasticModulus: 200e9,
    density: 7850,
    yieldStrength: 250e6,
    loadType: 'POINT',
    loadMagnitude: 50000,
    loadPosition: 5,
    supportType: 'SIMPLY_SUPPORTED',
    status: 'COMPLETED',
    isPublic: false,
    isFavorite: false,
    likesCount: 0,
    results: {
      maxDeflection: 0.005,
      maxBendingMoment: 125000,
      maxShearForce: 25000,
      maxStress: 150e6,
      safetyFactor: 2.5,
      isSafe: true,
      recommendations: 'Structure is safe.',
      naturalFrequency: 10.5,
      weight: 314
    },
    userId: 'user-1',
    userName: 'Test User',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z'
  };

  const mockSimulationWithAI: SimulationResponse = {
    ...mockSimulation,
    results: {
      ...mockSimulation.results,
      aiPredictions: {
        stabilityIndex: 0.85,
        seismicResistance: 0.75,
        crackRisk: 0.15,
        foundationStability: 0.9
      }
    }
  };

  beforeEach(async () => {
    simulationServiceMock = {
      getSimulation: vi.fn().mockReturnValue(of(mockSimulation)),
      togglePublic: vi.fn().mockReturnValue(of({ ...mockSimulation, isPublic: true }))
    };

    notificationServiceMock = {
      success: vi.fn(),
      error: vi.fn()
    };

    routerMock = {
      navigate: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [ResultsComponent],
      providers: [
        { provide: SimulationService, useValue: simulationServiceMock },
        { provide: NotificationService, useValue: notificationServiceMock },
        { provide: Router, useValue: routerMock },
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: { 
              params: {}, 
              queryParams: {},
              paramMap: convertToParamMap({ id: 'sim-123' })
            },
            params: of({}),
            queryParams: of({})
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(ResultsComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    vi.clearAllMocks();
    localStorage.clear();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should not be loading initially', () => {
      expect(component.isLoading()).toBe(false);
    });

    it('should have no load error initially', () => {
      expect(component.loadError()).toBeNull();
    });

    it('should have null simulation data initially', () => {
      expect(component.simulationData()).toBeNull();
    });

    it('should have default simulation name', () => {
      expect(component.simulationName()).toBe('Simulation Results');
    });

    it('should have default overall status as safe', () => {
      expect(component.overallStatus()).toBe('safe');
    });

    it('should have default safety factor', () => {
      expect(component.safetyFactor()).toBe(2.5);
    });

    it('should have default AI confidence', () => {
      expect(component.aiConfidence()).toBe(95);
    });

    it('should have empty results array initially', () => {
      expect(component.results()).toHaveLength(0);
    });

    it('should have empty recommendations initially', () => {
      expect(component.recommendations()).toHaveLength(0);
    });

    it('should have active tab as 3d by default', () => {
      expect(component.activeTab()).toBe('3d');
    });

    it('should show stress visualization by default', () => {
      expect(component.showStressVisualization()).toBe(true);
    });
  });

  describe('ngOnInit with ID', () => {
    beforeEach(() => {
      TestBed.resetTestingModule();
    });

    it('should load simulation when ID is provided', async () => {
      await TestBed.configureTestingModule({
        imports: [ResultsComponent],
        providers: [
          { provide: SimulationService, useValue: simulationServiceMock },
          { provide: NotificationService, useValue: notificationServiceMock },
          { provide: Router, useValue: routerMock },
          {
            provide: ActivatedRoute,
            useValue: {
              snapshot: { 
                params: { id: 'sim-123' }, 
                queryParams: {},
                paramMap: convertToParamMap({ id: 'sim-123' })
              },
              params: of({ id: 'sim-123' }),
              queryParams: of({})
            }
          }
        ]
      }).compileComponents();

      fixture = TestBed.createComponent(ResultsComponent);
      component = fixture.componentInstance;
      
      component.ngOnInit();
      
      expect(simulationServiceMock.getSimulation).toHaveBeenCalledWith('sim-123');
    });
  });

  describe('populateResults', () => {
    it('should set simulation data', () => {
      (component as any).populateResults(mockSimulation);
      expect(component.simulationData()).toEqual(mockSimulation);
    });

    it('should set simulation name', () => {
      (component as any).populateResults(mockSimulation);
      expect(component.simulationName()).toBe('Test Beam Simulation');
    });

    it('should set structure type', () => {
      (component as any).populateResults(mockSimulation);
      expect(component.structureType()).toBe('SIMPLY_SUPPORTED');
    });

    it('should set material', () => {
      (component as any).populateResults(mockSimulation);
      expect(component.material()).toBe('STEEL');
    });

    it('should set safety factor from results', () => {
      (component as any).populateResults(mockSimulation);
      expect(component.safetyFactor()).toBe(2.5);
    });

    it('should set overall status to safe for SF >= 2.0', () => {
      (component as any).populateResults(mockSimulation);
      expect(component.overallStatus()).toBe('safe');
    });

    it('should set overall status to warning for 1.0 <= SF < 2.0', () => {
      const warnSim = { 
        ...mockSimulation, 
        results: { ...mockSimulation.results, safetyFactor: 1.5 } 
      };
      (component as any).populateResults(warnSim);
      expect(component.overallStatus()).toBe('warning');
    });

    it('should set overall status to critical for SF < 1.0', () => {
      const critSim = { 
        ...mockSimulation, 
        results: { ...mockSimulation.results, safetyFactor: 0.8 } 
      };
      (component as any).populateResults(critSim);
      expect(component.overallStatus()).toBe('critical');
    });

    it('should populate results array with base results', () => {
      (component as any).populateResults(mockSimulation);
      const results = component.results();
      expect(results.length).toBeGreaterThan(0);
    });

    it('should include stress in results', () => {
      (component as any).populateResults(mockSimulation);
      const stressResult = component.results().find(r => r.metric === 'Max Stress');
      expect(stressResult).toBeDefined();
    });

    it('should include deflection in results', () => {
      (component as any).populateResults(mockSimulation);
      const deflResult = component.results().find(r => r.metric === 'Max Deflection');
      expect(deflResult).toBeDefined();
    });

    it('should include safety factor in results', () => {
      (component as any).populateResults(mockSimulation);
      const sfResult = component.results().find(r => r.metric === 'Safety Factor');
      expect(sfResult).toBeDefined();
    });
  });

  describe('populateResults with AI predictions', () => {
    it('should include AI results when aiPredictions is present', () => {
      (component as any).populateResults(mockSimulationWithAI);
      const aiResult = component.results().find(r => r.category === 'AI Analysis');
      expect(aiResult).toBeDefined();
    });

    it('should include stability index', () => {
      (component as any).populateResults(mockSimulationWithAI);
      const stabilityResult = component.results().find(r => r.metric === 'Stability Index');
      expect(stabilityResult).toBeDefined();
      expect(stabilityResult?.value).toBe(85);
    });

    it('should include seismic resistance', () => {
      (component as any).populateResults(mockSimulationWithAI);
      const seismicResult = component.results().find(r => r.metric === 'Seismic Resistance');
      expect(seismicResult).toBeDefined();
      expect(seismicResult?.value).toBe(75);
    });

    it('should include crack risk', () => {
      (component as any).populateResults(mockSimulationWithAI);
      const crackResult = component.results().find(r => r.metric === 'Crack Risk');
      expect(crackResult).toBeDefined();
      expect(crackResult?.value).toBe(15);
    });

    it('should include foundation stability', () => {
      (component as any).populateResults(mockSimulationWithAI);
      const foundationResult = component.results().find(r => r.metric === 'Foundation Stability');
      expect(foundationResult).toBeDefined();
      expect(foundationResult?.value).toBe(90);
    });

    it('should update AI confidence based on predictions', () => {
      (component as any).populateResults(mockSimulationWithAI);
      expect(component.aiConfidence()).toBeGreaterThan(0);
    });

    it('should generate AI-specific recommendations', () => {
      (component as any).populateResults(mockSimulationWithAI);
      const recs = component.recommendations();
      expect(recs.length).toBeGreaterThan(0);
    });
  });

  describe('generateAIRecommendations', () => {
    const aiPredictions = {
      stabilityIndex: 0.85,
      seismicResistance: 0.75,
      crackRisk: 0.15,
      foundationStability: 0.9
    };

    it('should generate success recommendation for safe structure', () => {
      (component as any).generateAIRecommendations(aiPredictions, 2.5);
      const recs = component.recommendations();
      expect(recs.some(r => r.type === 'success')).toBe(true);
    });

    it('should generate warning for low seismic resistance', () => {
      const lowSeismic = { ...aiPredictions, seismicResistance: 0.5 };
      (component as any).generateAIRecommendations(lowSeismic, 2.0);
      const recs = component.recommendations();
      expect(recs.some(r => r.title.includes('Seismic'))).toBe(true);
    });

    it('should generate warning for high crack risk', () => {
      const highCrack = { ...aiPredictions, crackRisk: 0.6 };
      (component as any).generateAIRecommendations(highCrack, 2.0);
      const recs = component.recommendations();
      expect(recs.some(r => r.title.includes('Crack'))).toBe(true);
    });

    it('should generate warning for low foundation stability', () => {
      const lowFoundation = { ...aiPredictions, foundationStability: 0.6 };
      (component as any).generateAIRecommendations(lowFoundation, 2.0);
      const recs = component.recommendations();
      expect(recs.some(r => r.title.includes('Foundation'))).toBe(true);
    });

    it('should generate info for over-design', () => {
      const overDesign = { ...aiPredictions, stabilityIndex: 0.95 };
      (component as any).generateAIRecommendations(overDesign, 3.5);
      const recs = component.recommendations();
      expect(recs.some(r => r.type === 'info' && r.title.includes('Over-Design'))).toBe(true);
    });
  });

  describe('getStatus', () => {
    it('should return safe for value below 70% of threshold', () => {
      const status = (component as any).getStatus(60, 100);
      expect(status).toBe('safe');
    });

    it('should return warning for value between 70% and 100% of threshold', () => {
      const status = (component as any).getStatus(80, 100);
      expect(status).toBe('warning');
    });

    it('should return critical for value above threshold', () => {
      const status = (component as any).getStatus(110, 100);
      expect(status).toBe('critical');
    });

    it('should handle inverse correctly - safe when above threshold', () => {
      const status = (component as any).getStatus(80, 70, true);
      expect(status).toBe('safe');
    });

    it('should handle inverse correctly - critical when below threshold', () => {
      const status = (component as any).getStatus(40, 70, true);
      expect(status).toBe('critical');
    });
  });

  describe('tab navigation', () => {
    it('should set active tab to stress', () => {
      component.setActiveTab('stress');
      expect(component.activeTab()).toBe('stress');
    });

    it('should set active tab to deformation', () => {
      component.setActiveTab('deformation');
      expect(component.activeTab()).toBe('deformation');
    });

    it('should set active tab to 3d', () => {
      component.setActiveTab('3d');
      expect(component.activeTab()).toBe('3d');
    });
  });

  describe('getStatusClass', () => {
    it('should return status-safe for safe status', () => {
      expect(component.getStatusClass('safe')).toBe('status-safe');
    });

    it('should return status-warning for warning status', () => {
      expect(component.getStatusClass('warning')).toBe('status-warning');
    });

    it('should return status-critical for critical status', () => {
      expect(component.getStatusClass('critical')).toBe('status-critical');
    });
  });

  describe('getSafetyClass', () => {
    it('should return safe for factor >= 2.0', () => {
      expect(component.getSafetyClass(2.5)).toBe('safe');
    });

    it('should return warning for factor >= 1.0 and < 2.0', () => {
      expect(component.getSafetyClass(1.5)).toBe('warning');
    });

    it('should return critical for factor < 1.0', () => {
      expect(component.getSafetyClass(0.8)).toBe('critical');
    });
  });

  describe('getStatusIcon', () => {
    it('should return checkmark for safe', () => {
      expect(component.getStatusIcon('safe')).toBe('✓');
    });

    it('should return warning icon for warning', () => {
      expect(component.getStatusIcon('warning')).toBe('⚠');
    });

    it('should return X for critical', () => {
      expect(component.getStatusIcon('critical')).toBe('✕');
    });
  });

  describe('getSafetyBarWidth', () => {
    it('should return 100 for safety factor 3.0', () => {
      component.safetyFactor.set(3.0);
      expect(component.getSafetyBarWidth()).toBe(100);
    });

    it('should return percentage based on safety factor', () => {
      component.safetyFactor.set(1.5);
      expect(component.getSafetyBarWidth()).toBe(50);
    });

    it('should cap at 100 for high safety factors', () => {
      component.safetyFactor.set(5.0);
      expect(component.getSafetyBarWidth()).toBe(100);
    });
  });

  describe('toggleStressVisualization', () => {
    it('should toggle from true to false', () => {
      component.showStressVisualization.set(true);
      component.toggleStressVisualization();
      expect(component.showStressVisualization()).toBe(false);
    });

    it('should toggle from false to true', () => {
      component.showStressVisualization.set(false);
      component.toggleStressVisualization();
      expect(component.showStressVisualization()).toBe(true);
    });
  });

  describe('getValuePercentage', () => {
    it('should return correct percentage', () => {
      expect(component.getValuePercentage(50, 100)).toBe(50);
    });

    it('should cap at 100 for value above threshold', () => {
      expect(component.getValuePercentage(150, 100)).toBe(100);
    });

    it('should return 0 for value 0', () => {
      expect(component.getValuePercentage(0, 100)).toBe(0);
    });
  });

  describe('navigation methods', () => {
    it('should navigate to simulation on newSimulation', () => {
      component.newSimulation();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/simulation']);
    });

    it('should navigate to history on compareResults', () => {
      component.compareResults();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/history']);
    });

    it('should navigate to simulation on modifyParameters', () => {
      component.modifyParameters();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/simulation']);
    });
  });

  describe('shareResults', () => {
    beforeEach(() => {
      (component as any).populateResults(mockSimulation);
    });

    it('should call togglePublic when sharing', () => {
      component.shareResults();
      expect(simulationServiceMock.togglePublic).toHaveBeenCalledWith('sim-123');
    });

    it('should show success notification on share', () => {
      component.shareResults();
      expect(notificationServiceMock.success).toHaveBeenCalledWith('Shared', 'Simulation is now public and can be viewed by others.');
    });

    it('should show error notification on share failure', () => {
      simulationServiceMock.togglePublic.mockReturnValue(
        throwError(() => new Error('Share failed'))
      );
      component.shareResults();
      expect(notificationServiceMock.error).toHaveBeenCalledWith('Error', 'Failed to share simulation.');
    });
  });

  describe('formatDate', () => {
    it('should format date correctly', () => {
      const date = new Date('2024-01-15');
      const formatted = component.formatDate(date);
      expect(formatted).toContain('Jan');
      expect(formatted).toContain('15');
      expect(formatted).toContain('2024');
    });
  });

  describe('exportReport', () => {
    beforeEach(() => {
      (component as any).populateResults(mockSimulation);
    });

    it('should show error when no simulation data', () => {
      component.simulationData.set(null);
      component.exportReport('pdf');
      expect(notificationServiceMock.error).toHaveBeenCalledWith('Error', 'No simulation data to export.');
    });

    it('should export as PDF', () => {
      const openSpy = vi.spyOn(window, 'open').mockReturnValue({
        document: {
          write: vi.fn(),
          close: vi.fn()
        },
        focus: vi.fn(),
        print: vi.fn()
      } as any);
      
      component.exportReport('pdf');
      expect(openSpy).toHaveBeenCalled();
      openSpy.mockRestore();
    });

    it('should export as JSON', () => {
      const createObjectURLSpy = vi.spyOn(URL, 'createObjectURL').mockReturnValue('blob:test');
      const revokeObjectURLSpy = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => {});
      
      component.exportReport('json');
      expect(notificationServiceMock.success).toHaveBeenCalledWith('JSON Export', 'JSON file downloaded successfully.');
      
      createObjectURLSpy.mockRestore();
      revokeObjectURLSpy.mockRestore();
    });

    it('should export as CSV', () => {
      const createObjectURLSpy = vi.spyOn(URL, 'createObjectURL').mockReturnValue('blob:test');
      const revokeObjectURLSpy = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => {});
      
      component.exportReport('csv');
      expect(notificationServiceMock.success).toHaveBeenCalledWith('CSV Export', 'CSV file downloaded successfully.');
      
      createObjectURLSpy.mockRestore();
      revokeObjectURLSpy.mockRestore();
    });
  });

  describe('loadFromLocalStorage', () => {
    it('should load from localStorage when available', () => {
      localStorage.setItem('lastSimulationResult', JSON.stringify(mockSimulation));
      (component as any).loadFromLocalStorage();
      expect(component.simulationData()).toEqual(mockSimulation);
    });

    it('should remove item after loading', () => {
      localStorage.setItem('lastSimulationResult', JSON.stringify(mockSimulation));
      (component as any).loadFromLocalStorage();
      expect(localStorage.getItem('lastSimulationResult')).toBeNull();
    });

    it('should handle parse errors gracefully', () => {
      localStorage.setItem('lastSimulationResult', 'invalid json');
      expect(() => (component as any).loadFromLocalStorage()).not.toThrow();
    });
  });

  describe('ngOnDestroy', () => {
    it('should clean up resources without error', () => {
      expect(() => component.ngOnDestroy()).not.toThrow();
    });
  });
});
