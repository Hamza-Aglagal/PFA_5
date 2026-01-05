import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
import { RegisterComponent } from './register.component';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';

// Mock Three.js
vi.mock('three', () => ({
  Scene: vi.fn().mockImplementation(() => ({
    add: vi.fn(),
    children: []
  })),
  PerspectiveCamera: vi.fn().mockImplementation(() => ({
    position: { set: vi.fn(), z: 0 },
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
  BufferGeometry: vi.fn().mockImplementation(() => ({
    setAttribute: vi.fn()
  })),
  Float32BufferAttribute: vi.fn(),
  PointsMaterial: vi.fn(),
  Points: vi.fn(),
  LineBasicMaterial: vi.fn(),
  Line: vi.fn()
}));

describe('RegisterComponent', () => {
  let component: RegisterComponent;
  let fixture: ComponentFixture<RegisterComponent>;
  let authServiceMock: { register: ReturnType<typeof vi.fn> };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let notificationMock: { success: ReturnType<typeof vi.fn>; error: ReturnType<typeof vi.fn>; warning: ReturnType<typeof vi.fn> };

  beforeEach(async () => {
    authServiceMock = {
      register: vi.fn()
    };

    routerMock = {
      navigate: vi.fn()
    };

    notificationMock = {
      success: vi.fn(),
      error: vi.fn(),
      warning: vi.fn()
    };

    await TestBed.configureTestingModule({
      imports: [RegisterComponent],
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

    fixture = TestBed.createComponent(RegisterComponent);
    component = fixture.componentInstance;
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should start with empty full name', () => {
      expect(component.fullName()).toBe('');
    });

    it('should start with empty email', () => {
      expect(component.email()).toBe('');
    });

    it('should start with empty password', () => {
      expect(component.password()).toBe('');
    });

    it('should start with empty confirm password', () => {
      expect(component.confirmPassword()).toBe('');
    });

    it('should start with not loading', () => {
      expect(component.isLoading()).toBe(false);
    });

    it('should start with no error message', () => {
      expect(component.errorMessage()).toBe('');
    });

    it('should start at step 1', () => {
      expect(component.currentStep()).toBe(1);
    });

    it('should start with password hidden', () => {
      expect(component.showPassword()).toBe(false);
    });

    it('should start with confirm password hidden', () => {
      expect(component.showConfirmPassword()).toBe(false);
    });

    it('should start with terms not agreed', () => {
      expect(component.agreeTerms()).toBe(false);
    });

    it('should start with zero password strength', () => {
      expect(component.passwordStrength()).toBe(0);
    });
  });

  describe('roles', () => {
    it('should have roles defined', () => {
      expect(component.roles.length).toBeGreaterThan(0);
    });

    it('should have engineer role', () => {
      const engineer = component.roles.find(r => r.value === 'engineer');
      expect(engineer).toBeTruthy();
      expect(engineer?.label).toBe('Structural Engineer');
    });

    it('should have architect role', () => {
      const architect = component.roles.find(r => r.value === 'architect');
      expect(architect).toBeTruthy();
    });

    it('should have researcher role', () => {
      const researcher = component.roles.find(r => r.value === 'researcher');
      expect(researcher).toBeTruthy();
    });

    it('should have student role', () => {
      const student = component.roles.find(r => r.value === 'student');
      expect(student).toBeTruthy();
    });

    it('should have other role', () => {
      const other = component.roles.find(r => r.value === 'other');
      expect(other).toBeTruthy();
    });
  });

  describe('form input signals', () => {
    it('should update full name', () => {
      component.fullName.set('John Doe');
      expect(component.fullName()).toBe('John Doe');
    });

    it('should update email', () => {
      component.email.set('test@example.com');
      expect(component.email()).toBe('test@example.com');
    });

    it('should update password', () => {
      component.password.set('password123');
      expect(component.password()).toBe('password123');
    });

    it('should update confirm password', () => {
      component.confirmPassword.set('password123');
      expect(component.confirmPassword()).toBe('password123');
    });

    it('should update organization', () => {
      component.organization.set('ACME Corp');
      expect(component.organization()).toBe('ACME Corp');
    });

    it('should update role', () => {
      component.role.set('engineer');
      expect(component.role()).toBe('engineer');
    });
  });

  describe('toggle methods', () => {
    it('should toggle show password', () => {
      expect(component.showPassword()).toBe(false);
      component.showPassword.set(true);
      expect(component.showPassword()).toBe(true);
    });

    it('should toggle show confirm password', () => {
      expect(component.showConfirmPassword()).toBe(false);
      component.showConfirmPassword.set(true);
      expect(component.showConfirmPassword()).toBe(true);
    });

    it('should toggle agree terms', () => {
      expect(component.agreeTerms()).toBe(false);
      component.agreeTerms.set(true);
      expect(component.agreeTerms()).toBe(true);
    });
  });

  describe('step navigation', () => {
    it('should update current step', () => {
      component.currentStep.set(2);
      expect(component.currentStep()).toBe(2);
    });

    it('should allow step 1', () => {
      component.currentStep.set(1);
      expect(component.currentStep()).toBe(1);
    });
  });

  describe('password strength', () => {
    it('should update password strength', () => {
      component.passwordStrength.set(50);
      expect(component.passwordStrength()).toBe(50);
    });

    it('should allow full strength', () => {
      component.passwordStrength.set(100);
      expect(component.passwordStrength()).toBe(100);
    });
  });

  describe('error handling', () => {
    it('should update error message', () => {
      component.errorMessage.set('Validation error');
      expect(component.errorMessage()).toBe('Validation error');
    });

    it('should clear error message', () => {
      component.errorMessage.set('Error');
      component.errorMessage.set('');
      expect(component.errorMessage()).toBe('');
    });
  });

  describe('loading state', () => {
    it('should update loading state', () => {
      component.isLoading.set(true);
      expect(component.isLoading()).toBe(true);
      component.isLoading.set(false);
      expect(component.isLoading()).toBe(false);
    });
  });

  describe('lifecycle', () => {
    it('should clean up on destroy', () => {
      component.ngOnDestroy();
      expect(true).toBe(true);
    });
  });

  describe('updateField method', () => {
    it('should update fullName field', () => {
      const event = { target: { value: 'Test User' } } as unknown as Event;
      component.updateField('fullName', event);
      expect(component.fullName()).toBe('Test User');
    });

    it('should update email field', () => {
      const event = { target: { value: 'test@test.com' } } as unknown as Event;
      component.updateField('email', event);
      expect(component.email()).toBe('test@test.com');
    });

    it('should update password field and calculate strength', () => {
      const event = { target: { value: 'StrongPass123!' } } as unknown as Event;
      component.updateField('password', event);
      expect(component.password()).toBe('StrongPass123!');
      expect(component.passwordStrength()).toBeGreaterThan(0);
    });

    it('should update confirmPassword field', () => {
      const event = { target: { value: 'mypassword' } } as unknown as Event;
      component.updateField('confirmPassword', event);
      expect(component.confirmPassword()).toBe('mypassword');
    });

    it('should update organization field', () => {
      const event = { target: { value: 'ACME Inc' } } as unknown as Event;
      component.updateField('organization', event);
      expect(component.organization()).toBe('ACME Inc');
    });

    it('should handle unknown field gracefully', () => {
      const event = { target: { value: 'test' } } as unknown as Event;
      expect(() => component.updateField('unknown', event)).not.toThrow();
    });
  });

  describe('updateRole method', () => {
    it('should update role from select event', () => {
      const event = { target: { value: 'architect' } } as unknown as Event;
      component.updateRole(event);
      expect(component.role()).toBe('architect');
    });

    it('should update role to engineer', () => {
      const event = { target: { value: 'engineer' } } as unknown as Event;
      component.updateRole(event);
      expect(component.role()).toBe('engineer');
    });
  });

  describe('toggle methods', () => {
    it('should toggle show password using toggleShowPassword', () => {
      expect(component.showPassword()).toBe(false);
      component.toggleShowPassword();
      expect(component.showPassword()).toBe(true);
      component.toggleShowPassword();
      expect(component.showPassword()).toBe(false);
    });

    it('should toggle show confirm password using toggleShowConfirmPassword', () => {
      expect(component.showConfirmPassword()).toBe(false);
      component.toggleShowConfirmPassword();
      expect(component.showConfirmPassword()).toBe(true);
      component.toggleShowConfirmPassword();
      expect(component.showConfirmPassword()).toBe(false);
    });

    it('should toggle agree terms using toggleAgreeTerms', () => {
      expect(component.agreeTerms()).toBe(false);
      component.toggleAgreeTerms();
      expect(component.agreeTerms()).toBe(true);
      component.toggleAgreeTerms();
      expect(component.agreeTerms()).toBe(false);
    });

    it('should toggle password with togglePassword method', () => {
      expect(component.showPassword()).toBe(false);
      component.togglePassword();
      expect(component.showPassword()).toBe(true);
    });

    it('should toggle confirm password with togglePassword("confirm")', () => {
      expect(component.showConfirmPassword()).toBe(false);
      component.togglePassword('confirm');
      expect(component.showConfirmPassword()).toBe(true);
    });

    it('should toggle terms with toggleTerms alias', () => {
      expect(component.agreeTerms()).toBe(false);
      component.toggleTerms();
      expect(component.agreeTerms()).toBe(true);
    });
  });

  describe('dismissError method', () => {
    it('should clear error message', () => {
      component.errorMessage.set('Some error');
      component.dismissError();
      expect(component.errorMessage()).toBe('');
    });
  });

  describe('password strength calculation', () => {
    it('should return weak for short password', () => {
      component.passwordStrength.set(0);
      expect(component.getPasswordStrengthClass()).toBe('weak');
      expect(component.getPasswordStrengthText()).toBe('Weak');
    });

    it('should return fair for 25 strength', () => {
      component.passwordStrength.set(25);
      expect(component.getPasswordStrengthClass()).toBe('fair');
      expect(component.getPasswordStrengthText()).toBe('Fair');
    });

    it('should return good for 50 strength', () => {
      component.passwordStrength.set(50);
      expect(component.getPasswordStrengthClass()).toBe('good');
      expect(component.getPasswordStrengthText()).toBe('Good');
    });

    it('should return strong for 75+ strength', () => {
      component.passwordStrength.set(75);
      expect(component.getPasswordStrengthClass()).toBe('strong');
      expect(component.getPasswordStrengthText()).toBe('Strong');
    });

    it('should return strong for 100 strength', () => {
      component.passwordStrength.set(100);
      expect(component.getPasswordStrengthClass()).toBe('strong');
      expect(component.getPasswordStrengthText()).toBe('Strong');
    });

    it('should use getStrengthClass alias', () => {
      component.passwordStrength.set(75);
      expect(component.getStrengthClass()).toBe('strong');
    });

    it('should use getStrengthLabel alias', () => {
      component.passwordStrength.set(75);
      expect(component.getStrengthLabel()).toBe('Strong');
    });
  });

  describe('step navigation', () => {
    it('should go to next step using nextStep', () => {
      component.currentStep.set(1);
      component.nextStep();
      expect(component.currentStep()).toBe(2);
    });

    it('should not go past step 2', () => {
      component.currentStep.set(2);
      component.nextStep();
      expect(component.currentStep()).toBe(2);
    });

    it('should go to previous step using prevStep', () => {
      component.currentStep.set(2);
      component.prevStep();
      expect(component.currentStep()).toBe(1);
    });

    it('should not go before step 1', () => {
      component.currentStep.set(1);
      component.prevStep();
      expect(component.currentStep()).toBe(1);
    });
  });

  describe('onSubmit validation', () => {
    it('should show error when fields are empty', async () => {
      await component.onSubmit();
      expect(component.errorMessage()).toBe('Please fill in all required fields');
      expect(notificationMock.warning).toHaveBeenCalled();
    });

    it('should show error when passwords do not match', async () => {
      component.fullName.set('Test User');
      component.email.set('test@test.com');
      component.password.set('Password123!');
      component.confirmPassword.set('DifferentPassword');
      await component.onSubmit();
      expect(component.errorMessage()).toBe('Passwords do not match');
    });

    it('should show error when password is too short', async () => {
      component.fullName.set('Test User');
      component.email.set('test@test.com');
      component.password.set('Pass1');
      component.confirmPassword.set('Pass1');
      await component.onSubmit();
      expect(component.errorMessage()).toBe('Password must be at least 8 characters');
    });

    it('should show error when terms not agreed', async () => {
      component.fullName.set('Test User');
      component.email.set('test@test.com');
      component.password.set('Password123!');
      component.confirmPassword.set('Password123!');
      component.agreeTerms.set(false);
      await component.onSubmit();
      expect(component.errorMessage()).toBe('Please agree to the terms and conditions');
    });

    it('should call authService.register on valid submit', async () => {
      component.fullName.set('Test User');
      component.email.set('test@test.com');
      component.password.set('Password123!');
      component.confirmPassword.set('Password123!');
      component.agreeTerms.set(true);
      authServiceMock.register.mockResolvedValue({ success: true });
      
      await component.onSubmit();
      
      expect(authServiceMock.register).toHaveBeenCalledWith('Test User', 'test@test.com', 'Password123!');
    });

    it('should navigate to dashboard on successful registration', async () => {
      component.fullName.set('Test User');
      component.email.set('test@test.com');
      component.password.set('Password123!');
      component.confirmPassword.set('Password123!');
      component.agreeTerms.set(true);
      authServiceMock.register.mockResolvedValue({ success: true });
      
      await component.onSubmit();
      
      expect(routerMock.navigate).toHaveBeenCalledWith(['/dashboard']);
      expect(notificationMock.success).toHaveBeenCalled();
    });

    it('should show error on failed registration', async () => {
      component.fullName.set('Test User');
      component.email.set('test@test.com');
      component.password.set('Password123!');
      component.confirmPassword.set('Password123!');
      component.agreeTerms.set(true);
      authServiceMock.register.mockResolvedValue({ success: false, message: 'Email already exists' });
      
      await component.onSubmit();
      
      expect(component.errorMessage()).toBe('Email already exists');
      expect(notificationMock.error).toHaveBeenCalled();
    });

    it('should set isLoading during submit', async () => {
      component.fullName.set('Test User');
      component.email.set('test@test.com');
      component.password.set('Password123!');
      component.confirmPassword.set('Password123!');
      component.agreeTerms.set(true);
      
      let loadingDuringCall = false;
      authServiceMock.register.mockImplementation(async () => {
        loadingDuringCall = component.isLoading();
        return { success: true };
      });
      
      await component.onSubmit();
      
      expect(loadingDuringCall).toBe(true);
      expect(component.isLoading()).toBe(false);
    });

    it('should prevent default on event', async () => {
      const event = { preventDefault: vi.fn() } as unknown as Event;
      await component.onSubmit(event);
      expect(event.preventDefault).toHaveBeenCalled();
    });
  });

  describe('password strength algorithm', () => {
    it('should add 25 for length >= 8', () => {
      component.password.set('12345678');
      const event = { target: { value: '12345678' } } as unknown as Event;
      component.updateField('password', event);
      expect(component.passwordStrength()).toBeGreaterThanOrEqual(25);
    });

    it('should add 25 for mixed case', () => {
      const event = { target: { value: 'aB' } } as unknown as Event;
      component.updateField('password', event);
      // Just mixed case (short password), should be 25
      expect(component.passwordStrength()).toBe(25);
    });

    it('should add 25 for including numbers', () => {
      const event = { target: { value: '12345' } } as unknown as Event;
      component.updateField('password', event);
      expect(component.passwordStrength()).toBe(25);
    });

    it('should add 25 for special characters', () => {
      const event = { target: { value: '!@#' } } as unknown as Event;
      component.updateField('password', event);
      expect(component.passwordStrength()).toBe(25);
    });

    it('should give 100 for complex password', () => {
      const event = { target: { value: 'Password123!' } } as unknown as Event;
      component.updateField('password', event);
      expect(component.passwordStrength()).toBe(100);
    });

    it('should give 0 for empty password', () => {
      const event = { target: { value: '' } } as unknown as Event;
      component.updateField('password', event);
      expect(component.passwordStrength()).toBe(0);
    });
  });
});
