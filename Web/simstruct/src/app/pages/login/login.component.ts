import { Component, signal, ElementRef, ViewChild, AfterViewInit, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import * as THREE from 'three';
import { AuthService } from '../../core/services/auth.service';
import { NotificationService } from '../../core/services/notification.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent implements AfterViewInit, OnDestroy {
  @ViewChild('bgCanvas', { static: false }) bgCanvasRef!: ElementRef<HTMLCanvasElement>;
  
  private router = inject(Router);
  private authService = inject(AuthService);
  private notificationService = inject(NotificationService);
  
  private scene!: THREE.Scene;
  private camera!: THREE.PerspectiveCamera;
  private renderer!: THREE.WebGLRenderer;
  private animationId: number = 0;
  private gridHelper!: THREE.GridHelper;
  
  email = signal('');
  password = signal('');
  rememberMe = signal(false);
  showPassword = signal(false);
  isLoading = signal(false);
  errorMessage = signal('');
  
  ngAfterViewInit(): void { setTimeout(() => this.initThreeJS(), 100); }
  
  ngOnDestroy(): void {
    if (this.animationId) cancelAnimationFrame(this.animationId);
    if (this.renderer) this.renderer.dispose();
  }
  
  private initThreeJS(): void {
    if (!this.bgCanvasRef?.nativeElement) return;
    const canvas = this.bgCanvasRef.nativeElement;
    
    this.scene = new THREE.Scene();
    this.scene.fog = new THREE.FogExp2(0x0f172a, 0.02);
    
    const width = window.innerWidth;
    const height = window.innerHeight;
    
    this.camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
    this.camera.position.set(0, 15, 30);
    this.camera.lookAt(0, 0, 0);
    
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    
    this.createGrid();
    this.createFloatingStructures();
    this.animate();
    
    window.addEventListener('resize', () => this.onWindowResize());
  }
  
  private createGrid(): void {
    this.gridHelper = new THREE.GridHelper(100, 50, 0x3b82f6, 0x1e3a5f);
    this.gridHelper.position.y = -5;
    this.scene.add(this.gridHelper);
  }
  
  private createFloatingStructures(): void {
    // Visual effect only - NOSONAR: Math.random used for non-security visual randomness
    for (let i = 0; i < 8; i++) {
      const group = new THREE.Group();
      const buildingGeometry = new THREE.BoxGeometry(Math.random() * 3 + 2, Math.random() * 8 + 4, Math.random() * 3 + 2); // NOSONAR - visual effect only
      const edges = new THREE.EdgesGeometry(buildingGeometry);
      const material = new THREE.LineBasicMaterial({ color: 0x3b82f6, transparent: true, opacity: 0.3 + Math.random() * 0.3 }); // NOSONAR - visual effect only
      const wireframe = new THREE.LineSegments(edges, material);
      group.add(wireframe);
      group.position.set((Math.random() - 0.5) * 60, Math.random() * 10, (Math.random() - 0.5) * 40); // NOSONAR - visual effect only
      group.userData = { floatSpeed: Math.random() * 0.5 + 0.5, floatOffset: Math.random() * Math.PI * 2, rotationSpeed: (Math.random() - 0.5) * 0.005 }; // NOSONAR - visual effect only
      this.scene.add(group);
    }
  }
  
  private animate(): void {
    this.animationId = requestAnimationFrame(() => this.animate());
    const time = Date.now() * 0.001;
    this.scene.children.forEach(child => {
      if (child.userData && child.userData['floatSpeed']) {
        child.position.y = Math.sin(time * child.userData['floatSpeed'] + child.userData['floatOffset']) * 2 + 5;
        child.rotation.y += child.userData['rotationSpeed'];
      }
    });
    this.camera.position.x = Math.sin(time * 0.1) * 5;
    this.renderer.render(this.scene, this.camera);
  }
  
  private onWindowResize(): void {
    const width = window.innerWidth;
    const height = window.innerHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }
  
  updateEmail(event: Event): void { this.email.set((event.target as HTMLInputElement).value); }
  updatePassword(event: Event): void { this.password.set((event.target as HTMLInputElement).value); }
  toggleShowPassword(): void { this.showPassword.update(v => !v); }
  togglePassword(): void { this.showPassword.update(v => !v); }
  toggleRememberMe(): void { this.rememberMe.update(v => !v); }
  dismissError(): void { this.errorMessage.set(''); }
  
  async onSubmit(event?: Event): Promise<void> {
    if (event) event.preventDefault();
    
    console.log('LoginComponent: Submit clicked');
    
    // Validate
    if (!this.email() || !this.password()) {
      this.errorMessage.set('Please fill in all fields');
      this.notificationService.warning('Validation Error', 'Please fill in all fields');
      console.log('LoginComponent: Validation failed - empty fields');
      return;
    }
    
    this.isLoading.set(true);
    this.errorMessage.set('');
    
    console.log('LoginComponent: Calling authService.login');
    
    // Call auth service
    const result = await this.authService.login(this.email(), this.password());
    
    this.isLoading.set(false);
    
    if (result.success) {
      console.log('LoginComponent: Login successful, redirecting...');
      
      // Show success notification
      this.notificationService.success('Welcome back!', 'Login successful');
      
      // Check for redirect URL
      const redirectUrl = localStorage.getItem('redirectUrl');
      if (redirectUrl) {
        localStorage.removeItem('redirectUrl');
        this.router.navigateByUrl(redirectUrl);
      } else {
        this.router.navigate(['/dashboard']);
      }
    } else {
      console.log('LoginComponent: Login failed -', result.message);
      this.errorMessage.set(result.message);
      this.notificationService.error('Login Failed', result.message);
    }
  }
}
