import { Component, signal, inject, computed, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';

interface SharedSimulation {
  id: string; name: string; description: string; structureType: string; material: string;
  safetyFactor: number; likes: number; views: number; isPublic: boolean; isOwner: boolean;
  sharedAt: Date; createdAt: Date; tags: string[]; authorName?: string;
  owner: { name: string; avatar?: string }; comments?: number;
  dimensions?: { length: number; width: number; height: number }; load?: number;
  sharedWith?: string[];
}

interface Friend {
  id: string; friendshipId: string; name: string; email: string; avatar?: string; avatarUrl?: string; status: string;
}

interface ChatMessage {
  id: string; senderId: string; senderName: string; content: string; sentAt: Date; timestamp?: Date;
}

@Component({
  selector: 'app-simulation-detail',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './simulation-detail.component.html',
  styleUrl: './simulation-detail.component.scss'
})
export class SimulationDetailComponent implements OnInit, OnDestroy, AfterViewChecked {
  @ViewChild('chatMessagesContainer') chatMessagesRef!: ElementRef;
  
  private route = inject(ActivatedRoute);
  private router = inject(Router);

  simulation = signal<SharedSimulation | null>(null);
  messages = signal<ChatMessage[]>([]);
  newMessage = signal('');
  showShareModal = signal(false);
  showInviteModal = signal(false);
  selectedFriends = signal<Set<string>>(new Set());
  inviteEmail = signal('');
  shareMessage = signal('');
  searchFriendQuery = signal('');
  private shouldScrollToBottom = false;

  friends = signal<Friend[]>([
    { id: 'f1', friendshipId: 'fs1', name: 'Alice Smith', email: 'alice@example.com', status: 'ACCEPTED', avatarUrl: '' },
    { id: 'f2', friendshipId: 'fs2', name: 'Bob Johnson', email: 'bob@example.com', status: 'ACCEPTED', avatarUrl: '' }
  ]);

  filteredFriends = computed(() => {
    const query = this.searchFriendQuery().toLowerCase();
    if (!query) return this.friends();
    return this.friends().filter(f => f.name.toLowerCase().includes(query) || f.email.toLowerCase().includes(query));
  });

  ngOnInit(): void {
    const simId = this.route.snapshot.paramMap.get('id');
    if (simId) {
      this.simulation.set({
        id: simId, name: 'Steel Bridge Analysis', description: 'Detailed truss bridge structural analysis.',
        structureType: 'Truss', material: 'Steel', safetyFactor: 2.8, likes: 45, views: 231, isPublic: true, isOwner: false,
        sharedAt: new Date(), createdAt: new Date(Date.now() - 7*24*60*60*1000), tags: ['bridge', 'steel', 'truss'],
        authorName: 'John Engineer', owner: { name: 'John Engineer' }, comments: 5,
        dimensions: { length: 10, width: 0.5, height: 0.8 }, load: 50, sharedWith: ['f1']
      });
      this.messages.set([
        { id: '1', senderId: 'u1', senderName: 'John Engineer', content: 'Great analysis!', sentAt: new Date(Date.now() - 3600000), timestamp: new Date(Date.now() - 3600000) },
        { id: '2', senderId: 'u2', senderName: 'Alice Smith', content: 'Check deflection at node 5.', sentAt: new Date(Date.now() - 1800000), timestamp: new Date(Date.now() - 1800000) }
      ]);
    }
  }

  ngAfterViewChecked(): void { if (this.shouldScrollToBottom) { this.scrollToBottom(); this.shouldScrollToBottom = false; } }
  ngOnDestroy(): void {}
  scrollToBottom(): void { if (this.chatMessagesRef) { this.chatMessagesRef.nativeElement.scrollTop = this.chatMessagesRef.nativeElement.scrollHeight; } }

  sendMessage(): void {
    const content = this.newMessage().trim();
    if (content && this.simulation()) {
      const now = new Date();
      this.messages.update(msgs => [...msgs, { id: 'msg-' + Date.now(), senderId: 'me', senderName: 'You', content, sentAt: now, timestamp: now }]);
      this.newMessage.set('');
      this.shouldScrollToBottom = true;
    }
  }

  handleKeyPress(event: KeyboardEvent): void { if (event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); this.sendMessage(); } }

  likeSimulation(): void {
    const sim = this.simulation();
    if (sim && !sim.isOwner) { this.simulation.set({ ...sim, likes: sim.likes + 1 }); console.log('UI Only: Liked'); }
  }

  openShareModal(): void { this.showShareModal.set(true); this.selectedFriends.set(new Set()); this.shareMessage.set(''); }
  closeShareModal(): void { this.showShareModal.set(false); }
  openInviteModal(): void { this.showInviteModal.set(true); this.inviteEmail.set(''); }
  closeInviteModal(): void { this.showInviteModal.set(false); }
  toggleFriendSelection(friendId: string): void { this.selectedFriends.update(set => { const n = new Set(set); n.has(friendId) ? n.delete(friendId) : n.add(friendId); return n; }); }
  isFriendSelected(friendId: string): boolean { return this.selectedFriends().has(friendId); }
  
  shareWithFriends(): void {
    const ids = Array.from(this.selectedFriends());
    if (ids.length > 0) { console.log('UI Only: Shared'); this.closeShareModal(); }
  }

  sendInvite(): void { if (this.inviteEmail()) { console.log('UI Only: Invite sent'); this.closeInviteModal(); } }

  goBack(): void { this.router.navigate(['/community']); }
  getInitials(name: string): string { return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2); }
  getTimeAgo(date: Date | undefined): string { if (!date) return ''; const diff = Date.now() - new Date(date).getTime(); const m = Math.floor(diff/60000); if (m < 1) return 'Just now'; if (m < 60) return m + 'm ago'; return Math.floor(diff/3600000) + 'h ago'; }
  
  // Missing methods for template
  isOwnMessage(msg: ChatMessage): boolean { return msg.senderId === 'me' || msg.senderName === 'You'; }
  getSenderName(msg: ChatMessage): string { return msg.senderName; }
  getStatusColor(status: string): string { return status === 'ACCEPTED' ? '#22c55e' : status === 'PENDING' ? '#f59e0b' : '#6b7280'; }
}
