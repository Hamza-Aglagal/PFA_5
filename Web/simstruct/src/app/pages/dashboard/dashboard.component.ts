import { Component, signal, computed, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import * as THREE from 'three';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';
import { SimulationService, SimulationResponse } from '../../core/services/simulation.service';

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
  private simulationService = inject(SimulationService);
  
  private scene!: THREE.Scene;
  private camera!: THREE.PerspectiveCamera;
  private renderer!: THREE.WebGLRenderer;
  private animationId: number = 0;
  private particles!: THREE.Points;
  
  userName = signal('Engineer');
  greeting = signal('');
  isLoading = signal(false);
  
  stats = signal<StatCard[]>([
    { title: 'Total Simulations', value: 0, change: 0, icon: '', color: 'primary' },
    { title: 'Safe Structures', value: 0, change: 0, icon: '', color: 'success' },
    { title: 'Warnings', value: 0, change: 0, icon: '', color: 'warning' },
    { title: 'Favorites', value: 0, change: 0, icon: '', color: 'accent' }
  ]);
  
  recentSimulations = signal<Simulation[]>([]);
  
  quickActions = [
    { icon: '', label: 'New Simulation', route: '/simulation', color: 'primary' },
    { icon: '', label: 'Import Model', route: '/simulation', color: 'secondary' },
    { icon: '', label: 'View History', route: '/history', color: 'tertiary' },
    { icon: '', label: 'Export Report', route: '/results', color: 'accent' }
  ];
  
  notifications = signal<Notification[]>([]);
  
  ngOnInit(): void {
    this.setGreeting();
    this.loadUserName();
    this.loadDashboardData();
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
  
  private loadDashboardData(): void {
    this.isLoading.set(true);
    console.log('Dashboard: Loading data from API...');
    
    // Load all user simulations to calculate stats
    this.simulationService.getUserSimulations().subscribe({
      next: (simulations) => {
        console.log('Dashboard: Loaded', simulations.length, 'simulations');
        
        // Calculate stats from real data
        const total = simulations.length;
        const safe = simulations.filter(s => s.results?.safetyFactor >= 1.5).length;
        const warnings = simulations.filter(s => s.results?.safetyFactor < 1.5 && s.results?.safetyFactor >= 1.0).length;
        const favorites = simulations.filter(s => s.isFavorite).length;
        
        this.stats.set([
          { title: 'Total Simulations', value: total, change: 0, icon: '', color: 'primary' },
          { title: 'Safe Structures', value: safe, change: 0, icon: '', color: 'success' },
          { title: 'Warnings', value: warnings, change: 0, icon: '', color: 'warning' },
          { title: 'Favorites', value: favorites, change: 0, icon: '', color: 'accent' }
        ]);
        
        // Map to dashboard format and take first 5
        const recentSims: Simulation[] = simulations.slice(0, 5).map(s => ({
          id: s.id,
          name: s.name,
          type: this.getStructureTypeFromMaterial(s.materialType),
          status: this.mapStatus(s.status),
          date: new Date(s.createdAt),
          safetyFactor: s.results?.safetyFactor || 0
        }));
        
        this.recentSimulations.set(recentSims);
        
        // Add notification for recent simulation
        if (recentSims.length > 0) {
          const latest = recentSims[0];
          if (latest.status === 'completed') {
            this.notifications.set([
              { id: '1', type: 'success', message: `"${latest.name}" completed successfully`, time: this.getTimeAgo(latest.date) }
            ]);
          }
        }
        
        this.isLoading.set(false);
      },
      error: (error) => {
        console.error('Dashboard: Failed to load data', error);
        this.isLoading.set(false);
        // Keep empty state - no mock data
      }
    });
  }
  
  private getStructureTypeFromMaterial(materialType: string): string {
    // Simple mapping - in real app this would be from the simulation data
    return 'Beam';
  }
  
  private mapStatus(status: string): 'completed' | 'running' | 'failed' | 'pending' {
    const statusMap: Record<string, 'completed' | 'running' | 'failed' | 'pending'> = {
      'COMPLETED': 'completed',
      'RUNNING': 'running',
      'FAILED': 'failed',
      'PENDING': 'pending'
    };
    return statusMap[status] || 'pending';
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
    if (sim.status !== 'completed') { 
      console.log('Cannot download incomplete simulation'); 
      return; 
    }
    // Navigate to results page where they can export
    this.router.navigate(['/results', sim.id]);
  }
  
  toggleFavorite(sim: Simulation, event?: Event): void {
    if (event) event.stopPropagation();
    this.simulationService.toggleFavorite(sim.id).subscribe({
      next: (updated) => {
        console.log('Dashboard: Toggled favorite for', sim.name);
        // Reload dashboard data
        this.loadDashboardData();
      },
      error: (err) => console.error('Dashboard: Failed to toggle favorite', err)
    });
  }
  
  togglePublic(sim: Simulation, event?: Event): void {
    if (event) event.stopPropagation();
    this.simulationService.togglePublic(sim.id).subscribe({
      next: (updated) => {
        console.log('Dashboard: Toggled public for', sim.name);
      },
      error: (err) => console.error('Dashboard: Failed to toggle public', err)
    });
  }
  
  async deleteSimulation(sim: Simulation, event?: Event): Promise<void> {
    if (event) event.stopPropagation();
    const confirmed = await this.modalService.confirm({ 
      title: 'Delete Simulation', 
      message: 'Are you sure you want to delete "' + sim.name + '"?', 
      confirmText: 'Delete', 
      cancelText: 'Cancel', 
      type: 'danger' 
    });
    if (confirmed) {
      this.simulationService.deleteSimulation(sim.id).subscribe({
        next: () => {
          console.log('Dashboard: Deleted', sim.name);
          this.recentSimulations.update(sims => sims.filter(s => s.id !== sim.id));
          this.loadDashboardData();
        },
        error: (err) => console.error('Dashboard: Failed to delete', err)
      });
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
