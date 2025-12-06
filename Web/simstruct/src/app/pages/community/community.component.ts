import { Component, signal, inject, computed, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router, ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';

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

interface UserSearchResult {
  id: string; name: string; email: string; avatar?: string; avatarUrl?: string; company?: string;
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

  // Mock data signals
  allSimulations = signal<SharedSimulation[]>([
    { id: '1', name: 'Steel Bridge Analysis', description: 'Truss bridge structural analysis', structureType: 'Truss', material: 'Steel',
      safetyFactor: 2.8, likes: 45, views: 230, isPublic: true, isOwner: false, sharedAt: new Date(), createdAt: new Date(),
      tags: ['bridge', 'steel', 'truss'], authorName: 'John Engineer', owner: { name: 'John Engineer' }, comments: 5 },
    { id: '2', name: 'Concrete Frame Building', description: 'Multi-story frame analysis', structureType: 'Frame', material: 'Concrete',
      safetyFactor: 2.1, likes: 32, views: 180, isPublic: true, isOwner: false, sharedAt: new Date(), createdAt: new Date(),
      tags: ['frame', 'concrete', 'building'], authorName: 'Jane Architect', owner: { name: 'Jane Architect' }, comments: 3 },
    { id: '3', name: 'Wooden Beam Design', description: 'Simple supported beam', structureType: 'Beam', material: 'Wood',
      safetyFactor: 1.9, likes: 18, views: 95, isPublic: true, isOwner: false, sharedAt: new Date(), createdAt: new Date(),
      tags: ['beam', 'wood'], authorName: 'Bob Builder', owner: { name: 'Bob Builder' }, comments: 1 }
  ]);

  mySimulations = signal<SharedSimulation[]>([
    { id: 'my-1', name: 'My Test Beam', description: 'Personal beam analysis', structureType: 'Beam', material: 'Steel',
      safetyFactor: 2.5, likes: 5, views: 20, isPublic: true, isOwner: true, sharedAt: new Date(), createdAt: new Date(),
      tags: ['test'], owner: { name: 'You' }, comments: 0 }
  ]);

  friends = signal<Friend[]>([
    { id: 'f1', friendshipId: 'fs1', name: 'Alice Smith', email: 'alice@example.com', status: 'ACCEPTED', mutualFriends: 3, sharedSimulations: 5, company: 'Engineering Corp', connectedAt: new Date(Date.now() - 86400000 * 30) },
    { id: 'f2', friendshipId: 'fs2', name: 'Bob Johnson', email: 'bob@example.com', status: 'ACCEPTED', mutualFriends: 1, sharedSimulations: 2, company: 'Architects Ltd', connectedAt: new Date(Date.now() - 86400000 * 7) }
  ]);

  pendingRequests = signal<Friend[]>([]);
  receivedInvitations = signal<Invitation[]>([]);
  sentInvitations = signal<Invitation[]>([]);
  searchResults = signal<UserSearchResult[]>([]);
  userSearchLoading = signal(false);

  // Mock communityService for template compatibility
  communityService = {
    allFriends: () => this.friends(),
    pendingInvitations: () => this.receivedInvitations(),
    allInvitationsSent: () => this.sentInvitations(),
    userSearchResults: () => this.searchResults(),
    userSearchLoading: () => this.userSearchLoading(),
    allUserSearchResults: () => this.searchResults(),
    cancelInvitation: (id: string) => { console.log('UI Only: Cancel invitation', id); this.sentInvitations.update(arr => arr.filter(i => i.id !== id)); }
  };

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

  mySharedSimulations = computed(() => this.mySimulations().filter(s => s.isPublic || (s.sharedWith && s.sharedWith.length > 0)));

  ngOnInit(): void {
    this.route.queryParams.subscribe(params => { if (params['tab']) this.activeTab.set(params['tab'] as TabType); });
  }
  ngOnDestroy(): void {}

  setTab(tab: TabType): void { this.activeTab.set(tab); }
  updateSearch(event: Event): void { this.searchQuery.set((event.target as HTMLInputElement).value); }
  likeSimulation(sim: SharedSimulation, event: Event): void { event.stopPropagation(); if (!sim.isOwner) sim.likes++; console.log('Liked:', sim.name); }
  viewSimulation(sim: SharedSimulation): void { this.router.navigate(['/community/simulation', sim.id]); }

  openShareModal(sim: SharedSimulation, event: Event): void {
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
      const names = ids.map(id => this.friends().find(f => f.id === id)?.name).filter(Boolean).join(', ');
      console.log('UI Only: Shared with', names);
      this.closeShareModal();
    }
  }

  openInviteModal(sim?: SharedSimulation): void {
    if (sim) this.selectedSimulation.set(sim);
    this.showInviteModal.set(true); this.inviteMode.set('search'); this.inviteEmail.set('');
    this.inviteMessage.set(''); this.userSearchQuery.set(''); this.suggestedUser.set(null); this.inviteError.set('');
  }
  closeInviteModal(): void { this.showInviteModal.set(false); this.suggestedUser.set(null); this.inviteError.set(''); if (!this.showShareModal()) this.selectedSimulation.set(null); }
  setInviteMode(mode: InviteMode): void { this.inviteMode.set(mode); this.inviteError.set(''); this.suggestedUser.set(null); }
  onUserSearchInput(event: Event): void { this.userSearchQuery.set((event.target as HTMLInputElement).value); }
  sendFriendRequestTo(user: UserSearchResult): void { this.sendingRequest.set(true); console.log('UI Only: Friend request to', user.name); this.sendingRequest.set(false); this.closeInviteModal(); }
  sendFriendRequestToSuggested(): void { const u = this.suggestedUser(); if (u) this.sendFriendRequestTo(u); }
  sendInvite(): void { if (this.inviteEmail()) { console.log('UI Only: Invite sent to', this.inviteEmail()); this.closeInviteModal(); } }
  acceptInvitation(inv: Invitation): void { console.log('UI Only: Accepted', inv.senderName); this.receivedInvitations.update(arr => arr.filter(i => i.id !== inv.id)); }
  declineInvitation(inv: Invitation): void { console.log('UI Only: Declined', inv.senderName); this.receivedInvitations.update(arr => arr.filter(i => i.id !== inv.id)); }
  acceptFriendRequest(friend: Friend): void { console.log('UI Only: Accepted friend', friend.name); this.pendingRequests.update(arr => arr.filter(f => f.id !== friend.id)); }
  rejectFriendRequest(friend: Friend): void { console.log('UI Only: Rejected friend', friend.name); this.pendingRequests.update(arr => arr.filter(f => f.id !== friend.id)); }

  async removeFriend(friend: Friend): Promise<void> {
    const confirmed = await this.modalService.confirm({ title: 'Remove Friend', message: 'Are you sure you want to remove ' + friend.name + '?', confirmText: 'Remove', cancelText: 'Cancel', type: 'danger' });
    if (confirmed) { console.log('UI Only: Removed', friend.name); this.friends.update(arr => arr.filter(f => f.id !== friend.id)); }
  }

  getTimeAgo(date: Date): string { const diff = Date.now() - new Date(date).getTime(); const m = Math.floor(diff/60000); const h = Math.floor(diff/3600000); const d = Math.floor(diff/86400000); if (m < 1) return 'Just now'; if (m < 60) return m + 'm ago'; if (h < 24) return h + 'h ago'; if (d < 7) return d + 'd ago'; return new Date(date).toLocaleDateString(); }
  getStatusColor(status: string): string { return status === 'ACCEPTED' ? '#22c55e' : status === 'PENDING' ? '#f59e0b' : '#6b7280'; }
  getInitials(name: string): string { return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2); }
  openChat(friend: Friend): void { this.router.navigate(['/chat'], { queryParams: { userId: friend.id, userName: friend.name } }); }
}
