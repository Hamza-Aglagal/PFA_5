import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed } from '@angular/core/testing';
import { HttpClient } from '@angular/common/http';
import { of, throwError, firstValueFrom } from 'rxjs';
import { SimulationService, SimulationRequest, SimulationResponse, SimulationResults } from './simulation.service';

describe('SimulationService', () => {
  let service: SimulationService;
  let httpClientSpy: {
    get: ReturnType<typeof vi.fn>;
    post: ReturnType<typeof vi.fn>;
    put: ReturnType<typeof vi.fn>;
    delete: ReturnType<typeof vi.fn>;
  };

  const mockResults: SimulationResults = {
    maxDeflection: 0.005,
    maxBendingMoment: 1500,
    maxShearForce: 500,
    maxStress: 250,
    safetyFactor: 2.5,
    isSafe: true,
    recommendations: 'Structure is safe'
  };

  const mockSimulation: SimulationResponse = {
    id: 'sim-1',
    name: 'Test Simulation',
    description: 'Test description',
    beamLength: 10,
    beamWidth: 0.3,
    beamHeight: 0.5,
    materialType: 'STEEL',
    elasticModulus: 200000,
    density: 7850,
    yieldStrength: 250,
    loadType: 'POINT',
    loadMagnitude: 10000,
    loadPosition: 5,
    supportType: 'SIMPLY_SUPPORTED',
    status: 'COMPLETED',
    isPublic: false,
    isFavorite: false,
    likesCount: 0,
    results: mockResults,
    userId: 'user-1',
    userName: 'Test User',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z'
  };

  const mockSimulationRequest: SimulationRequest = {
    name: 'New Simulation',
    beamLength: 10,
    beamWidth: 0.3,
    beamHeight: 0.5,
    materialType: 'STEEL',
    loadType: 'POINT',
    loadMagnitude: 10000,
    supportType: 'SIMPLY_SUPPORTED',
    numFloors: 5,
    floorHeight: 3,
    numBeams: 4,
    numColumns: 6,
    beamSection: 0.3,
    columnSection: 0.4,
    concreteStrength: 30,
    steelGrade: 400,
    windLoad: 1.5,
    liveLoad: 2.5,
    deadLoad: 5.0
  };

  beforeEach(() => {
    httpClientSpy = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      delete: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        SimulationService,
        { provide: HttpClient, useValue: httpClientSpy }
      ]
    });

    service = TestBed.inject(SimulationService);
  });

  describe('initialization', () => {
    it('should be created', () => {
      expect(service).toBeTruthy();
    });

    it('should start with empty simulations list', () => {
      expect(service.simulations()).toEqual([]);
    });

    it('should start with no current simulation', () => {
      expect(service.currentSimulation()).toBeNull();
    });

    it('should start with isLoading as false', () => {
      expect(service.isLoading()).toBe(false);
    });
  });

  describe('createSimulation', () => {
    it('should create a simulation successfully', async () => {
      httpClientSpy.post.mockReturnValue(of({ success: true, data: mockSimulation }));

      const result = await firstValueFrom(service.createSimulation(mockSimulationRequest));
      expect(result.id).toBe('sim-1');
      expect(result.name).toBe('Test Simulation');
    });

    it('should set current simulation after creation', async () => {
      httpClientSpy.post.mockReturnValue(of({ success: true, data: mockSimulation }));

      await firstValueFrom(service.createSimulation(mockSimulationRequest));
      expect(service.currentSimulation()?.id).toBe('sim-1');
    });

    it('should add simulation to list', async () => {
      httpClientSpy.post.mockReturnValue(of({ success: true, data: mockSimulation }));

      await firstValueFrom(service.createSimulation(mockSimulationRequest));
      expect(service.simulations().length).toBe(1);
      expect(service.simulations()[0].id).toBe('sim-1');
    });

    it('should handle creation error', async () => {
      httpClientSpy.post.mockReturnValue(throwError(() => new Error('Creation failed')));

      try {
        await firstValueFrom(service.createSimulation(mockSimulationRequest));
      } catch (error: any) {
        expect(error.message).toBe('Creation failed');
        expect(service.isLoading()).toBe(false);
      }
    });
  });

  describe('getSimulation', () => {
    it('should get a simulation by id', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockSimulation }));

      const result = await firstValueFrom(service.getSimulation('sim-1'));
      expect(result.id).toBe('sim-1');
    });

    it('should set current simulation after getting', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockSimulation }));

      await firstValueFrom(service.getSimulation('sim-1'));
      expect(service.currentSimulation()?.id).toBe('sim-1');
    });

    it('should handle get error', async () => {
      httpClientSpy.get.mockReturnValue(throwError(() => new Error('Not found')));

      try {
        await firstValueFrom(service.getSimulation('invalid-id'));
      } catch (error: any) {
        expect(error.message).toBe('Not found');
      }
    });
  });

  describe('getUserSimulations', () => {
    it('should get all user simulations', async () => {
      const simulations = [mockSimulation, { ...mockSimulation, id: 'sim-2' }];
      httpClientSpy.get.mockReturnValue(of(simulations));

      const result = await firstValueFrom(service.getUserSimulations());
      expect(result.length).toBe(2);
    });

    it('should set simulations list', async () => {
      const simulations = [mockSimulation];
      httpClientSpy.get.mockReturnValue(of(simulations));

      await firstValueFrom(service.getUserSimulations());
      expect(service.simulations().length).toBe(1);
    });

    it('should handle empty list', async () => {
      httpClientSpy.get.mockReturnValue(of([]));

      const result = await firstValueFrom(service.getUserSimulations());
      expect(result.length).toBe(0);
      expect(service.simulations()).toEqual([]);
    });
  });

  describe('simulation results', () => {
    it('should have results with safety factor', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockSimulation }));

      const result = await firstValueFrom(service.getSimulation('sim-1'));
      expect(result.results.safetyFactor).toBe(2.5);
      expect(result.results.isSafe).toBe(true);
    });

    it('should have structural analysis results', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockSimulation }));

      const result = await firstValueFrom(service.getSimulation('sim-1'));
      expect(result.results.maxDeflection).toBeDefined();
      expect(result.results.maxBendingMoment).toBeDefined();
      expect(result.results.maxShearForce).toBeDefined();
      expect(result.results.maxStress).toBeDefined();
    });
  });

  describe('simulation status', () => {
    it('should handle PENDING status', async () => {
      const pendingSimulation = { ...mockSimulation, status: 'PENDING' as const };
      httpClientSpy.get.mockReturnValue(of({ success: true, data: pendingSimulation }));

      const result = await firstValueFrom(service.getSimulation('sim-1'));
      expect(result.status).toBe('PENDING');
    });

    it('should handle COMPLETED status', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockSimulation }));

      const result = await firstValueFrom(service.getSimulation('sim-1'));
      expect(result.status).toBe('COMPLETED');
    });

    it('should handle FAILED status', async () => {
      const failedSimulation = { ...mockSimulation, status: 'FAILED' as const };
      httpClientSpy.get.mockReturnValue(of({ success: true, data: failedSimulation }));

      const result = await firstValueFrom(service.getSimulation('sim-1'));
      expect(result.status).toBe('FAILED');
    });
  });
});
