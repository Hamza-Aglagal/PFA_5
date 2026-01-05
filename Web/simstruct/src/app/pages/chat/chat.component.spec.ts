import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of, throwError } from 'rxjs';
import { ChatComponent } from './chat.component';
import { CommunityService } from '../../core/services/community.service';
import { SimulationService } from '../../core/services/simulation.service';

describe('ChatComponent', () => {
  let component: ChatComponent;
  let fixture: ComponentFixture<ChatComponent>;
  let communityServiceMock: {
    getConversation: ReturnType<typeof vi.fn>;
    getSharesWithFriend: ReturnType<typeof vi.fn>;
    sendMessage: ReturnType<typeof vi.fn>;
    markAsRead: ReturnType<typeof vi.fn>;
    shareSimulation: ReturnType<typeof vi.fn>;
  };
  let simulationServiceMock: {
    getUserSimulations: ReturnType<typeof vi.fn>;
  };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };

  const mockMessages = [
    { id: 'msg-1', senderId: 'friend-1', senderName: 'Alice', content: 'Hello!', sentAt: '2024-01-01T10:00:00Z', isRead: true },
    { id: 'msg-2', senderId: 'user-1', senderName: 'You', content: 'Hi there!', sentAt: '2024-01-01T10:01:00Z', isRead: true }
  ];

  const mockShares = [
    { id: 'share-1', simulationName: 'Test Sim', simulationDescription: 'Description', ownerId: 'user-1', sharedAt: '2024-01-01T00:00:00Z' }
  ];

  const mockSimulations = [
    {
      id: 'sim-1',
      name: 'My Simulation',
      description: 'A test simulation',
      supportType: 'SIMPLY_SUPPORTED',
      materialType: 'STEEL',
      beamLength: 10,
      beamWidth: 0.5,
      beamHeight: 0.8,
      loadMagnitude: 50000,
      isPublic: true,
      likesCount: 5,
      createdAt: '2024-01-01T00:00:00Z',
      results: { safetyFactor: 2.5 }
    }
  ];

  beforeEach(async () => {
    communityServiceMock = {
      getConversation: vi.fn().mockReturnValue(of({ success: true, data: mockMessages })),
      getSharesWithFriend: vi.fn().mockReturnValue(of({ success: true, data: mockShares })),
      sendMessage: vi.fn().mockReturnValue(of({ 
        success: true, 
        data: { id: 'msg-new', senderId: 'user-1', senderName: 'You', content: 'Test', sentAt: new Date().toISOString() } 
      })),
      markAsRead: vi.fn().mockReturnValue(of({})),
      shareSimulation: vi.fn().mockReturnValue(of({ success: true }))
    };

    simulationServiceMock = {
      getUserSimulations: vi.fn().mockReturnValue(of({ success: true, data: mockSimulations }))
    };

    routerMock = {
      navigate: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [ChatComponent],
      providers: [
        { provide: CommunityService, useValue: communityServiceMock },
        { provide: SimulationService, useValue: simulationServiceMock },
        { provide: Router, useValue: routerMock },
        {
          provide: ActivatedRoute,
          useValue: {
            queryParams: of({ userId: 'friend-1', userName: 'Alice' })
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(ChatComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should have empty message input initially', () => {
      expect(component.messageInput()).toBe('');
    });

    it('should have chat as active panel initially', () => {
      expect(component.activePanel()).toBe('chat');
    });

    it('should have sent tab selected initially', () => {
      expect(component.simulationTab()).toBe('sent');
    });

    it('should show sidebar initially', () => {
      expect(component.showSidebar()).toBe(true);
    });

    it('should have no selected simulation initially', () => {
      expect(component.selectedSimulation()).toBeNull();
    });

    it('should have share modal hidden initially', () => {
      expect(component.showShareModal()).toBe(false);
    });

    it('should not be sharing simulation initially', () => {
      expect(component.isSharingSimulation()).toBe(false);
    });

    it('should have empty messages initially', () => {
      expect(component.messages()).toHaveLength(0);
    });
  });

  describe('ngOnInit', () => {
    it('should set friend name from query params', () => {
      component.ngOnInit();
      expect(component.friendName()).toBe('Alice');
    });

    it('should set friend id from query params', () => {
      component.ngOnInit();
      expect(component.friendId()).toBe('friend-1');
    });

    it('should load conversation on init', () => {
      component.ngOnInit();
      expect(communityServiceMock.getConversation).toHaveBeenCalled();
    });

    it('should load shares with friend', () => {
      component.ngOnInit();
      expect(communityServiceMock.getSharesWithFriend).toHaveBeenCalledWith('friend-1');
    });
  });

  describe('totalSharedCount computed', () => {
    it('should calculate total shared count', () => {
      component.sharedWithPartner.set([{ id: '1' } as any, { id: '2' } as any]);
      component.sharedByPartner.set([{ id: '3' } as any]);
      expect(component.totalSharedCount()).toBe(3);
    });
  });

  describe('goBack', () => {
    it('should navigate to community', () => {
      component.goBack();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/community']);
    });
  });

  describe('toggleSidebar', () => {
    it('should toggle sidebar from true to false', () => {
      component.showSidebar.set(true);
      component.toggleSidebar();
      expect(component.showSidebar()).toBe(false);
    });

    it('should toggle sidebar from false to true', () => {
      component.showSidebar.set(false);
      component.toggleSidebar();
      expect(component.showSidebar()).toBe(true);
    });
  });

  describe('setActivePanel', () => {
    it('should set active panel to chat', () => {
      component.setActivePanel('chat');
      expect(component.activePanel()).toBe('chat');
    });

    it('should set active panel to simulations', () => {
      component.setActivePanel('simulations');
      expect(component.activePanel()).toBe('simulations');
    });

    it('should set active panel to details', () => {
      component.setActivePanel('details');
      expect(component.activePanel()).toBe('details');
    });
  });

  describe('getInitials', () => {
    it('should return initials for single name', () => {
      expect(component.getInitials('Alice')).toBe('A');
    });

    it('should return initials for full name', () => {
      expect(component.getInitials('Alice Smith')).toBe('AS');
    });

    it('should return ? for empty name', () => {
      expect(component.getInitials('')).toBe('?');
    });

    it('should limit to 2 characters', () => {
      expect(component.getInitials('Alice Bob Charlie')).toBe('AB');
    });
  });

  describe('formatTime', () => {
    it('should return "Just now" for very recent date', () => {
      const now = new Date();
      expect(component.formatTime(now)).toBe('Just now');
    });

    it('should return minutes ago for recent date', () => {
      const fiveMinAgo = new Date(Date.now() - 5 * 60 * 1000);
      expect(component.formatTime(fiveMinAgo)).toBe('5m ago');
    });

    it('should return time for today', () => {
      const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);
      const result = component.formatTime(twoHoursAgo);
      expect(result).toMatch(/^\d{1,2}:\d{2}/);
    });
  });

  describe('updateInput', () => {
    it('should update message input from event', () => {
      const event = { target: { value: 'Hello world' } } as unknown as Event;
      component.updateInput(event);
      expect(component.messageInput()).toBe('Hello world');
    });
  });

  describe('handleKeyPress', () => {
    it('should call sendMessage on Enter', () => {
      const sendMessageSpy = vi.spyOn(component, 'sendMessage');
      component.messageInput.set('Test message');
      component.friendId.set('friend-1');
      
      const event = { 
        key: 'Enter', 
        shiftKey: false, 
        preventDefault: vi.fn() 
      } as unknown as KeyboardEvent;
      
      component.handleKeyPress(event);
      expect(event.preventDefault).toHaveBeenCalled();
      expect(sendMessageSpy).toHaveBeenCalled();
    });

    it('should not send on Shift+Enter', () => {
      const sendMessageSpy = vi.spyOn(component, 'sendMessage');
      const event = { 
        key: 'Enter', 
        shiftKey: true, 
        preventDefault: vi.fn() 
      } as unknown as KeyboardEvent;
      
      component.handleKeyPress(event);
      expect(sendMessageSpy).not.toHaveBeenCalled();
    });

    it('should not send on other keys', () => {
      const sendMessageSpy = vi.spyOn(component, 'sendMessage');
      const event = { 
        key: 'a', 
        shiftKey: false, 
        preventDefault: vi.fn() 
      } as unknown as KeyboardEvent;
      
      component.handleKeyPress(event);
      expect(sendMessageSpy).not.toHaveBeenCalled();
    });
  });

  describe('sendMessage', () => {
    beforeEach(() => {
      component.friendId.set('friend-1');
    });

    it('should send message and clear input', () => {
      component.messageInput.set('Hello!');
      component.sendMessage();
      expect(communityServiceMock.sendMessage).toHaveBeenCalledWith('friend-1', 'Hello!');
      expect(component.messageInput()).toBe('');
    });

    it('should not send empty message', () => {
      component.messageInput.set('   ');
      component.sendMessage();
      expect(communityServiceMock.sendMessage).not.toHaveBeenCalled();
    });

    it('should not send if no friend id', () => {
      component.friendId.set(null);
      component.messageInput.set('Hello!');
      component.sendMessage();
      expect(communityServiceMock.sendMessage).not.toHaveBeenCalled();
    });
  });

  describe('isOwnMessage', () => {
    beforeEach(() => {
      component.friendId.set('friend-1');
    });

    it('should return true for message from You', () => {
      const message = { senderId: 'user-1', senderName: 'You' } as any;
      expect(component.isOwnMessage(message)).toBe(true);
    });

    it('should return true for message not from friend', () => {
      const message = { senderId: 'user-1', senderName: 'Me' } as any;
      expect(component.isOwnMessage(message)).toBe(true);
    });

    it('should return false for message from friend', () => {
      const message = { senderId: 'friend-1', senderName: 'Alice' } as any;
      expect(component.isOwnMessage(message)).toBe(false);
    });
  });

  describe('getSafetyClass', () => {
    it('should return safe for sf >= 1.5', () => {
      expect(component.getSafetyClass(2.0)).toBe('safe');
      expect(component.getSafetyClass(1.5)).toBe('safe');
    });

    it('should return warning for 1.0 <= sf < 1.5', () => {
      expect(component.getSafetyClass(1.2)).toBe('warning');
      expect(component.getSafetyClass(1.0)).toBe('warning');
    });

    it('should return critical for sf < 1.0', () => {
      expect(component.getSafetyClass(0.8)).toBe('critical');
    });
  });

  describe('getSafetyDashArray', () => {
    it('should return valid dash array', () => {
      const result = component.getSafetyDashArray(1.5);
      expect(result).toContain(' ');
    });
  });

  describe('viewSimulationDetail', () => {
    const mockSim = {
      id: 'sim-1',
      name: 'Test Sim',
      description: 'Description',
      material: 'Steel',
      structureType: 'Beam',
      safetyFactor: 2.0,
      likes: 5,
      views: 10,
      isPublic: true,
      isOwner: true,
      sharedAt: new Date(),
      createdAt: new Date(),
      tags: [],
      dimensions: { length: 10, width: 0.5, height: 0.8 },
      load: 50000
    };

    it('should set selected simulation', () => {
      component.viewSimulationDetail(mockSim);
      expect(component.selectedSimulation()).not.toBeNull();
      expect(component.selectedSimulation()?.name).toBe('Test Sim');
    });

    it('should set active panel to details', () => {
      component.viewSimulationDetail(mockSim);
      expect(component.activePanel()).toBe('details');
    });
  });

  describe('viewReceivedSimulation', () => {
    it('should navigate to results', () => {
      const mockShare = { simulationId: 'sim-1' } as any;
      component.viewReceivedSimulation(mockShare);
      expect(routerMock.navigate).toHaveBeenCalledWith(['/results', 'sim-1']);
    });
  });

  describe('clearSelectedSimulation', () => {
    it('should clear selected simulation', () => {
      component.selectedSimulation.set({ id: 'sim-1' } as any);
      component.clearSelectedSimulation();
      expect(component.selectedSimulation()).toBeNull();
    });
  });

  describe('viewFullResults', () => {
    it('should navigate to results for selected simulation', () => {
      component.selectedSimulation.set({ id: 'sim-1' } as any);
      component.viewFullResults();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/results', 'sim-1']);
    });

    it('should not navigate if no selected simulation', () => {
      component.selectedSimulation.set(null);
      component.viewFullResults();
      expect(routerMock.navigate).not.toHaveBeenCalled();
    });
  });

  describe('share modal', () => {
    it('should open share modal', () => {
      component.openShareModal();
      expect(component.showShareModal()).toBe(true);
      expect(component.selectedShareSimulation()).toBeNull();
      expect(component.shareMessage()).toBe('');
    });

    it('should close share modal', () => {
      component.showShareModal.set(true);
      component.closeShareModal();
      expect(component.showShareModal()).toBe(false);
    });

    it('should select share simulation', () => {
      const mockSim = { id: 'sim-1' } as any;
      component.selectShareSimulation(mockSim);
      expect(component.selectedShareSimulation()).toEqual(mockSim);
    });

    it('should deselect if same simulation selected again', () => {
      const mockSim = { id: 'sim-1' } as any;
      component.selectShareSimulation(mockSim);
      component.selectShareSimulation(mockSim);
      expect(component.selectedShareSimulation()).toBeNull();
    });
  });

  describe('updateShareMessage', () => {
    it('should update share message from event', () => {
      const event = { target: { value: 'Check this out!' } } as unknown as Event;
      component.updateShareMessage(event);
      expect(component.shareMessage()).toBe('Check this out!');
    });
  });

  describe('shareSimulation', () => {
    beforeEach(() => {
      component.friendId.set('friend-1');
    });

    it('should share simulation with friend', () => {
      const mockSim = { id: 'sim-1', name: 'Test' } as any;
      component.selectedShareSimulation.set(mockSim);
      component.shareSimulation();
      expect(communityServiceMock.shareSimulation).toHaveBeenCalledWith('sim-1', 'friend-1', 'VIEW');
    });

    it('should not share if no simulation selected', () => {
      component.selectedShareSimulation.set(null);
      component.shareSimulation();
      expect(communityServiceMock.shareSimulation).not.toHaveBeenCalled();
    });

    it('should not share if no friend id', () => {
      component.friendId.set(null);
      const mockSim = { id: 'sim-1', name: 'Test' } as any;
      component.selectedShareSimulation.set(mockSim);
      component.shareSimulation();
      expect(communityServiceMock.shareSimulation).not.toHaveBeenCalled();
    });
  });

  describe('ngOnDestroy', () => {
    it('should clean up without error', () => {
      expect(() => component.ngOnDestroy()).not.toThrow();
    });
  });
});
