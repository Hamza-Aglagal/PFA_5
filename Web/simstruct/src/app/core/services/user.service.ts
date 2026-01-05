import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../config/environment';
import { User, AuthService } from './auth.service';

// API response wrapper
interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: { code: string; message: string; };
}

// Update profile request
export interface UpdateProfileRequest {
  name?: string;
  phone?: string;
  company?: string;
  jobTitle?: string;
  bio?: string;
}

// Change password request
export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private http = inject(HttpClient);
  private authService = inject(AuthService);

  private apiUrl = environment.apiUrl;

  /**
   * Get current user profile
   */
  async getProfile(): Promise<{ success: boolean; data?: User; message?: string }> {
    console.log('UserService: Getting profile');

    try {
      const response = await this.http.get<ApiResponse<User>>(
        `${this.apiUrl}/users/me`
      ).toPromise();

      if (response?.success && response.data) {
        console.log('UserService: Profile loaded');
        this.authService.updateUser(response.data);
        return { success: true, data: response.data };
      }
      return { success: false, message: 'Failed to load profile' };
    } catch (error: any) {
      console.log('UserService: Error loading profile -', error);
      return { success: false, message: error.error?.error?.message || 'Failed to load profile' };
    }
  }

  /**
   * Update user profile
   */
  async updateProfile(data: UpdateProfileRequest): Promise<{ success: boolean; data?: User; message?: string }> {
    console.log('UserService: Updating profile');

    try {
      const response = await this.http.put<ApiResponse<User>>(
        `${this.apiUrl}/users/me`,
        data
      ).toPromise();

      if (response?.success && response.data) {
        console.log('UserService: Profile updated');
        this.authService.updateUser(response.data);
        return { success: true, data: response.data };
      }
      return { success: false, message: 'Failed to update profile' };
    } catch (error: any) {
      console.log('UserService: Error updating profile -', error);
      return { success: false, message: error.error?.error?.message || 'Failed to update profile' };
    }
  }

  /**
   * Change password
   */
  async changePassword(data: ChangePasswordRequest): Promise<{ success: boolean; message: string }> {
    console.log('UserService: Changing password');

    try {
      const response = await this.http.put<ApiResponse<string>>(
        `${this.apiUrl}/users/me/password`,
        data
      ).toPromise();

      if (response?.success) {
        console.log('UserService: Password changed');
        return { success: true, message: 'Password changed successfully' };
      }
      return { success: false, message: response?.error?.message || 'Failed to change password' };
    } catch (error: any) {
      console.log('UserService: Error changing password -', error);
      return { success: false, message: error.error?.error?.message || 'Failed to change password' };
    }
  }

  /**
   * Delete account
   */
  async deleteAccount(): Promise<{ success: boolean; message: string }> {
    console.log('UserService: Deleting account');

    try {
      const response = await this.http.delete<ApiResponse<string>>(
        `${this.apiUrl}/users/me`
      ).toPromise();

      if (response?.success) {
        console.log('UserService: Account deleted');
        this.authService.logout();
        return { success: true, message: 'Account deleted successfully' };
      }
      return { success: false, message: 'Failed to delete account' };
    } catch (error: any) {
      console.log('UserService: Error deleting account -', error);
      return { success: false, message: error.error?.error?.message || 'Failed to delete account' };
    }
  }
}
