import { Injectable, signal, computed, inject } from '@angular/core';
import { Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { environment } from '../config/environment';

// User interface
export interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  role: string;
  phone?: string;
  company?: string;
  jobTitle?: string;
  bio?: string;
  emailVerified?: boolean;
  createdAt?: string;
}

// Auth response from API
interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: User;
}

// API response wrapper
interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: { code: string; message: string; };
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private router = inject(Router);
  private http = inject(HttpClient);
  
  private apiUrl = environment.apiUrl;
  private currentUser = signal<User | null>(null);
  
  // Computed signals
  isAuthenticated = computed(() => !!this.currentUser());
  user = computed(() => this.currentUser());
  userInitials = computed(() => {
    const user = this.currentUser();
    if (!user) return '';
    const names = user.name.split(' ');
    return names.map(n => n[0]).join('').toUpperCase().slice(0, 2);
  });

  constructor() {
    console.log('AuthService: Initializing...');
    this.checkSession();
  }

  private checkSession(): void {
    console.log('AuthService: Checking session...');
    const token = localStorage.getItem('accessToken');
    const savedUser = localStorage.getItem('user');
    
    if (token && savedUser) {
      try {
        const user = JSON.parse(savedUser);
        this.currentUser.set(user);
        console.log('AuthService: Session restored for', user.email);
      } catch {
        console.log('AuthService: Failed to parse saved user');
        this.clearStorage();
      }
    }
  }

  private clearStorage(): void {
    console.log('AuthService: Clearing storage');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('user');
  }
  
  private clearSession(): void {
    this.currentUser.set(null);
    this.clearStorage();
  }

  private saveSession(response: AuthResponse): void {
    console.log('AuthService: Saving session');
    localStorage.setItem('accessToken', response.accessToken);
    localStorage.setItem('refreshToken', response.refreshToken);
    localStorage.setItem('user', JSON.stringify(response.user));
    this.currentUser.set(response.user);
  }

  getAccessToken(): string | null {
    return localStorage.getItem('accessToken');
  }

  getRefreshToken(): string | null {
    return localStorage.getItem('refreshToken');
  }

  async login(email: string, password: string): Promise<{ success: boolean; message: string }> {
    console.log('AuthService: Login attempt for', email);
    
    try {
      const response = await this.http.post<ApiResponse<AuthResponse>>(
        `${this.apiUrl}/auth/login`,
        { email, password }
      ).toPromise();
      
      if (response?.success && response.data) {
        this.saveSession(response.data);
        console.log('AuthService: Login successful');
        return { success: true, message: 'Login successful' };
      } else {
        console.log('AuthService: Login failed -', response?.error?.message);
        return { success: false, message: response?.error?.message || 'Login failed' };
      }
    } catch (error: any) {
      console.log('AuthService: Login error -', error);
      const message = error.error?.error?.message || 'Login failed. Please try again.';
      return { success: false, message };
    }
  }

  async register(name: string, email: string, password: string): Promise<{ success: boolean; message: string }> {
    console.log('AuthService: Register attempt for', email);
    
    try {
      const response = await this.http.post<ApiResponse<AuthResponse>>(
        `${this.apiUrl}/auth/register`,
        { name, email, password }
      ).toPromise();
      
      if (response?.success && response.data) {
        this.saveSession(response.data);
        console.log('AuthService: Registration successful');
        return { success: true, message: 'Account created successfully' };
      } else {
        console.log('AuthService: Registration failed -', response?.error?.message);
        return { success: false, message: response?.error?.message || 'Registration failed' };
      }
    } catch (error: any) {
      console.log('AuthService: Registration error -', error);
      const message = error.error?.error?.message || 'Registration failed. Please try again.';
      return { success: false, message };
    }
  }

  async refreshToken(): Promise<boolean> {
    console.log('AuthService: Refreshing token...');
    const refreshToken = this.getRefreshToken();
    if (!refreshToken) return false;
    
    try {
      const response = await this.http.post<ApiResponse<AuthResponse>>(
        `${this.apiUrl}/auth/refresh`,
        { refreshToken }
      ).toPromise();
      
      if (response?.success && response.data) {
        this.saveSession(response.data);
        console.log('AuthService: Token refreshed');
        return true;
      }
      return false;
    } catch (error) {
      console.log('AuthService: Token refresh failed');
      return false;
    }
  }

  logout(): void {
    console.log('AuthService: Logging out');
    this.clearSession();
    this.router.navigate(['/']);
  }
  
  updateUser(user: User): void {
    console.log('AuthService: Updating user');
    this.currentUser.set(user);
    localStorage.setItem('user', JSON.stringify(user));
  }
}
