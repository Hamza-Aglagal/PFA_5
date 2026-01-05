import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { TestBed } from '@angular/core/testing';
import { AuthService } from '../services/auth.service';
import { authGuard, guestGuard } from './auth.guard';
import { signal } from '@angular/core';

describe('authGuard', () => {
  let authServiceMock: { isAuthenticated: ReturnType<typeof signal> };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let routeSnapshot: ActivatedRouteSnapshot;
  let stateSnapshot: RouterStateSnapshot;

  beforeEach(() => {
    authServiceMock = {
      isAuthenticated: signal(false)
    };

    routerMock = {
      navigate: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authServiceMock },
        { provide: Router, useValue: routerMock }
      ]
    });

    routeSnapshot = {} as ActivatedRouteSnapshot;
    stateSnapshot = { url: '/dashboard' } as RouterStateSnapshot;
  });

  describe('when user is authenticated', () => {
    beforeEach(() => {
      authServiceMock.isAuthenticated = signal(true);
      TestBed.overrideProvider(AuthService, { useValue: authServiceMock });
    });

    it('should allow access', () => {
      const result = TestBed.runInInjectionContext(() => 
        authGuard(routeSnapshot, stateSnapshot)
      );

      expect(result).toBe(true);
    });

    it('should not navigate', () => {
      TestBed.runInInjectionContext(() => 
        authGuard(routeSnapshot, stateSnapshot)
      );

      expect(routerMock.navigate).not.toHaveBeenCalled();
    });
  });

  describe('when user is not authenticated', () => {
    beforeEach(() => {
      authServiceMock.isAuthenticated = signal(false);
      TestBed.overrideProvider(AuthService, { useValue: authServiceMock });
      localStorage.removeItem('redirectUrl');
    });

    it('should deny access', () => {
      const result = TestBed.runInInjectionContext(() => 
        authGuard(routeSnapshot, stateSnapshot)
      );

      expect(result).toBe(false);
    });

    it('should redirect to login', () => {
      TestBed.runInInjectionContext(() => 
        authGuard(routeSnapshot, stateSnapshot)
      );

      expect(routerMock.navigate).toHaveBeenCalledWith(['/login']);
    });

    it('should store redirect URL', () => {
      TestBed.runInInjectionContext(() => 
        authGuard(routeSnapshot, stateSnapshot)
      );

      expect(localStorage.getItem('redirectUrl')).toBe('/dashboard');
    });
  });
});

describe('guestGuard', () => {
  let authServiceMock: { isAuthenticated: ReturnType<typeof signal> };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let routeSnapshot: ActivatedRouteSnapshot;
  let stateSnapshot: RouterStateSnapshot;

  beforeEach(() => {
    authServiceMock = {
      isAuthenticated: signal(false)
    };

    routerMock = {
      navigate: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authServiceMock },
        { provide: Router, useValue: routerMock }
      ]
    });

    routeSnapshot = {} as ActivatedRouteSnapshot;
    stateSnapshot = { url: '/login' } as RouterStateSnapshot;
    localStorage.removeItem('user');
  });

  describe('when user is not authenticated', () => {
    it('should allow access to login page', () => {
      const result = TestBed.runInInjectionContext(() => 
        guestGuard(routeSnapshot, stateSnapshot)
      );

      expect(result).toBe(true);
    });

    it('should not redirect', () => {
      TestBed.runInInjectionContext(() => 
        guestGuard(routeSnapshot, stateSnapshot)
      );

      expect(routerMock.navigate).not.toHaveBeenCalled();
    });
  });

  describe('when user is authenticated', () => {
    beforeEach(() => {
      authServiceMock.isAuthenticated = signal(true);
      localStorage.setItem('user', JSON.stringify({ id: '1', email: 'test@test.com' }));
      TestBed.overrideProvider(AuthService, { useValue: authServiceMock });
    });

    it('should deny access', () => {
      const result = TestBed.runInInjectionContext(() => 
        guestGuard(routeSnapshot, stateSnapshot)
      );

      expect(result).toBe(false);
    });

    it('should redirect to dashboard', () => {
      TestBed.runInInjectionContext(() => 
        guestGuard(routeSnapshot, stateSnapshot)
      );

      expect(routerMock.navigate).toHaveBeenCalledWith(['/dashboard']);
    });
  });

  describe('edge cases', () => {
    it('should handle missing user in localStorage with authenticated service', () => {
      authServiceMock.isAuthenticated = signal(true);
      localStorage.removeItem('user');
      TestBed.overrideProvider(AuthService, { useValue: authServiceMock });

      const result = TestBed.runInInjectionContext(() => 
        guestGuard(routeSnapshot, stateSnapshot)
      );

      // Should allow access because localStorage has no user
      expect(result).toBe(true);
    });
  });
});
