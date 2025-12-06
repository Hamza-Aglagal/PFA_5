import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

/**
 * Auth Interceptor - adds JWT token to all requests
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  
  // Get token from localStorage
  const token = localStorage.getItem('accessToken');
  
  // Clone request and add auth header if token exists
  if (token) {
    console.log('Interceptor: Adding token to request -', req.url);
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }
  
  // Handle response errors
  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      console.log('Interceptor: Error -', error.status, error.url);
      
      // If 401 Unauthorized, clear session and redirect to login
      if (error.status === 401) {
        console.log('Interceptor: 401 - Clearing session and redirecting to login');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        localStorage.removeItem('user');
        router.navigate(['/login']);
      }
      
      return throwError(() => error);
    })
  );
};
