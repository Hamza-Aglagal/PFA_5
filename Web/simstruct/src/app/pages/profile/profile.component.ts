import { Component, signal, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';
import { UserService } from '../../core/services/user.service';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';

interface UserProfile {
  name: string; email: string; organization: string; jobTitle: string; phone: string; bio: string; role: string; avatar?: string; joinDate: Date; plan: 'free' | 'pro' | 'enterprise';
}

interface UsageStats {
  simulationsThisMonth: number; simulationsLimit: number; storageUsed: number; storageLimit: number;
}

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.scss'
})
export class ProfileComponent implements OnInit {
  private router = inject(Router);
  private modalService = inject(ModalService);
  private userService = inject(UserService);
  private authService = inject(AuthService);
  private notificationService = inject(NotificationService);
  
  activeTab = signal<'profile' | 'security' | 'notifications' | 'billing'>('profile');
  isEditing = signal(false);
  isSaving = signal(false);
  isLoading = signal(false);
  errorMessage = signal('');
  successMessage = signal('');
  
  showPasswordModal = signal(false);
  currentPassword = signal('');
  newPassword = signal('');
  confirmNewPassword = signal('');
  isChangingPassword = signal(false);
  
  profile = signal<UserProfile>({
    name: '', email: '', organization: '', jobTitle: '',
    phone: '', bio: '', role: 'USER', joinDate: new Date(), plan: 'free'
  });
  
  editedProfile = signal<Partial<UserProfile>>({});
  
  usage = signal<UsageStats>({ simulationsThisMonth: 12, simulationsLimit: 50, storageUsed: 2.5, storageLimit: 5 });
  
  notifications = signal({
    emailSimulationComplete: true, emailWeeklyReport: true, emailProductUpdates: false, pushSimulationComplete: true, pushWarnings: true
  });
  
  securitySettings = signal({ twoFactorEnabled: false, lastPasswordChange: new Date('2024-06-01'), activeSessions: 2 });
  
  tabs = [
    { id: 'profile', label: 'Profile', icon: '' },
    { id: 'security', label: 'Security', icon: '' },
    { id: 'notifications', label: 'Notifications', icon: '' },
    { id: 'billing', label: 'Billing', icon: '' }
  ];
  
  ngOnInit(): void {
    console.log('ProfileComponent: Initializing');
    this.loadProfile();
  }
  
  async loadProfile(): Promise<void> {
    console.log('ProfileComponent: Loading profile from API');
    this.isLoading.set(true);
    
    const result = await this.userService.getProfile();
    
    this.isLoading.set(false);
    
    if (result.success && result.data) {
      console.log('ProfileComponent: Profile loaded', result.data);
      this.profile.update(p => ({
        ...p,
        name: result.data!.name || '',
        email: result.data!.email || '',
        phone: result.data!.phone || '',
        organization: result.data!.company || '',
        jobTitle: result.data!.jobTitle || '',
        bio: result.data!.bio || '',
        role: result.data!.role || 'USER',
        joinDate: result.data!.createdAt ? new Date(result.data!.createdAt) : new Date()
      }));
    } else {
      console.log('ProfileComponent: Failed to load profile, using localStorage');
      const savedUser = localStorage.getItem('user');
      if (savedUser) {
        try {
          const user = JSON.parse(savedUser);
          this.profile.update(p => ({ ...p, name: user.name || '', email: user.email || '' }));
        } catch {}
      }
    }
  }
  
  setActiveTab(tab: 'profile' | 'security' | 'notifications' | 'billing'): void { this.activeTab.set(tab); }
  startEditing(): void { this.editedProfile.set({ ...this.profile() }); this.isEditing.set(true); }
  cancelEditing(): void { this.editedProfile.set({}); this.isEditing.set(false); this.errorMessage.set(''); this.successMessage.set(''); }
  
  async saveProfile(): Promise<void> {
    console.log('ProfileComponent: Saving profile');
    this.isSaving.set(true);
    this.errorMessage.set('');
    this.successMessage.set('');
    
    const edited = this.editedProfile();
    const result = await this.userService.updateProfile({
      name: edited.name,
      phone: edited.phone,
      company: edited.organization,
      jobTitle: edited.jobTitle,
      bio: edited.bio
    });
    
    this.isSaving.set(false);
    
    if (result.success) {
      console.log('ProfileComponent: Profile saved successfully');
      this.profile.update(p => ({ ...p, ...edited }));
      this.isEditing.set(false);
      this.successMessage.set('Profile updated successfully');
      this.notificationService.success('Profile Updated', 'Your profile has been saved successfully');
    } else {
      console.log('ProfileComponent: Failed to save profile -', result.message);
      this.errorMessage.set(result.message || 'Failed to save profile');
      this.notificationService.error('Update Failed', result.message || 'Failed to save profile');
    }
  }
  
