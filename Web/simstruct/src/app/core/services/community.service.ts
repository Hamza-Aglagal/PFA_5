import { Injectable, inject, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, catchError, of, tap } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface FriendDTO {
  id: string;
  name: string;
  email: string;
  friendshipId: string;
  friendsSince?: Date;
  status: string;
  avatarUrl?: string;
  company?: string;
  connectedAt?: Date;
}

export interface InvitationDTO {
  id: string;
  senderId?: string;
  receiverId?: string;
  senderName?: string;
  senderEmail?: string;
  receiverName?: string;
  receiverEmail?: string;
  recipientEmail?: string;
  message?: string;
  createdAt: Date;
  status: string;
  isExpired?: boolean;
}

export interface SharedSimulationDTO {
  id: string;
  simulationId: string;
  simulationName: string;
  simulationDescription?: string;
  ownerName: string;
  sharedWithName: string;
  sharedWithId: string;
  ownerId: string;
  permission: string;
  sharedAt: Date;
  sharedByName?: string;
  name?: string;
  sharedWith?: string;
  structureType?: string;
  description?: string;
  likes?: number;
  comments?: number;
  views?: number;
  material?: string;
  safetyFactor?: number;
  isPublic?: boolean;
  isOwner?: boolean;
  createdAt?: Date;
  tags?: string[];
  dimensions?: { length?: number; width?: number; height?: number };
  load?: number;
}

export interface ChatMessageDTO {
  id: string;
  senderId: string;
  senderName: string;
  receiverId: string;
  content: string;
  sentAt: Date;
  isRead: boolean;
}

export interface ConversationDTO {
  friendId: string;
  friendName: string;
  friendEmail: string;
  lastMessage?: string;
  lastMessageTime?: Date;
  unreadCount: number;
}

export interface UserSearchResult {
  id: string;
  name: string;
  email: string;
  status?: string;
  avatarUrl?: string;
  company?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
}

@Injectable({
  providedIn: 'root'
})
export class CommunityService {
  private http = inject(HttpClient);
  private baseUrl = environment.apiUrl;
  
  // Signals for reactive state
  private _friends = signal<FriendDTO[]>([]);
  private _pendingInvitations = signal<InvitationDTO[]>([]);
  private _sentInvitations = signal<InvitationDTO[]>([]);
  private _myShares = signal<SharedSimulationDTO[]>([]);
  private _sharedWithMe = signal<SharedSimulationDTO[]>([]);
  private _conversations = signal<ConversationDTO[]>([]);
  private _searchResults = signal<UserSearchResult[]>([]);
  private _searchLoading = signal(false);
  
  // Public computed signals
  allFriends = computed(() => this._friends());
  pendingInvitations = computed(() => this._pendingInvitations());
  allInvitationsSent = computed(() => this._sentInvitations());
  myShares = computed(() => this._myShares());
  sharedWithMe = computed(() => this._sharedWithMe());
  allConversations = computed(() => this._conversations());
  userSearchResults = computed(() => this._searchResults());
  userSearchLoading = computed(() => this._searchLoading());
  allUserSearchResults = computed(() => this._searchResults());
  
  // ========== FRIENDSHIP APIs ==========
  
