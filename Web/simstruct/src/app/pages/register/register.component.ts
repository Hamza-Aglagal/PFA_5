import { Component, signal, ElementRef, ViewChild, AfterViewInit, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import * as THREE from 'three';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss'
})
export class RegisterComponent implements AfterViewInit, OnDestroy {
  @ViewChild('bgCanvas', { static: false }) bgCanvasRef!: ElementRef<HTMLCanvasElement>;
  
  private router = inject(Router);
  private authService = inject(AuthService);
  private notificationService = inject(NotificationService);
  
  private scene!: THREE.Scene;
  private camera!: THREE.PerspectiveCamera;
  private renderer!: THREE.WebGLRenderer;
  private animationId: number = 0;
  
  fullName = signal('');
  email = signal('');
  password = signal('');
  confirmPassword = signal('');
  organization = signal('');
  role = signal('');
  agreeTerms = signal(false);
  showPassword = signal(false);
  showConfirmPassword = signal(false);
  
  isLoading = signal(false);
  errorMessage = signal('');
  currentStep = signal(1);
  passwordStrength = signal(0);
  
  roles = [
    { value: 'engineer', label: 'Structural Engineer' },
    { value: 'architect', label: 'Architect' },
    { value: 'researcher', label: 'Researcher' },
    { value: 'student', label: 'Student' },
    { value: 'other', label: 'Other' }
  ];
  
  ngAfterViewInit(): void { setTimeout(() => this.initThreeJS(), 100); }
  
  ngOnDestroy(): void {
    if (this.animationId) cancelAnimationFrame(this.animationId);
    if (this.renderer) this.renderer.dispose();
  }
  
  private initThreeJS(): void {
    if (!this.bgCanvasRef?.nativeElement) return;
    const canvas = this.bgCanvasRef.nativeElement;
    
    this.scene = new THREE.Scene();
    
    const width = window.innerWidth;
    const height = window.innerHeight;
    
    this.camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
    this.camera.position.z = 50;
    
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    
    this.createParticleNetwork();
    this.animate();
    
    window.addEventListener('resize', () => this.onWindowResize());
  }
  
  private createParticleNetwork(): void {
    // Visual effect only - NOSONAR: Math.random used for non-security visual randomness
    const particleCount = 200;
    const positions = new Float32Array(particleCount * 3);
    const colors = new Float32Array(particleCount * 3);
    
    for (let i = 0; i < particleCount * 3; i += 3) {
      positions[i] = (Math.random() - 0.5) * 100; // NOSONAR - visual effect only
      positions[i + 1] = (Math.random() - 0.5) * 100; // NOSONAR - visual effect only
      positions[i + 2] = (Math.random() - 0.5) * 50; // NOSONAR - visual effect only
      colors[i] = 0.2 + Math.random() * 0.2; // NOSONAR - visual effect only
      colors[i + 1] = 0.4 + Math.random() * 0.3; // NOSONAR - visual effect only
      colors[i + 2] = 0.9 + Math.random() * 0.1; // NOSONAR - visual effect only
    }
    
    const geometry = new THREE.BufferGeometry();
    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
    
    const material = new THREE.PointsMaterial({ size: 2, vertexColors: true, transparent: true, opacity: 0.6, blending: THREE.AdditiveBlending });
    const particles = new THREE.Points(geometry, material);
    this.scene.add(particles);
    (this.scene as any).particles = particles;
  }
  
  private animate(): void {
    this.animationId = requestAnimationFrame(() => this.animate());
    const particles = (this.scene as any).particles;
    if (particles) particles.rotation.y += 0.001;
    this.renderer.render(this.scene, this.camera);
  }
  
  private onWindowResize(): void {
    const width = window.innerWidth;
    const height = window.innerHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }
  
  updateField(field: string, event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    switch(field) {
      case 'fullName': this.fullName.set(value); break;
      case 'email': this.email.set(value); break;
      case 'password': this.password.set(value); this.calculatePasswordStrength(value); break;
      case 'confirmPassword': this.confirmPassword.set(value); break;
      case 'organization': this.organization.set(value); break;
    }
  }
  
