import { Component, signal, inject, computed, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';
import { CommunityService, UserSearchResult } from '../../core/services/community.service';
import { SimulationService } from '../../core/services/simulation.service';
import { Subject, debounceTime, distinctUntilChanged, takeUntil } from 'rxjs';

type TabType = 'explore' | 'friends' | 'invitations' | 'my-shares';
type InviteMode = 'invite' | 'search';

interface SharedSimulation {
  id: string; name: string; description: string; structureType: string; material: string;
  safetyFactor: number; likes: number; views: number; isPublic: boolean; isOwner: boolean;
  sharedAt: Date; createdAt: Date; tags: string[]; authorName?: string;
  owner: { name: string }; comments: number;
  dimensions?: { length: number; width: number; height: number }; load?: number; sharedWith?: string[];
}

interface Friend {
  id: string; friendshipId: string; name: string; email: string; avatar?: string; avatarUrl?: string;
  status: string; mutualFriends?: number; sharedSimulations?: number; lastActive?: Date; company?: string;
  connectedAt?: Date;
}

interface Invitation {
  id: string; senderId?: string; senderName: string; senderEmail: string; recipientEmail?: string;
  message?: string; createdAt: Date; isExpired: boolean; status: string;
}

@Component({
  selector: 'app-community',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './community.component.html',
  styleUrl: './community.component.scss'
})
export class CommunityComponent implements OnInit, OnDestroy {
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private modalService = inject(ModalService);
  communityService = inject(CommunityService);
  private simulationService = inject(SimulationService);
  private destroy$ = new Subject<void>();
  private searchSubject = new Subject<string>();

  activeTab = signal<TabType>('explore');
  searchQuery = signal('');
  showInviteModal = signal(false);
  showShareModal = signal(false);
  inviteEmail = signal('');
  inviteMessage = signal('');
  selectedSimulation = signal<SharedSimulation | null>(null);
  selectedFriends = signal<Set<string>>(new Set());
  shareMessage = signal('');
  inviteMode = signal<InviteMode>('search');
  userSearchQuery = signal('');
  suggestedUser = signal<UserSearchResult | null>(null);
  inviteError = signal('');
  sendingRequest = signal(false);
  structureFilter = signal('all');
  materialFilter = signal('all');
  sortBy = signal<'recent' | 'popular' | 'views'>('recent');
  isLoading = signal(false);

  // Simulations data from API
  allSimulations = signal<SharedSimulation[]>([]);
  mySimulations = signal<SharedSimulation[]>([]);

  // Friends data from service
  friends = computed<Friend[]>(() => 
    this.communityService.allFriends().map(f => ({
      id: f.id, friendshipId: f.friendshipId, name: f.name, email: f.email,
      status: f.status || 'ACCEPTED', connectedAt: f.friendsSince
    }))
  );

  pendingRequests = signal<Friend[]>([]);
  
  receivedInvitations = computed<Invitation[]>(() =>
    this.communityService.pendingInvitations().map(i => ({
      id: i.id, senderId: i.senderId, senderName: i.senderName || 'Unknown',
      senderEmail: i.senderEmail || '', createdAt: new Date(i.createdAt), isExpired: false, status: i.status
    }))
  );

  sentInvitations = computed<Invitation[]>(() =>
    this.communityService.allInvitationsSent().map(i => ({
      id: i.id, senderId: i.receiverId, senderName: i.receiverName || 'Unknown',
      senderEmail: i.receiverEmail || '', recipientEmail: i.receiverEmail,
      createdAt: new Date(i.createdAt), isExpired: false, status: i.status
    }))
  );

  searchResults = computed(() => this.communityService.userSearchResults());
  userSearchLoading = computed(() => this.communityService.userSearchLoading());

  structureTypes = ['all', 'beam', 'frame', 'truss', 'column'];
  materials = ['all', 'steel', 'concrete', 'aluminum', 'wood'];

  filteredSimulations = computed(() => {
    let sims = [...this.mySimulations(), ...this.allSimulations()];
    const query = this.searchQuery().toLowerCase();
    if (query) sims = sims.filter(s => s.name.toLowerCase().includes(query) || s.description.toLowerCase().includes(query) || s.tags.some(t => t.toLowerCase().includes(query)));
    if (this.structureFilter() !== 'all') sims = sims.filter(s => s.structureType.toLowerCase() === this.structureFilter());
    if (this.materialFilter() !== 'all') sims = sims.filter(s => s.material.toLowerCase() === this.materialFilter());
    switch (this.sortBy()) {
      case 'popular': return [...sims].sort((a, b) => b.likes - a.likes);
      case 'views': return [...sims].sort((a, b) => b.views - a.views);
      default: return [...sims].sort((a, b) => b.sharedAt.getTime() - a.sharedAt.getTime());
    }
  });

  mySharedSimulations = computed(() => {
    const myShares = this.communityService.myShares();
    return myShares.map(s => ({
      id: s.id, simulationId: s.simulationId, name: s.simulationName,
      sharedWith: s.sharedWithName, permission: s.permission, sharedAt: new Date(s.sharedAt),
      structureType: s.structureType || 'Beam', description: s.description || s.simulationDescription || '',
      likes: s.likes || 0, comments: s.comments || 0, views: s.views || 0
    }));
  });

  ngOnInit(): void {
    this.loadData();
    this.searchSubject.pipe(
      debounceTime(300), distinctUntilChanged(), takeUntil(this.destroy$)
    ).subscribe(query => {
      if (query.length >= 2) this.communityService.searchUsers(query).subscribe();
      else this.communityService.clearSearchResults();
    });
    this.route.queryParams.subscribe(params => { if (params['tab']) this.activeTab.set(params['tab'] as TabType); });
  }
  
  ngOnDestroy(): void { this.destroy$.next(); this.destroy$.complete(); }

  private loadData(): void {
    this.isLoading.set(true);
    this.communityService.loadFriends().subscribe();
    this.communityService.loadPendingInvitations().subscribe();
    this.communityService.loadSentInvitations().subscribe();
    this.communityService.loadMyShares().subscribe();
    this.communityService.loadSharedWithMe().subscribe();
    this.loadSimulations();
    this.isLoading.set(false);
  }

  private loadSimulations(): void {
    this.simulationService.getUserSimulations().subscribe({
      next: (simulations: any[]) => {
        if (simulations) {
          this.mySimulations.set(simulations.map((s: any) => ({
            id: s.id, name: s.name, description: s.description || '', structureType: s.supportType || 'Beam',
            material: s.materialType || 'Steel', safetyFactor: s.results?.safetyFactor || 1.5,
            likes: s.likesCount || 0, views: 0, isPublic: s.isPublic || false, isOwner: true,
            sharedAt: new Date(s.createdAt), createdAt: new Date(s.createdAt),
            tags: [s.materialType?.toLowerCase(), s.supportType?.toLowerCase()].filter(Boolean),
            owner: { name: 'You' }, comments: 0, dimensions: { length: s.beamLength, width: s.beamWidth, height: s.beamHeight },
            load: s.loadMagnitude
          })));
        }
      }
    });
  }

  setTab(tab: TabType): void { this.activeTab.set(tab); }
  updateSearch(event: Event): void { this.searchQuery.set((event.target as HTMLInputElement).value); }
  likeSimulation(sim: any, event: Event): void { event.stopPropagation(); if (!sim.isOwner) sim.likes++; }
  viewSimulation(sim: any): void { this.router.navigate(['/results', sim.simulationId || sim.id]); }

  openShareModal(sim: any, event: Event): void {
    event.stopPropagation(); this.selectedSimulation.set(sim); this.showShareModal.set(true);
    this.selectedFriends.set(new Set()); this.shareMessage.set('');
  }
  closeShareModal(): void { this.showShareModal.set(false); this.selectedSimulation.set(null); }
  toggleFriendSelection(friendId: string): void { this.selectedFriends.update(set => { const n = new Set(set); n.has(friendId) ? n.delete(friendId) : n.add(friendId); return n; }); }
  isFriendSelected(friendId: string): boolean { return this.selectedFriends().has(friendId); }

  shareWithFriends(): void {
    const sim = this.selectedSimulation();
    const ids = Array.from(this.selectedFriends());
    if (sim && ids.length > 0) {
      ids.forEach(friendId => {
        this.communityService.shareSimulation(sim.id, friendId, 'VIEW').subscribe({
          next: () => console.log('Shared with friend:', friendId),
          error: (err) => console.error('Share error:', err)
        });
      });
      this.closeShareModal();
    }
  }

  openInviteModal(sim?: SharedSimulation): void {
    if (sim) this.selectedSimulation.set(sim);
    this.showInviteModal.set(true); this.inviteMode.set('search'); this.inviteEmail.set('');
    this.inviteMessage.set(''); this.userSearchQuery.set(''); this.suggestedUser.set(null); this.inviteError.set('');
    this.communityService.clearSearchResults();
  }
  closeInviteModal(): void { this.showInviteModal.set(false); this.suggestedUser.set(null); this.inviteError.set(''); if (!this.showShareModal()) this.selectedSimulation.set(null); }
  setInviteMode(mode: InviteMode): void { this.inviteMode.set(mode); this.inviteError.set(''); this.suggestedUser.set(null); }
  
  onUserSearchInput(event: Event): void { 
    const query = (event.target as HTMLInputElement).value;
    this.userSearchQuery.set(query);
    this.searchSubject.next(query);
  }
  
  sendFriendRequestTo(user: UserSearchResult): void { 
    this.sendingRequest.set(true);
    this.communityService.sendFriendRequest(user.id).subscribe({
      next: () => { this.sendingRequest.set(false); this.closeInviteModal(); },
      error: (err) => { this.sendingRequest.set(false); this.inviteError.set(err.error?.message || 'Failed to send request'); }
    });
  }
  sendFriendRequestToSuggested(): void { const u = this.suggestedUser(); if (u) this.sendFriendRequestTo(u); }
  sendInvite(): void { if (this.inviteEmail()) { console.log('Email invite to:', this.inviteEmail()); this.closeInviteModal(); } }
  
  acceptInvitation(inv: Invitation): void { 
    if (inv.senderId) this.communityService.acceptFriendRequest(inv.senderId).subscribe({ error: (err) => console.error('Accept error:', err) });
  }
  declineInvitation(inv: Invitation): void { 
    if (inv.senderId) this.communityService.rejectFriendRequest(inv.senderId).subscribe({ error: (err) => console.error('Decline error:', err) });
  }
  acceptFriendRequest(friend: any): void { this.communityService.acceptFriendRequest(friend.id).subscribe({ error: (err) => console.error('Accept error:', err) }); }
  rejectFriendRequest(friend: any): void { this.communityService.rejectFriendRequest(friend.id).subscribe({ error: (err) => console.error('Reject error:', err) }); }

  async removeFriend(friend: any): Promise<void> {
    const confirmed = await this.modalService.confirm({ title: 'Remove Friend', message: 'Are you sure you want to remove ' + friend.name + '?', confirmText: 'Remove', cancelText: 'Cancel', type: 'danger' });
    if (confirmed) { this.communityService.removeFriend(friend.id).subscribe({ error: (err) => console.error('Remove error:', err) }); }
  }

  getTimeAgo(date: Date): string { const diff = Date.now() - new Date(date).getTime(); const m = Math.floor(diff/60000); const h = Math.floor(diff/3600000); const d = Math.floor(diff/86400000); if (m < 1) return 'Just now'; if (m < 60) return m + 'm ago'; if (h < 24) return h + 'h ago'; if (d < 7) return d + 'd ago'; return new Date(date).toLocaleDateString(); }
  getStatusColor(status: string | undefined): string { return status === 'ACCEPTED' ? '#22c55e' : status === 'PENDING' ? '#f59e0b' : '#6b7280'; }
  getInitials(name: string): string { return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2); }
  openChat(friend: any): void { this.router.navigate(['/chat'], { queryParams: { userId: friend.id, userName: friend.name } }); }
}
