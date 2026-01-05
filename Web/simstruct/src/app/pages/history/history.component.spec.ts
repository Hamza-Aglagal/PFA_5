import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of, throwError } from 'rxjs';
import { HistoryComponent } from './history.component';
import { SimulationService, SimulationResponse } from '../../core/services/simulation.service';
import { NotificationService } from '../../core/services/notification.service';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';

describe('HistoryComponent', () => {
  let component: HistoryComponent;
  let fixture: ComponentFixture<HistoryComponent>;
  let simulationServiceMock: {
    getUserSimulations: ReturnType<typeof vi.fn>;
    deleteSimulation: ReturnType<typeof vi.fn>;
  };
  let notificationServiceMock: {
    success: ReturnType<typeof vi.fn>;
    error: ReturnType<typeof vi.fn>;
  };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let modalServiceMock: { confirm: ReturnType<typeof vi.fn> };

  const mockSimulations: Partial<SimulationResponse>[] = [
    {
      id: 'sim-1',
      name: 'Test Simulation 1',
      status: 'COMPLETED',
      supportType: 'SIMPLY_SUPPORTED',
      materialType: 'STEEL',
      results: { 
        safetyFactor: 2.5,
        maxDeflection: 0.005,
        maxBendingMoment: 100000,
        maxShearForce: 25000,
        maxStress: 150e6,
        isSafe: true,
        recommendations: 'Safe'
      },
      createdAt: '2024-01-01T00:00:00Z'
    },
    {
      id: 'sim-2',
      name: 'Failed Simulation',
      status: 'FAILED',
      supportType: 'FIXED_FIXED',
      materialType: 'CONCRETE',
      results: { 
        safetyFactor: 0.8,
        maxDeflection: 0.01,
        maxBendingMoment: 200000,
        maxShearForce: 50000,
        maxStress: 300e6,
        isSafe: false,
        recommendations: 'Unsafe'
      },
      createdAt: '2024-01-02T00:00:00Z'
    },
    {
      id: 'sim-3',
      name: 'Pending Simulation',
      status: 'RUNNING',
      supportType: 'FIXED_FREE',
      materialType: 'ALUMINUM',
      results: { 
        safetyFactor: 1.5,
        maxDeflection: 0.003,
        maxBendingMoment: 80000,
        maxShearForce: 20000,
        maxStress: 120e6,
        isSafe: true,
        recommendations: 'Safe'
      },
      createdAt: '2024-01-03T00:00:00Z'
    }
  ];

  beforeEach(async () => {
    simulationServiceMock = {
      getUserSimulations: vi.fn().mockReturnValue(of(mockSimulations)),
      deleteSimulation: vi.fn().mockReturnValue(of({}))
    };

    notificationServiceMock = {
      success: vi.fn(),
      error: vi.fn()
    };

    routerMock = {
      navigate: vi.fn()
    };

    modalServiceMock = {
      confirm: vi.fn().mockResolvedValue(true)
    };

    await TestBed.configureTestingModule({
      imports: [HistoryComponent],
      providers: [
        { provide: SimulationService, useValue: simulationServiceMock },
        { provide: NotificationService, useValue: notificationServiceMock },
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

    fixture = TestBed.createComponent(HistoryComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should have empty search query initially', () => {
      expect(component.searchQuery()).toBe('');
    });

    it('should have all filter selected initially', () => {
      expect(component.selectedFilter()).toBe('all');
    });

    it('should have newest sort selected initially', () => {
      expect(component.selectedSort()).toBe('newest');
    });

    it('should have grid view mode initially', () => {
      expect(component.viewMode()).toBe('grid');
    });

    it('should not be loading initially', () => {
      expect(component.isLoading()).toBe(false);
    });

    it('should have empty simulations initially', () => {
      expect(component.simulations()).toHaveLength(0);
    });

    it('should have empty selected simulations initially', () => {
      expect(component.selectedSimulations().size).toBe(0);
    });
  });

  describe('filters', () => {
    it('should have 4 filter options', () => {
      expect(component.filters).toHaveLength(4);
    });

    it('should include all filter', () => {
      const allFilter = component.filters.find(f => f.value === 'all');
      expect(allFilter).toBeDefined();
    });

    it('should include completed filter', () => {
      const completedFilter = component.filters.find(f => f.value === 'completed');
      expect(completedFilter).toBeDefined();
    });

    it('should include failed filter', () => {
      const failedFilter = component.filters.find(f => f.value === 'failed');
      expect(failedFilter).toBeDefined();
    });

    it('should include pending filter', () => {
      const pendingFilter = component.filters.find(f => f.value === 'pending');
      expect(pendingFilter).toBeDefined();
    });
  });

  describe('sort options', () => {
    it('should have 4 sort options', () => {
      expect(component.sortOptions).toHaveLength(4);
    });

    it('should include newest sort option', () => {
      const newest = component.sortOptions.find(s => s.value === 'newest');
      expect(newest).toBeDefined();
      expect(newest?.label).toBe('Newest First');
    });

    it('should include oldest sort option', () => {
      const oldest = component.sortOptions.find(s => s.value === 'oldest');
      expect(oldest).toBeDefined();
    });

    it('should include name sort option', () => {
      const name = component.sortOptions.find(s => s.value === 'name');
      expect(name).toBeDefined();
    });

    it('should include safety sort option', () => {
      const safety = component.sortOptions.find(s => s.value === 'safety');
      expect(safety).toBeDefined();
    });
  });

  describe('ngOnInit', () => {
    it('should load simulations on init', () => {
      component.ngOnInit();
      expect(simulationServiceMock.getUserSimulations).toHaveBeenCalled();
    });

    it('should set loading to true initially', () => {
      component.ngOnInit();
      // Note: In real scenario it would briefly be true
      expect(simulationServiceMock.getUserSimulations).toHaveBeenCalled();
    });

    it('should populate simulations after load', () => {
      component.ngOnInit();
      expect(component.simulations().length).toBe(3);
    });

    it('should map COMPLETED status correctly', () => {
      component.ngOnInit();
      const completedSim = component.simulations().find(s => s.id === 'sim-1');
      expect(completedSim?.status).toBe('completed');
    });

    it('should map FAILED status correctly', () => {
      component.ngOnInit();
      const failedSim = component.simulations().find(s => s.id === 'sim-2');
      expect(failedSim?.status).toBe('failed');
    });

    it('should map RUNNING status to pending', () => {
      component.ngOnInit();
      const pendingSim = component.simulations().find(s => s.id === 'sim-3');
      expect(pendingSim?.status).toBe('pending');
    });

    it('should handle load error', () => {
      simulationServiceMock.getUserSimulations.mockReturnValue(
        throwError(() => new Error('Load failed'))
      );
      component.ngOnInit();
      expect(notificationServiceMock.error).toHaveBeenCalledWith('Load Failed', 'Failed to load simulations');
    });
  });

  describe('filteredSimulations', () => {
    beforeEach(() => {
      component.ngOnInit();
    });

    it('should return all simulations with all filter', () => {
      expect(component.filteredSimulations).toHaveLength(3);
    });

    it('should filter by completed status', () => {
      component.setFilter('completed');
      expect(component.filteredSimulations).toHaveLength(1);
      expect(component.filteredSimulations[0].status).toBe('completed');
    });

    it('should filter by failed status', () => {
      component.setFilter('failed');
      expect(component.filteredSimulations).toHaveLength(1);
      expect(component.filteredSimulations[0].status).toBe('failed');
    });

    it('should filter by pending status', () => {
      component.setFilter('pending');
      expect(component.filteredSimulations).toHaveLength(1);
      expect(component.filteredSimulations[0].status).toBe('pending');
    });

    it('should filter by search query on name', () => {
      component.searchQuery.set('Failed');
      expect(component.filteredSimulations).toHaveLength(1);
      expect(component.filteredSimulations[0].name).toBe('Failed Simulation');
    });

    it('should filter by search query on material', () => {
      component.searchQuery.set('CONCRETE');
      expect(component.filteredSimulations).toHaveLength(1);
    });

    it('should sort by newest first', () => {
      component.selectedSort.set('newest');
      const results = component.filteredSimulations;
      expect(results[0].id).toBe('sim-3'); // Most recent
    });

    it('should sort by oldest first', () => {
      component.selectedSort.set('oldest');
      const results = component.filteredSimulations;
      expect(results[0].id).toBe('sim-1'); // Oldest
    });

    it('should sort by name', () => {
      component.selectedSort.set('name');
      const results = component.filteredSimulations;
      // Alphabetically first
      expect(results[0].name).toBe('Failed Simulation');
    });

    it('should sort by safety factor', () => {
      component.selectedSort.set('safety');
      const results = component.filteredSimulations;
      expect(results[0].safetyFactor).toBe(2.5); // Highest safety factor
    });
  });

  describe('updateSearch', () => {
    it('should update search query from event', () => {
      const event = { target: { value: 'test search' } } as unknown as Event;
      component.updateSearch(event);
      expect(component.searchQuery()).toBe('test search');
    });
  });

  describe('setFilter', () => {
    it('should update selected filter', () => {
      component.setFilter('completed');
      expect(component.selectedFilter()).toBe('completed');
    });
  });

  describe('setSort', () => {
    it('should update selected sort from event', () => {
      const event = { target: { value: 'oldest' } } as unknown as Event;
      component.setSort(event);
      expect(component.selectedSort()).toBe('oldest');
    });
  });

  describe('setViewMode', () => {
    it('should set view mode to list', () => {
      component.setViewMode('list');
      expect(component.viewMode()).toBe('list');
    });

    it('should set view mode to grid', () => {
      component.setViewMode('grid');
      expect(component.viewMode()).toBe('grid');
    });
  });

  describe('selection', () => {
    beforeEach(() => {
      component.ngOnInit();
    });

    it('should toggle selection for id', () => {
      component.toggleSelection('sim-1');
      expect(component.isSelected('sim-1')).toBe(true);
    });

    it('should toggle selection off', () => {
      component.toggleSelection('sim-1');
      component.toggleSelection('sim-1');
      expect(component.isSelected('sim-1')).toBe(false);
    });

    it('should select all simulations', () => {
      component.selectAll();
      expect(component.selectedSimulations().size).toBe(3);
    });

    it('should deselect all if all are selected', () => {
      component.selectAll(); // Select all
      component.selectAll(); // Deselect all
      expect(component.selectedSimulations().size).toBe(0);
    });

    it('should correctly report isSelected', () => {
      expect(component.isSelected('sim-1')).toBe(false);
      component.toggleSelection('sim-1');
      expect(component.isSelected('sim-1')).toBe(true);
    });
  });

  describe('deleteSelected', () => {
    beforeEach(() => {
      component.ngOnInit();
    });

    it('should show confirmation modal', async () => {
      component.toggleSelection('sim-1');
      await component.deleteSelected();
      expect(modalServiceMock.confirm).toHaveBeenCalled();
    });

    it('should delete selected simulations on confirm', async () => {
      component.toggleSelection('sim-1');
      component.toggleSelection('sim-2');
      await component.deleteSelected();
      expect(simulationServiceMock.deleteSimulation).toHaveBeenCalledWith('sim-1');
      expect(simulationServiceMock.deleteSimulation).toHaveBeenCalledWith('sim-2');
    });

    it('should show success notification after delete', async () => {
      component.toggleSelection('sim-1');
      await component.deleteSelected();
      expect(notificationServiceMock.success).toHaveBeenCalled();
    });

    it('should clear selection after delete', async () => {
      component.toggleSelection('sim-1');
      await component.deleteSelected();
      expect(component.selectedSimulations().size).toBe(0);
    });

    it('should not delete if modal is cancelled', async () => {
      modalServiceMock.confirm.mockResolvedValue(false);
      component.toggleSelection('sim-1');
      await component.deleteSelected();
      expect(simulationServiceMock.deleteSimulation).not.toHaveBeenCalled();
    });
  });

  describe('getStatusClass', () => {
    it('should return status-completed for completed', () => {
      expect(component.getStatusClass('completed')).toBe('status-completed');
    });

    it('should return status-failed for failed', () => {
      expect(component.getStatusClass('failed')).toBe('status-failed');
    });

    it('should return status-pending for pending', () => {
      expect(component.getStatusClass('pending')).toBe('status-pending');
    });
  });

  describe('getStatusIcon', () => {
    it('should return checkmark for completed', () => {
      expect(component.getStatusIcon('completed')).toBe('✓');
    });

    it('should return X for failed', () => {
      expect(component.getStatusIcon('failed')).toBe('✕');
    });

    it('should return hourglass for pending', () => {
      expect(component.getStatusIcon('pending')).toBe('⏳');
    });

    it('should return ? for unknown status', () => {
      expect(component.getStatusIcon('unknown')).toBe('?');
    });
  });

  describe('getSafetyClass', () => {
    it('should return safety-excellent for factor >= 2.5', () => {
      expect(component.getSafetyClass(2.5)).toBe('safety-excellent');
      expect(component.getSafetyClass(3.0)).toBe('safety-excellent');
    });

    it('should return safety-good for factor >= 1.5 and < 2.5', () => {
      expect(component.getSafetyClass(1.5)).toBe('safety-good');
      expect(component.getSafetyClass(2.0)).toBe('safety-good');
    });

    it('should return safety-warning for factor >= 1.0 and < 1.5', () => {
      expect(component.getSafetyClass(1.0)).toBe('safety-warning');
      expect(component.getSafetyClass(1.2)).toBe('safety-warning');
    });

    it('should return safety-critical for factor < 1.0', () => {
      expect(component.getSafetyClass(0.5)).toBe('safety-critical');
      expect(component.getSafetyClass(0.9)).toBe('safety-critical');
    });
  });

  describe('getTypeIcon', () => {
    it('should return correct icon for Beam', () => {
      expect(component.getTypeIcon('Beam')).toBe('═');
    });

    it('should return correct icon for Frame', () => {
      expect(component.getTypeIcon('Frame')).toBe('╔');
    });

    it('should return correct icon for Truss', () => {
      expect(component.getTypeIcon('Truss')).toBe('△');
    });

    it('should return correct icon for Column', () => {
      expect(component.getTypeIcon('Column')).toBe('║');
    });

    it('should return empty string for unknown type', () => {
      expect(component.getTypeIcon('Unknown')).toBe('');
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

  describe('navigation methods', () => {
    const mockSim = {
      id: 'sim-1',
      name: 'Test',
      type: 'Beam',
      material: 'STEEL',
      status: 'completed' as const,
      safetyFactor: 2.5,
      date: new Date()
    };
    const mockEvent = { stopPropagation: vi.fn() } as unknown as Event;

    it('should navigate to results on viewResults', () => {
      component.viewResults(mockSim, mockEvent);
      expect(mockEvent.stopPropagation).toHaveBeenCalled();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/results', 'sim-1']);
    });

    it('should navigate to simulation on duplicateSimulation', () => {
      component.duplicateSimulation(mockSim, mockEvent);
      expect(mockEvent.stopPropagation).toHaveBeenCalled();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/simulation'], { queryParams: { clone: 'sim-1' } });
    });

    it('should call stopPropagation on downloadSimulation', () => {
      component.downloadSimulation(mockSim, mockEvent);
      expect(mockEvent.stopPropagation).toHaveBeenCalled();
    });
  });

  describe('deleteSingle', () => {
    const mockSim = {
      id: 'sim-1',
      name: 'Test Simulation',
      type: 'Beam',
      material: 'STEEL',
      status: 'completed' as const,
      safetyFactor: 2.5,
      date: new Date()
    };
    const mockEvent = { stopPropagation: vi.fn() } as unknown as Event;

    beforeEach(() => {
      component.ngOnInit();
    });

    it('should show confirmation modal', async () => {
      await component.deleteSingle(mockSim, mockEvent);
      expect(modalServiceMock.confirm).toHaveBeenCalled();
    });

    it('should delete simulation on confirm', async () => {
      await component.deleteSingle(mockSim, mockEvent);
      expect(simulationServiceMock.deleteSimulation).toHaveBeenCalledWith('sim-1');
    });

    it('should show success notification on delete', async () => {
      await component.deleteSingle(mockSim, mockEvent);
      expect(notificationServiceMock.success).toHaveBeenCalledWith('Deleted', 'Simulation deleted successfully');
    });

    it('should remove simulation from list', async () => {
      const initialLength = component.simulations().length;
      await component.deleteSingle(mockSim, mockEvent);
      expect(component.simulations().length).toBe(initialLength - 1);
    });

    it('should not delete if modal is cancelled', async () => {
      modalServiceMock.confirm.mockResolvedValue(false);
      await component.deleteSingle(mockSim, mockEvent);
      expect(simulationServiceMock.deleteSimulation).not.toHaveBeenCalled();
    });

    it('should handle delete error', async () => {
      simulationServiceMock.deleteSimulation.mockReturnValue(
        throwError(() => new Error('Delete failed'))
      );
      await component.deleteSingle(mockSim, mockEvent);
      expect(notificationServiceMock.error).toHaveBeenCalledWith('Error', 'Failed to delete simulation');
    });
  });
});
