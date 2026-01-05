import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
import { LoginComponent } from './login.component';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';

// Mock Three.js
vi.mock('three', () => ({
  Scene: vi.fn().mockImplementation(() => ({
    add: vi.fn(),
    children: [],
    fog: null
  })),
  PerspectiveCamera: vi.fn().mockImplementation(() => ({
    position: { set: vi.fn(), x: 0 },
    lookAt: vi.fn(),
    aspect: 1,
    updateProjectionMatrix: vi.fn()
  })),
  WebGLRenderer: vi.fn().mockImplementation(() => ({
    setSize: vi.fn(),
    setPixelRatio: vi.fn(),
    render: vi.fn(),
    dispose: vi.fn()
  })),
  GridHelper: vi.fn().mockImplementation(() => ({
    position: { y: 0 }
  })),
  Group: vi.fn().mockImplementation(() => ({
    add: vi.fn(),
    position: { set: vi.fn(), y: 0 },
    rotation: { y: 0 },
    userData: {}
  })),
  BoxGeometry: vi.fn(),
  EdgesGeometry: vi.fn(),
  LineBasicMaterial: vi.fn(),
  LineSegments: vi.fn(),
  FogExp2: vi.fn()
}));

describe('LoginComponent', () => {
  let component: LoginComponent;
  let fixture: ComponentFixture<LoginComponent>;
  let authServiceMock: { login: ReturnType<typeof vi.fn> };
  let routerMock: { navigate: ReturnType<typeof vi.fn>; navigateByUrl: ReturnType<typeof vi.fn> };
  let notificationMock: { success: ReturnType<typeof vi.fn>; error: ReturnType<typeof vi.fn>; warning: ReturnType<typeof vi.fn> };

  beforeEach(async () => {
    authServiceMock = {
      login: vi.fn()
    };

    routerMock = {
      navigate: vi.fn(),
      navigateByUrl: vi.fn()
    };

    notificationMock = {
      success: vi.fn(),
      error: vi.fn(),
      warning: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [LoginComponent],
      providers: [
        { provide: AuthService, useValue: authServiceMock },
        { provide: Router, useValue: routerMock },
        { provide: NotificationService, useValue: notificationMock },
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

    fixture = TestBed.createComponent(LoginComponent);
    component = fixture.componentInstance;
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should start with empty email', () => {
      expect(component.email()).toBe('');
    });

    it('should start with empty password', () => {
      expect(component.password()).toBe('');
    });

    it('should start with password hidden', () => {
      expect(component.showPassword()).toBe(false);
    });

    it('should start with no error message', () => {
      expect(component.errorMessage()).toBe('');
    });

    it('should start with not loading', () => {
      expect(component.isLoading()).toBe(false);
    });

    it('should start with rememberMe as false', () => {
      expect(component.rememberMe()).toBe(false);
    });
  });

  describe('form input methods', () => {
    it('should update email', () => {
      const event = { target: { value: 'test@example.com' } } as unknown as Event;
      component.updateEmail(event);
      expect(component.email()).toBe('test@example.com');
    });

    it('should update password', () => {
      const event = { target: { value: 'password123' } } as unknown as Event;
      component.updatePassword(event);
      expect(component.password()).toBe('password123');
    });

    it('should toggle show password', () => {
      expect(component.showPassword()).toBe(false);
      component.toggleShowPassword();
      expect(component.showPassword()).toBe(true);
      component.toggleShowPassword();
      expect(component.showPassword()).toBe(false);
    });

    it('should toggle remember me', () => {
      expect(component.rememberMe()).toBe(false);
      component.toggleRememberMe();
      expect(component.rememberMe()).toBe(true);
    });

    it('should dismiss error message', () => {
      component.errorMessage.set('Some error');
      component.dismissError();
      expect(component.errorMessage()).toBe('');
    });
  });

  describe('onSubmit', () => {
    it('should show validation error for empty fields', async () => {
      await component.onSubmit();

      expect(component.errorMessage()).toBe('Please fill in all fields');
      expect(notificationMock.warning).toHaveBeenCalled();
    });

    it('should not call login with empty email', async () => {
      component.password.set('password123');
      await component.onSubmit();

      expect(authServiceMock.login).not.toHaveBeenCalled();
    });

    it('should not call login with empty password', async () => {
      component.email.set('test@example.com');
      await component.onSubmit();

      expect(authServiceMock.login).not.toHaveBeenCalled();
    });

    it('should call authService.login with credentials', async () => {
      component.email.set('test@example.com');
      component.password.set('password123');
      authServiceMock.login.mockResolvedValue({ success: true, message: 'Success' });

      await component.onSubmit();

      expect(authServiceMock.login).toHaveBeenCalledWith('test@example.com', 'password123');
    });

    it('should set loading state during login', async () => {
      component.email.set('test@example.com');
      component.password.set('password123');
      
      let loadingDuringCall = false;
      authServiceMock.login.mockImplementation(async () => {
        loadingDuringCall = component.isLoading();
        return { success: true, message: 'Success' };
      });

      await component.onSubmit();

      expect(loadingDuringCall).toBe(true);
      expect(component.isLoading()).toBe(false);
    });

    it('should navigate to dashboard on successful login', async () => {
      component.email.set('test@example.com');
      component.password.set('password123');
      authServiceMock.login.mockResolvedValue({ success: true, message: 'Success' });
      localStorage.removeItem('redirectUrl');

      await component.onSubmit();

      expect(routerMock.navigate).toHaveBeenCalledWith(['/dashboard']);
    });

    it('should navigate to redirect URL if set', async () => {
      component.email.set('test@example.com');
      component.password.set('password123');
      authServiceMock.login.mockResolvedValue({ success: true, message: 'Success' });
      localStorage.setItem('redirectUrl', '/simulation');

      await component.onSubmit();

      expect(routerMock.navigateByUrl).toHaveBeenCalledWith('/simulation');
      expect(localStorage.getItem('redirectUrl')).toBeNull();
    });

    it('should show success notification on login', async () => {
      component.email.set('test@example.com');
      component.password.set('password123');
      authServiceMock.login.mockResolvedValue({ success: true, message: 'Success' });

      await component.onSubmit();

      expect(notificationMock.success).toHaveBeenCalledWith('Welcome back!', 'Login successful');
    });

    it('should show error message on failed login', async () => {
      component.email.set('test@example.com');
      component.password.set('wrong-password');
      authServiceMock.login.mockResolvedValue({ success: false, message: 'Invalid credentials' });

      await component.onSubmit();

      expect(component.errorMessage()).toBe('Invalid credentials');
      expect(notificationMock.error).toHaveBeenCalled();
    });

    it('should prevent default event', async () => {
      const event = { preventDefault: vi.fn() } as unknown as Event;
      component.email.set('test@example.com');
      component.password.set('password123');
      authServiceMock.login.mockResolvedValue({ success: true, message: 'Success' });

      await component.onSubmit(event);

      expect(event.preventDefault).toHaveBeenCalled();
    });
  });

  describe('togglePassword alias', () => {
    it('should toggle password visibility', () => {
      expect(component.showPassword()).toBe(false);
      component.togglePassword();
      expect(component.showPassword()).toBe(true);
    });
  });

  describe('lifecycle', () => {
    it('should clean up on destroy', () => {
      component.ngOnDestroy();
      // Should not throw
      expect(true).toBe(true);
    });
  });
});
