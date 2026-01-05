import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { ToastComponent } from './toast.component';
import { NotificationService } from '../../../core/services/notification.service';
import { signal } from '@angular/core';

// Create a mock notification service
const createMockNotificationService = () => {
  const toasts = signal<any[]>([]);
  return {
    activeToasts: toasts.asReadonly(),
    dismiss: vi.fn((id: string) => {
      toasts.update(t => t.filter(toast => toast.id !== id));
    }),
    dismissAll: vi.fn(() => {
      toasts.set([]);
    }),
    show: vi.fn((type: string, title: string, message: string) => {
      const id = Date.now().toString();
      toasts.update(t => [...t, { id, type, title, message }]);
    }),
    success: vi.fn((title: string, message: string) => {
      const id = Date.now().toString();
      toasts.update(t => [...t, { id, type: 'success', title, message }]);
    }),
    error: vi.fn((title: string, message: string) => {
      const id = Date.now().toString();
      toasts.update(t => [...t, { id, type: 'error', title, message }]);
    }),
    warning: vi.fn((title: string, message: string) => {
      const id = Date.now().toString();
      toasts.update(t => [...t, { id, type: 'warning', title, message }]);
    }),
    info: vi.fn((title: string, message: string) => {
      const id = Date.now().toString();
      toasts.update(t => [...t, { id, type: 'info', title, message }]);
    }),
    _toasts: toasts
  };
};