  updateRole(event: Event): void { this.role.set((event.target as HTMLSelectElement).value); }
  toggleShowPassword(): void { this.showPassword.update(v => !v); }
  toggleShowConfirmPassword(): void { this.showConfirmPassword.update(v => !v); }
  toggleAgreeTerms(): void { this.agreeTerms.update(v => !v); }
  togglePassword(field?: string): void { 
    if (field === 'confirm') { this.showConfirmPassword.update(v => !v); }
    else { this.showPassword.update(v => !v); }
  }
  toggleTerms(): void { this.agreeTerms.update(v => !v); } // Alias for template
  dismissError(): void { this.errorMessage.set(''); } // For template
  
  private calculatePasswordStrength(password: string): void {
    let strength = 0;
    if (password.length >= 8) strength += 25;
    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength += 25;
    if (/[0-9]/.test(password)) strength += 25;
    if (/[^a-zA-Z0-9]/.test(password)) strength += 25;
    this.passwordStrength.set(strength);
  }
  
  getPasswordStrengthClass(): string {
    const strength = this.passwordStrength();
    if (strength < 25) return 'weak';
    if (strength < 50) return 'fair';
    if (strength < 75) return 'good';
    return 'strong';
  }
  
  getPasswordStrengthText(): string {
    const strength = this.passwordStrength();
    if (strength < 25) return 'Weak';
    if (strength < 50) return 'Fair';
    if (strength < 75) return 'Good';
    return 'Strong';
  }
  
  getStrengthClass(): string { return this.getPasswordStrengthClass(); } // Alias for template
  getStrengthLabel(): string { return this.getPasswordStrengthText(); } // Alias for template
  
  nextStep(): void { if (this.currentStep() < 2) this.currentStep.update(s => s + 1); }
  prevStep(): void { if (this.currentStep() > 1) this.currentStep.update(s => s - 1); }
  
  async onSubmit(event?: Event): Promise<void> {
    if (event) event.preventDefault();
    
    console.log('RegisterComponent: Submit clicked');
    this.errorMessage.set('');
    
    // Validate
    if (!this.fullName() || !this.email() || !this.password()) {
      this.errorMessage.set('Please fill in all required fields');
      this.notificationService.warning('Validation Error', 'Please fill in all required fields');
      console.log('RegisterComponent: Validation failed - empty fields');
      return;
    }
    if (this.password() !== this.confirmPassword()) {
      this.errorMessage.set('Passwords do not match');
      this.notificationService.warning('Validation Error', 'Passwords do not match');
      console.log('RegisterComponent: Validation failed - passwords dont match');
      return;
    }
    if (this.password().length < 8) {
      this.errorMessage.set('Password must be at least 8 characters');
      this.notificationService.warning('Validation Error', 'Password must be at least 8 characters');
      console.log('RegisterComponent: Validation failed - password too short');
      return;
    }
    if (!this.agreeTerms()) {
      this.errorMessage.set('Please agree to the terms and conditions');
      this.notificationService.warning('Validation Error', 'Please agree to the terms and conditions');
      console.log('RegisterComponent: Validation failed - terms not accepted');
      return;
    }
    
    this.isLoading.set(true);
    
    console.log('RegisterComponent: Calling authService.register');
    
    // Call auth service
    const result = await this.authService.register(this.fullName(), this.email(), this.password());
    
    this.isLoading.set(false);
    
    if (result.success) {
      console.log('RegisterComponent: Registration successful, redirecting...');
      
      // Show success notification
      this.notificationService.success('Welcome!', 'Account created successfully');
      
      this.router.navigate(['/dashboard']);
    } else {
      console.log('RegisterComponent: Registration failed -', result.message);
      this.errorMessage.set(result.message);
      this.notificationService.error('Registration Failed', result.message);
    }
  }
}
