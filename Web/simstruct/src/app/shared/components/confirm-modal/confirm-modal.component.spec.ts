import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { ModalService, ConfirmModalComponent } from './confirm-modal.component';

describe('ModalService', () => {
  let service: ModalService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [ModalService]
    });
    service = TestBed.inject(ModalService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(service).toBeTruthy();
    });

    it('should not show confirm modal initially', () => {
      expect(service.showConfirm()).toBe(false);
    });

    it('should not show actions modal initially', () => {
      expect(service.showActions()).toBe(false);
    });

    it('should have null confirm config initially', () => {
      expect(service.confirmConfig()).toBeNull();
    });

    it('should have null action config initially', () => {
      expect(service.actionConfig()).toBeNull();
    });
  });

  describe('confirm', () => {
    it('should show confirm modal with config', async () => {
      const config = {
        title: 'Test Title',
        message: 'Test Message',
        confirmText: 'Yes',
        cancelText: 'No',
        type: 'danger' as const
      };
      
      const promise = service.confirm(config);
      
      expect(service.showConfirm()).toBe(true);
      expect(service.confirmConfig()).toEqual(config);
      
      // Close it to resolve promise
      service.closeConfirm(true);
      const result = await promise;
      expect(result).toBe(true);
    });

    it('should resolve with true when confirmed', async () => {
      const promise = service.confirm({ title: 'Test', message: 'Test message' });
      service.closeConfirm(true);
      const result = await promise;
      expect(result).toBe(true);
    });

    it('should resolve with false when cancelled', async () => {
      const promise = service.confirm({ title: 'Test', message: 'Test message' });
      service.closeConfirm(false);
      const result = await promise;
      expect(result).toBe(false);
    });

    it('should handle default config values', async () => {
      const config = { title: 'Title', message: 'Message' };
      const promise = service.confirm(config);
      
      expect(service.confirmConfig()?.confirmText).toBeUndefined();
      expect(service.confirmConfig()?.cancelText).toBeUndefined();
      expect(service.confirmConfig()?.type).toBeUndefined();
      
      service.closeConfirm(true);
      await promise;
    });
  });

  describe('closeConfirm', () => {
    it('should hide confirm modal', async () => {
      const promise = service.confirm({ title: 'Test', message: 'Test' });
      expect(service.showConfirm()).toBe(true);
      
      service.closeConfirm(false);
      expect(service.showConfirm()).toBe(false);
      await promise;
    });
  });

  describe('showActionMenu', () => {
    it('should show actions modal with config', async () => {
      const config = {
        title: 'Actions',
        subtitle: 'Choose an action',
        actions: [
          { id: 'edit', label: 'Edit', icon: '✏️' },
          { id: 'delete', label: 'Delete', icon: '🗑️', type: 'danger' as const }
        ],
        type: 'default' as const
      };
      
      const promise = service.showActionMenu(config);
      
      expect(service.showActions()).toBe(true);
      expect(service.actionConfig()).toEqual(config);
      
      service.closeActionMenu('edit');
      const result = await promise;
      expect(result).toBe('edit');
    });

    it('should resolve with action id when selected', async () => {
      const promise = service.showActionMenu({
        title: 'Actions',
        actions: [{ id: 'action-1', label: 'Action 1', icon: '✓' }]
      });
      
      service.closeActionMenu('action-1');
      const result = await promise;
      expect(result).toBe('action-1');
    });

    it('should resolve with null when cancelled', async () => {
      const promise = service.showActionMenu({
        title: 'Actions',
        actions: [{ id: 'action-1', label: 'Action 1', icon: '✓' }]
      });
      
      service.closeActionMenu(null);
      const result = await promise;
      expect(result).toBeNull();
    });
  });

  describe('closeActionMenu', () => {
    it('should hide actions modal', async () => {
      const promise = service.showActionMenu({
        title: 'Actions',
        actions: [{ id: 'action-1', label: 'Action 1', icon: '✓' }]
      });
      
      expect(service.showActions()).toBe(true);
      
      service.closeActionMenu(null);
      expect(service.showActions()).toBe(false);
      await promise;
    });
  });
});