  /**
   * Load all friends
   */
  loadFriends(): Observable<ApiResponse<FriendDTO[]>> {
    return this.http.get<ApiResponse<FriendDTO[]>>(`${this.baseUrl}/friends`).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._friends.set(response.data);
        }
      }),
      catchError(error => {
        console.error('Error loading friends:', error);
        return of({ success: false, message: error.message, data: [] });
      })
    );
  }
  
  /**
   * Search users by query
   */
  searchUsers(query: string): Observable<ApiResponse<UserSearchResult[]>> {
    this._searchLoading.set(true);
    return this.http.get<ApiResponse<UserSearchResult[]>>(`${this.baseUrl}/friends/search`, { params: { query } }).pipe(
      tap(response => {
        this._searchLoading.set(false);
        if (response.success && response.data) {
          this._searchResults.set(response.data);
        }
      }),
      catchError(error => {
        this._searchLoading.set(false);
        console.error('Error searching users:', error);
        return of({ success: false, message: error.message, data: [] });
      })
    );
  }
  
  /**
   * Load pending invitations (received)
   */
  loadPendingInvitations(): Observable<ApiResponse<InvitationDTO[]>> {
    return this.http.get<ApiResponse<InvitationDTO[]>>(`${this.baseUrl}/friends/invitations`).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._pendingInvitations.set(response.data);
        }
      }),
      catchError(error => {
        console.error('Error loading invitations:', error);
        return of({ success: false, message: error.message, data: [] });
      })
    );
  }
  
  /**
   * Load sent invitations
   */
  loadSentInvitations(): Observable<ApiResponse<InvitationDTO[]>> {
    return this.http.get<ApiResponse<InvitationDTO[]>>(`${this.baseUrl}/friends/sent`).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._sentInvitations.set(response.data);
        }
      }),
      catchError(error => {
        console.error('Error loading sent invitations:', error);
        return of({ success: false, message: error.message, data: [] });
      })
    );
  }
  
  /**
   * Send friend request
   */
  sendFriendRequest(receiverId: string): Observable<ApiResponse<InvitationDTO>> {
    return this.http.post<ApiResponse<InvitationDTO>>(`${this.baseUrl}/friends/request/${receiverId}`, {}).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._sentInvitations.update(arr => [...arr, response.data]);
          // Remove from search results
          this._searchResults.update(arr => arr.filter(u => u.id !== receiverId));
        }
      }),
      catchError(error => {
        console.error('Error sending friend request:', error);
        throw error;
      })
    );
  }
  
  /**
   * Accept friend request
   */
  acceptFriendRequest(senderId: string): Observable<ApiResponse<FriendDTO>> {
    return this.http.post<ApiResponse<FriendDTO>>(`${this.baseUrl}/friends/accept/${senderId}`, {}).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._friends.update(arr => [...arr, response.data]);
          this._pendingInvitations.update(arr => arr.filter(i => i.senderId !== senderId));
        }
      }),
      catchError(error => {
        console.error('Error accepting friend request:', error);
        throw error;
      })
    );
  }
  
  /**
   * Reject friend request
   */
  rejectFriendRequest(senderId: string): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(`${this.baseUrl}/friends/reject/${senderId}`, {}).pipe(
      tap(response => {
        if (response.success) {
          this._pendingInvitations.update(arr => arr.filter(i => i.senderId !== senderId));
        }
      }),
      catchError(error => {
        console.error('Error rejecting friend request:', error);
        throw error;
      })
    );
  }
  
  /**
   * Cancel sent friend request
   */
  cancelInvitation(receiverId: string): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(`${this.baseUrl}/friends/cancel/${receiverId}`).pipe(
      tap(response => {
        if (response.success) {
          this._sentInvitations.update(arr => arr.filter(i => i.receiverId !== receiverId));
        }
      }),
      catchError(error => {
        console.error('Error canceling invitation:', error);
        throw error;
      })
    );
  }
  
  /**
   * Remove friend
   */
  removeFriend(friendId: string): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(`${this.baseUrl}/friends/${friendId}`).pipe(
      tap(response => {
        if (response.success) {
          this._friends.update(arr => arr.filter(f => f.id !== friendId));
        }
      }),
      catchError(error => {
        console.error('Error removing friend:', error);
        throw error;
      })
    );
  }
  
  // ========== SHARING APIs ==========
  
  /**
   * Load my shares (simulations I shared)
   */
  loadMyShares(): Observable<ApiResponse<SharedSimulationDTO[]>> {
    return this.http.get<ApiResponse<SharedSimulationDTO[]>>(`${this.baseUrl}/shares/my-shares`).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._myShares.set(response.data);
        }
      }),
      catchError(error => {
        console.error('Error loading my shares:', error);
        return of({ success: false, message: error.message, data: [] });
      })
    );
  }
  
  /**
   * Load simulations shared with me
   */
  loadSharedWithMe(): Observable<ApiResponse<SharedSimulationDTO[]>> {
    return this.http.get<ApiResponse<SharedSimulationDTO[]>>(`${this.baseUrl}/shares/shared-with-me`).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._sharedWithMe.set(response.data);
        }
      }),
      catchError(error => {
        console.error('Error loading shared with me:', error);
        return of({ success: false, message: error.message, data: [] });
      })
    );
  }
  
  /**
   * Get shares with a specific friend
   */
  getSharesWithFriend(friendId: string): Observable<ApiResponse<SharedSimulationDTO[]>> {
    return this.http.get<ApiResponse<SharedSimulationDTO[]>>(`${this.baseUrl}/shares/with-friend/${friendId}`);
  }
  
  /**
   * Share a simulation with a friend
   */
  shareSimulation(simulationId: string, friendId: string, permission: string = 'VIEW'): Observable<ApiResponse<SharedSimulationDTO>> {
    return this.http.post<ApiResponse<SharedSimulationDTO>>(`${this.baseUrl}/shares`, null, {
      params: { simulationId, friendId, permission }
    }).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._myShares.update(arr => [...arr, response.data]);
        }
      }),
      catchError(error => {
        console.error('Error sharing simulation:', error);
        throw error;
      })
    );
  }
  
  /**
   * Unshare a simulation
   */
  unshareSimulation(shareId: string): Observable<ApiResponse<void>> {
    return this.http.delete<ApiResponse<void>>(`${this.baseUrl}/shares/${shareId}`).pipe(
      tap(response => {
        if (response.success) {
          this._myShares.update(arr => arr.filter(s => s.id !== shareId));
        }
      }),
      catchError(error => {
        console.error('Error unsharing simulation:', error);
        throw error;
      })
    );
  }
  
  // ========== CHAT APIs ==========
  
  /**
   * Load all conversations
   */
  loadConversations(): Observable<ApiResponse<ConversationDTO[]>> {
    return this.http.get<ApiResponse<ConversationDTO[]>>(`${this.baseUrl}/chat/conversations`).pipe(
      tap(response => {
        if (response.success && response.data) {
          this._conversations.set(response.data);
        }
      }),
      catchError(error => {
        console.error('Error loading conversations:', error);
        return of({ success: false, message: error.message, data: [] });
      })
    );
  }
  
  /**
   * Get conversation with a friend
   */
  getConversation(friendId: string, limit: number = 50): Observable<ApiResponse<ChatMessageDTO[]>> {
    return this.http.get<ApiResponse<ChatMessageDTO[]>>(`${this.baseUrl}/chat/conversation/${friendId}`, {
      params: { limit: limit.toString() }
    });
  }
  
  /**
   * Send a message
   */
  sendMessage(receiverId: string, content: string): Observable<ApiResponse<ChatMessageDTO>> {
    return this.http.post<ApiResponse<ChatMessageDTO>>(`${this.baseUrl}/chat/send`, {
      receiverId,
      content
    });
  }
  
  /**
   * Mark messages as read
   */
  markAsRead(senderId: string): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(`${this.baseUrl}/chat/read/${senderId}`, {}).pipe(
      tap(response => {
        if (response.success) {
          this._conversations.update(arr => 
            arr.map(c => c.friendId === senderId ? { ...c, unreadCount: 0 } : c)
          );
        }
      })
    );
  }
  
  /**
   * Get unread message count
   */
  getUnreadCount(): Observable<ApiResponse<number>> {
    return this.http.get<ApiResponse<number>>(`${this.baseUrl}/chat/unread`);
  }
  
  // ========== UTILITY ==========
  
  /**
   * Clear search results
   */
  clearSearchResults(): void {
    this._searchResults.set([]);
  }
  
  /**
   * Refresh all data
   */
  refreshAll(): void {
    this.loadFriends().subscribe();
    this.loadPendingInvitations().subscribe();
    this.loadSentInvitations().subscribe();
    this.loadMyShares().subscribe();
    this.loadSharedWithMe().subscribe();
    this.loadConversations().subscribe();
  }
}
