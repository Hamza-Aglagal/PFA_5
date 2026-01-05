import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed } from '@angular/core/testing';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { of, throwError, firstValueFrom } from 'rxjs';
import { BackendNotificationService, BackendNotification, NotificationType } from './backend-notification.service';
import { AuthService } from './auth.service';
import { NotificationService } from './notification.service';
import { signal } from '@angular/core';

describe('BackendNotificationService', () => {
  let service: BackendNotificationService;
  let httpClientSpy: {
    get: ReturnType<typeof vi.fn>;
    post: ReturnType<typeof vi.fn>;
    put: ReturnType<typeof vi.fn>;
    delete: ReturnType<typeof vi.fn>;
  };
  let routerSpy: { navigate: ReturnType<typeof vi.fn> };
  let authServiceSpy: { user: ReturnType<typeof signal> };
  let toastServiceSpy: {
    show: ReturnType<typeof vi.fn>;
    info: ReturnType<typeof vi.fn>;
    success: ReturnType<typeof vi.fn>;
    error: ReturnType<typeof vi.fn>;
    warning: ReturnType<typeof vi.fn>;
  };

  const mockNotification: BackendNotification = {
    id: 'notif-1',
    type: 'SIMULATION_COMPLETE' as NotificationType,
    title: 'Simulation Complete',
    message: 'Your simulation has finished',
    relatedId: 'sim-1',
    relatedType: 'SIMULATION',
    actionUrl: '/results/sim-1',
    isRead: false,
    createdAt: '2024-01-01T00:00:00Z',
    readAt: null
  };

  beforeEach(() => {
    httpClientSpy = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      delete: vi.fn()
    };

    routerSpy = {
      navigate: vi.fn()
    };

    authServiceSpy = {
      user: signal(null)
    };

    toastServiceSpy = {
      show: vi.fn(),
      info: vi.fn(),
      success: vi.fn(),
      error: vi.fn(),
      warning: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        BackendNotificationService,
        { provide: HttpClient, useValue: httpClientSpy },
        { provide: Router, useValue: routerSpy },
        { provide: AuthService, useValue: authServiceSpy },
        { provide: NotificationService, useValue: toastServiceSpy }
      ]
    });

    service = TestBed.inject(BackendNotificationService);
  });

  afterEach(() => {
    service.ngOnDestroy();
  });

  describe('initialization', () => {
    it('should be created', () => {
      expect(service).toBeTruthy();
    });

    it('should start with empty notifications', () => {
      expect(service.notifications()).toEqual([]);
    });

    it('should start with zero unread count', () => {
      expect(service.unreadCount()).toBe(0);
    });

    it('should start with not connected', () => {
      expect(service.connected()).toBe(false);
    });

    it('should start with loading false', () => {
      expect(service.loading()).toBe(false);
    });
  });

  describe('loadNotifications', () => {
    it('should load notifications successfully', () => {
      const notifications = [mockNotification, { ...mockNotification, id: 'notif-2' }];
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: notifications
      }));

      service.loadNotifications();
      expect(service.notifications().length).toBe(2);
    });

    it('should handle empty notifications', () => {
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: []
      }));

      service.loadNotifications();
      expect(service.notifications()).toEqual([]);
    });

    it('should set loading to false after load', () => {
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: []
      }));

      service.loadNotifications();
      expect(service.loading()).toBe(false);
    });
  });

  describe('loadNotificationCount', () => {
    it('should load unread count', () => {
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: { unreadCount: 5, totalCount: 10 }
      }));

      service.loadNotificationCount();
      expect(service.unreadCount()).toBe(5);
    });

    it('should handle zero unread', () => {
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: { unreadCount: 0, totalCount: 10 }
      }));

      service.loadNotificationCount();
      expect(service.unreadCount()).toBe(0);
    });
  });

  describe('markAsRead', () => {
    it('should mark notification as read', () => {
      // First load notifications
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: [mockNotification]
      }));
      service.loadNotifications();

      // Then mark as read
      httpClientSpy.put.mockReturnValue(of({ success: true }));

      service.markAsRead('notif-1');
      expect(httpClientSpy.put).toHaveBeenCalled();
    });

    it('should update notification state after marking as read', () => {
      // Load unread notification
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: [mockNotification]
      }));
      service.loadNotifications();

      // Mark as read
      httpClientSpy.put.mockReturnValue(of({ success: true }));

      service.markAsRead('notif-1');
      const notification = service.notifications().find(n => n.id === 'notif-1');
      expect(notification?.isRead).toBe(true);
    });
  });

  describe('markAllAsRead', () => {
    it('should mark all notifications as read', () => {
      httpClientSpy.put.mockReturnValue(of({ success: true }));

      service.markAllAsRead();
      expect(httpClientSpy.put).toHaveBeenCalled();
    });

    it('should reset unread count to zero', () => {
      httpClientSpy.put.mockReturnValue(of({ success: true }));

      service.markAllAsRead();
      expect(service.unreadCount()).toBe(0);
    });
  });

  describe('deleteNotification', () => {
    it('should delete notification', () => {
      httpClientSpy.delete.mockReturnValue(of({ success: true }));

      service.deleteNotification('notif-1');
      expect(httpClientSpy.delete).toHaveBeenCalled();
    });

    it('should remove notification from list', () => {
      // Load notifications
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: [mockNotification]
      }));
      service.loadNotifications();

      expect(service.notifications().length).toBe(1);

      // Delete
      httpClientSpy.delete.mockReturnValue(of({ success: true }));

      service.deleteNotification('notif-1');
      expect(service.notifications().length).toBe(0);
    });
  });

  describe('unreadNotifications computed', () => {
    it('should filter unread notifications', () => {
      const notifications = [
        mockNotification,
        { ...mockNotification, id: 'notif-2', isRead: true }
      ];
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: notifications
      }));

      service.loadNotifications();
      expect(service.unreadNotifications().length).toBe(1);
      expect(service.unreadNotifications()[0].id).toBe('notif-1');
    });
  });

  describe('notification types', () => {
    it('should handle SIMULATION_COMPLETE type', () => {
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: [mockNotification]
      }));

      service.loadNotifications();
      expect(service.notifications()[0].type).toBe('SIMULATION_COMPLETE');
    });

    it('should handle FRIEND_REQUEST type', () => {
      const friendNotification = {
        ...mockNotification,
        type: 'FRIEND_REQUEST' as NotificationType,
        title: 'Friend Request'
      };
      httpClientSpy.get.mockReturnValue(of({
        success: true,
        data: [friendNotification]
      }));

      service.loadNotifications();
      expect(service.notifications()[0].type).toBe('FRIEND_REQUEST');
    });
  });

  describe('cleanup', () => {
    it('should clean up on destroy', () => {
      // Just verify ngOnDestroy exists and can be called
      expect(() => service.ngOnDestroy()).not.toThrow();
    });
  });

  describe('utility methods', () => {
    describe('getNotificationIcon', () => {
      it('should return correct icons', () => {
        expect(service.getNotificationIcon('SIMULATION_COMPLETE')).toBe('check_circle');
        expect(service.getNotificationIcon('SIMULATION_FAILED')).toBe('error');
        expect(service.getNotificationIcon('SIMULATION_SHARED')).toBe('share');
        expect(service.getNotificationIcon('FRIEND_REQUEST')).toBe('person_add');
        expect(service.getNotificationIcon('FRIEND_ACCEPTED')).toBe('how_to_reg');
        expect(service.getNotificationIcon('FRIEND_REJECTED')).toBe('person_remove');
        expect(service.getNotificationIcon('NEW_MESSAGE')).toBe('message');
        expect(service.getNotificationIcon('SIMULATION_RECEIVED')).toBe('inbox');
        expect(service.getNotificationIcon('SYSTEM')).toBe('info');
        expect(service.getNotificationIcon('WELCOME')).toBe('celebration');
        expect(service.getNotificationIcon('ACCOUNT_UPDATE')).toBe('manage_accounts');
      });

      it('should return default icon for unknown type', () => {
        expect(service.getNotificationIcon('UNKNOWN' as NotificationType)).toBe('notifications');
      });
    });

    describe('getNotificationColor', () => {
      it('should return correct colors', () => {
        expect(service.getNotificationColor('SIMULATION_COMPLETE')).toBe('text-green-500');
        expect(service.getNotificationColor('SIMULATION_FAILED')).toBe('text-red-500');
        expect(service.getNotificationColor('SIMULATION_SHARED')).toBe('text-blue-500');
        expect(service.getNotificationColor('FRIEND_REQUEST')).toBe('text-indigo-500');
        expect(service.getNotificationColor('FRIEND_ACCEPTED')).toBe('text-green-500');
        expect(service.getNotificationColor('FRIEND_REJECTED')).toBe('text-orange-500');
        expect(service.getNotificationColor('NEW_MESSAGE')).toBe('text-blue-500');
        expect(service.getNotificationColor('SIMULATION_RECEIVED')).toBe('text-purple-500');
        expect(service.getNotificationColor('SYSTEM')).toBe('text-gray-500');
        expect(service.getNotificationColor('WELCOME')).toBe('text-yellow-500');
        expect(service.getNotificationColor('ACCOUNT_UPDATE')).toBe('text-gray-500');
      });

      it('should return default color for unknown type', () => {
        expect(service.getNotificationColor('UNKNOWN' as NotificationType)).toBe('text-gray-500');
      });
    });

    describe('formatTime', () => {
      it('should return "Just now" for less than 1 minute', () => {
        const now = new Date();
        expect(service.formatTime(now.toISOString())).toBe('Just now');
      });

      it('should return minutes ago', () => {
        const date = new Date();
        date.setMinutes(date.getMinutes() - 30);
        expect(service.formatTime(date.toISOString())).toBe('30m ago');
      });

      it('should return hours ago', () => {
        const date = new Date();
        date.setHours(date.getHours() - 5);
        expect(service.formatTime(date.toISOString())).toBe('5h ago');
      });

      it('should return days ago', () => {
        const date = new Date();
        date.setDate(date.getDate() - 3);
        expect(service.formatTime(date.toISOString())).toBe('3d ago');
      });

      it('should return date string for older dates', () => {
        const date = new Date();
        date.setDate(date.getDate() - 10);
        expect(service.formatTime(date.toISOString())).toBe(date.toLocaleDateString());
      });
    });
  });

  describe('showToastForNotification', () => {
    it('should show success toast for SIMULATION_COMPLETE', () => {
      // @ts-ignore - Accessing private method for testing coverage
      service['showToastForNotification']({ ...mockNotification, type: 'SIMULATION_COMPLETE' });
      expect(toastServiceSpy.show).toHaveBeenCalledWith('success', expect.any(String), expect.any(String), expect.any(Number));
    });

    it('should show error toast for SIMULATION_FAILED', () => {
      // @ts-ignore
      service['showToastForNotification']({ ...mockNotification, type: 'SIMULATION_FAILED' });
      expect(toastServiceSpy.show).toHaveBeenCalledWith('error', expect.any(String), expect.any(String), expect.any(Number));
    });

    it('should show warning toast for FRIEND_REJECTED', () => {
      // @ts-ignore
      service['showToastForNotification']({ ...mockNotification, type: 'FRIEND_REJECTED' });
      expect(toastServiceSpy.show).toHaveBeenCalledWith('warning', expect.any(String), expect.any(String), expect.any(Number));
    });

    it('should show info toast for default types', () => {
      // @ts-ignore
      service['showToastForNotification']({ ...mockNotification, type: 'SYSTEM' });
      expect(toastServiceSpy.show).toHaveBeenCalledWith('info', expect.any(String), expect.any(String), expect.any(Number));
    });
  });
});
