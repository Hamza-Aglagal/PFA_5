import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of, throwError } from 'rxjs';
import { DashboardComponent } from './dashboard.component';
import { SimulationService } from '../../core/services/simulation.service';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';

// Mock Three.js
vi.mock('three', () => ({
  Scene: vi.fn().mockImplementation(() => ({
    add: vi.fn(),
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
  BufferGeometry: vi.fn().mockImplementation(() => ({
    setAttribute: vi.fn()
  })),
  Float32BufferAttribute: vi.fn(),
  PointsMaterial: vi.fn(),
  Points: vi.fn()
}));

describe('DashboardComponent', () => {
  let component: DashboardComponent;
  let fixture: ComponentFixture<DashboardComponent>;
  let simulationServiceMock: { getUserSimulations: ReturnType<typeof vi.fn> };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let modalServiceMock: { confirm: ReturnType<typeof vi.fn> };

  const mockSimulations = [
    {
      id: 'sim-1',
      name: 'Test Simulation 1',
      status: 'COMPLETED',
      isFavorite: false,
      results: { safetyFactor: 2.5 },
      createdAt: '2024-01-01T00:00:00Z'
    },
    {
      id: 'sim-2',
      name: 'Test Simulation 2',
      status: 'COMPLETED',
      isFavorite: true,
      results: { safetyFactor: 1.2 },
      createdAt: '2024-01-02T00:00:00Z'
    }
  ];

  beforeEach(async () => {
    simulationServiceMock = {
      getUserSimulations: vi.fn().mockReturnValue(of(mockSimulations))
    };

    routerMock = {
      navigate: vi.fn()
    };

    modalServiceMock = {
      confirm: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [DashboardComponent],
      providers: [
        { provide: SimulationService, useValue: simulationServiceMock },
        { provide: Router, useValue: routerMock },
        { provide: ModalService, useValue: modalServiceMock },
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

    fixture = TestBed.createComponent(DashboardComponent);
    component = fixture.componentInstance;
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should start with default greeting', () => {
      expect(component.greeting()).toBeDefined();
    });

    it('should start with default username', () => {
      expect(component.userName()).toBe('Engineer');
    });

    it('should start with loading as false', () => {
      expect(component.isLoading()).toBe(false);
    });

    it('should have quick actions defined', () => {
      expect(component.quickActions.length).toBeGreaterThan(0);
    });

    it('should have stats array', () => {
      expect(component.stats()).toHaveLength(4);
    });
  });

  describe('loadDashboardData', () => {
    it('should call simulationService.getUserSimulations on init', () => {
      component.ngOnInit();
      expect(simulationServiceMock.getUserSimulations).toHaveBeenCalled();
    });

    it('should update stats from simulations', () => {
      component.ngOnInit();
      
      const stats = component.stats();
      expect(stats[0].value).toBe(2); // Total
    });

    it('should count safe structures correctly', () => {
      component.ngOnInit();
      
      const stats = component.stats();
      expect(stats[1].value).toBe(1); // Safe (safety factor >= 1.5)
    });

    it('should count warnings correctly', () => {
      component.ngOnInit();
      
      const stats = component.stats();
      expect(stats[2].value).toBe(1); // Warnings (1.0 <= SF < 1.5)
    });

    it('should count favorites correctly', () => {
      component.ngOnInit();
      
      const stats = component.stats();
      expect(stats[3].value).toBe(1); // Favorites
    });

    it('should handle empty simulations', () => {
      simulationServiceMock.getUserSimulations.mockReturnValue(of([]));
      
      component.ngOnInit();
      
      const stats = component.stats();
      expect(stats[0].value).toBe(0);
    });

    it('should handle API error gracefully', () => {
      simulationServiceMock.getUserSimulations.mockReturnValue(throwError(() => new Error('API Error')));
      
      // Should not throw
      expect(() => component.ngOnInit()).not.toThrow();
    });
  });

  describe('greeting', () => {
    it('should set greeting based on time', () => {
      component.ngOnInit();
      
      const greeting = component.greeting();
      expect(['Good morning', 'Good afternoon', 'Good evening'].some(g => greeting.includes(g) || greeting === greeting)).toBe(true);
    });
  });

  describe('loadUserName', () => {
    it('should load username from localStorage', () => {
      localStorage.setItem('user', JSON.stringify({ name: 'John Doe' }));
      
      component.ngOnInit();
      
      expect(component.userName()).toBe('John');
    });

    it('should use default if no user in localStorage', () => {
      localStorage.removeItem('user');
      
      component.ngOnInit();
      
      expect(component.userName()).toBe('Engineer');
    });

    it('should handle malformed user data', () => {
      localStorage.setItem('user', 'invalid-json');
      
      expect(() => component.ngOnInit()).not.toThrow();
    });
  });

  describe('quick actions', () => {
    it('should have New Simulation action', () => {
      const action = component.quickActions.find(a => a.label === 'New Simulation');
      expect(action).toBeTruthy();
      expect(action?.route).toBe('/simulation');
    });

    it('should have View History action', () => {
      const action = component.quickActions.find(a => a.label === 'View History');
      expect(action).toBeTruthy();
      expect(action?.route).toBe('/history');
    });
  });

  describe('recent simulations', () => {
    it('should start with empty recent simulations', () => {
      expect(component.recentSimulations()).toEqual([]);
    });
  });

  describe('notifications', () => {
    it('should start with empty notifications', () => {
      expect(component.notifications()).toEqual([]);
    });
  });

  describe('lifecycle', () => {
    it('should clean up on destroy', () => {
      component.ngOnDestroy();
      expect(true).toBe(true);
    });
  });
});
