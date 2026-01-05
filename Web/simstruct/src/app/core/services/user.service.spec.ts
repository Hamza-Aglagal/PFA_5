import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed } from '@angular/core/testing';
import { HttpClient } from '@angular/common/http';
import { of, throwError } from 'rxjs';
import { UserService, UpdateProfileRequest, ChangePasswordRequest } from './user.service';
import { AuthService, User } from './auth.service';

describe('UserService', () => {
  let service: UserService;
  let httpClientSpy: { get: ReturnType<typeof vi.fn>; put: ReturnType<typeof vi.fn> };
  let authServiceSpy: { updateUser: ReturnType<typeof vi.fn> };

  const mockUser: User = {
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    role: 'USER',
    phone: '+1234567890',
    company: 'Test Company',
    jobTitle: 'Engineer',
    bio: 'Test bio'
  };

  beforeEach(() => {
    httpClientSpy = {
      get: vi.fn(),
      put: vi.fn()
    };

    authServiceSpy = {
      updateUser: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        UserService,
        { provide: HttpClient, useValue: httpClientSpy },
        { provide: AuthService, useValue: authServiceSpy }
      ]
    });

    service = TestBed.inject(UserService);
  });

  describe('initialization', () => {
    it('should be created', () => {
      expect(service).toBeTruthy();
    });
  });

  describe('getProfile', () => {
    it('should get user profile successfully', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockUser }));

      const result = await service.getProfile();

      expect(result.success).toBe(true);
      expect(result.data?.email).toBe('test@example.com');
    });

    it('should update auth service with profile data', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockUser }));

      await service.getProfile();

      expect(authServiceSpy.updateUser).toHaveBeenCalledWith(mockUser);
    });

    it('should return error on failure', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: false }));

      const result = await service.getProfile();

      expect(result.success).toBe(false);
      expect(result.message).toBe('Failed to load profile');
    });

    it('should handle network error', async () => {
      httpClientSpy.get.mockReturnValue(throwError(() => ({
        error: { error: { message: 'Network error' } }
      })));

      const result = await service.getProfile();

      expect(result.success).toBe(false);
      expect(result.message).toContain('Network error');
    });
  });

  describe('updateProfile', () => {
    const updateRequest: UpdateProfileRequest = {
      name: 'Updated Name',
      phone: '+9876543210',
      company: 'New Company'
    };

    it('should update profile successfully', async () => {
      const updatedUser = { ...mockUser, ...updateRequest };
      httpClientSpy.put.mockReturnValue(of({ success: true, data: updatedUser }));

      const result = await service.updateProfile(updateRequest);

      expect(result.success).toBe(true);
      expect(result.data?.name).toBe('Updated Name');
    });

    it('should update auth service with new data', async () => {
      const updatedUser = { ...mockUser, ...updateRequest };
      httpClientSpy.put.mockReturnValue(of({ success: true, data: updatedUser }));

      await service.updateProfile(updateRequest);

      expect(authServiceSpy.updateUser).toHaveBeenCalledWith(updatedUser);
    });

    it('should return error on failure', async () => {
      httpClientSpy.put.mockReturnValue(of({ success: false }));

      const result = await service.updateProfile(updateRequest);

      expect(result.success).toBe(false);
    });

    it('should handle partial update', async () => {
      const partialUpdate: UpdateProfileRequest = { name: 'Only Name' };
      const updatedUser = { ...mockUser, name: 'Only Name' };
      httpClientSpy.put.mockReturnValue(of({ success: true, data: updatedUser }));

      const result = await service.updateProfile(partialUpdate);

      expect(result.success).toBe(true);
      expect(result.data?.name).toBe('Only Name');
    });
  });

  describe('changePassword', () => {
    const passwordRequest: ChangePasswordRequest = {
      currentPassword: 'oldPassword123',
      newPassword: 'newPassword456'
    };

    it('should change password successfully', async () => {
      httpClientSpy.put.mockReturnValue(of({ success: true }));

      const result = await service.changePassword(passwordRequest);

      expect(result.success).toBe(true);
    });

    it('should return error for wrong current password', async () => {
      httpClientSpy.put.mockReturnValue(throwError(() => ({
        error: { error: { message: 'Current password is incorrect' } }
      })));

      const result = await service.changePassword(passwordRequest);

      expect(result.success).toBe(false);
      expect(result.message).toContain('incorrect');
    });

    it('should handle password validation error', async () => {
      httpClientSpy.put.mockReturnValue(throwError(() => ({
        error: { error: { message: 'Password too weak' } }
      })));

      const result = await service.changePassword(passwordRequest);

      expect(result.success).toBe(false);
      expect(result.message).toContain('weak');
    });
  });

  describe('profile fields', () => {
    it('should include all profile fields', async () => {
      httpClientSpy.get.mockReturnValue(of({ success: true, data: mockUser }));

      const result = await service.getProfile();

      expect(result.data?.id).toBeDefined();
      expect(result.data?.email).toBeDefined();
      expect(result.data?.name).toBeDefined();
      expect(result.data?.role).toBeDefined();
      expect(result.data?.phone).toBeDefined();
      expect(result.data?.company).toBeDefined();
      expect(result.data?.jobTitle).toBeDefined();
      expect(result.data?.bio).toBeDefined();
    });
  });
});
