import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, fakeAsync, tick } from '@angular/core/testing';
import { NotificationService, Toast } from './notification.service';

describe('NotificationService', () => {
  let service: NotificationService;

  beforeEach(() => {
    vi.useFakeTimers();

    TestBed.configureTestingModule({
      providers: [NotificationService]
    });

    service = TestBed.inject(NotificationService);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  describe('initialization', () => {
    it('should be created', () => {
      expect(service).toBeTruthy();
    });

    it('should start with empty toasts', () => {
      expect(service.activeToasts()).toEqual([]);
    });
  });

  describe('show', () => {
    it('should add a toast', () => {
      service.show('success', 'Title', 'Message');

      expect(service.activeToasts().length).toBe(1);
      expect(service.activeToasts()[0].type).toBe('success');
      expect(service.activeToasts()[0].title).toBe('Title');
      expect(service.activeToasts()[0].message).toBe('Message');
    });

    it('should generate unique id for each toast', () => {
      service.show('success', 'Toast 1', 'Message 1');
      service.show('error', 'Toast 2', 'Message 2');

      const ids = service.activeToasts().map(t => t.id);
      expect(new Set(ids).size).toBe(2);
    });

    it('should auto-dismiss toast after duration', () => {
      service.show('success', 'Title', 'Message', 2000);

      expect(service.activeToasts().length).toBe(1);

      vi.advanceTimersByTime(2000);

      expect(service.activeToasts().length).toBe(0);
    });

    it('should not auto-dismiss when duration is 0', () => {
      service.show('info', 'Title', 'Message', 0);

      vi.advanceTimersByTime(10000);

      expect(service.activeToasts().length).toBe(1);
    });

    it('should use default duration of 4000ms', () => {
      service.show('warning', 'Title', 'Message');

      vi.advanceTimersByTime(3999);
      expect(service.activeToasts().length).toBe(1);

      vi.advanceTimersByTime(1);
      expect(service.activeToasts().length).toBe(0);
    });

    it('should generate valid UUID v4', () => {
      service.show('success', 'T', 'M');
      const id = service.activeToasts()[0].id;
      // Simple regex for UUID
      expect(id).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i);
    });
  });

  describe('success', () => {
    it('should show success toast', () => {
      service.success('Success', 'Operation completed');

      expect(service.activeToasts().length).toBe(1);
      expect(service.activeToasts()[0].type).toBe('success');
    });

    it('should use correct title and message', () => {
      service.success('Title Here', 'Message Here');

      expect(service.activeToasts()[0].title).toBe('Title Here');
      expect(service.activeToasts()[0].message).toBe('Message Here');
    });
  });

  describe('error', () => {
    it('should show error toast', () => {
      service.error('Error', 'Something went wrong');

      expect(service.activeToasts().length).toBe(1);
      expect(service.activeToasts()[0].type).toBe('error');
    });
  });

  describe('warning', () => {
    it('should show warning toast', () => {
      service.warning('Warning', 'Please be careful');

      expect(service.activeToasts().length).toBe(1);
      expect(service.activeToasts()[0].type).toBe('warning');
    });
  });

  describe('info', () => {
    it('should show info toast', () => {
      service.info('Info', 'Just letting you know');

      expect(service.activeToasts().length).toBe(1);
      expect(service.activeToasts()[0].type).toBe('info');
    });
  });

  describe('dismiss', () => {
    it('should remove specific toast by id', () => {
      service.show('success', 'Toast 1', 'Message 1');
      service.show('error', 'Toast 2', 'Message 2');

      const toastId = service.activeToasts()[0].id;
      service.dismiss(toastId);

      expect(service.activeToasts().length).toBe(1);
      expect(service.activeToasts()[0].title).toBe('Toast 2');
    });

    it('should do nothing if toast id not found', () => {
      service.show('success', 'Toast', 'Message');

      service.dismiss('non-existent-id');

      expect(service.activeToasts().length).toBe(1);
    });
  });

  describe('dismissAll', () => {
    it('should remove all toasts', () => {
      service.show('success', 'Toast 1', 'Message 1', 0);
      service.show('error', 'Toast 2', 'Message 2', 0);
      service.show('warning', 'Toast 3', 'Message 3', 0);

      service.dismissAll();

      expect(service.activeToasts().length).toBe(0);
    });

    it('should work when no toasts exist', () => {
      service.dismissAll();

      expect(service.activeToasts().length).toBe(0);
    });
  });

  describe('multiple toasts', () => {
    it('should handle multiple toasts simultaneously', () => {
      service.success('Success', 'Message 1', 1000);
      service.error('Error', 'Message 2', 2000);
      service.warning('Warning', 'Message 3', 3000);

      expect(service.activeToasts().length).toBe(3);

      vi.advanceTimersByTime(1000);
      expect(service.activeToasts().length).toBe(2);

      vi.advanceTimersByTime(1000);
      expect(service.activeToasts().length).toBe(1);

      vi.advanceTimersByTime(1000);
      expect(service.activeToasts().length).toBe(0);
    });

    it('should maintain order when adding toasts', () => {
      service.success('First', 'Message', 0);
      service.error('Second', 'Message', 0);
      service.info('Third', 'Message', 0);

      const titles = service.activeToasts().map(t => t.title);
      expect(titles).toEqual(['First', 'Second', 'Third']);
    });
  });

  describe('toast properties', () => {
    it('should have all required properties', () => {
      service.show('success', 'Title', 'Message', 5000);

      const toast = service.activeToasts()[0];
      expect(toast).toHaveProperty('id');
      expect(toast).toHaveProperty('type');
      expect(toast).toHaveProperty('title');
      expect(toast).toHaveProperty('message');
      expect(toast).toHaveProperty('duration');
    });

    it('should store duration correctly', () => {
      service.show('success', 'Title', 'Message', 5000);

      expect(service.activeToasts()[0].duration).toBe(5000);
    });
  });
});
