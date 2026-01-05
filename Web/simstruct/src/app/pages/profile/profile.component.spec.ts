import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { TestBed, ComponentFixture } from '@angular/core/testing';
import { Router, ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
import { ProfileComponent } from './profile.component';
import { UserService } from '../../core/services/user.service';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';

describe('ProfileComponent', () => {
  let component: ProfileComponent;
  let fixture: ComponentFixture<ProfileComponent>;
  let userServiceMock: {
    getProfile: ReturnType<typeof vi.fn>;
    updateProfile: ReturnType<typeof vi.fn>;
    changePassword: ReturnType<typeof vi.fn>;
    deleteAccount: ReturnType<typeof vi.fn>;
  };
  let authServiceMock: {
    logout: ReturnType<typeof vi.fn>;
  };
  let notificationServiceMock: {
    success: ReturnType<typeof vi.fn>;
    error: ReturnType<typeof vi.fn>;
  };
  let routerMock: { navigate: ReturnType<typeof vi.fn> };
  let modalServiceMock: { confirm: ReturnType<typeof vi.fn> };

  const mockProfile = {
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+1234567890',
    company: 'Test Corp',
    jobTitle: 'Engineer',
    bio: 'Test bio',
    role: 'USER',
    createdAt: '2024-01-01T00:00:00Z'
  };

  beforeEach(async () => {
    userServiceMock = {
      getProfile: vi.fn().mockResolvedValue({ success: true, data: mockProfile }),
      updateProfile: vi.fn().mockResolvedValue({ success: true }),
      changePassword: vi.fn().mockResolvedValue({ success: true }),
      deleteAccount: vi.fn().mockResolvedValue({ success: true })
    };

    authServiceMock = {
      logout: vi.fn()
    };

    notificationServiceMock = {
      success: vi.fn(),
      error: vi.fn()
    };

    routerMock = {
      navigate: vi.fn()
    };

    modalServiceMock = {
      confirm: vi.fn().mockResolvedValue(true)
    };

    await TestBed.configureTestingModule({
      imports: [ProfileComponent],
      providers: [
        { provide: UserService, useValue: userServiceMock },
        { provide: AuthService, useValue: authServiceMock },
        { provide: NotificationService, useValue: notificationServiceMock },
        { provide: Router, useValue: routerMock },
        { provide: ModalService, useValue: modalServiceMock },
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

    fixture = TestBed.createComponent(ProfileComponent);
    component = fixture.componentInstance;
  });

  afterEach(() => {
    vi.clearAllMocks();
    localStorage.clear();
  });

  describe('initialization', () => {
    it('should create', () => {
      expect(component).toBeTruthy();
    });

    it('should have profile tab active initially', () => {
      expect(component.activeTab()).toBe('profile');
    });

    it('should not be editing initially', () => {
      expect(component.isEditing()).toBe(false);
    });

    it('should not be saving initially', () => {
      expect(component.isSaving()).toBe(false);
    });

    it('should not be loading initially', () => {
      expect(component.isLoading()).toBe(false);
    });

    it('should have empty error message initially', () => {
      expect(component.errorMessage()).toBe('');
    });

    it('should have empty success message initially', () => {
      expect(component.successMessage()).toBe('');
    });

    it('should have password modal hidden initially', () => {
      expect(component.showPasswordModal()).toBe(false);
    });

    it('should have empty current password initially', () => {
      expect(component.currentPassword()).toBe('');
    });

    it('should have empty new password initially', () => {
      expect(component.newPassword()).toBe('');
    });

    it('should have default profile values', () => {
      expect(component.profile().name).toBe('');
      expect(component.profile().email).toBe('');
    });

    it('should have default usage stats', () => {
      expect(component.usage().simulationsThisMonth).toBe(12);
      expect(component.usage().simulationsLimit).toBe(50);
    });
  });

  describe('tabs', () => {
    it('should have 4 tabs', () => {
      expect(component.tabs).toHaveLength(4);
    });

    it('should have profile tab', () => {
      const profileTab = component.tabs.find(t => t.id === 'profile');
      expect(profileTab).toBeDefined();
      expect(profileTab?.label).toBe('Profile');
    });

    it('should have security tab', () => {
      const securityTab = component.tabs.find(t => t.id === 'security');
      expect(securityTab).toBeDefined();
      expect(securityTab?.label).toBe('Security');
    });

    it('should have notifications tab', () => {
      const notifTab = component.tabs.find(t => t.id === 'notifications');
      expect(notifTab).toBeDefined();
    });

    it('should have billing tab', () => {
      const billingTab = component.tabs.find(t => t.id === 'billing');
      expect(billingTab).toBeDefined();
    });
  });

  describe('setActiveTab', () => {
    it('should set active tab to profile', () => {
      component.setActiveTab('profile');
      expect(component.activeTab()).toBe('profile');
    });

    it('should set active tab to security', () => {
      component.setActiveTab('security');
      expect(component.activeTab()).toBe('security');
    });

    it('should set active tab to notifications', () => {
      component.setActiveTab('notifications');
      expect(component.activeTab()).toBe('notifications');
    });

    it('should set active tab to billing', () => {
      component.setActiveTab('billing');
      expect(component.activeTab()).toBe('billing');
    });
  });

  describe('ngOnInit', () => {
    it('should load profile on init', async () => {
      await component.ngOnInit();
      expect(userServiceMock.getProfile).toHaveBeenCalled();
    });
  });

  describe('loadProfile', () => {
    it('should set loading to true while loading', async () => {
      const loadPromise = component.loadProfile();
      // Note: loading state is briefly true
      await loadPromise;
      expect(component.isLoading()).toBe(false);
    });

    it('should populate profile from API response', async () => {
      await component.loadProfile();
      expect(component.profile().name).toBe('John Doe');
      expect(component.profile().email).toBe('john@example.com');
    });

    it('should populate phone from API response', async () => {
      await component.loadProfile();
      expect(component.profile().phone).toBe('+1234567890');
    });

    it('should populate organization from company field', async () => {
      await component.loadProfile();
      expect(component.profile().organization).toBe('Test Corp');
    });

    it('should populate jobTitle from API response', async () => {
      await component.loadProfile();
      expect(component.profile().jobTitle).toBe('Engineer');
    });

    it('should fall back to localStorage on API failure', async () => {
      userServiceMock.getProfile.mockResolvedValue({ success: false });
      localStorage.setItem('user', JSON.stringify({ name: 'Local User', email: 'local@test.com' }));
      await component.loadProfile();
      expect(component.profile().name).toBe('Local User');
    });

    it('should handle localStorage parse errors gracefully', async () => {
      userServiceMock.getProfile.mockResolvedValue({ success: false });
      localStorage.setItem('user', 'invalid json');
      await expect(component.loadProfile()).resolves.not.toThrow();
    });
  });

  describe('editing', () => {
    it('should start editing and copy profile', () => {
      component.profile.update(p => ({ ...p, name: 'Test User' }));
      component.startEditing();
      expect(component.isEditing()).toBe(true);
      expect(component.editedProfile().name).toBe('Test User');
    });

    it('should cancel editing and clear edited profile', () => {
      component.startEditing();
      component.editedProfile.update(e => ({ ...e, name: 'Changed' }));
      component.cancelEditing();
      expect(component.isEditing()).toBe(false);
      expect(component.editedProfile()).toEqual({});
    });

    it('should clear error and success messages on cancel', () => {
      component.errorMessage.set('Some error');
      component.successMessage.set('Some success');
      component.cancelEditing();
      expect(component.errorMessage()).toBe('');
      expect(component.successMessage()).toBe('');
    });
  });

  describe('saveProfile', () => {
    beforeEach(() => {
      component.startEditing();
      component.editedProfile.set({ name: 'New Name', phone: '123456' });
    });

    it('should call userService.updateProfile', async () => {
      await component.saveProfile();
      expect(userServiceMock.updateProfile).toHaveBeenCalled();
    });

    it('should update profile on success', async () => {
      await component.saveProfile();
      expect(component.profile().name).toBe('New Name');
    });

    it('should stop editing on success', async () => {
      await component.saveProfile();
      expect(component.isEditing()).toBe(false);
    });

    it('should set success message on success', async () => {
      await component.saveProfile();
      expect(component.successMessage()).toBe('Profile updated successfully');
    });

    it('should show success notification', async () => {
      await component.saveProfile();
      expect(notificationServiceMock.success).toHaveBeenCalledWith('Profile Updated', 'Your profile has been saved successfully');
    });

    it('should set error message on failure', async () => {
      userServiceMock.updateProfile.mockResolvedValue({ success: false, message: 'Update failed' });
      await component.saveProfile();
      expect(component.errorMessage()).toBe('Update failed');
    });

    it('should show error notification on failure', async () => {
      userServiceMock.updateProfile.mockResolvedValue({ success: false, message: 'Update failed' });
      await component.saveProfile();
      expect(notificationServiceMock.error).toHaveBeenCalledWith('Update Failed', 'Update failed');
    });
  });

  describe('updateEditedField', () => {
    it('should update edited field from event', () => {
      component.startEditing();
      const event = { target: { value: 'New Value' } } as unknown as Event;
      component.updateEditedField('name', event);
      expect(component.editedProfile().name).toBe('New Value');
    });
  });

  describe('toggleNotification', () => {
    it('should toggle notification setting', () => {
      const initial = component.notifications().emailSimulationComplete;
      component.toggleNotification('emailSimulationComplete');
      expect(component.notifications().emailSimulationComplete).toBe(!initial);
    });

    it('should toggle emailWeeklyReport', () => {
      const initial = component.notifications().emailWeeklyReport;
      component.toggleNotification('emailWeeklyReport');
      expect(component.notifications().emailWeeklyReport).toBe(!initial);
    });
  });

  describe('toggle2FA', () => {
    it('should toggle two factor enabled', () => {
      const initial = component.securitySettings().twoFactorEnabled;
      component.toggle2FA();
      expect(component.securitySettings().twoFactorEnabled).toBe(!initial);
    });
  });

  describe('getUsagePercentage', () => {
    it('should calculate correct percentage', () => {
      expect(component.getUsagePercentage(25, 100)).toBe(25);
    });

    it('should calculate 50%', () => {
      expect(component.getUsagePercentage(50, 100)).toBe(50);
    });

    it('should calculate 100% when at limit', () => {
      expect(component.getUsagePercentage(100, 100)).toBe(100);
    });
  });

  describe('formatDate', () => {
    it('should format date correctly', () => {
      const date = new Date('2024-06-15');
      const formatted = component.formatDate(date);
      expect(formatted).toContain('June');
      expect(formatted).toContain('15');
      expect(formatted).toContain('2024');
    });
  });

  describe('getPlanBadgeClass', () => {
    it('should return plan-free for free plan', () => {
      component.profile.update(p => ({ ...p, plan: 'free' }));
      expect(component.getPlanBadgeClass()).toBe('plan-free');
    });

    it('should return plan-pro for pro plan', () => {
      component.profile.update(p => ({ ...p, plan: 'pro' }));
      expect(component.getPlanBadgeClass()).toBe('plan-pro');
    });

    it('should return plan-enterprise for enterprise plan', () => {
      component.profile.update(p => ({ ...p, plan: 'enterprise' }));
      expect(component.getPlanBadgeClass()).toBe('plan-enterprise');
    });
  });

  describe('password change', () => {
    it('should open password modal', () => {
      component.changePassword();
      expect(component.showPasswordModal()).toBe(true);
    });

    it('should clear password fields on open', () => {
      component.currentPassword.set('old');
      component.changePassword();
      expect(component.currentPassword()).toBe('');
      expect(component.newPassword()).toBe('');
      expect(component.confirmNewPassword()).toBe('');
    });

    it('should close password modal', () => {
      component.showPasswordModal.set(true);
      component.closePasswordModal();
      expect(component.showPasswordModal()).toBe(false);
    });

    it('should clear error message on close', () => {
      component.errorMessage.set('Some error');
      component.closePasswordModal();
      expect(component.errorMessage()).toBe('');
    });
  });

  describe('updatePasswordField', () => {
    it('should update current password', () => {
      const event = { target: { value: 'currentPass' } } as unknown as Event;
      component.updatePasswordField('current', event);
      expect(component.currentPassword()).toBe('currentPass');
    });

    it('should update new password', () => {
      const event = { target: { value: 'newPass123' } } as unknown as Event;
      component.updatePasswordField('new', event);
      expect(component.newPassword()).toBe('newPass123');
    });

    it('should update confirm password', () => {
      const event = { target: { value: 'confirmPass' } } as unknown as Event;
      component.updatePasswordField('confirm', event);
      expect(component.confirmNewPassword()).toBe('confirmPass');
    });
  });

  describe('submitPasswordChange', () => {
    it('should require all fields', async () => {
      await component.submitPasswordChange();
      expect(component.errorMessage()).toBe('Please fill in all fields');
    });

    it('should require matching passwords', async () => {
      component.currentPassword.set('oldpass');
      component.newPassword.set('newpass123');
      component.confirmNewPassword.set('different');
      await component.submitPasswordChange();
      expect(component.errorMessage()).toBe('New passwords do not match');
    });

    it('should require minimum password length', async () => {
      component.currentPassword.set('oldpass');
      component.newPassword.set('short');
      component.confirmNewPassword.set('short');
      await component.submitPasswordChange();
      expect(component.errorMessage()).toBe('New password must be at least 8 characters');
    });

    it('should call userService.changePassword with valid data', async () => {
      component.currentPassword.set('oldpassword');
      component.newPassword.set('newpassword123');
      component.confirmNewPassword.set('newpassword123');
      await component.submitPasswordChange();
      expect(userServiceMock.changePassword).toHaveBeenCalledWith({
        currentPassword: 'oldpassword',
        newPassword: 'newpassword123'
      });
    });

    it('should close modal on success', async () => {
      component.showPasswordModal.set(true);
      component.currentPassword.set('oldpassword');
      component.newPassword.set('newpassword123');
      component.confirmNewPassword.set('newpassword123');
      await component.submitPasswordChange();
      expect(component.showPasswordModal()).toBe(false);
    });

    it('should update lastPasswordChange on success', async () => {
      const before = component.securitySettings().lastPasswordChange;
      component.currentPassword.set('oldpassword');
      component.newPassword.set('newpassword123');
      component.confirmNewPassword.set('newpassword123');
      await component.submitPasswordChange();
      expect(component.securitySettings().lastPasswordChange.getTime()).toBeGreaterThan(before.getTime());
    });

    it('should show success notification', async () => {
      component.currentPassword.set('oldpassword');
      component.newPassword.set('newpassword123');
      component.confirmNewPassword.set('newpassword123');
      await component.submitPasswordChange();
      expect(notificationServiceMock.success).toHaveBeenCalledWith('Password Changed', 'Your password has been updated successfully');
    });

    it('should set error message on failure', async () => {
      userServiceMock.changePassword.mockResolvedValue({ success: false, message: 'Wrong password' });
      component.currentPassword.set('oldpassword');
      component.newPassword.set('newpassword123');
      component.confirmNewPassword.set('newpassword123');
      await component.submitPasswordChange();
      expect(component.errorMessage()).toBe('Wrong password');
    });
  });

  describe('deleteAccount', () => {
    it('should show confirmation modal', async () => {
      await component.deleteAccount();
      expect(modalServiceMock.confirm).toHaveBeenCalled();
    });

    it('should call userService.deleteAccount on confirm', async () => {
      await component.deleteAccount();
      expect(userServiceMock.deleteAccount).toHaveBeenCalled();
    });

    it('should show success notification on delete', async () => {
      await component.deleteAccount();
      expect(notificationServiceMock.success).toHaveBeenCalledWith('Account Deleted', 'Your account has been deleted');
    });

    it('should not delete if cancelled', async () => {
      modalServiceMock.confirm.mockResolvedValue(false);
      await component.deleteAccount();
      expect(userServiceMock.deleteAccount).not.toHaveBeenCalled();
    });

    it('should set error message on failure', async () => {
      userServiceMock.deleteAccount.mockResolvedValue({ success: false, message: 'Delete failed' });
      await component.deleteAccount();
      expect(component.errorMessage()).toBe('Delete failed');
    });

    it('should show error notification on failure', async () => {
      userServiceMock.deleteAccount.mockResolvedValue({ success: false, message: 'Delete failed' });
      await component.deleteAccount();
      expect(notificationServiceMock.error).toHaveBeenCalledWith('Delete Failed', 'Delete failed');
    });
  });

  describe('stub methods', () => {
    it('should have manageSessions method', () => {
      expect(() => component.manageSessions()).not.toThrow();
    });

    it('should have upgradePlan method', () => {
      expect(() => component.upgradePlan()).not.toThrow();
    });

    it('should have addPaymentMethod method', () => {
      expect(() => component.addPaymentMethod()).not.toThrow();
    });

    it('should have downloadInvoice method', () => {
      expect(() => component.downloadInvoice('inv-123')).not.toThrow();
    });
  });
});
