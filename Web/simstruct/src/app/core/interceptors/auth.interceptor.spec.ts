import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed } from '@angular/core/testing';
import { HttpRequest, HttpEvent, HttpErrorResponse } from '@angular/common/http';
import { Router } from '@angular/router';
import { of, throwError, firstValueFrom } from 'rxjs';
import { authInterceptor } from './auth.interceptor';

describe('authInterceptor', () => {
  let routerMock: { navigate: ReturnType<typeof vi.fn> };

  beforeEach(() => {
    routerMock = {
      navigate: vi.fn()
    };

    TestBed.configureTestingModule({
      providers: [
        { provide: Router, useValue: routerMock }
      ]
    });

    localStorage.clear();
  });

  function createRequest(url: string): HttpRequest<unknown> {
    return new HttpRequest('GET', url);
  }

  describe('when token exists', () => {
    beforeEach(() => {
      localStorage.setItem('accessToken', 'test-jwt-token');
    });

    it('should add Authorization header', async () => {
      let capturedRequest: HttpRequest<unknown> | null = null;

      const next = (req: HttpRequest<unknown>) => {
        capturedRequest = req;
        return of({} as HttpEvent<unknown>);
      };

      await TestBed.runInInjectionContext(async () => {
        await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
      });

      expect(capturedRequest?.headers.get('Authorization')).toBe('Bearer test-jwt-token');
    });

    it('should use Bearer prefix', async () => {
      let capturedRequest: HttpRequest<unknown> | null = null;

      const next = (req: HttpRequest<unknown>) => {
        capturedRequest = req;
        return of({} as HttpEvent<unknown>);
      };

      await TestBed.runInInjectionContext(async () => {
        await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
      });

      expect(capturedRequest?.headers.get('Authorization')).toContain('Bearer');
    });
  });

  describe('when no token exists', () => {
    it('should not add Authorization header', async () => {
      let capturedRequest: HttpRequest<unknown> | null = null;

      const next = (req: HttpRequest<unknown>) => {
        capturedRequest = req;
        return of({} as HttpEvent<unknown>);
      };

      await TestBed.runInInjectionContext(async () => {
        await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
      });

      expect(capturedRequest?.headers.has('Authorization')).toBe(false);
    });
  });

  describe('error handling', () => {
    beforeEach(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
      localStorage.setItem('user', JSON.stringify({ id: '1' }));
    });

    it('should handle 401 error', async () => {
      const error401 = new HttpErrorResponse({ status: 401, url: '/api/data' });
      const next = () => throwError(() => error401);

      try {
        await TestBed.runInInjectionContext(async () => {
          await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
        });
      } catch {
        // Expected error
      }

      expect(localStorage.getItem('accessToken')).toBeNull();
      expect(localStorage.getItem('refreshToken')).toBeNull();
      expect(localStorage.getItem('user')).toBeNull();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/login']);
    });

    it('should handle 403 error', async () => {
      const error403 = new HttpErrorResponse({ status: 403, url: '/api/data' });
      const next = () => throwError(() => error403);

      try {
        await TestBed.runInInjectionContext(async () => {
          await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
        });
      } catch {
        // Expected error
      }

      expect(localStorage.getItem('accessToken')).toBeNull();
      expect(routerMock.navigate).toHaveBeenCalledWith(['/login']);
    });

    it('should not clear session for other errors', async () => {
      const error500 = new HttpErrorResponse({ status: 500, url: '/api/data' });
      const next = () => throwError(() => error500);

      try {
        await TestBed.runInInjectionContext(async () => {
          await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
        });
      } catch {
        // Expected error
      }

      expect(localStorage.getItem('accessToken')).toBe('test-token');
      expect(routerMock.navigate).not.toHaveBeenCalled();
    });

    it('should handle 400 error without redirect', async () => {
      const error400 = new HttpErrorResponse({ status: 400, url: '/api/data' });
      const next = () => throwError(() => error400);

      try {
        await TestBed.runInInjectionContext(async () => {
          await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
        });
      } catch {
        // Expected error
      }

      expect(routerMock.navigate).not.toHaveBeenCalled();
    });

    it('should handle 404 error without redirect', async () => {
      const error404 = new HttpErrorResponse({ status: 404, url: '/api/data' });
      const next = () => throwError(() => error404);

      try {
        await TestBed.runInInjectionContext(async () => {
          await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
        });
      } catch {
        // Expected error
      }

      expect(routerMock.navigate).not.toHaveBeenCalled();
    });
  });

  describe('successful requests', () => {
    it('should pass through successful response', async () => {
      const successResponse = { body: { data: 'test' } } as HttpEvent<unknown>;
      const next = () => of(successResponse);

      let result: HttpEvent<unknown> | undefined;
      await TestBed.runInInjectionContext(async () => {
        result = await firstValueFrom(authInterceptor(createRequest('/api/data'), next));
      });

      expect(result).toBe(successResponse);
    });
  });

  describe('request cloning', () => {
    it('should not modify original request', async () => {
      localStorage.setItem('accessToken', 'test-token');
      const originalRequest = createRequest('/api/data');

      const next = () => of({} as HttpEvent<unknown>);

      await TestBed.runInInjectionContext(async () => {
        await firstValueFrom(authInterceptor(originalRequest, next));
      });

      expect(originalRequest.headers.has('Authorization')).toBe(false);
    });
  });

  describe('different HTTP methods', () => {
    beforeEach(() => {
      localStorage.setItem('accessToken', 'test-token');
    });

    it('should add token to POST requests', async () => {
      const postRequest = new HttpRequest('POST', '/api/data', { data: 'test' });
      let capturedRequest: HttpRequest<unknown> | null = null;

      const next = (req: HttpRequest<unknown>) => {
        capturedRequest = req;
        return of({} as HttpEvent<unknown>);
      };

      await TestBed.runInInjectionContext(async () => {
        await firstValueFrom(authInterceptor(postRequest, next));
      });

      expect(capturedRequest?.headers.get('Authorization')).toBe('Bearer test-token');
    });

    it('should add token to PUT requests', async () => {
      const putRequest = new HttpRequest('PUT', '/api/data', { data: 'test' });
      let capturedRequest: HttpRequest<unknown> | null = null;

      const next = (req: HttpRequest<unknown>) => {
        capturedRequest = req;
        return of({} as HttpEvent<unknown>);
      };

      await TestBed.runInInjectionContext(async () => {
        await firstValueFrom(authInterceptor(putRequest, next));
      });

      expect(capturedRequest?.headers.get('Authorization')).toBe('Bearer test-token');
    });

    it('should add token to DELETE requests', async () => {
      const deleteRequest = new HttpRequest('DELETE', '/api/data/1');
      let capturedRequest: HttpRequest<unknown> | null = null;

      const next = (req: HttpRequest<unknown>) => {
        capturedRequest = req;
        return of({} as HttpEvent<unknown>);
      };

      await TestBed.runInInjectionContext(async () => {
        await firstValueFrom(authInterceptor(deleteRequest, next));
      });

      expect(capturedRequest?.headers.get('Authorization')).toBe('Bearer test-token');
    });
  });
});