  updateEditedField(field: string, event: Event): void { this.editedProfile.update(p => ({ ...p, [field]: (event.target as HTMLInputElement).value })); }
  toggleNotification(key: string): void { this.notifications.update(n => ({ ...n, [key]: !(n as any)[key] })); }
  toggle2FA(): void { this.securitySettings.update(s => ({ ...s, twoFactorEnabled: !s.twoFactorEnabled })); }
  getUsagePercentage(used: number, limit: number): number { return (used / limit) * 100; }
  formatDate(date: Date): string { return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }); }
  getPlanBadgeClass(): string { switch(this.profile().plan) { case 'free': return 'plan-free'; case 'pro': return 'plan-pro'; case 'enterprise': return 'plan-enterprise'; default: return ''; } }
  
  changePassword(): void { this.showPasswordModal.set(true); this.currentPassword.set(''); this.newPassword.set(''); this.confirmNewPassword.set(''); this.errorMessage.set(''); }
  closePasswordModal(): void { this.showPasswordModal.set(false); this.errorMessage.set(''); }
  updatePasswordField(field: 'current' | 'new' | 'confirm', event: Event): void {
    const val = (event.target as HTMLInputElement).value;
    if (field === 'current') this.currentPassword.set(val);
    else if (field === 'new') this.newPassword.set(val);
    else this.confirmNewPassword.set(val);
  }
  
  async submitPasswordChange(): Promise<void> {
    console.log('ProfileComponent: Submitting password change');
    this.errorMessage.set('');
    
    if (!this.currentPassword() || !this.newPassword() || !this.confirmNewPassword()) {
      this.errorMessage.set('Please fill in all fields');
      return;
    }
    if (this.newPassword() !== this.confirmNewPassword()) {
      this.errorMessage.set('New passwords do not match');
      return;
    }
    if (this.newPassword().length < 8) {
      this.errorMessage.set('New password must be at least 8 characters');
      return;
    }
    
    this.isChangingPassword.set(true);
    
    const result = await this.userService.changePassword({
      currentPassword: this.currentPassword(),
      newPassword: this.newPassword()
    });
    
    this.isChangingPassword.set(false);
    
    if (result.success) {
      console.log('ProfileComponent: Password changed successfully');
      this.showPasswordModal.set(false);
      this.securitySettings.update(s => ({ ...s, lastPasswordChange: new Date() }));
      this.successMessage.set('Password changed successfully');
      this.notificationService.success('Password Changed', 'Your password has been updated successfully');
    } else {
      console.log('ProfileComponent: Failed to change password -', result.message);
      this.errorMessage.set(result.message);
      this.notificationService.error('Password Change Failed', result.message);
    }
  }
  
  manageSessions(): void { console.log('Manage sessions - not implemented'); }
  
  async deleteAccount(): Promise<void> {
    console.log('ProfileComponent: Delete account requested');
    
    const confirmed = await this.modalService.confirm({
      title: 'Delete Account',
      message: 'Are you sure you want to delete your account? This action cannot be undone.',
      confirmText: 'Delete Account',
      cancelText: 'Cancel',
      type: 'danger'
    });
    
    if (confirmed) {
      console.log('ProfileComponent: Deleting account...');
      const result = await this.userService.deleteAccount();
      
      if (result.success) {
        console.log('ProfileComponent: Account deleted successfully');
        this.notificationService.success('Account Deleted', 'Your account has been deleted');
        // authService.logout() is called in userService.deleteAccount()
      } else {
        console.log('ProfileComponent: Failed to delete account -', result.message);
        this.errorMessage.set(result.message);
        this.notificationService.error('Delete Failed', result.message);
      }
    }
  }
  
  upgradePlan(): void { console.log('Upgrade plan - not implemented'); }
  addPaymentMethod(): void { console.log('Add payment - not implemented'); }
  downloadInvoice(invoiceId: string): void { console.log('UI Only: Download invoice', invoiceId); }
}
