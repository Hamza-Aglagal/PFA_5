import { Component, signal, computed, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import * as THREE from 'three';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';

interface Simulation {
  id: string; name: string; type: string; status: 'completed' | 'running' | 'failed' | 'pending'; date: Date; safetyFactor: number; thumbnail?: string;
}

interface StatCard {
  title: string; value: string | number; change: number; icon: string; color: string;
}

interface Notification {
  id: string; type: 'success' | 'info' | 'warning' | 'error'; message: string; time: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('statsCanvas', { static: false }) statsCanvasRef!: ElementRef<HTMLCanvasElement>;
  
  private router = inject(Router);
  private modalService = inject(ModalService);
  
  private scene!: THREE.Scene;
  private camera!: THREE.PerspectiveCamera;
  private renderer!: THREE.WebGLRenderer;
  private animationId: number = 0;
  private particles!: THREE.Points;
  
  userName = signal('Engineer');
  greeting = signal('');
  isLoading = signal(false);
  
  stats = signal<StatCard[]>([
    { title: 'Total Simulations', value: 12, change: 3, icon: '', color: 'primary' },
    { title: 'Safe Structures', value: 10, change: 2, icon: '', color: 'success' },
    { title: 'Warnings', value: 2, change: 0, icon: '', color: 'warning' },
    { title: 'Favorites', value: 5, change: 1, icon: '', color: 'accent' }
  ]);
  
  recentSimulations = signal<Simulation[]>([
    { id: '1', name: 'Steel Beam Analysis', type: 'Beam', status: 'completed', date: new Date(), safetyFactor: 2.5 },
    { id: '2', name: 'Concrete Frame', type: 'Frame', status: 'completed', date: new Date(Date.now() - 86400000), safetyFactor: 1.8 },
    { id: '3', name: 'Truss Bridge', type: 'Truss', status: 'completed', date: new Date(Date.now() - 2*86400000), safetyFactor: 2.1 },
    { id: '4', name: 'Column Test', type: 'Column', status: 'pending', date: new Date(Date.now() - 3*86400000), safetyFactor: 0 }
  ]);
  
  quickActions = [
    { icon: '', label: 'New Simulation', route: '/simulation', color: 'primary' },
    { icon: '', label: 'Import Model', route: '/simulation', color: 'secondary' },
    { icon: '', label: 'View History', route: '/history', color: 'tertiary' },
    { icon: '', label: 'Export Report', route: '/results', color: 'accent' }
  ];
  
  notifications = signal<Notification[]>([
    { id: '1', type: 'success', message: 'Simulation completed successfully', time: '2m ago' },
    { id: '2', type: 'info', message: 'New community post available', time: '1h ago' },
    { id: '3', type: 'warning', message: 'Low safety factor detected', time: '3h ago' }
  ]);
  
  ngOnInit(): void {
    this.setGreeting();
    this.loadUserName();
  }
  
  ngAfterViewInit(): void {
    setTimeout(() => this.initThreeJS(), 100);
  }
  
  ngOnDestroy(): void {
    if (this.animationId) cancelAnimationFrame(this.animationId);
    if (this.renderer) this.renderer.dispose();
  }
  
  private loadUserName(): void {
    const savedUser = localStorage.getItem('user');
    if (savedUser) {
      try {
        const user = JSON.parse(savedUser);
        this.userName.set(user.name?.split(' ')[0] || 'Engineer');
      } catch { }
    }
  }
  
  private setGreeting(): void {
    const hour = new Date().getHours();
    if (hour < 12) this.greeting.set('Good morning');
    else if (hour < 18) this.greeting.set('Good afternoon');
    else this.greeting.set('Good evening');
  }
  
  private initThreeJS(): void {
    if (!this.statsCanvasRef?.nativeElement) return;
    const canvas = this.statsCanvasRef.nativeElement;
    const container = canvas.parentElement;
    if (!container) return;
    
    this.scene = new THREE.Scene();
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    this.camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
    this.camera.position.z = 50;
    
    this.renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    
    // Create particles
    const particleCount = 100;
    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount * 3; i += 3) {
      positions[i] = (Math.random() - 0.5) * 100;
      positions[i + 1] = (Math.random() - 0.5) * 100;
      positions[i + 2] = (Math.random() - 0.5) * 50;
    }
    const geometry = new THREE.BufferGeometry();
    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    const material = new THREE.PointsMaterial({ size: 2, color: 0x3b82f6, transparent: true, opacity: 0.6 });
    this.particles = new THREE.Points(geometry, material);
    this.scene.add(this.particles);
    
    this.animate();
  }
  
  private animate(): void {
    this.animationId = requestAnimationFrame(() => this.animate());
    if (this.particles) this.particles.rotation.y += 0.001;
    this.renderer.render(this.scene, this.camera);
  }
  
  getTimeAgo(date: Date): string {
    const diff = Date.now() - new Date(date).getTime();
    const m = Math.floor(diff / 60000);
    const h = Math.floor(diff / 3600000);
    const d = Math.floor(diff / 86400000);
    if (m < 1) return 'Just now';
    if (m < 60) return m + 'm ago';
    if (h < 24) return h + 'h ago';
    return d + 'd ago';
  }
  
  getStatusClass(status: string): string { return 'status-' + status; }
  getSafetyClass(factor: number): string { return factor >= 1.5 ? 'safety-good' : factor >= 1.0 ? 'safety-warning' : 'safety-critical'; }
  getTypeIcon(type: string): string { switch(type) { case 'Beam': return ''; case 'Frame': return ''; case 'Truss': return ''; case 'Column': return ''; default: return ''; } }
  
  viewResults(sim: Simulation): void { this.router.navigate(['/results', sim.id]); }
  
  downloadReport(sim: Simulation, event?: Event): void {
    if (event) event.stopPropagation();
    if (sim.status !== 'completed') { console.log('Cannot download incomplete simulation'); return; }
    console.log('UI Only: Download report for', sim.name);
  }
  
  async toggleFavorite(sim: Simulation): Promise<void> { console.log('UI Only: Toggle favorite for', sim.name); }
  
  async deleteSimulation(sim: Simulation): Promise<void> {
    const confirmed = await this.modalService.confirm({ title: 'Delete Simulation', message: 'Are you sure you want to delete "' + sim.name + '"?', confirmText: 'Delete', cancelText: 'Cancel', type: 'danger' });
    if (confirmed) {
      this.recentSimulations.update(sims => sims.filter(s => s.id !== sim.id));
      console.log('UI Only: Deleted', sim.name);
    }
  }
  
  dismissNotification(id: string): void { this.notifications.update(arr => arr.filter(n => n.id !== id)); }

  // Additional methods for template
  toggleNotifications(): void { console.log('UI Only: Toggle notifications'); }
  formatDate(date: Date): string { return new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }); }
  getStatusIcon(status: string): string {
    switch (status) {
      case 'completed': return '✓';
      case 'running': return '⏳';
      case 'failed': return '✕';
      case 'pending': return '○';
      default: return '•';
    }
  }
  viewSimulationResults(sim: Simulation): void { this.router.navigate(['/results', sim.id]); }
  showMoreOptions(sim: Simulation, event: Event): void { event.stopPropagation(); console.log('UI Only: More options for', sim.name); }
  clearAllNotifications(): void { this.notifications.set([]); }
}