describe('ConfirmModalComponent', () => {
  let component: ConfirmModalComponent;
  let fixture: ComponentFixture<ConfirmModalComponent>;
  let modalService: ModalService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ConfirmModalComponent],
      providers: [ModalService]
    }).compileComponents();

    fixture = TestBed.createComponent(ConfirmModalComponent);
    component = fixture.componentInstance;
    modalService = TestBed.inject(ModalService);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should inject modal service', () => {
      expect(component.modalService).toBeTruthy();
    });
  });

  describe('onOverlayClick', () => {
    it('should close confirm modal when clicking overlay with showConfirm true', async () => {
      // First set up a confirm modal
      const promise = modalService.confirm({ title: 'Test', message: 'Test' });
      
      const overlayDiv = document.createElement('div');
      overlayDiv.classList.add('modal-overlay');
      const mockEvent = new MouseEvent('click', { bubbles: true });
      Object.defineProperty(mockEvent, 'target', { value: overlayDiv });
      
      const closeConfirmSpy = vi.spyOn(modalService, 'closeConfirm');
      component.onOverlayClick(mockEvent);
      expect(closeConfirmSpy).toHaveBeenCalledWith(false);
      
      await promise;
    });

    it('should close action menu when clicking overlay with showActions true', async () => {
      // First set up an action modal
      const promise = modalService.showActionMenu({
        title: 'Actions',
        actions: [{ id: 'test', label: 'Test', icon: '✓' }]
      });
      
      const overlayDiv = document.createElement('div');
      overlayDiv.classList.add('modal-overlay');
      const mockEvent = new MouseEvent('click', { bubbles: true });
      Object.defineProperty(mockEvent, 'target', { value: overlayDiv });
      
      const closeActionMenuSpy = vi.spyOn(modalService, 'closeActionMenu');
      component.onOverlayClick(mockEvent);
      expect(closeActionMenuSpy).toHaveBeenCalledWith(null);
      
      await promise;
    });

    it('should not close when clicking inside modal (not on overlay)', () => {
      const target = document.createElement('div');
      target.classList.add('modal-container');
      
      const mockEvent = new MouseEvent('click', { bubbles: true });
      Object.defineProperty(mockEvent, 'target', { value: target });
      
      const closeConfirmSpy = vi.spyOn(modalService, 'closeConfirm');
      const closeActionMenuSpy = vi.spyOn(modalService, 'closeActionMenu');
      component.onOverlayClick(mockEvent);
      expect(closeConfirmSpy).not.toHaveBeenCalled();
      expect(closeActionMenuSpy).not.toHaveBeenCalled();
    });
  });

  describe('modal service integration', () => {
    it('should show confirm modal when service showConfirm is true', async () => {
      const promise = modalService.confirm({
        title: 'Test',
        message: 'Test message',
        type: 'danger'
      });
      
      expect(modalService.showConfirm()).toBe(true);
      
      modalService.closeConfirm(true);
      await promise;
    });

    it('should show action modal when service showActions is true', async () => {
      const promise = modalService.showActionMenu({
        title: 'Actions',
        actions: [{ id: 'test', label: 'Test', icon: '✓' }]
      });
      
      expect(modalService.showActions()).toBe(true);
      
      modalService.closeActionMenu('test');
      await promise;
    });

    it('should access confirm config from service', async () => {
      const config = { title: 'Title', message: 'Message', type: 'warning' as const };
      const promise = modalService.confirm(config);
      
      expect(modalService.confirmConfig()?.title).toBe('Title');
      expect(modalService.confirmConfig()?.message).toBe('Message');
      expect(modalService.confirmConfig()?.type).toBe('warning');
      
      modalService.closeConfirm(false);
      await promise;
    });

    it('should access action config from service', async () => {
      const actions = [{ id: 'edit', label: 'Edit', icon: '✏️' }];
      const promise = modalService.showActionMenu({
        title: 'Choose Action',
        subtitle: 'Select one',
        actions
      });
      
      expect(modalService.actionConfig()?.title).toBe('Choose Action');
      expect(modalService.actionConfig()?.subtitle).toBe('Select one');
      expect(modalService.actionConfig()?.actions).toEqual(actions);
      
      modalService.closeActionMenu(null);
      await promise;
    });
  });
});
