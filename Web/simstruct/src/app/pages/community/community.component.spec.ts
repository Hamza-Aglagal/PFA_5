import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of, Subject, throwError } from 'rxjs';
import { CommunityComponent } from './community.component';
import { CommunityService, UserSearchResult } from '../../core/services/community.service';
import { SimulationService } from '../../core/services/simulation.service';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';
import { signal } from '@angular/core';

describe('CommunityComponent', () => {
  let component: CommunityComponent;
  let fixture: ComponentFixture<CommunityComponent>;
  let communityServiceMock: {
    allFriends: ReturnType<typeof signal>;
    pendingInvitations: ReturnType<typeof signal>;
    allInvitationsSent: ReturnType<typeof signal>;
    myShares: ReturnType<typeof signal>;
    userSearchResults: ReturnType<typeof signal>;
    userSearchLoading: ReturnType<typeof signal>;
    loadFriends: ReturnType<typeof vi.fn>;
    loadPendingInvitations: ReturnType<typeof vi.fn>;
    loadSentInvitations: ReturnType<typeof vi.fn>;
    loadMyShares: ReturnType<typeof vi.fn>;
    loadSharedWithMe: ReturnType<typeof vi.fn>;
    searchUsers: ReturnType<typeof vi.fn>;
    clearSearchResults: ReturnType<typeof vi.fn>;
    shareSimulation: ReturnType<typeof vi.fn>;
    sendFriendRequest: ReturnType<typeof vi.fn>;
    acceptFriendRequest: ReturnType<typeof vi.fn>;
    rejectFriendRequest: ReturnType<typeof vi.fn>;
    removeFriend: ReturnType<typeof vi.fn>;
  };
  let simulationServiceMock: {
    getUserSimulations: ReturnType<typeof vi.fn>;
  };
  let notificationServiceMock: {
    success: ReturnType<typeof vi.fn>;
    error: ReturnType<typeof vi.fn>;
  };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let modalServiceMock: { confirm: ReturnType<typeof vi.fn> };

  const mockFriends = [
    { id: 'friend-1', friendshipId: 'fs-1', name: 'Alice', email: 'alice@test.com', status: 'ACCEPTED', friendsSince: new Date() },
    { id: 'friend-2', friendshipId: 'fs-2', name: 'Bob', email: 'bob@test.com', status: 'ACCEPTED', friendsSince: new Date() }
  ];

  const mockSimulations = [
    {
      id: 'sim-1',
      name: 'Test Simulation',
      description: 'A test',
      supportType: 'Beam',
      materialType: 'STEEL',
      isPublic: true,
      likesCount: 5,
      createdAt: '2024-01-01T00:00:00Z',
      beamLength: 10,
      beamWidth: 0.5,
      beamHeight: 0.8,
      loadMagnitude: 50000,
      results: { safetyFactor: 2.5 }
    }
  ];

  const mockPendingInvitations = [
    { id: 'inv-1', senderId: 'user-1', senderName: 'Charlie', senderEmail: 'charlie@test.com', createdAt: '2024-01-01T00:00:00Z', status: 'PENDING' }
  ];

  beforeEach(async () => {
    communityServiceMock = {
      allFriends: signal(mockFriends),
      pendingInvitations: signal(mockPendingInvitations),
      allInvitationsSent: signal([]),
      myShares: signal([]),
      userSearchResults: signal([]),
      userSearchLoading: signal(false),
      loadFriends: vi.fn().mockReturnValue(of([])),
      loadPendingInvitations: vi.fn().mockReturnValue(of([])),
      loadSentInvitations: vi.fn().mockReturnValue(of([])),
      loadMyShares: vi.fn().mockReturnValue(of([])),
      loadSharedWithMe: vi.fn().mockReturnValue(of([])),
      searchUsers: vi.fn().mockReturnValue(of([])),
      clearSearchResults: vi.fn(),
      shareSimulation: vi.fn().mockReturnValue(of({})),
      sendFriendRequest: vi.fn().mockReturnValue(of({})),
      acceptFriendRequest: vi.fn().mockReturnValue(of({})),
      rejectFriendRequest: vi.fn().mockReturnValue(of({})),
      removeFriend: vi.fn().mockReturnValue(of({}))
    };

    simulationServiceMock = {
      getUserSimulations: vi.fn().mockReturnValue(of(mockSimulations))
    };

    routerMock = {
      navigate: vi.fn()
    };

    modalServiceMock = {
      confirm: vi.fn().mockResolvedValue(true)
    };

    await TestBed.configureTestingModule({
      imports: [CommunityComponent],
      providers: [
        { provide: CommunityService, useValue: communityServiceMock },
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

    fixture = TestBed.createComponent(CommunityComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should have explore tab active initially', () => {
      expect(component.activeTab()).toBe('explore');
    });

    it('should have empty search query initially', () => {
      expect(component.searchQuery()).toBe('');
    });

    it('should have invite modal hidden initially', () => {
      expect(component.showInviteModal()).toBe(false);
    });

    it('should have share modal hidden initially', () => {
      expect(component.showShareModal()).toBe(false);
    });

    it('should have empty invite email initially', () => {
      expect(component.inviteEmail()).toBe('');
    });

    it('should have no selected simulation initially', () => {
      expect(component.selectedSimulation()).toBeNull();
    });

    it('should have empty selected friends set', () => {
      expect(component.selectedFriends().size).toBe(0);
    });

    it('should have search invite mode initially', () => {
      expect(component.inviteMode()).toBe('search');
    });

    it('should have all structure filter initially', () => {
      expect(component.structureFilter()).toBe('all');
    });

    it('should have all material filter initially', () => {
      expect(component.materialFilter()).toBe('all');
    });

    it('should have recent sort initially', () => {
      expect(component.sortBy()).toBe('recent');
    });

    it('should not be loading initially', () => {
      expect(component.isLoading()).toBe(false);
    });
  });

  describe('filter options', () => {
    it('should have 5 structure types', () => {
      expect(component.structureTypes).toHaveLength(5);
      expect(component.structureTypes).toContain('all');
      expect(component.structureTypes).toContain('beam');
    });

    it('should have 5 materials', () => {
      expect(component.materials).toHaveLength(5);
      expect(component.materials).toContain('all');
      expect(component.materials).toContain('steel');
    });
  });

  describe('ngOnInit', () => {
    it('should load data on init', () => {
      component.ngOnInit();
      expect(communityServiceMock.loadFriends).toHaveBeenCalled();
      expect(communityServiceMock.loadPendingInvitations).toHaveBeenCalled();
      expect(communityServiceMock.loadSentInvitations).toHaveBeenCalled();
      expect(communityServiceMock.loadMyShares).toHaveBeenCalled();
    });

    it('should load simulations on init', () => {
      component.ngOnInit();
      expect(simulationServiceMock.getUserSimulations).toHaveBeenCalled();
    });
  });

  describe('tab navigation', () => {
    it('should set tab to explore', () => {
      component.setTab('explore');
      expect(component.activeTab()).toBe('explore');
    });

    it('should set tab to friends', () => {
      component.setTab('friends');
      expect(component.activeTab()).toBe('friends');
    });

    it('should set tab to invitations', () => {
      component.setTab('invitations');
      expect(component.activeTab()).toBe('invitations');
    });

    it('should set tab to my-shares', () => {
      component.setTab('my-shares');
      expect(component.activeTab()).toBe('my-shares');
    });
  });

  describe('updateSearch', () => {
    it('should update search query from event', () => {
      const event = { target: { value: 'test search' } } as unknown as Event;
      component.updateSearch(event);
      expect(component.searchQuery()).toBe('test search');
    });
  });

  describe('computed friends', () => {
    it('should map friends from service', () => {
      const friends = component.friends();
      expect(friends).toHaveLength(2);
      expect(friends[0].name).toBe('Alice');
      expect(friends[1].name).toBe('Bob');
    });

    it('should have friend id and friendshipId', () => {
      const friends = component.friends();
      expect(friends[0].id).toBe('friend-1');
      expect(friends[0].friendshipId).toBe('fs-1');
    });
  });

  describe('computed receivedInvitations', () => {
    it('should map pending invitations from service', () => {
      const invitations = component.receivedInvitations();
      expect(invitations).toHaveLength(1);
      expect(invitations[0].senderName).toBe('Charlie');
    });
  });

  describe('filteredSimulations', () => {
    beforeEach(() => {
      component.ngOnInit();
    });

    it('should return all simulations with no filters', () => {
      const filtered = component.filteredSimulations();
      expect(filtered.length).toBeGreaterThan(0);
    });

    it('should filter by search query', () => {
      component.searchQuery.set('test');
      const filtered = component.filteredSimulations();
      expect(filtered.every(s => 
        s.name.toLowerCase().includes('test') || 
        s.description.toLowerCase().includes('test')
      )).toBe(true);
    });

    it('should sort by popular', () => {
      component.sortBy.set('popular');
      const filtered = component.filteredSimulations();
      if (filtered.length > 1) {
        expect(filtered[0].likes).toBeGreaterThanOrEqual(filtered[1].likes);
      }
    });
  });

  describe('share modal', () => {
    const mockSim = { id: 'sim-1', name: 'Test' } as any;

    it('should open share modal with simulation', () => {
      const event = { stopPropagation: vi.fn() } as unknown as Event;
      component.openShareModal(mockSim, event);
      expect(component.showShareModal()).toBe(true);
      expect(component.selectedSimulation()).toEqual(mockSim);
      expect(event.stopPropagation).toHaveBeenCalled();
    });

    it('should clear selected friends on open', () => {
      component.selectedFriends.set(new Set(['friend-1']));
      const event = { stopPropagation: vi.fn() } as unknown as Event;
      component.openShareModal(mockSim, event);
      expect(component.selectedFriends().size).toBe(0);
    });

    it('should close share modal', () => {
      component.showShareModal.set(true);
      component.closeShareModal();
      expect(component.showShareModal()).toBe(false);
      expect(component.selectedSimulation()).toBeNull();
    });
  });

  describe('friend selection', () => {
    it('should toggle friend selection', () => {
      component.toggleFriendSelection('friend-1');
      expect(component.isFriendSelected('friend-1')).toBe(true);
    });

    it('should toggle friend selection off', () => {
      component.toggleFriendSelection('friend-1');
      component.toggleFriendSelection('friend-1');
      expect(component.isFriendSelected('friend-1')).toBe(false);
    });

    it('should correctly report isFriendSelected', () => {
      expect(component.isFriendSelected('friend-1')).toBe(false);
      component.toggleFriendSelection('friend-1');
      expect(component.isFriendSelected('friend-1')).toBe(true);
    });
  });

  describe('shareWithFriends', () => {
    it('should share with selected friends', () => {
      component.selectedSimulation.set({ id: 'sim-1' } as any);
      component.toggleFriendSelection('friend-1');
      component.toggleFriendSelection('friend-2');
      component.shareWithFriends();
      expect(communityServiceMock.shareSimulation).toHaveBeenCalledWith('sim-1', 'friend-1', 'VIEW');
      expect(communityServiceMock.shareSimulation).toHaveBeenCalledWith('sim-1', 'friend-2', 'VIEW');
    });

    it('should not share if no friends selected', () => {
      component.selectedSimulation.set({ id: 'sim-1' } as any);
      component.shareWithFriends();
      expect(communityServiceMock.shareSimulation).not.toHaveBeenCalled();
    });

    it('should close share modal after sharing', () => {
      component.selectedSimulation.set({ id: 'sim-1' } as any);
      component.toggleFriendSelection('friend-1');
      component.showShareModal.set(true);
      component.shareWithFriends();
      expect(component.showShareModal()).toBe(false);
    });
  });

  describe('invite modal', () => {
    it('should open invite modal', () => {
      component.openInviteModal();
      expect(component.showInviteModal()).toBe(true);
    });

    it('should reset state when opening', () => {
      component.inviteEmail.set('test@test.com');
      component.openInviteModal();
      expect(component.inviteEmail()).toBe('');
      expect(component.inviteMode()).toBe('search');
    });

    it('should close invite modal', () => {
      component.showInviteModal.set(true);
      component.closeInviteModal();
      expect(component.showInviteModal()).toBe(false);
    });

    it('should clear invite error on close', () => {
      component.inviteError.set('Some error');
      component.closeInviteModal();
      expect(component.inviteError()).toBe('');
    });
  });

  describe('setInviteMode', () => {
    it('should set invite mode to search', () => {
      component.setInviteMode('search');
      expect(component.inviteMode()).toBe('search');
    });

    it('should set invite mode to invite', () => {
      component.setInviteMode('invite');
      expect(component.inviteMode()).toBe('invite');
    });

    it('should clear error when changing mode', () => {
      component.inviteError.set('Some error');
      component.setInviteMode('invite');
      expect(component.inviteError()).toBe('');
    });
  });

  describe('sendFriendRequestTo', () => {
    const mockUser: UserSearchResult = { id: 'user-1', name: 'Test User', email: 'test@test.com' };

    it('should send friend request', () => {
      component.sendFriendRequestTo(mockUser);
      expect(communityServiceMock.sendFriendRequest).toHaveBeenCalledWith('user-1');
    });

    it('should close modal on success', () => {
      component.showInviteModal.set(true);
      component.sendFriendRequestTo(mockUser);
      expect(component.showInviteModal()).toBe(false);
    });

    it('should set error on failure', () => {
      communityServiceMock.sendFriendRequest.mockReturnValue(
        throwError(() => ({ error: { message: 'Request failed' } }))
      );
      component.sendFriendRequestTo(mockUser);
      expect(component.inviteError()).toBe('Request failed');
    });
  });

  describe('sendFriendRequestToSuggested', () => {
    it('should send request to suggested user', () => {
      const mockUser: UserSearchResult = { id: 'user-1', name: 'Test', email: 'test@test.com' };
      component.suggestedUser.set(mockUser);
      component.sendFriendRequestToSuggested();
      expect(communityServiceMock.sendFriendRequest).toHaveBeenCalledWith('user-1');
    });

    it('should not send if no suggested user', () => {
      component.suggestedUser.set(null);
      component.sendFriendRequestToSuggested();
      expect(communityServiceMock.sendFriendRequest).not.toHaveBeenCalled();
    });
  });

  describe('invitation actions', () => {
    const mockInvitation = { id: 'inv-1', senderId: 'user-1', senderName: 'Test' } as any;

    it('should accept invitation', () => {
      component.acceptInvitation(mockInvitation);
      expect(communityServiceMock.acceptFriendRequest).toHaveBeenCalledWith('user-1');
    });

    it('should decline invitation', () => {
      component.declineInvitation(mockInvitation);
      expect(communityServiceMock.rejectFriendRequest).toHaveBeenCalledWith('user-1');
    });
  });

  describe('friend actions', () => {
    const mockFriend = { id: 'friend-1', name: 'Alice' };

    it('should accept friend request', () => {
      component.acceptFriendRequest(mockFriend);
      expect(communityServiceMock.acceptFriendRequest).toHaveBeenCalledWith('friend-1');
    });

    it('should reject friend request', () => {
      component.rejectFriendRequest(mockFriend);
      expect(communityServiceMock.rejectFriendRequest).toHaveBeenCalledWith('friend-1');
    });

    it('should show confirmation modal on remove', async () => {
      await component.removeFriend(mockFriend);
      expect(modalServiceMock.confirm).toHaveBeenCalled();
    });

    it('should remove friend on confirmation', async () => {
      await component.removeFriend(mockFriend);
      expect(communityServiceMock.removeFriend).toHaveBeenCalledWith('friend-1');
    });

    it('should not remove if cancelled', async () => {
      modalServiceMock.confirm.mockResolvedValue(false);
      await component.removeFriend(mockFriend);
      expect(communityServiceMock.removeFriend).not.toHaveBeenCalled();
    });
  });

  describe('navigation', () => {
    it('should navigate to results on viewSimulation', () => {
      component.viewSimulation({ id: 'sim-1' });
      expect(routerMock.navigate).toHaveBeenCalledWith(['/results', 'sim-1']);
    });

    it('should navigate with simulationId if present', () => {
      component.viewSimulation({ simulationId: 'sim-2', id: 'share-1' });
      expect(routerMock.navigate).toHaveBeenCalledWith(['/results', 'sim-2']);
    });

    it('should navigate to chat on openChat', () => {
      component.openChat({ id: 'user-1', name: 'Alice' });
      expect(routerMock.navigate).toHaveBeenCalledWith(['/chat'], { queryParams: { userId: 'user-1', userName: 'Alice' } });
    });
  });

  describe('utility methods', () => {
    describe('getTimeAgo', () => {
      it('should return "Just now" for recent dates', () => {
        const now = new Date();
        expect(component.getTimeAgo(now)).toBe('Just now');
      });

      it('should return minutes ago', () => {
        const fiveMinAgo = new Date(Date.now() - 5 * 60 * 1000);
        expect(component.getTimeAgo(fiveMinAgo)).toBe('5m ago');
      });

      it('should return hours ago', () => {
        const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);
        expect(component.getTimeAgo(twoHoursAgo)).toBe('2h ago');
      });

      it('should return days ago', () => {
        const threeDaysAgo = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000);
        expect(component.getTimeAgo(threeDaysAgo)).toBe('3d ago');
      });
    });

    describe('getStatusColor', () => {
      it('should return green for ACCEPTED', () => {
        expect(component.getStatusColor('ACCEPTED')).toBe('#22c55e');
      });

      it('should return orange for PENDING', () => {
        expect(component.getStatusColor('PENDING')).toBe('#f59e0b');
      });

      it('should return gray for unknown', () => {
        expect(component.getStatusColor('OTHER')).toBe('#6b7280');
      });

      it('should handle undefined', () => {
        expect(component.getStatusColor(undefined)).toBe('#6b7280');
      });
    });

    describe('getInitials', () => {
      it('should return initials for single name', () => {
        expect(component.getInitials('Alice')).toBe('A');
      });

      it('should return initials for full name', () => {
        expect(component.getInitials('Alice Smith')).toBe('AS');
      });

      it('should limit to 2 characters', () => {
        expect(component.getInitials('Alice Bob Charlie')).toBe('AB');
      });
    });
  });

  describe('likeSimulation', () => {
    it('should increment likes for non-owner', () => {
      const sim = { likes: 5, isOwner: false };
      const event = { stopPropagation: vi.fn() } as unknown as Event;
      component.likeSimulation(sim, event);
      expect(sim.likes).toBe(6);
      expect(event.stopPropagation).toHaveBeenCalled();
    });

    it('should not increment likes for owner', () => {
      const sim = { likes: 5, isOwner: true };
      const event = { stopPropagation: vi.fn() } as unknown as Event;
      component.likeSimulation(sim, event);
      expect(sim.likes).toBe(5);
    });
  });

  describe('ngOnDestroy', () => {
    it('should clean up without error', () => {
      expect(() => component.ngOnDestroy()).not.toThrow();
    });
  });
});
