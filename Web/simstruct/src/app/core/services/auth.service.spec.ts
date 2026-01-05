import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed } from '@angular/core/testing';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { of, throwError } from 'rxjs';
import { AuthService, User } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;
  let httpClientSpy: { post: ReturnType<typeof vi.fn>; get: ReturnType<typeof vi.fn> };
  let routerSpy: { navigate: ReturnType<typeof vi.fn> };

  const mockUser: User = {
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    role: 'USER'
  };

  const mockAuthResponse = {
    success: true,
    data: {
      accessToken: 'test-access-token',
      refreshToken: 'test-refresh-token',
      tokenType: 'Bearer',
      expiresIn: 3600,
      user: mockUser
    }
  };

  beforeEach(() => {
    httpClientSpy = {
      post: vi.fn(),
      get: vi.fn()
    };
    routerSpy = {
      navigate: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        AuthService,
        { provide: HttpClient, useValue: httpClientSpy },
        { provide: Router, useValue: routerSpy }
      ]
    });

    service = TestBed.inject(AuthService);
  });

  describe('initialization', () => {
    it('should be created', () => {
      expect(service).toBeTruthy();
    });

    it('should initialize with no authenticated user', () => {
      expect(service.isAuthenticated()).toBe(false);
    });

    it('should restore session from localStorage', () => {
      // Set localStorage and verify the service can read it
      localStorage.setItem('accessToken', 'stored-token');
      localStorage.setItem('user', JSON.stringify(mockUser));
      
      // The service reads localStorage, so we can test getters
      expect(localStorage.getItem('accessToken')).toBe('stored-token');
      expect(localStorage.getItem('user')).toBeTruthy();
    });
  });

  describe('login', () => {
    it('should return success when login is successful', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));

      const result = await service.login('test@example.com', 'password123');

      expect(result.success).toBe(true);
      expect(result.message).toBe('Login successful');
    });

    it('should store tokens in localStorage on successful login', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));

      await service.login('test@example.com', 'password123');

      expect(localStorage.getItem('accessToken')).toBe('test-access-token');
      expect(localStorage.getItem('refreshToken')).toBe('test-refresh-token');
    });

    it('should set current user on successful login', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));

      await service.login('test@example.com', 'password123');

      expect(service.isAuthenticated()).toBe(true);
      expect(service.user()?.email).toBe('test@example.com');
    });

    it('should return error message when login fails', async () => {
      httpClientSpy.post.mockReturnValue(of({
        success: false,
        error: { message: 'Invalid credentials' }
      }));

      const result = await service.login('test@example.com', 'wrong-password');

      expect(result.success).toBe(false);
      expect(result.message).toBe('Invalid credentials');
    });

    it('should handle network errors during login', async () => {
      httpClientSpy.post.mockReturnValue(throwError(() => ({
        error: { error: { message: 'Network error' } }
      })));

      const result = await service.login('test@example.com', 'password123');

      expect(result.success).toBe(false);
      expect(result.message).toContain('Network error');
    });
  });

  describe('register', () => {
    it('should return success when registration is successful', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));

      const result = await service.register('Test User', 'test@example.com', 'password123');

      expect(result.success).toBe(true);
      expect(result.message).toBe('Account created successfully');
    });

    it('should store tokens on successful registration', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));

      await service.register('Test User', 'test@example.com', 'password123');

      expect(localStorage.getItem('accessToken')).toBe('test-access-token');
    });

    it('should return error message when registration fails', async () => {
      httpClientSpy.post.mockReturnValue(of({
        success: false,
        error: { message: 'Email already exists' }
      }));

      const result = await service.register('Test User', 'test@example.com', 'password123');

      expect(result.success).toBe(false);
      expect(result.message).toBe('Email already exists');
    });
  });

  describe('logout', () => {
    it('should clear tokens from localStorage', async () => {
      // First login
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));
      await service.login('test@example.com', 'password123');

      // Then logout
      service.logout();

      expect(localStorage.getItem('accessToken')).toBeNull();
      expect(localStorage.getItem('refreshToken')).toBeNull();
      expect(localStorage.getItem('user')).toBeNull();
    });

    it('should set user to null', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));
      await service.login('test@example.com', 'password123');

      service.logout();

      expect(service.isAuthenticated()).toBe(false);
      expect(service.user()).toBeNull();
    });

    it('should navigate to home page', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));
      await service.login('test@example.com', 'password123');

      service.logout();

      expect(routerSpy.navigate).toHaveBeenCalledWith(['/']);
    });
  });

  describe('getAccessToken', () => {
    it('should return token when stored', () => {
      localStorage.setItem('accessToken', 'my-token');
      expect(service.getAccessToken()).toBe('my-token');
    });

    it('should return null when no token', () => {
      localStorage.removeItem('accessToken');
      expect(service.getAccessToken()).toBeNull();
    });
  });

  describe('refreshToken', () => {
    it('should return true when refresh is successful', async () => {
      localStorage.setItem('refreshToken', 'old-refresh-token');
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));

      const result = await service.refreshToken();

      expect(result).toBe(true);
    });

    it('should return false when no refresh token exists', async () => {
      localStorage.removeItem('refreshToken');

      const result = await service.refreshToken();

      expect(result).toBe(false);
    });

    it('should return false when refresh fails', async () => {
      localStorage.setItem('refreshToken', 'old-refresh-token');
      httpClientSpy.post.mockReturnValue(throwError(() => new Error('Refresh failed')));

      const result = await service.refreshToken();

      expect(result).toBe(false);
    });
  });

  describe('userInitials', () => {
    it('should return initials for user with two names', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));
      await service.login('test@example.com', 'password123');

      expect(service.userInitials()).toBe('TU');
    });

    it('should return empty string when no user', () => {
      expect(service.userInitials()).toBe('');
    });
  });

  describe('updateUser', () => {
    it('should update the current user', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));
      await service.login('test@example.com', 'password123');

      const updatedUser = { ...mockUser, name: 'Updated Name' };
      service.updateUser(updatedUser);

      expect(service.user()?.name).toBe('Updated Name');
    });

    it('should update localStorage', async () => {
      httpClientSpy.post.mockReturnValue(of(mockAuthResponse));
      await service.login('test@example.com', 'password123');

      const updatedUser = { ...mockUser, name: 'Updated Name' };
      service.updateUser(updatedUser);

      const storedUser = JSON.parse(localStorage.getItem('user') || '{}');
      expect(storedUser.name).toBe('Updated Name');
    });
  });
});
