import { Component, inject, HostListener, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

// Mock types for UI only
type SidebarPanel = 'notifications' | 'messages' | 'quick-actions' | 'share' | null;

interface QuickAction {
  id: string;
  label: string;
  icon: string;
  route?: string;
  action?: () => void;
  color: string;
}

interface Message {
  id: string;
  sender: string;
  avatar?: string;
  message: string;
  timestamp: Date;
  unread: boolean;
}

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.scss'
})
export class SidebarComponent {
  // Mock sidebar state (UI only)
  isOpen = signal(false);
  currentPanel = signal<SidebarPanel>(null);
  unreadCount = signal(0);
  
  // Mock notifications
  mockNotifications = signal([
    { id: '1', title: 'Welcome', message: 'Welcome to SimStruct!', type: 'INFO', isRead: false, createdAt: new Date() }
  ]);
  
  allNotifications = computed(() => this.mockNotifications());

  quickActions: QuickAction[] = [
    { id: 'new-sim', label: 'New Simulation', icon: 'simulation', route: '/simulation', color: '#3b82f6' },
    { id: 'history', label: 'View History', icon: 'history', route: '/history', color: '#8b5cf6' },
    { id: 'share', label: 'Share Results', icon: 'share', action: () => this.openShareModal(), color: '#10b981' },
    { id: 'export', label: 'Export Report', icon: 'export', action: () => this.exportReport(), color: '#f59e0b' },
    { id: 'compare', label: 'Compare Results', icon: 'compare', route: '/history?mode=compare', color: '#ec4899' },
    { id: 'settings', label: 'Settings', icon: 'settings', route: '/settings', color: '#6b7280' },
  ];

  // Mock messages for demo
  messages: Message[] = [
    {
      id: 'msg1',
      sender: 'Sarah Engineer',
      message: 'Hey! Can you check the bridge simulation I shared?',
      timestamp: new Date(Date.now() - 300000),
      unread: true
    },
    {
      id: 'msg2',
      sender: 'Team SimStruct',
      message: 'Your simulation "Tower Analysis" was viewed 5 times!',
      timestamp: new Date(Date.now() - 3600000),
      unread: true
    },
    {
      id: 'msg3',
      sender: 'Alex Builder',
      message: 'Thanks for the collaboration on the warehouse project.',
      timestamp: new Date(Date.now() - 86400000),
      unread: false
    }
  ];

  @HostListener('document:keydown.escape')
  onEscape() {
    this.closePanel();
  }

  closePanel() {
    this.isOpen.set(false);
    this.currentPanel.set(null);
  }

  getTimeAgo(date: Date): string {
    const now = new Date();
    const diff = now.getTime() - new Date(date).getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return 'Just now';
    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    return `${days}d ago`;
  }

  getUnreadMessagesCount(): number {
    return this.messages.filter(m => m.unread).length;
  }

  markMessageAsRead(id: string) {
    const msg = this.messages.find(m => m.id === id);
    if (msg) msg.unread = false;
  }

  openShareModal() {
    // Mock share modal (UI only)
    console.log('Share functionality - UI only mode');
    this.closePanel();
  }

  exportReport() {
    // Mock export report (UI only)
    console.log('Export report - UI only mode');
    this.closePanel();
  }
  
  markAllAsRead() {
    // Mock mark all as read (UI only)
    const notifications = this.mockNotifications();
    notifications.forEach(n => n.isRead = true);
    this.mockNotifications.set([...notifications]);
  }
  
  markAsRead(id: string) {
    // Mock mark as read (UI only)
    const notifications = this.mockNotifications();
    const notif = notifications.find(n => n.id === id);
    if (notif) notif.isRead = true;
    this.mockNotifications.set([...notifications]);
  }
  
  removeNotification(id: string) {
    // Mock remove notification (UI only)
    const notifications = this.mockNotifications();
    this.mockNotifications.set(notifications.filter(n => n.id !== id));
  }

  getSenderInitials(name: string): string {
    return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  }

  getNotificationIcon(type: string): string {
    switch (type) {
      case 'SUCCESS': return '✅';
      case 'ERROR': return '❌';
      case 'WARNING': return '⚠️';
      default: return '📢';
    }
  }
}
