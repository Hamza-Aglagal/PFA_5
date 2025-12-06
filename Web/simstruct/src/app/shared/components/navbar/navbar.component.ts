import { Component, signal, HostListener, Renderer2, inject, computed, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { NotificationService } from '../../../core/services/notification.service';

interface NavLink {
  path: string;
  label: string;
  icon: string;
  authRequired?: boolean;
  hideWhenAuth?: boolean;
}

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.scss'
})
export class NavbarComponent implements OnInit {
  private renderer = inject(Renderer2);
  private router = inject(Router);
  private authService = inject(AuthService);
  private notificationService = inject(NotificationService);
  
  // Auth state - reactive from AuthService
  isAuthenticated = this.authService.isAuthenticated;
  user = this.authService.user;
  userInitials = this.authService.userInitials;
  
  unreadCount = signal(0);
  
  isScrolled = signal(false);
  isMobileMenuOpen = signal(false);
  isLightMode = signal(false);
  showUserDropdown = signal(false);
  showNotificationPanel = signal(false);
  
  // Mock notifications (UI only)
  mockNotifications = signal([
    { id: '1', title: 'Welcome', message: 'Welcome to SimStruct!', type: 'INFO', isRead: false, createdAt: new Date() }
  ]);

  // Public nav links (before login)
  publicNavLinks: NavLink[] = [
    { path: '/', label: 'Home', icon: 'home' },
    { path: '/simulation', label: 'Simulation', icon: 'simulation' },
  ];

  // Auth nav links (after login)
  authNavLinks: NavLink[] = [
    { path: '/', label: 'Home', icon: 'home' },
    { path: '/dashboard', label: 'Dashboard', icon: 'dashboard' },
    { path: '/simulation', label: 'Simulation', icon: 'simulation' },
    { path: '/community', label: 'Community', icon: 'community' },
    { path: '/history', label: 'History', icon: 'history' },
  ];

  // Computed nav links based on auth state
  navLinks = computed(() => {
    return this.isAuthenticated() ? this.authNavLinks : this.publicNavLinks;
  });

  constructor() {
    // Check for saved theme preference
    const savedTheme = localStorage.getItem('simstruct-theme');
    const isLight = savedTheme === 'light';
    this.isLightMode.set(isLight);
    if (isLight) {
      document.body.classList.add('light-mode');
    }
  }

  ngOnInit(): void {
    console.log('NavbarComponent: Initialized, auth state:', this.isAuthenticated());
  }

  @HostListener('window:scroll')
  onScroll() {
    this.isScrolled.set(window.scrollY > 50);
  }

  @HostListener('document:click', ['$event'])
  onDocumentClick(event: MouseEvent) {
    const target = event.target as HTMLElement;
    if (!target.closest('.user-menu-container')) {
      this.showUserDropdown.set(false);
    }
    if (!target.closest('.notification-container')) {
      this.showNotificationPanel.set(false);
    }
  }

  toggleMobileMenu() {
    this.isMobileMenuOpen.update(v => !v);
  }

  closeMobileMenu() {
    this.isMobileMenuOpen.set(false);
  }
  
  toggleTheme() {
    this.isLightMode.update(v => !v);
    
    if (this.isLightMode()) {
      this.renderer.addClass(document.body, 'light-mode');
      localStorage.setItem('simstruct-theme', 'light');
    } else {
      this.renderer.removeClass(document.body, 'light-mode');
      localStorage.setItem('simstruct-theme', 'dark');
    }
  }

  toggleUserDropdown() {
    this.showUserDropdown.update(v => !v);
    this.showNotificationPanel.set(false);
  }

  toggleNotificationPanel() {
    this.showNotificationPanel.update(v => !v);
    this.showUserDropdown.set(false);
  }

  logout() {
    console.log('NavbarComponent: Logging out');
    this.authService.logout();
    this.showUserDropdown.set(false);
    this.closeMobileMenu();
    this.notificationService.success('Goodbye!', 'You have been logged out successfully');
  }

  markNotificationAsRead(id: string) {
    // Mock mark as read (UI only)
    const notifications = this.mockNotifications();
    const notif = notifications.find(n => n.id === id);
    if (notif) notif.isRead = true;
    this.mockNotifications.set([...notifications]);
  }

  markAllNotificationsAsRead() {
    // Mock mark all as read (UI only)
    const notifications = this.mockNotifications();
    notifications.forEach(n => n.isRead = true);
    this.mockNotifications.set([...notifications]);
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
    if (days < 7) return `${days}d ago`;
    return new Date(date).toLocaleDateString();
  }

  openSidebar(panel: 'notifications' | 'messages' | 'quick-actions') {
    // Mock sidebar open (UI only - no action)
    this.showNotificationPanel.set(false);
    this.showUserDropdown.set(false);
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
