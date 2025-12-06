import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  if (authService.isAuthenticated()) {
    return true;
  }
  
  // Store the attempted URL for redirecting after login
  localStorage.setItem('redirectUrl', state.url);
  
  // Redirect to login page
  router.navigate(['/login']);
  return false;
};

// Guard for pages that should only be accessed when NOT authenticated (login, register)
export const guestGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  // Check localStorage for user
  const hasUser = !!localStorage.getItem('user');
  
  // Only redirect if we're truly authenticated
  if (authService.isAuthenticated() && hasUser) {
    // Already logged in, redirect to dashboard
    router.navigate(['/dashboard']);
    return false;
  }
  
  return true;
};