describe('ToastComponent', () => {
  let component: ToastComponent;
  let fixture: ComponentFixture<ToastComponent>;
  let mockNotificationService: ReturnType<typeof createMockNotificationService>;

  beforeEach(async () => {
    mockNotificationService = createMockNotificationService();

    await TestBed.configureTestingModule({
      imports: [ToastComponent],
      providers: [
        { provide: NotificationService, useValue: mockNotificationService }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(ToastComponent);
    component = fixture.componentInstance;
  });

  describe('Component Creation', () => {
    it('should create the component', () => {
      expect(component).toBeTruthy();
    });

    it('should have notification service injected', () => {
      expect(component.notificationService).toBeDefined();
    });

    it('should have activeToasts accessible', () => {
      expect(component.notificationService.activeToasts).toBeDefined();
    });

    it('should start with no active toasts', () => {
      expect(component.notificationService.activeToasts().length).toBe(0);
    });
  });

  describe('Dismiss Toast', () => {
    it('should call dismiss on notification service', () => {
      component.dismiss('toast-123');
      expect(mockNotificationService.dismiss).toHaveBeenCalledWith('toast-123');
    });

    it('should dismiss with correct id', () => {
      const toastId = 'unique-toast-id';
      component.dismiss(toastId);
      expect(mockNotificationService.dismiss).toHaveBeenCalledWith(toastId);
    });

    it('should remove toast from active toasts', () => {
      mockNotificationService._toasts.set([
        { id: 'toast-1', type: 'success', title: 'Test', message: 'Message' }
      ]);
      expect(component.notificationService.activeToasts().length).toBe(1);
      component.dismiss('toast-1');
      expect(component.notificationService.activeToasts().length).toBe(0);
    });

    it('should only remove the specified toast', () => {
      mockNotificationService._toasts.set([
        { id: 'toast-1', type: 'success', title: 'Test 1', message: 'Message 1' },
        { id: 'toast-2', type: 'error', title: 'Test 2', message: 'Message 2' }
      ]);
      component.dismiss('toast-1');
      expect(component.notificationService.activeToasts().length).toBe(1);
      expect(component.notificationService.activeToasts()[0].id).toBe('toast-2');
    });

    it('should handle dismissing non-existent toast', () => {
      mockNotificationService._toasts.set([
        { id: 'toast-1', type: 'success', title: 'Test', message: 'Message' }
      ]);
      component.dismiss('non-existent');
      expect(component.notificationService.activeToasts().length).toBe(1);
    });

    it('should handle empty toast list', () => {
      expect(() => component.dismiss('any-id')).not.toThrow();
    });
  });

  describe('Toast Types', () => {
    it('should handle success toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Success', message: 'Operation completed' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.type).toBe('success');
    });

    it('should handle error toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'error', title: 'Error', message: 'Something went wrong' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.type).toBe('error');
    });

    it('should handle warning toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'warning', title: 'Warning', message: 'Please check input' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.type).toBe('warning');
    });

    it('should handle info toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'info', title: 'Info', message: 'FYI notification' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.type).toBe('info');
    });
  });

  describe('Toast Content', () => {
    it('should display toast title', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'My Title', message: 'Message' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.title).toBe('My Title');
    });

    it('should display toast message', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'My Message Content' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.message).toBe('My Message Content');
    });

    it('should have unique toast id', () => {
      mockNotificationService._toasts.set([
        { id: 'unique-123', type: 'success', title: 'Title', message: 'Message' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.id).toBe('unique-123');
    });

    it('should handle empty title', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: '', message: 'Message' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.title).toBe('');
    });

    it('should handle empty message', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: '' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.message).toBe('');
    });

    it('should handle long title', () => {
      const longTitle = 'A'.repeat(200);
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: longTitle, message: 'Message' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.title).toBe(longTitle);
    });

    it('should handle long message', () => {
      const longMessage = 'B'.repeat(500);
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: longMessage }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.message).toBe(longMessage);
    });

    it('should handle special characters in title', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: '<script>alert("xss")</script>', message: 'Message' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.title).toBe('<script>alert("xss")</script>');
    });

    it('should handle unicode in message', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'Hello 世界 🌍 مرحبا' }
      ]);
      const toast = component.notificationService.activeToasts()[0];
      expect(toast.message).toBe('Hello 世界 🌍 مرحبا');
    });
  });

  describe('Multiple Toasts', () => {
    it('should handle multiple toasts', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title 1', message: 'Message 1' },
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' },
        { id: 't3', type: 'warning', title: 'Title 3', message: 'Message 3' }
      ]);
      expect(component.notificationService.activeToasts().length).toBe(3);
    });

    it('should dismiss correct toast from multiple', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title 1', message: 'Message 1' },
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' },
        { id: 't3', type: 'warning', title: 'Title 3', message: 'Message 3' }
      ]);
      component.dismiss('t2');
      const remainingIds = component.notificationService.activeToasts().map(t => t.id);
      expect(remainingIds).toContain('t1');
      expect(remainingIds).not.toContain('t2');
      expect(remainingIds).toContain('t3');
    });

    it('should maintain order after dismissing middle toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title 1', message: 'Message 1' },
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' },
        { id: 't3', type: 'warning', title: 'Title 3', message: 'Message 3' }
      ]);
      component.dismiss('t2');
      expect(component.notificationService.activeToasts()[0].id).toBe('t1');
      expect(component.notificationService.activeToasts()[1].id).toBe('t3');
    });

    it('should dismiss first toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title 1', message: 'Message 1' },
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' }
      ]);
      component.dismiss('t1');
      expect(component.notificationService.activeToasts().length).toBe(1);
      expect(component.notificationService.activeToasts()[0].id).toBe('t2');
    });

    it('should dismiss last toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title 1', message: 'Message 1' },
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' }
      ]);
      component.dismiss('t2');
      expect(component.notificationService.activeToasts().length).toBe(1);
      expect(component.notificationService.activeToasts()[0].id).toBe('t1');
    });

    it('should dismiss all toasts one by one', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title 1', message: 'Message 1' },
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' }
      ]);
      component.dismiss('t1');
      component.dismiss('t2');
      expect(component.notificationService.activeToasts().length).toBe(0);
    });
  });

  describe('Component Rendering', () => {
    it('should have template with toast container', () => {
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelector('.toast-container')).toBeTruthy();
    });

    it('should not render toasts when empty', () => {
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelectorAll('.toast').length).toBe(0);
    });

    it('should render toasts when present', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'Message' }
      ]);
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelectorAll('.toast').length).toBe(1);
    });

    it('should render multiple toasts', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title 1', message: 'Message 1' },
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' }
      ]);
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelectorAll('.toast').length).toBe(2);
    });

    it('should apply correct class for success toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'Message' }
      ]);
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelector('.toast-success')).toBeTruthy();
    });

    it('should apply correct class for error toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'error', title: 'Title', message: 'Message' }
      ]);
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelector('.toast-error')).toBeTruthy();
    });

    it('should apply correct class for warning toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'warning', title: 'Title', message: 'Message' }
      ]);
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelector('.toast-warning')).toBeTruthy();
    });

    it('should apply correct class for info toast', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'info', title: 'Title', message: 'Message' }
      ]);
      fixture.detectChanges();
      const compiled = fixture.nativeElement;
      expect(compiled.querySelector('.toast-info')).toBeTruthy();
    });
  });

  describe('Toast Interaction', () => {
    it('should call dismiss when toast is clicked', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'Message' }
      ]);
      fixture.detectChanges();
      const toastElement = fixture.nativeElement.querySelector('.toast');
      toastElement.click();
      expect(mockNotificationService.dismiss).toHaveBeenCalledWith('t1');
    });

    it('should call dismiss when close button is clicked', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'Message' }
      ]);
      fixture.detectChanges();
      const closeButton = fixture.nativeElement.querySelector('.toast-close');
      closeButton.click();
      expect(mockNotificationService.dismiss).toHaveBeenCalledWith('t1');
    });
  });

  describe('Edge Cases', () => {
    it('should handle rapid add and dismiss', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'Message' }
      ]);
      component.dismiss('t1');
      mockNotificationService._toasts.set([
        { id: 't2', type: 'error', title: 'Title 2', message: 'Message 2' }
      ]);
      expect(component.notificationService.activeToasts().length).toBe(1);
      expect(component.notificationService.activeToasts()[0].id).toBe('t2');
    });

    it('should handle same id dismiss called multiple times', () => {
      mockNotificationService._toasts.set([
        { id: 't1', type: 'success', title: 'Title', message: 'Message' }
      ]);
      component.dismiss('t1');
      component.dismiss('t1');
      component.dismiss('t1');
      expect(component.notificationService.activeToasts().length).toBe(0);
    });

    it('should handle toast with numeric id', () => {
      mockNotificationService._toasts.set([
        { id: '12345', type: 'success', title: 'Title', message: 'Message' }
      ]);
      component.dismiss('12345');
      expect(component.notificationService.activeToasts().length).toBe(0);
    });

    it('should handle toast with special characters in id', () => {
      mockNotificationService._toasts.set([
        { id: 'toast-@#$-123', type: 'success', title: 'Title', message: 'Message' }
      ]);
      component.dismiss('toast-@#$-123');
      expect(component.notificationService.activeToasts().length).toBe(0);
    });

    it('should handle dismiss with empty string id', () => {
      mockNotificationService._toasts.set([
        { id: '', type: 'success', title: 'Title', message: 'Message' }
      ]);
      component.dismiss('');
      expect(component.notificationService.activeToasts().length).toBe(0);
    });
  });
});
