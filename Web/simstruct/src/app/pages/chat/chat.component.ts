import { Component, signal, inject, computed, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { CommunityService, ChatMessageDTO, SharedSimulationDTO } from '../../core/services/community.service';
import { SimulationService } from '../../core/services/simulation.service';
import { interval, takeUntil, Subject } from 'rxjs';

interface ChatMessageItem {
  id: string;
  senderId: string;
  senderName: string;
  content: string;
  sentAt: Date;
  isRead?: boolean;
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
  private communityService = inject(CommunityService);
  private simulationService = inject(SimulationService);
  private destroy$ = new Subject<void>();
  
  messageInput = signal('');
  private shouldScrollToBottom = true;
  
  friendId = signal<string | null>(null);
  friendName = signal<string>('');
  isLoading = signal(false);
  
  activePanel = signal<'chat' | 'simulations' | 'details'>('chat');
  simulationTab = signal<'sent' | 'received'>('sent');
  showSidebar = signal(true);
  
  selectedSimulation = signal<SimulationResponse | null>(null);
  
  showShareModal = signal(false);
  selectedShareSimulation = signal<SharedSimulation | null>(null);
  shareMessage = signal('');
  isSharingSimulation = signal(false);

  messages = signal<ChatMessageItem[]>([]);
  sharedWithPartner = signal<SharedSimulation[]>([]);
  sharedByPartner = signal<SharedSimulationDTO[]>([]);
  mySimulations = signal<SharedSimulation[]>([]);

  totalSharedCount = computed(() => this.sharedWithPartner().length + this.sharedByPartner().length);

  ngOnInit(): void {
    this.route.queryParams.subscribe(params => {
      if (params['userName']) this.friendName.set(params['userName']);
      if (params['userId']) {
        this.friendId.set(params['userId']);
        this.loadChatData();
      }
    });

    // Poll for new messages every 5 seconds
    interval(5000).pipe(takeUntil(this.destroy$)).subscribe(() => {
      const fId = this.friendId();
      if (fId) this.loadMessages(fId);
    });
  }
  
  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
  
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

  private loadChatData(): void {
    const fId = this.friendId();
    if (!fId) return;
    
    this.isLoading.set(true);
    
    // Load messages
    this.loadMessages(fId);
    
    // Load shared simulations
    this.communityService.getSharesWithFriend(fId).subscribe({
      next: (response) => {
        if (response.success && response.data) {
          // Split into sent and received
          const sent = response.data.filter(s => s.ownerId !== fId).map(s => ({
            id: s.id, name: s.simulationName, description: s.simulationDescription || '',
            structureType: 'Beam', material: 'Steel', safetyFactor: 1.5,
            likes: 0, views: 0, isPublic: true, isOwner: true,
            sharedAt: new Date(s.sharedAt), createdAt: new Date(s.sharedAt), tags: []
          }));
          this.sharedWithPartner.set(sent);
          this.sharedByPartner.set(response.data.filter(s => s.ownerId === fId));
        }
      },
      error: (err) => console.error('Error loading shares:', err)
    });
    
    // Load my simulations for sharing
    this.simulationService.getUserSimulations().subscribe({
      next: (response: any) => {
        if (response.success && response.data) {
          this.mySimulations.set(response.data.map((s: any) => ({
            id: s.id, name: s.name, description: s.description || '',
            structureType: s.supportType || 'Beam', material: s.materialType || 'Steel',
            safetyFactor: s.results?.safetyFactor || 1.5,
            likes: s.likesCount || 0, views: 0, isPublic: s.isPublic || false, isOwner: true,
            sharedAt: new Date(s.createdAt), createdAt: new Date(s.createdAt),
            tags: [s.materialType?.toLowerCase()].filter(Boolean),
            dimensions: { length: s.beamLength, width: s.beamWidth, height: s.beamHeight },
            load: s.loadMagnitude
          })));
        }
      },
      error: (err) => console.error('Error loading simulations:', err)
    });
    
    this.isLoading.set(false);
  }

  private loadMessages(friendId: string): void {
    this.communityService.getConversation(friendId, 100).subscribe({
      next: (response) => {
        if (response.success && response.data) {
          this.messages.set(response.data.map(m => ({
            id: m.id, senderId: m.senderId, senderName: m.senderName,
            content: m.content, sentAt: new Date(m.sentAt), isRead: m.isRead
          })));
          // Mark as read
          this.communityService.markAsRead(friendId).subscribe();
        }
      },
      error: (err) => console.error('Error loading messages:', err)
    });
  }
  
  goBack(): void { this.router.navigate(['/community']); }
  toggleSidebar(): void { this.showSidebar.update(v => !v); }
  setActivePanel(panel: 'chat' | 'simulations' | 'details'): void { this.activePanel.set(panel); }
  getInitials(name: string): string { return name ? name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2) : '?'; }
  
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
    const fId = this.friendId();
    if (content && fId) {
      this.communityService.sendMessage(fId, content).subscribe({
        next: (response) => {
          if (response.success && response.data) {
            this.messages.update(msgs => [...msgs, {
              id: response.data.id, senderId: response.data.senderId, senderName: response.data.senderName,
              content: response.data.content, sentAt: new Date(response.data.sentAt), isRead: false
            }]);
            this.shouldScrollToBottom = true;
          }
        },
        error: (err) => console.error('Error sending message:', err)
      });
      this.messageInput.set('');
    }
  }
  
  isOwnMessage(message: ChatMessageItem): boolean { 
    // Compare with current user - sender is current user if senderName is 'You' or senderId matches
    return message.senderName === 'You' || message.senderId !== this.friendId();
  }
  
  getSafetyClass(sf: number): string { return sf >= 1.5 ? 'safe' : sf >= 1.0 ? 'warning' : 'critical'; }
  getSafetyDashArray(sf: number): string { const pct = Math.min(sf / 3.0, 1.0); const c = 2 * Math.PI * 45; return pct * c + ' ' + c; }
  
  viewSimulationDetail(sim: SharedSimulation): void {
    this.selectedSimulation.set({
      id: sim.id, name: sim.name, description: sim.description,
      beamLength: sim.dimensions?.length || 10, beamWidth: sim.dimensions?.width || 0.5, beamHeight: sim.dimensions?.height || 0.8,
      materialType: sim.material, elasticModulus: 200, loadType: 'POINT', loadMagnitude: sim.load || 50, supportType: sim.structureType,
      isPublic: sim.isPublic, isFavorite: false, likesCount: sim.likes, createdAt: sim.createdAt.toISOString(), updatedAt: sim.sharedAt.toISOString(),
      results: { maxDeflection: 0.015, maxBendingMoment: 125000, maxShearForce: 25000, maxStress: 150, safetyFactor: sim.safetyFactor }
    });
    this.setActivePanel('details');
  }
  
  viewReceivedSimulation(sim: SharedSimulationDTO): void { 
    this.router.navigate(['/results', sim.simulationId]); 
  }
  
  clearSelectedSimulation(): void { this.selectedSimulation.set(null); }
  viewFullResults(): void { const sim = this.selectedSimulation(); if (sim) this.router.navigate(['/results', sim.id]); }
  
  openShareModal(): void { this.showShareModal.set(true); this.selectedShareSimulation.set(null); this.shareMessage.set(''); }
  closeShareModal(): void { this.showShareModal.set(false); this.selectedShareSimulation.set(null); this.shareMessage.set(''); }
  selectShareSimulation(sim: SharedSimulation): void { this.selectedShareSimulation.set(this.selectedShareSimulation()?.id === sim.id ? null : sim); }
  updateShareMessage(event: Event): void { this.shareMessage.set((event.target as HTMLTextAreaElement).value); }
  
  shareSimulation(): void {
    const sim = this.selectedShareSimulation();
    const fId = this.friendId();
    if (!sim || !fId) return;
    
    this.isSharingSimulation.set(true);
    this.communityService.shareSimulation(sim.id, fId, 'VIEW').subscribe({
      next: (response) => {
        if (response.success) {
          // Add to shared list
          this.sharedWithPartner.update(arr => [...arr, sim]);
          // Send message about sharing
          this.communityService.sendMessage(fId, `I shared a simulation: "${sim.name}"`).subscribe({
            next: (msgResponse) => {
              if (msgResponse.success && msgResponse.data) {
                this.messages.update(msgs => [...msgs, {
                  id: msgResponse.data.id, senderId: msgResponse.data.senderId, senderName: msgResponse.data.senderName,
                  content: msgResponse.data.content, sentAt: new Date(msgResponse.data.sentAt), isRead: false
                }]);
              }
            }
          });
        }
        this.closeShareModal();
        this.isSharingSimulation.set(false);
      },
      error: (err) => {
        console.error('Error sharing simulation:', err);
        this.isSharingSimulation.set(false);
      }
    });
  }
}
