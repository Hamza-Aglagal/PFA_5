import { Component, signal, inject, computed, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';

// Mock types for UI only
interface ChatMessageItem {
  id: string;
  senderId: string;
  senderName: string;
  content: string;
  sentAt: Date;
  isRead?: boolean;
}

interface Conversation {
  id: string;
  otherParticipant: {
    id: string;
    name: string;
    avatar?: string;
  };
  lastMessage?: {
    content: string;
    sentAt: Date;
  };
  unreadCount: number;
}

interface SharedSimulation {
  id: string;
  name: string;
  description: string;
  structureType: string;
  material: string;
  safetyFactor: number;
  likes: number;
  views: number;
  isPublic: boolean;
  isOwner: boolean;
  sharedAt: Date;
  createdAt: Date;
  tags: string[];
  dimensions?: { length: number; width: number; height: number };
  load?: number;
  sharedWith?: string[];
}

interface SimulationResponse {
  id: string;
  name: string;
  description: string;
  beamLength: number;
  beamWidth: number;
  beamHeight: number;
  materialType: string;
  elasticModulus: number;
  loadType: string;
  loadMagnitude: number;
  supportType: string;
  isPublic: boolean;
  isFavorite: boolean;
  likesCount: number;
  createdAt: string;
  updatedAt: string;
  results?: {
    maxDeflection: number;
    maxBendingMoment: number;
    maxShearForce: number;
    maxStress: number;
    safetyFactor: number;
  };
}

interface SharedSimulationResponse {
  id: string;
  simulationId: string;
  simulationName: string;
  sharedById: string;
  sharedByName: string;
  permission: string;
  message?: string;
  sharedAt: Date;
}

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './chat.component.html',
  styleUrl: './chat.component.scss'
})
export class ChatComponent implements OnInit, OnDestroy, AfterViewChecked {
  @ViewChild('messagesContainer') messagesContainer!: ElementRef;
  
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  
  messageInput = signal('');
  private shouldScrollToBottom = true;
  
  friendId = signal<string | null>(null);
  friendName = signal<string>('Demo Friend');
  isLoading = signal(false);
  
  activePanel = signal<'chat' | 'simulations' | 'details'>('chat');
  simulationTab = signal<'sent' | 'received'>('sent');
  
  selectedSimulation = signal<SimulationResponse | null>(null);
  
  showShareModal = signal(false);
  selectedShareSimulation = signal<SharedSimulation | null>(null);
  shareMessage = signal('');
  isSharingSimulation = signal(false);

  activeConversation = signal<Conversation | null>({
    id: 'demo-conv-1',
    otherParticipant: { id: 'user-2', name: 'Demo Friend' },
    lastMessage: { content: 'Hello!', sentAt: new Date() },
    unreadCount: 0
  });
  
  messages = signal<ChatMessageItem[]>([
    { id: '1', senderId: 'user-2', senderName: 'Demo Friend', content: 'Hello! Welcome to the chat.', sentAt: new Date(Date.now() - 60000) },
    { id: '2', senderId: 'user-1', senderName: 'You', content: 'Hi! Thanks for the welcome.', sentAt: new Date(Date.now() - 30000) },
    { id: '3', senderId: 'user-2', senderName: 'Demo Friend', content: 'Feel free to share any simulations!', sentAt: new Date() }
  ]);
  
  sharedWithPartner = signal<SharedSimulation[]>([
    {
      id: 'sim-1', name: 'Steel Beam Analysis', description: 'Sample beam simulation',
      structureType: 'Beam', material: 'Steel', safetyFactor: 2.5, likes: 10, views: 50,
      isPublic: true, isOwner: true, sharedAt: new Date(), createdAt: new Date(), tags: ['beam', 'steel']
    }
  ]);
  
  sharedByPartner = signal<SharedSimulationResponse[]>([]);
  
  mySimulations = signal<SharedSimulation[]>([
    {
      id: 'sim-2', name: 'Frame Structure Test', description: 'Portal frame analysis',
      structureType: 'Frame', material: 'Concrete', safetyFactor: 1.8, likes: 5, views: 25,
      isPublic: false, isOwner: true, sharedAt: new Date(), createdAt: new Date(), tags: ['frame', 'concrete']
    }
  ]);

  totalSharedCount = computed(() => this.sharedWithPartner().length + this.sharedByPartner().length);
  unreadCount = computed(() => this.activeConversation()?.unreadCount || 0);

