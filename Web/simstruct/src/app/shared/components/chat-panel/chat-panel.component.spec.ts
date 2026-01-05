import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { ChatPanelComponent } from './chat-panel.component';
import { ElementRef } from '@angular/core';

describe('ChatPanelComponent', () => {
  let component: ChatPanelComponent;
  let fixture: ComponentFixture<ChatPanelComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ChatPanelComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(ChatPanelComponent);
    component = fixture.componentInstance;
  });

  describe('Component Creation', () => {
    it('should create the component', () => {
      expect(component).toBeTruthy();
    });

    it('should have chatService defined', () => {
      expect(component.chatService).toBeDefined();
    });

    it('should have authService defined', () => {
      expect(component.authService).toBeDefined();
    });

    it('should have empty messageInput initially', () => {
      expect(component.messageInput()).toBe('');
    });

    it('should have chatOpen as false initially', () => {
      expect(component.chatService.chatOpen()).toBe(false);
    });

    it('should have null activeConversation initially', () => {
      expect(component.chatService.activeConversation()).toBeNull();
    });

    it('should have empty activeMessages initially', () => {
      expect(component.chatService.activeMessages()).toEqual([]);
    });

    it('should have empty allConversations initially', () => {
      expect(component.chatService.allConversations()).toEqual([]);
    });

    it('should have zero totalUnreadCount initially', () => {
      expect(component.chatService.totalUnreadCount()).toBe(0);
    });
  });

  describe('Chat Service Methods', () => {
    it('should open chat', () => {
      component.chatService.openChat();
      expect(component.chatService.chatOpen()).toBe(true);
    });

    it('should close chat', () => {
      component.chatService.openChat();
      component.chatService.closeChat();
      expect(component.chatService.chatOpen()).toBe(false);
    });

    it('should clear active conversation', () => {
      const mockConversation = {
        id: 'conv1',
        otherParticipant: { id: 'p1', name: 'Test User' },
        lastMessage: { content: 'Hello', sentAt: new Date(), senderName: 'Test' },
        unreadCount: 0
      };
      component.chatService.activeConversation.set(mockConversation);
      component.chatService.clearActiveConversation();
      expect(component.chatService.activeConversation()).toBeNull();
    });

    it('should log when selecting conversation', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.chatService.selectConversation('conv1');
      expect(consoleSpy).toHaveBeenCalledWith('Select conversation:', 'conv1');
    });

    it('should log when sending message', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.chatService.sendMessage('Hello');
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', 'Hello');
    });

    it('should format message time', () => {
      const result = component.chatService.formatMessageTime(new Date());
      expect(result).toBe('Just now');
    });

    it('should get time ago', () => {
      const result = component.chatService.getTimeAgo(new Date());
      expect(result).toBe('Just now');
    });
  });

  describe('Auth Service', () => {
    it('should have null user initially', () => {
      expect(component.authService.user()).toBeNull();
    });

    it('should allow setting user', () => {
      const mockUser = { id: 'u1', name: 'Test User' };
      component.authService.user.set(mockUser as any);
      expect(component.authService.user()).toEqual(mockUser);
    });
  });

  describe('Send Message', () => {
    it('should send message when content is not empty', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.messageInput.set('Hello World');
      component.sendMessage();
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', 'Hello World');
    });

    it('should clear input after sending message', () => {
      component.messageInput.set('Hello World');
      component.sendMessage();
      expect(component.messageInput()).toBe('');
    });

    it('should not send empty message', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('');
      component.sendMessage();
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });

    it('should not send whitespace-only message', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('   ');
      component.sendMessage();
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });

    it('should trim message before sending', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.messageInput.set('  Hello World  ');
      component.sendMessage();
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', 'Hello World');
    });
  });

  describe('Handle Key Press', () => {
    it('should send message on Enter key', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.messageInput.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'Enter', shiftKey: false });
      const preventDefaultSpy = vi.spyOn(event, 'preventDefault');
      component.handleKeyPress(event);
      expect(preventDefaultSpy).toHaveBeenCalled();
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', 'Hello');
    });

    it('should not send on Shift+Enter', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'Enter', shiftKey: true });
      component.handleKeyPress(event);
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });

    it('should not send on other keys', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'a' });
      component.handleKeyPress(event);
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });

    it('should not send on Escape key', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'Escape' });
      component.handleKeyPress(event);
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });

    it('should not send on Tab key', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('Hello');
      const event = new KeyboardEvent('keydown', { key: 'Tab' });
      component.handleKeyPress(event);
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });
  });

  describe('Is Own Message', () => {
    it('should return true when user id matches senderId', () => {
      const mockUser = { id: 'user123' };
      component.authService.user.set(mockUser as any);
      const message = {
        id: 'm1',
        senderId: 'user123',
        senderName: 'Test',
        content: 'Hello',
        sentAt: new Date()
      };
      expect(component.isOwnMessage(message)).toBe(true);
    });

    it('should return false when user id does not match senderId', () => {
      const mockUser = { id: 'user123' };
      component.authService.user.set(mockUser as any);
      const message = {
        id: 'm1',
        senderId: 'user456',
        senderName: 'Other',
        content: 'Hello',
        sentAt: new Date()
      };
      expect(component.isOwnMessage(message)).toBe(false);
    });

    it('should return true when senderName is You and no user', () => {
      component.authService.user.set(null);
      const message = {
        id: 'm1',
        senderId: 'any',
        senderName: 'You',
        content: 'Hello',
        sentAt: new Date()
      };
      expect(component.isOwnMessage(message)).toBe(true);
    });

    it('should return false when senderName is not You and no user', () => {
      component.authService.user.set(null);
      const message = {
        id: 'm1',
        senderId: 'any',
        senderName: 'Other',
        content: 'Hello',
        sentAt: new Date()
      };
      expect(component.isOwnMessage(message)).toBe(false);
    });
  });

  describe('Get Initials', () => {
    it('should return initials for single name', () => {
      expect(component.getInitials('John')).toBe('J');
    });

    it('should return initials for two names', () => {
      expect(component.getInitials('John Doe')).toBe('JD');
    });

    it('should return initials for three names', () => {
      expect(component.getInitials('John Middle Doe')).toBe('JM');
    });

    it('should limit initials to 2 characters', () => {
      expect(component.getInitials('John Middle Last Name').length).toBeLessThanOrEqual(2);
    });

    it('should return uppercase initials', () => {
      expect(component.getInitials('john doe')).toBe('JD');
    });

    it('should handle single character name', () => {
      expect(component.getInitials('J')).toBe('J');
    });

    it('should handle names with extra spaces', () => {
      const result = component.getInitials('John  Doe');
      expect(result).toContain('J');
    });
  });

  describe('Update Input', () => {
    it('should update messageInput from event', () => {
      const event = { target: { value: 'New message' } } as unknown as Event;
      component.updateInput(event);
      expect(component.messageInput()).toBe('New message');
    });

    it('should handle empty input', () => {
      component.messageInput.set('existing');
      const event = { target: { value: '' } } as unknown as Event;
      component.updateInput(event);
      expect(component.messageInput()).toBe('');
    });

    it('should handle input with spaces', () => {
      const event = { target: { value: '  Hello  ' } } as unknown as Event;
      component.updateInput(event);
      expect(component.messageInput()).toBe('  Hello  ');
    });

    it('should handle special characters', () => {
      const event = { target: { value: 'Hello @#$%!' } } as unknown as Event;
      component.updateInput(event);
      expect(component.messageInput()).toBe('Hello @#$%!');
    });

    it('should handle unicode characters', () => {
      const event = { target: { value: 'Hello 世界 🌍' } } as unknown as Event;
      component.updateInput(event);
      expect(component.messageInput()).toBe('Hello 世界 🌍');
    });
  });

  describe('NgAfterViewChecked', () => {
    it('should not throw when called', () => {
      expect(() => component.ngAfterViewChecked()).not.toThrow();
    });

    it('should call scrollToBottom when shouldScrollToBottom is true', () => {
      (component as any).shouldScrollToBottom = true;
      const mockElement = { scrollTop: 0, scrollHeight: 500 };
      component.messagesContainer = { nativeElement: mockElement } as ElementRef;
      component.ngAfterViewChecked();
      expect(mockElement.scrollTop).toBe(500);
    });

    it('should not scroll when shouldScrollToBottom is false', () => {
      (component as any).shouldScrollToBottom = false;
      const mockElement = { scrollTop: 0, scrollHeight: 500 };
      component.messagesContainer = { nativeElement: mockElement } as ElementRef;
      component.ngAfterViewChecked();
      expect(mockElement.scrollTop).toBe(0);
    });
  });

  describe('Scroll To Bottom', () => {
    it('should scroll container to bottom', () => {
      const mockElement = { scrollTop: 0, scrollHeight: 1000 };
      component.messagesContainer = { nativeElement: mockElement } as ElementRef;
      (component as any).scrollToBottom();
      expect(mockElement.scrollTop).toBe(1000);
    });

    it('should handle missing container gracefully', () => {
      component.messagesContainer = undefined as any;
      expect(() => (component as any).scrollToBottom()).not.toThrow();
    });

    it('should handle null nativeElement', () => {
      component.messagesContainer = { nativeElement: null } as any;
      expect(() => (component as any).scrollToBottom()).not.toThrow();
    });
  });

  describe('Conversation Signals', () => {
    it('should update activeConversation', () => {
      const conversation = {
        id: 'conv1',
        otherParticipant: { id: 'p1', name: 'Alice' },
        lastMessage: { content: 'Hi', sentAt: new Date(), senderName: 'Alice' },
        unreadCount: 3
      };
      component.chatService.activeConversation.set(conversation);
      expect(component.chatService.activeConversation()?.id).toBe('conv1');
    });

    it('should update activeMessages', () => {
      const messages = [
        { id: 'm1', senderId: 's1', senderName: 'Alice', content: 'Hello', sentAt: new Date() }
      ];
      component.chatService.activeMessages.set(messages);
      expect(component.chatService.activeMessages().length).toBe(1);
    });

    it('should update allConversations', () => {
      const conversations = [
        {
          id: 'conv1',
          otherParticipant: { id: 'p1', name: 'Alice' },
          lastMessage: { content: 'Hi', sentAt: new Date(), senderName: 'Alice' },
          unreadCount: 1
        }
      ];
      component.chatService.allConversations.set(conversations);
      expect(component.chatService.allConversations().length).toBe(1);
    });

    it('should update totalUnreadCount', () => {
      component.chatService.totalUnreadCount.set(5);
      expect(component.chatService.totalUnreadCount()).toBe(5);
    });
  });

  describe('Edge Cases', () => {
    it('should handle very long message', () => {
      const longMessage = 'a'.repeat(10000);
      const consoleSpy = vi.spyOn(console, 'log');
      component.messageInput.set(longMessage);
      component.sendMessage();
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', longMessage);
    });

    it('should handle message with only newlines', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('\n\n\n');
      component.sendMessage();
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });

    it('should handle message with tabs', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      consoleSpy.mockClear();
      component.messageInput.set('\t\t\t');
      component.sendMessage();
      expect(consoleSpy).not.toHaveBeenCalledWith('Send message:', expect.anything());
    });

    it('should handle rapid multiple sends', () => {
      const consoleSpy = vi.spyOn(console, 'log');
      component.messageInput.set('Message 1');
      component.sendMessage();
      component.messageInput.set('Message 2');
      component.sendMessage();
      component.messageInput.set('Message 3');
      component.sendMessage();
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', 'Message 1');
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', 'Message 2');
      expect(consoleSpy).toHaveBeenCalledWith('Send message:', 'Message 3');
    });
  });
});
