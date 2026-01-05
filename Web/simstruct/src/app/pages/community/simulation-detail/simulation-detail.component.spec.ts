import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { ActivatedRoute, Router } from '@angular/router';
import { of } from 'rxjs';
import { SimulationDetailComponent } from './simulation-detail.component';
import { ElementRef } from '@angular/core';

describe('SimulationDetailComponent', () => {
  let component: SimulationDetailComponent;
  let fixture: ComponentFixture<SimulationDetailComponent>;
  let routerMock: { navigate: ReturnType<typeof vi.fn> };

  beforeEach(async () => {
    routerMock = {
      navigate: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [SimulationDetailComponent],
      providers: [
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: {
              paramMap: {
                get: vi.fn().mockReturnValue('sim-123')
              },
              params: { id: 'sim-123' },
              queryParams: {}
            },
            params: of({ id: 'sim-123' }),
            queryParams: of({})
          }
        },
        { provide: Router, useValue: routerMock }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(SimulationDetailComponent);
    component = fixture.componentInstance;
  });

  describe('Component Creation', () => {
    it('should create the component', () => {
      expect(component).toBeTruthy();
    });

    it('should have initial null simulation', () => {
      expect(component.simulation()).toBeNull();
    });

    it('should have empty messages array initially', () => {
      expect(component.messages()).toEqual([]);
    });

    it('should have empty newMessage initially', () => {
      expect(component.newMessage()).toBe('');
    });

    it('should have showShareModal as false initially', () => {
      expect(component.showShareModal()).toBe(false);
    });

    it('should have showInviteModal as false initially', () => {
      expect(component.showInviteModal()).toBe(false);
    });

    it('should have empty selectedFriends set initially', () => {
      expect(component.selectedFriends().size).toBe(0);
    });

    it('should have empty inviteEmail initially', () => {
      expect(component.inviteEmail()).toBe('');
    });

    it('should have empty shareMessage initially', () => {
      expect(component.shareMessage()).toBe('');
    });

    it('should have empty searchFriendQuery initially', () => {
      expect(component.searchFriendQuery()).toBe('');
    });
  });

  describe('ngOnInit', () => {
    it('should load simulation data on init', () => {
      component.ngOnInit();
      expect(component.simulation()).not.toBeNull();
    });

    it('should set simulation id from route params', () => {
      component.ngOnInit();
      expect(component.simulation()?.id).toBe('sim-123');
    });

    it('should set simulation name', () => {
      component.ngOnInit();
      expect(component.simulation()?.name).toBe('Steel Bridge Analysis');
    });

    it('should set simulation structure type', () => {
      component.ngOnInit();
      expect(component.simulation()?.structureType).toBe('Truss');
    });

    it('should set simulation material', () => {
      component.ngOnInit();
      expect(component.simulation()?.material).toBe('Steel');
    });

    it('should set simulation safety factor', () => {
      component.ngOnInit();
      expect(component.simulation()?.safetyFactor).toBe(2.8);
    });

    it('should load mock messages on init', () => {
      component.ngOnInit();
      expect(component.messages().length).toBe(2);
    });

    it('should have tags in simulation', () => {
      component.ngOnInit();
      expect(component.simulation()?.tags).toContain('bridge');
      expect(component.simulation()?.tags).toContain('steel');
    });

    it('should have dimensions in simulation', () => {
      component.ngOnInit();
      expect(component.simulation()?.dimensions?.length).toBe(10);
      expect(component.simulation()?.dimensions?.width).toBe(0.5);
    });
  });

  describe('Friends List', () => {
    it('should have mock friends', () => {
      expect(component.friends().length).toBe(2);
    });

    it('should have Alice in friends list', () => {
      const alice = component.friends().find(f => f.name === 'Alice Smith');
      expect(alice).toBeTruthy();
      expect(alice?.email).toBe('alice@example.com');
    });

    it('should have Bob in friends list', () => {
      const bob = component.friends().find(f => f.name === 'Bob Johnson');
      expect(bob).toBeTruthy();
      expect(bob?.email).toBe('bob@example.com');
    });

    it('should filter friends by name', () => {
      component.searchFriendQuery.set('alice');
      expect(component.filteredFriends().length).toBe(1);
      expect(component.filteredFriends()[0].name).toBe('Alice Smith');
    });

    it('should filter friends by email', () => {
      component.searchFriendQuery.set('bob@');
      expect(component.filteredFriends().length).toBe(1);
      expect(component.filteredFriends()[0].name).toBe('Bob Johnson');
    });

    it('should return all friends when query is empty', () => {
      component.searchFriendQuery.set('');
      expect(component.filteredFriends().length).toBe(2);
    });

    it('should return empty when no match found', () => {
      component.searchFriendQuery.set('xyz123');
      expect(component.filteredFriends().length).toBe(0);
    });

    it('should be case insensitive in search', () => {
      component.searchFriendQuery.set('ALICE');
      expect(component.filteredFriends().length).toBe(1);
    });
  });

  describe('Friend Selection', () => {
    it('should toggle friend selection - add', () => {
      component.toggleFriendSelection('f1');
      expect(component.isFriendSelected('f1')).toBe(true);
    });

    it('should toggle friend selection - remove', () => {
      component.toggleFriendSelection('f1');
      component.toggleFriendSelection('f1');
      expect(component.isFriendSelected('f1')).toBe(false);
    });

    it('should select multiple friends', () => {
      component.toggleFriendSelection('f1');
      component.toggleFriendSelection('f2');
      expect(component.selectedFriends().size).toBe(2);
    });

    it('should correctly check if friend is not selected', () => {
      expect(component.isFriendSelected('f1')).toBe(false);
    });
  });

  describe('Share Modal', () => {
    it('should open share modal', () => {
      component.openShareModal();
      expect(component.showShareModal()).toBe(true);
    });

    it('should reset selected friends when opening modal', () => {
      component.toggleFriendSelection('f1');
      component.openShareModal();
      expect(component.selectedFriends().size).toBe(0);
    });

    it('should reset share message when opening modal', () => {
      component.shareMessage.set('test message');
      component.openShareModal();
      expect(component.shareMessage()).toBe('');
    });

    it('should close share modal', () => {
      component.openShareModal();
      component.closeShareModal();
      expect(component.showShareModal()).toBe(false);
    });

    it('should share with selected friends', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.toggleFriendSelection('f1');
      component.toggleFriendSelection('f2');
      component.shareWithFriends();
      expect(consoleSpy).toHaveBeenCalledWith('UI Only: Shared');
    });

    it('should close modal after sharing', () => {
      component.openShareModal();
      component.toggleFriendSelection('f1');
      component.shareWithFriends();
      expect(component.showShareModal()).toBe(false);
    });

    it('should not share when no friends selected', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.shareWithFriends();
      expect(consoleSpy).not.toHaveBeenCalledWith('UI Only: Shared');
    });
  });

  describe('Invite Modal', () => {
    it('should open invite modal', () => {
      component.openInviteModal();
      expect(component.showInviteModal()).toBe(true);
    });

    it('should reset invite email when opening modal', () => {
      component.inviteEmail.set('test@test.com');
      component.openInviteModal();
      expect(component.inviteEmail()).toBe('');
    });

    it('should close invite modal', () => {
      component.openInviteModal();
      component.closeInviteModal();
      expect(component.showInviteModal()).toBe(false);
    });

    it('should send invite when email is provided', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.inviteEmail.set('new@friend.com');
      component.sendInvite();
      expect(consoleSpy).toHaveBeenCalledWith('UI Only: Invite sent');
    });

    it('should close modal after sending invite', () => {
      component.openInviteModal();
      component.inviteEmail.set('new@friend.com');
      component.sendInvite();
      expect(component.showInviteModal()).toBe(false);
    });

    it('should not send invite when email is empty', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.inviteEmail.set('');
      component.sendInvite();
      expect(consoleSpy).not.toHaveBeenCalledWith('UI Only: Invite sent');
    });
  });

  describe('Message Handling', () => {
    beforeEach(() => {
      component.ngOnInit();
    });

    it('should send message when content is provided', () => {
      const initialCount = component.messages().length;
      component.newMessage.set('Hello world');
      component.sendMessage();
      expect(component.messages().length).toBe(initialCount + 1);
    });

    it('should clear input after sending message', () => {
      component.newMessage.set('Hello world');
      component.sendMessage();
      expect(component.newMessage()).toBe('');
    });

    it('should not send empty messages', () => {
      const initialCount = component.messages().length;
      component.newMessage.set('   ');
      component.sendMessage();
      expect(component.messages().length).toBe(initialCount);
    });

    it('should set sender name to You for own messages', () => {
      component.newMessage.set('Test message');
      component.sendMessage();
      const lastMsg = component.messages()[component.messages().length - 1];
      expect(lastMsg.senderName).toBe('You');
    });

    it('should set sender id to me for own messages', () => {
      component.newMessage.set('Test message');
      component.sendMessage();
      const lastMsg = component.messages()[component.messages().length - 1];
      expect(lastMsg.senderId).toBe('me');
    });

    it('should add timestamp to sent message', () => {
      component.newMessage.set('Test message');
      component.sendMessage();
      const lastMsg = component.messages()[component.messages().length - 1];
      expect(lastMsg.sentAt).toBeInstanceOf(Date);
    });

    it('should handle key press - Enter sends message', () => {
      component.newMessage.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'Enter', shiftKey: false });
      const preventDefaultSpy = vi.spyOn(event, 'preventDefault');
      component.handleKeyPress(event);
      expect(preventDefaultSpy).toHaveBeenCalled();
    });

    it('should handle key press - Shift+Enter does not send', () => {
      const initialCount = component.messages().length;
      component.newMessage.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'Enter', shiftKey: true });
      component.handleKeyPress(event);
      expect(component.messages().length).toBe(initialCount);
    });

    it('should handle key press - other keys do nothing', () => {
      const initialCount = component.messages().length;
      component.newMessage.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'a' });
      component.handleKeyPress(event);
      expect(component.messages().length).toBe(initialCount);
    });
  });

  describe('Message Helpers', () => {
    it('should identify own message by senderId', () => {
      const msg = { id: '1', senderId: 'me', senderName: 'Test', content: 'Hello', sentAt: new Date() };
      expect(component.isOwnMessage(msg)).toBe(true);
    });

    it('should identify own message by senderName', () => {
      const msg = { id: '1', senderId: 'other', senderName: 'You', content: 'Hello', sentAt: new Date() };
      expect(component.isOwnMessage(msg)).toBe(true);
    });

    it('should identify other user message', () => {
      const msg = { id: '1', senderId: 'u1', senderName: 'John', content: 'Hello', sentAt: new Date() };
      expect(component.isOwnMessage(msg)).toBe(false);
    });

    it('should get sender name from message', () => {
      const msg = { id: '1', senderId: 'u1', senderName: 'John Engineer', content: 'Hi', sentAt: new Date() };
      expect(component.getSenderName(msg)).toBe('John Engineer');
    });
  });

  describe('Like Simulation', () => {
    beforeEach(() => {
      component.ngOnInit();
    });

    it('should increment likes when not owner', () => {
      const initialLikes = component.simulation()?.likes || 0;
      component.likeSimulation();
      expect(component.simulation()?.likes).toBe(initialLikes + 1);
    });

    it('should not like when user is owner', () => {
      const sim = component.simulation();
      if (sim) {
        component.simulation.set({ ...sim, isOwner: true });
        const likes = component.simulation()?.likes || 0;
        component.likeSimulation();
        expect(component.simulation()?.likes).toBe(likes);
      }
    });

    it('should not like when no simulation', () => {
      component.simulation.set(null);
      expect(() => component.likeSimulation()).not.toThrow();
    });
  });

  describe('Navigation', () => {
    it('should navigate to community on goBack', () => {
      component.goBack();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/community']);
    });
  });

  describe('Utility Methods', () => {
    it('should get initials for single name', () => {
      expect(component.getInitials('John')).toBe('J');
    });

    it('should get initials for two names', () => {
      expect(component.getInitials('John Doe')).toBe('JD');
    });

    it('should get initials for multiple names', () => {
      expect(component.getInitials('John Middle Doe')).toBe('JM');
    });

    it('should get initials in uppercase', () => {
      expect(component.getInitials('john doe')).toBe('JD');
    });

    it('should return "Just now" for recent time', () => {
      const now = new Date();
      expect(component.getTimeAgo(now)).toBe('Just now');
    });

    it('should return minutes ago for times within an hour', () => {
      const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
      expect(component.getTimeAgo(fiveMinutesAgo)).toBe('5m ago');
    });

    it('should return hours ago for times beyond an hour', () => {
      const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);
      expect(component.getTimeAgo(twoHoursAgo)).toBe('2h ago');
    });

    it('should return empty string for undefined date', () => {
      expect(component.getTimeAgo(undefined)).toBe('');
    });

    it('should return green color for ACCEPTED status', () => {
      expect(component.getStatusColor('ACCEPTED')).toBe('#22c55e');
    });

    it('should return amber color for PENDING status', () => {
      expect(component.getStatusColor('PENDING')).toBe('#f59e0b');
    });

    it('should return gray color for other status', () => {
      expect(component.getStatusColor('BLOCKED')).toBe('#6b7280');
    });
  });

  describe('Lifecycle Hooks', () => {
    it('should implement ngOnDestroy without error', () => {
      expect(() => component.ngOnDestroy()).not.toThrow();
    });

    it('should implement ngAfterViewChecked without error', () => {
      expect(() => component.ngAfterViewChecked()).not.toThrow();
    });

    it('should call scrollToBottom when shouldScrollToBottom is true', () => {
      const scrollSpy = vi.spyOn(component, 'scrollToBottom');
      (component as any).shouldScrollToBottom = true;
      component.ngAfterViewChecked();
      expect(scrollSpy).toHaveBeenCalled();
    });

    it('should handle scrollToBottom when no ref', () => {
      component.chatMessagesRef = undefined as any;
      expect(() => component.scrollToBottom()).not.toThrow();
    });

    it('should scroll to bottom when ref exists', () => {
      const mockElement = { scrollTop: 0, scrollHeight: 500 };
      component.chatMessagesRef = { nativeElement: mockElement } as ElementRef;
      component.scrollToBottom();
      expect(mockElement.scrollTop).toBe(500);
    });
  });

  describe('Edge Cases', () => {
    it('should handle simulation with no sharedWith', () => {
      component.ngOnInit();
      const sim = component.simulation();
      if (sim) {
        component.simulation.set({ ...sim, sharedWith: undefined });
        expect(component.simulation()?.sharedWith).toBeUndefined();
      }
    });

    it('should handle empty friend filter query with spaces', () => {
      component.searchFriendQuery.set('   ');
      expect(component.filteredFriends().length).toBe(0);
    });

    it('should handle simulation without owner name', () => {
      component.ngOnInit();
      const sim = component.simulation();
      if (sim) {
        component.simulation.set({ ...sim, owner: { name: '' } });
        expect(component.getInitials(component.simulation()?.owner.name || '')).toBe('');
      }
    });
  });
});
