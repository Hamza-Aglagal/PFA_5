import { Component, signal, inject, ElementRef, ViewChild, AfterViewChecked } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

// Mock types for UI only
interface ChatMessageItem {
  id: string;
  senderId: string;
  senderName: string;
  content: string;
  sentAt: Date;
}

interface Conversation {
  id: string;
  otherParticipant: {
    id: string;
    name: string;
    avatar?: string;
  };
  lastMessage: {
    content: string;
    sentAt: Date;
    senderName: string;
  };
  unreadCount: number;
}

@Component({
  selector: 'app-chat-panel',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './chat-panel.component.html',
  styleUrl: './chat-panel.component.scss'
})
export class ChatPanelComponent implements AfterViewChecked {
  @ViewChild('messagesContainer') messagesContainer!: ElementRef;
  
  // Mock chat service properties (UI only)
  chatService = {
    chatOpen: signal(false),
    activeConversation: signal<Conversation | null>(null),
    activeMessages: signal<ChatMessageItem[]>([]),
    allConversations: signal<Conversation[]>([]),
    totalUnreadCount: signal(0),
    openChat: () => this.chatService.chatOpen.set(true),
    closeChat: () => this.chatService.chatOpen.set(false),
    clearActiveConversation: () => this.chatService.activeConversation.set(null),
    selectConversation: (id: string) => console.log('Select conversation:', id),
    sendMessage: (content: string) => console.log('Send message:', content),
    formatMessageTime: (date: Date) => 'Just now',
    getTimeAgo: (date: Date) => 'Just now'
  };
  
  // Mock auth service (UI only)
  authService = {
    user: signal(null)
  };
  
  messageInput = signal('');
  private shouldScrollToBottom = true;
  
  ngAfterViewChecked(): void {
    if (this.shouldScrollToBottom) {
      this.scrollToBottom();
    }
  }
  
  private scrollToBottom(): void {
    if (this.messagesContainer?.nativeElement) {
      const container = this.messagesContainer.nativeElement;
      container.scrollTop = container.scrollHeight;
    }
  }
  
  sendMessage(): void {
    const content = this.messageInput().trim();
    if (content) {
      this.chatService.sendMessage(content);
      this.messageInput.set('');
      this.shouldScrollToBottom = true;
    }
  }
  
  handleKeyPress(event: KeyboardEvent): void {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      this.sendMessage();
    }
  }
  
  isOwnMessage(message: ChatMessageItem): boolean {
    const user = this.authService.user();
    return user ? message.senderId === (user as any).id : message.senderName === 'You';
  }
  
  getInitials(name: string): string {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  }
  
  updateInput(event: Event): void {
    const target = event.target as HTMLInputElement;
    this.messageInput.set(target.value);
  }
}
