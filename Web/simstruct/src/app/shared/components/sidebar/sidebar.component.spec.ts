import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { SidebarComponent } from './sidebar.component';

describe('SidebarComponent', () => {
  let component: SidebarComponent;
  let fixture: ComponentFixture<SidebarComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SidebarComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(SidebarComponent);
    component = fixture.componentInstance;
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should start with sidebar closed', () => {
      expect(component.isOpen()).toBe(false);
    });

    it('should start with no panel open', () => {
      expect(component.currentPanel()).toBeNull();
    });

    it('should start with zero unread count', () => {
      expect(component.unreadCount()).toBe(0);
    });

    it('should have mock notifications', () => {
      expect(component.mockNotifications().length).toBeGreaterThan(0);
    });
  });

  describe('quick actions', () => {
    it('should have quick actions defined', () => {
      expect(component.quickActions.length).toBeGreaterThan(0);
    });

    it('should have new simulation action', () => {
      const action = component.quickActions.find(a => a.id === 'new-sim');
      expect(action).toBeTruthy();
      expect(action?.route).toBe('/simulation');
    });

    it('should have history action', () => {
      const action = component.quickActions.find(a => a.id === 'history');
      expect(action).toBeTruthy();
      expect(action?.route).toBe('/history');
    });

    it('should have share action with function', () => {
      const action = component.quickActions.find(a => a.id === 'share');
      expect(action).toBeTruthy();
      expect(action?.action).toBeDefined();
    });

    it('should have export action', () => {
      const action = component.quickActions.find(a => a.id === 'export');
      expect(action).toBeTruthy();
    });

    it('should have compare action', () => {
      const action = component.quickActions.find(a => a.id === 'compare');
      expect(action).toBeTruthy();
    });

    it('should have settings action', () => {
      const action = component.quickActions.find(a => a.id === 'settings');
      expect(action).toBeTruthy();
      expect(action?.route).toBe('/settings');
    });

    it('should have color for each action', () => {
      component.quickActions.forEach(action => {
        expect(action.color).toBeDefined();
        expect(action.color).toMatch(/^#[0-9a-f]{6}$/i);
      });
    });
  });

  describe('messages', () => {
    it('should have mock messages', () => {
      expect(component.messages.length).toBeGreaterThan(0);
    });

    it('should have unread messages', () => {
      const unreadMessages = component.messages.filter(m => m.unread);
      expect(unreadMessages.length).toBeGreaterThan(0);
    });

    it('should have message properties', () => {
      const message = component.messages[0];
      expect(message.id).toBeDefined();
      expect(message.sender).toBeDefined();
      expect(message.message).toBeDefined();
      expect(message.timestamp).toBeDefined();
      expect(typeof message.unread).toBe('boolean');
    });
  });

  describe('sidebar toggle', () => {
    it('should toggle sidebar open', () => {
      component.isOpen.set(false);
      component.isOpen.set(true);
      expect(component.isOpen()).toBe(true);
    });

    it('should toggle sidebar closed', () => {
      component.isOpen.set(true);
      component.isOpen.set(false);
      expect(component.isOpen()).toBe(false);
    });
  });

  describe('panel management', () => {
    it('should set current panel', () => {
      component.currentPanel.set('notifications');
      expect(component.currentPanel()).toBe('notifications');
    });

    it('should set messages panel', () => {
      component.currentPanel.set('messages');
      expect(component.currentPanel()).toBe('messages');
    });

    it('should set quick-actions panel', () => {
      component.currentPanel.set('quick-actions');
      expect(component.currentPanel()).toBe('quick-actions');
    });

    it('should clear panel', () => {
      component.currentPanel.set('notifications');
      component.currentPanel.set(null);
      expect(component.currentPanel()).toBeNull();
    });
  });

  describe('allNotifications computed', () => {
    it('should return mock notifications', () => {
      const notifications = component.allNotifications();
      expect(notifications).toEqual(component.mockNotifications());
    });

    it('should update when mock notifications change', () => {
      component.mockNotifications.set([]);
      expect(component.allNotifications().length).toBe(0);
    });
  });

  describe('actions', () => {
    it('should have openShareModal method', () => {
      // Should not throw
      expect(() => (component as any).openShareModal?.()).not.toThrow();
    });

    it('should have exportReport method', () => {
      // Should not throw
      expect(() => (component as any).exportReport?.()).not.toThrow();
    });
  });

  describe('closePanel', () => {
    it('should close sidebar', () => {
      component.isOpen.set(true);
      component.closePanel();
      expect(component.isOpen()).toBe(false);
    });

    it('should clear current panel', () => {
      component.currentPanel.set('notifications');
      component.closePanel();
      expect(component.currentPanel()).toBeNull();
    });

    it('should close both sidebar and panel together', () => {
      component.isOpen.set(true);
      component.currentPanel.set('messages');
      component.closePanel();
      expect(component.isOpen()).toBe(false);
      expect(component.currentPanel()).toBeNull();
    });
  });

  describe('onEscape', () => {
    it('should close panel on escape', () => {
      component.isOpen.set(true);
      component.currentPanel.set('notifications');
      component.onEscape();
      expect(component.isOpen()).toBe(false);
      expect(component.currentPanel()).toBeNull();
    });
  });

  describe('getTimeAgo', () => {
    it('should return "Just now" for recent times', () => {
      const now = new Date();
      expect(component.getTimeAgo(now)).toBe('Just now');
    });

    it('should return minutes ago for times within an hour', () => {
      const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
      expect(component.getTimeAgo(fiveMinutesAgo)).toBe('5m ago');
    });

    it('should return hours ago for times within a day', () => {
      const threeHoursAgo = new Date(Date.now() - 3 * 60 * 60 * 1000);
      expect(component.getTimeAgo(threeHoursAgo)).toBe('3h ago');
    });

    it('should return days ago for older times', () => {
      const twoDaysAgo = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000);
      expect(component.getTimeAgo(twoDaysAgo)).toBe('2d ago');
    });

    it('should handle 1 minute ago', () => {
      const oneMinuteAgo = new Date(Date.now() - 60 * 1000);
      expect(component.getTimeAgo(oneMinuteAgo)).toBe('1m ago');
    });

    it('should handle 59 minutes ago', () => {
      const fiftyNineMinutesAgo = new Date(Date.now() - 59 * 60 * 1000);
      expect(component.getTimeAgo(fiftyNineMinutesAgo)).toBe('59m ago');
    });

    it('should handle exactly 1 hour ago', () => {
      const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
      expect(component.getTimeAgo(oneHourAgo)).toBe('1h ago');
    });

    it('should handle 23 hours ago', () => {
      const twentyThreeHoursAgo = new Date(Date.now() - 23 * 60 * 60 * 1000);
      expect(component.getTimeAgo(twentyThreeHoursAgo)).toBe('23h ago');
    });

    it('should handle exactly 1 day ago', () => {
      const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
      expect(component.getTimeAgo(oneDayAgo)).toBe('1d ago');
    });
  });

  describe('getUnreadMessagesCount', () => {
    it('should count unread messages', () => {
      const count = component.getUnreadMessagesCount();
      const expectedCount = component.messages.filter(m => m.unread).length;
      expect(count).toBe(expectedCount);
    });

    it('should return 0 when no unread messages', () => {
      component.messages.forEach(m => m.unread = false);
      expect(component.getUnreadMessagesCount()).toBe(0);
    });

    it('should count correctly after marking as read', () => {
      const initialCount = component.getUnreadMessagesCount();
      const unreadMsg = component.messages.find(m => m.unread);
      if (unreadMsg) {
        component.markMessageAsRead(unreadMsg.id);
        expect(component.getUnreadMessagesCount()).toBe(initialCount - 1);
      }
    });
  });

  describe('markMessageAsRead', () => {
    it('should mark message as read', () => {
      const unreadMsg = component.messages.find(m => m.unread);
      if (unreadMsg) {
        expect(unreadMsg.unread).toBe(true);
        component.markMessageAsRead(unreadMsg.id);
        expect(unreadMsg.unread).toBe(false);
      }
    });

    it('should handle non-existent message id', () => {
      expect(() => component.markMessageAsRead('non-existent')).not.toThrow();
    });

    it('should not affect other messages', () => {
      const messages = component.messages.filter(m => m.unread);
      if (messages.length > 1) {
        component.markMessageAsRead(messages[0].id);
        expect(messages[1].unread).toBe(true);
      }
    });
  });

  describe('openShareModal', () => {
    it('should log share functionality', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.openShareModal();
      expect(consoleSpy).toHaveBeenCalledWith('Share functionality - UI only mode');
    });

    it('should close panel after opening share modal', () => {
      component.isOpen.set(true);
      component.currentPanel.set('quick-actions');
      component.openShareModal();
      expect(component.isOpen()).toBe(false);
      expect(component.currentPanel()).toBeNull();
    });
  });

  describe('exportReport', () => {
    it('should log export functionality', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.exportReport();
      expect(consoleSpy).toHaveBeenCalledWith('Export report - UI only mode');
    });

    it('should close panel after exporting', () => {
      component.isOpen.set(true);
      component.currentPanel.set('quick-actions');
      component.exportReport();
      expect(component.isOpen()).toBe(false);
      expect(component.currentPanel()).toBeNull();
    });
  });

  describe('markAllAsRead', () => {
    it('should mark all notifications as read', () => {
      component.mockNotifications.set([
        { id: '1', title: 'Test 1', message: 'Msg 1', type: 'INFO', isRead: false, createdAt: new Date() },
        { id: '2', title: 'Test 2', message: 'Msg 2', type: 'INFO', isRead: false, createdAt: new Date() }
      ]);
      component.markAllAsRead();
      const unreadCount = component.mockNotifications().filter(n => !n.isRead).length;
      expect(unreadCount).toBe(0);
    });

    it('should handle empty notifications list', () => {
      component.mockNotifications.set([]);
      expect(() => component.markAllAsRead()).not.toThrow();
    });
  });

  describe('markAsRead', () => {
    it('should mark specific notification as read', () => {
      component.mockNotifications.set([
        { id: 'n1', title: 'Test', message: 'Msg', type: 'INFO', isRead: false, createdAt: new Date() }
      ]);
      component.markAsRead('n1');
      expect(component.mockNotifications()[0].isRead).toBe(true);
    });

    it('should not affect other notifications', () => {
      component.mockNotifications.set([
        { id: 'n1', title: 'Test 1', message: 'Msg 1', type: 'INFO', isRead: false, createdAt: new Date() },
        { id: 'n2', title: 'Test 2', message: 'Msg 2', type: 'INFO', isRead: false, createdAt: new Date() }
      ]);
      component.markAsRead('n1');
      expect(component.mockNotifications()[1].isRead).toBe(false);
    });

    it('should handle non-existent notification id', () => {
      expect(() => component.markAsRead('non-existent')).not.toThrow();
    });
  });

  describe('removeNotification', () => {
    it('should remove notification by id', () => {
      component.mockNotifications.set([
        { id: 'n1', title: 'Test', message: 'Msg', type: 'INFO', isRead: false, createdAt: new Date() }
      ]);
      component.removeNotification('n1');
      expect(component.mockNotifications().length).toBe(0);
    });

    it('should only remove specified notification', () => {
      component.mockNotifications.set([
        { id: 'n1', title: 'Test 1', message: 'Msg 1', type: 'INFO', isRead: false, createdAt: new Date() },
        { id: 'n2', title: 'Test 2', message: 'Msg 2', type: 'INFO', isRead: false, createdAt: new Date() }
      ]);
      component.removeNotification('n1');
      expect(component.mockNotifications().length).toBe(1);
      expect(component.mockNotifications()[0].id).toBe('n2');
    });

    it('should handle removing non-existent notification', () => {
      const initialCount = component.mockNotifications().length;
      component.removeNotification('non-existent');
      expect(component.mockNotifications().length).toBe(initialCount);
    });
  });

  describe('getSenderInitials', () => {
    it('should get initials for two-word name', () => {
      expect(component.getSenderInitials('John Doe')).toBe('JD');
    });

    it('should get initials for single name', () => {
      expect(component.getSenderInitials('John')).toBe('J');
    });

    it('should limit initials to 2 characters', () => {
      expect(component.getSenderInitials('John Middle Doe').length).toBeLessThanOrEqual(2);
    });

    it('should return uppercase initials', () => {
      expect(component.getSenderInitials('john doe')).toBe('JD');
    });

    it('should handle names with extra spaces', () => {
      const result = component.getSenderInitials('Sarah  Engineer');
      expect(result).toContain('S');
    });
  });

  describe('getNotificationIcon', () => {
    it('should return checkmark for SUCCESS', () => {
      expect(component.getNotificationIcon('SUCCESS')).toBe('✅');
    });

    it('should return X for ERROR', () => {
      expect(component.getNotificationIcon('ERROR')).toBe('❌');
    });

    it('should return warning for WARNING', () => {
      expect(component.getNotificationIcon('WARNING')).toBe('⚠️');
    });

    it('should return megaphone for INFO', () => {
      expect(component.getNotificationIcon('INFO')).toBe('📢');
    });

    it('should return megaphone for unknown type', () => {
      expect(component.getNotificationIcon('UNKNOWN')).toBe('📢');
    });

    it('should return megaphone for empty string', () => {
      expect(component.getNotificationIcon('')).toBe('📢');
    });
  });

  describe('quick action execution', () => {
    it('should execute share action', () => {
      const shareAction = component.quickActions.find(a => a.id === 'share');
      expect(shareAction?.action).toBeDefined();
      if (shareAction?.action) {
        expect(() => shareAction.action!()).not.toThrow();
      }
    });

    it('should execute export action', () => {
      const exportAction = component.quickActions.find(a => a.id === 'export');
      expect(exportAction?.action).toBeDefined();
      if (exportAction?.action) {
        expect(() => exportAction.action!()).not.toThrow();
      }
    });
  });
});
