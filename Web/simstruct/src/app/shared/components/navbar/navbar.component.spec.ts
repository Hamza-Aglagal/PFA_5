import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
import { signal } from '@angular/core';
import { NavbarComponent } from './navbar.component';
import { AuthService } from '../../../core/services/auth.service';
import { NotificationService } from '../../../core/services/notification.service';
import { BackendNotificationService } from '../../../core/services/backend-notification.service';

describe('NavbarComponent', () => {
  let component: NavbarComponent;
  let fixture: ComponentFixture<NavbarComponent>;
  let authServiceMock: {
    isAuthenticated: ReturnType<typeof signal>;
    user: ReturnType<typeof signal>;
    userInitials: ReturnType<typeof signal>;
    logout: ReturnType<typeof vi.fn>;
  };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let notificationMock: { success: ReturnType<typeof vi.fn> };
  let backendNotificationMock: {
    notifications: ReturnType<typeof signal>;
    unreadCount: ReturnType<typeof signal>;
    loading: ReturnType<typeof signal>;
    loadNotifications: ReturnType<typeof vi.fn>;
    markAsRead: ReturnType<typeof vi.fn>;
  };

  beforeEach(async () => {
    authServiceMock = {
      isAuthenticated: signal(false),
      user: signal(null),
      userInitials: signal(''),
      logout: vi.fn()
    };

    routerMock = {
      navigate: vi.fn()
    };

    notificationMock = {
      success: vi.fn()
    };

    backendNotificationMock = {
      notifications: signal([]),
      unreadCount: signal(0),
      loading: signal(false),
      loadNotifications: vi.fn(),
      markAsRead: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [NavbarComponent],
      providers: [
        { provide: AuthService, useValue: authServiceMock },
        { provide: Router, useValue: routerMock },
        { provide: NotificationService, useValue: notificationMock },
        { provide: BackendNotificationService, useValue: backendNotificationMock },
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: { params: {}, queryParams: {} },
            params: of({}),
            queryParams: of({})
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(NavbarComponent);
    component = fixture.componentInstance;
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should start with mobile menu closed', () => {
      expect(component.isMobileMenuOpen()).toBe(false);
    });

    it('should start with not scrolled', () => {
      expect(component.isScrolled()).toBe(false);
    });

    it('should start with user dropdown closed', () => {
      expect(component.showUserDropdown()).toBe(false);
    });

    it('should start with notification panel closed', () => {
      expect(component.showNotificationPanel()).toBe(false);
    });
  });

  describe('navigation links', () => {
    it('should show public nav links when not authenticated', () => {
      authServiceMock.isAuthenticated.set(false);
      
      const links = component.navLinks();
      expect(links.length).toBe(2);
    });

    it('should show auth nav links when authenticated', () => {
      authServiceMock.isAuthenticated.set(true);

      const links = component.navLinks();
      expect(links.length).toBe(5);
    });

    it('should include home link in public nav', () => {
      const homeLink = component.publicNavLinks.find(l => l.path === '/');
      expect(homeLink).toBeTruthy();
      expect(homeLink?.label).toBe('Home');
    });

    it('should include dashboard link in auth nav', () => {
      const dashboardLink = component.authNavLinks.find(l => l.path === '/dashboard');
      expect(dashboardLink).toBeTruthy();
    });

    it('should include simulation link in both navs', () => {
      const publicSim = component.publicNavLinks.find(l => l.path === '/simulation');
      const authSim = component.authNavLinks.find(l => l.path === '/simulation');
      expect(publicSim).toBeTruthy();
      expect(authSim).toBeTruthy();
    });
  });

  describe('mobile menu', () => {
    it('should toggle mobile menu', () => {
      expect(component.isMobileMenuOpen()).toBe(false);
      component.toggleMobileMenu();
      expect(component.isMobileMenuOpen()).toBe(true);
      component.toggleMobileMenu();
      expect(component.isMobileMenuOpen()).toBe(false);
    });

    it('should close mobile menu', () => {
      component.isMobileMenuOpen.set(true);
      component.closeMobileMenu();
      expect(component.isMobileMenuOpen()).toBe(false);
    });
  });

  describe('theme toggle', () => {
    it('should toggle light mode', () => {
      expect(component.isLightMode()).toBe(false);
      component.toggleTheme();
      expect(component.isLightMode()).toBe(true);
    });

    it('should save theme preference to localStorage', () => {
      component.toggleTheme();
      expect(localStorage.getItem('simstruct-theme')).toBe('light');
      
      component.toggleTheme();
      expect(localStorage.getItem('simstruct-theme')).toBe('dark');
    });

    it('should add/remove light-mode class on body', () => {
      component.toggleTheme();
      expect(document.body.classList.contains('light-mode')).toBe(true);
      
      component.toggleTheme();
      expect(document.body.classList.contains('light-mode')).toBe(false);
    });
  });

  describe('user dropdown', () => {
    it('should toggle user dropdown', () => {
      expect(component.showUserDropdown()).toBe(false);
      component.toggleUserDropdown();
      expect(component.showUserDropdown()).toBe(true);
    });

    it('should close notification panel when opening user dropdown', () => {
      component.showNotificationPanel.set(true);
      component.toggleUserDropdown();
      expect(component.showNotificationPanel()).toBe(false);
    });
  });

  describe('notification panel', () => {
    it('should toggle notification panel', () => {
      expect(component.showNotificationPanel()).toBe(false);
      component.toggleNotificationPanel();
      expect(component.showNotificationPanel()).toBe(true);
    });

    it('should close user dropdown when opening notifications', () => {
      component.showUserDropdown.set(true);
      component.toggleNotificationPanel();
      expect(component.showUserDropdown()).toBe(false);
    });
  });

  describe('scroll handling', () => {
    it('should update isScrolled on scroll', () => {
      expect(component.isScrolled()).toBe(false);
      
      // Simulate scroll
      Object.defineProperty(window, 'scrollY', { value: 100, writable: true });
      component.onScroll();
      
      expect(component.isScrolled()).toBe(true);
    });

    it('should not be scrolled when at top', () => {
      Object.defineProperty(window, 'scrollY', { value: 0, writable: true });
      component.onScroll();
      expect(component.isScrolled()).toBe(false);
    });
  });

  describe('document click handling', () => {
    it('should close user dropdown on outside click', () => {
      component.showUserDropdown.set(true);
      
      const event = {
        target: {
          closest: vi.fn().mockReturnValue(null)
        }
      } as unknown as MouseEvent;
      
      component.onDocumentClick(event);
      
      expect(component.showUserDropdown()).toBe(false);
    });

    it('should close notification panel on outside click', () => {
      component.showNotificationPanel.set(true);
      
      const event = {
        target: {
          closest: vi.fn().mockReturnValue(null)
        }
      } as unknown as MouseEvent;
      
      component.onDocumentClick(event);
      
      expect(component.showNotificationPanel()).toBe(false);
    });
  });

  describe('logout', () => {
    it('should call authService.logout', () => {
      component.logout();
      expect(authServiceMock.logout).toHaveBeenCalled();
    });

    it('should close user dropdown', () => {
      component.showUserDropdown.set(true);
      component.logout();
      expect(component.showUserDropdown()).toBe(false);
    });
  });

  describe('auth state binding', () => {
    it('should reflect isAuthenticated from authService', () => {
      expect(component.isAuthenticated()).toBe(false);
    });

    it('should reflect user from authService', () => {
      expect(component.user()).toBeNull();
    });

    it('should reflect userInitials from authService', () => {
      expect(component.userInitials()).toBe('');
    });
  });

  describe('notification bindings', () => {
    it('should reflect notifications from backend service', () => {
      expect(component.notifications()).toEqual([]);
    });

    it('should reflect unreadCount from backend service', () => {
      expect(component.unreadCount()).toBe(0);
    });

    it('should reflect loading state from backend service', () => {
      expect(component.notificationsLoading()).toBe(false);
    });
  });
});