  ngOnInit(): void {
    this.route.queryParams.subscribe(params => {
      if (params['userName']) this.friendName.set(params['userName']);
      if (params['userId']) this.friendId.set(params['userId']);
    });
  }
  
  ngOnDestroy(): void {}
  
  ngAfterViewChecked(): void {
    if (this.shouldScrollToBottom) {
      this.scrollToBottom();
      this.shouldScrollToBottom = false;
    }
  }
  
  private scrollToBottom(): void {
    if (this.messagesContainer?.nativeElement) {
      this.messagesContainer.nativeElement.scrollTop = this.messagesContainer.nativeElement.scrollHeight;
    }
  }
  
  goBack(): void { this.router.navigate(['/community']); }
  setActivePanel(panel: 'chat' | 'simulations' | 'details'): void { this.activePanel.set(panel); }
  getInitials(name: string): string { return name ? name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2) : '?'; }
  isOnline(): boolean { return true; }
  
  formatTime(date: Date): string {
    const d = new Date(date);
    const diff = Date.now() - d.getTime();
    if (diff < 60000) return 'Just now';
    if (diff < 3600000) return Math.floor(diff / 60000) + 'm ago';
    if (diff < 86400000) return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    return d.toLocaleDateString([], { month: 'short', day: 'numeric' });
  }
  
  updateInput(event: Event): void { this.messageInput.set((event.target as HTMLInputElement).value); }
  handleKeyPress(event: KeyboardEvent): void { if (event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); this.sendMessage(); } }
  
  sendMessage(): void {
    const content = this.messageInput().trim();
    if (content) {
      this.messages.update(msgs => [...msgs, { id: 'msg-' + Date.now(), senderId: 'user-1', senderName: 'You', content, sentAt: new Date() }]);
      this.messageInput.set('');
      this.shouldScrollToBottom = true;
    }
  }
  
  isOwnMessage(message: ChatMessageItem): boolean { return message.senderName === 'You' || message.senderId === 'user-1'; }
  getSafetyClass(sf: number): string { return sf >= 1.5 ? 'safe' : sf >= 1.0 ? 'warning' : 'critical'; }
  getSafetyDashArray(sf: number): string { const pct = Math.min(sf / 3.0, 1.0); const c = 2 * Math.PI * 45; return pct * c + ' ' + c; }
  
  viewSimulationDetail(sim: SharedSimulation): void {
    this.selectedSimulation.set({
      id: sim.id, name: sim.name, description: sim.description,
      beamLength: sim.dimensions?.length || 10, beamWidth: sim.dimensions?.width || 0.5, beamHeight: sim.dimensions?.height || 0.8,
      materialType: sim.material, elasticModulus: 200, loadType: 'POINT', loadMagnitude: sim.load || 50, supportType: sim.structureType,
      isPublic: sim.isPublic, isFavorite: false, likesCount: sim.likes, createdAt: sim.createdAt.toISOString(), updatedAt: sim.sharedAt.toISOString(),
      results: { maxDeflection: 0.015, maxBendingMoment: 125000, maxShearForce: 25000, maxStress: 150e6, safetyFactor: sim.safetyFactor }
    });
    this.setActivePanel('details');
  }
  
  viewReceivedSimulation(sim: SharedSimulationResponse): void { console.log('UI Only: View received', sim.simulationId); }
  clearSelectedSimulation(): void { this.selectedSimulation.set(null); }
  viewFullResults(): void { const sim = this.selectedSimulation(); if (sim) this.router.navigate(['/results', sim.id]); }
  
  openShareModal(): void { this.showShareModal.set(true); this.selectedShareSimulation.set(null); this.shareMessage.set(''); }
  closeShareModal(): void { this.showShareModal.set(false); this.selectedShareSimulation.set(null); this.shareMessage.set(''); }
  selectShareSimulation(sim: SharedSimulation): void { this.selectedShareSimulation.set(this.selectedShareSimulation()?.id === sim.id ? null : sim); }
  updateShareMessage(event: Event): void { this.shareMessage.set((event.target as HTMLTextAreaElement).value); }
  
  shareSimulation(): void {
    const sim = this.selectedShareSimulation();
    if (!sim) return;
    this.isSharingSimulation.set(true);
    this.messages.update(msgs => [...msgs, { id: 'msg-' + Date.now(), senderId: 'user-1', senderName: 'You', content: ' I shared: "' + sim.name + '"', sentAt: new Date() }]);
    this.closeShareModal();
    this.isSharingSimulation.set(false);
  }
}
