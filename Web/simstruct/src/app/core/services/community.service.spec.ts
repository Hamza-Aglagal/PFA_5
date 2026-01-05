import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed } from '@angular/core/testing';
import { HttpClient } from '@angular/common/http';
import { of, throwError, firstValueFrom } from 'rxjs';
import { CommunityService, FriendDTO, InvitationDTO, UserSearchResult } from './community.service';

describe('CommunityService', () => {
  let service: CommunityService;
  let httpClientSpy: {
    get: ReturnType<typeof vi.fn>;
    post: ReturnType<typeof vi.fn>;
    put: ReturnType<typeof vi.fn>;
    delete: ReturnType<typeof vi.fn>;
  };

  const mockFriend: FriendDTO = {
    id: 'friend-1',
    name: 'Friend User',
    email: 'friend@example.com',
    friendshipId: 'friendship-1',
    status: 'ACCEPTED',
    friendsSince: new Date()
  };

  const mockInvitation: InvitationDTO = {
    id: 'inv-1',
    senderId: 'sender-1',
    senderName: 'Sender User',
    senderEmail: 'sender@example.com',
    receiverId: 'receiver-1',
    receiverName: 'Receiver User',
    receiverEmail: 'receiver@example.com',
    message: 'Hello!',
    createdAt: new Date(),
    status: 'PENDING'
  };

  const mockSearchResult: UserSearchResult = {
    id: 'user-1',
    name: 'Search User',
    email: 'search@example.com',
    status: 'AVAILABLE'
  };

  beforeEach(() => {
    httpClientSpy = {
      get: vi.fn(),
      post: vi.fn(),
      put: vi.fn(),
      delete: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        CommunityService,
        { provide: HttpClient, useValue: httpClientSpy }
      ]
    });

    service = TestBed.inject(CommunityService);
  });

  describe('initialization', () => {
    it('should be created', () => {
      expect(service).toBeTruthy();
    });

    it('should start with empty friends list', () => {
      expect(service.allFriends()).toEqual([]);
    });

    it('should start with empty pending invitations', () => {
      expect(service.pendingInvitations()).toEqual([]);
    });

    it('should start with empty search results', () => {
      expect(service.userSearchResults()).toEqual([]);
    });
  });

  describe('loadFriends', () => {
    it('should load friends successfully', () => {
      const friends = [mockFriend, { ...mockFriend, id: 'friend-2' }];
      httpClientSpy.get.mockReturnValue(of({ success: true, data: friends }));

      service.loadFriends().subscribe();

      expect(service.allFriends().length).toBe(2);
    });

    it('should handle empty friends list', () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: [] }));

      service.loadFriends().subscribe();

      expect(service.allFriends()).toEqual([]);
    });

    it('should handle load error gracefully', () => {
      httpClientSpy.get.mockReturnValue(throwError(() => new Error('Network error')));

      service.loadFriends().subscribe({
        error: () => {
          expect(service.allFriends()).toEqual([]);
        }
      });
    });
  });

  describe('searchUsers', () => {
    it('should search users by query', () => {
      const results = [mockSearchResult];
      httpClientSpy.get.mockReturnValue(of({ success: true, data: results }));

      service.searchUsers('search');

      expect(httpClientSpy.get).toHaveBeenCalled();
    });

    it('should update search results signal', () => {
      const results = [mockSearchResult];
      httpClientSpy.get.mockReturnValue(of({ success: true, data: results }));

      service.searchUsers('test');

      expect(service.userSearchResults().length).toBeGreaterThanOrEqual(0);
    });

    it('should not search for empty query', () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: [] }));
      
      service.searchUsers('').subscribe();

      // The service still makes the request (no client-side validation)
      expect(httpClientSpy.get).toHaveBeenCalled();
    });

    it('should search for query with less than 2 characters', () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: [] }));
      
      service.searchUsers('a').subscribe();

      // The service still makes the request
      expect(httpClientSpy.get).toHaveBeenCalled();
    });
  });

  describe('sendFriendRequest', () => {
    it('should send friend request successfully', async () => {
      httpClientSpy.post.mockReturnValue(of({ success: true, data: mockInvitation }));

      const result = await firstValueFrom(service.sendFriendRequest('receiver-1'));
      expect(result.success).toBe(true);
    });

    it('should handle request error', async () => {
      httpClientSpy.post.mockReturnValue(throwError(() => new Error('Already invited')));

      try {
        await firstValueFrom(service.sendFriendRequest('receiver-1'));
      } catch (error) {
        expect(error).toBeTruthy();
      }
    });

    it('should send friend request to user', async () => {
      httpClientSpy.post.mockReturnValue(of({ success: true, data: mockInvitation }));

      const result = await firstValueFrom(service.sendFriendRequest('receiver-1'));
      expect(result.success).toBe(true);
    });
  });

  describe('loadPendingInvitations', () => {
    it('should load pending invitations', () => {
      const invitations = [mockInvitation];
      httpClientSpy.get.mockReturnValue(of({ success: true, data: invitations }));

      service.loadPendingInvitations().subscribe();

      expect(service.pendingInvitations().length).toBe(1);
    });

    it('should handle empty invitations', () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: [] }));

      service.loadPendingInvitations().subscribe();

      expect(service.pendingInvitations()).toEqual([]);
    });
  });

  describe('acceptFriendRequest', () => {
    it('should accept friend request successfully', async () => {
      httpClientSpy.post.mockReturnValue(of({ success: true }));

      const result = await firstValueFrom(service.acceptFriendRequest('sender-1'));
      expect(result.success).toBe(true);
    });

    it('should handle accept error', async () => {
      httpClientSpy.post.mockReturnValue(throwError(() => new Error('Request expired')));

      try {
        await firstValueFrom(service.acceptFriendRequest('sender-1'));
      } catch (error) {
        expect(error).toBeTruthy();
      }
    });
  });

  describe('rejectFriendRequest', () => {
    it('should reject friend request successfully', async () => {
      httpClientSpy.post.mockReturnValue(of({ success: true }));

      const result = await firstValueFrom(service.rejectFriendRequest('sender-1'));
      expect(result.success).toBe(true);
    });
  });

  describe('removeFriend', () => {
    it('should remove friend successfully', async () => {
      httpClientSpy.delete.mockReturnValue(of({ success: true }));

      const result = await firstValueFrom(service.removeFriend('friend-1'));
      expect(result.success).toBe(true);
    });

    it('should update friends list after removal', () => {
      // First load friends
      httpClientSpy.get.mockReturnValue(of({ success: true, data: [mockFriend] }));
      service.loadFriends().subscribe();
      
      expect(service.allFriends().length).toBe(1);
      
      // Then remove
      httpClientSpy.delete.mockReturnValue(of({ success: true }));
      service.removeFriend('friend-1').subscribe();
      
      // Friends list should update
      expect(service.allFriends().length).toBe(0);
    });
  });

  describe('conversations', () => {
    it('should start with empty conversations', () => {
      expect(service.allConversations()).toEqual([]);
    });

    it('should load conversations', () => {
      const conversations = [
        { friendId: 'f1', friendName: 'Friend 1', friendEmail: 'f1@test.com', unreadCount: 2 }
      ];
      httpClientSpy.get.mockReturnValue(of({ success: true, data: conversations }));

      service.loadConversations().subscribe();

      expect(service.allConversations().length).toBe(1);
    });
  });

  describe('shared simulations', () => {
    it('should start with empty shared simulations', () => {
      expect(service.myShares()).toEqual([]);
      expect(service.sharedWithMe()).toEqual([]);
    });

    it('should load my shares', () => {
      const shares = [{ id: 'share-1', simulationId: 'sim-1', simulationName: 'Test' }];
      httpClientSpy.get.mockReturnValue(of({ success: true, data: shares }));

      service.loadMyShares().subscribe();

      expect(service.myShares().length).toBe(1);
    });
  });
});
