import { Component, signal, ElementRef, ViewChild, AfterViewInit, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, ActivatedRoute } from '@angular/router';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { SimulationService, SimulationResponse } from '../../core/services/simulation.service';
import { NotificationService } from '../../core/services/notification.service';

interface AnalysisResult {
  id: string; category: string; metric: string; value: number; unit: string; status: 'safe' | 'warning' | 'critical'; threshold: number;
}

@Component({
  selector: 'app-results',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './results.component.html',
  styleUrl: './results.component.scss'
})
export class ResultsComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('structureCanvas', { static: false }) structureCanvasRef!: ElementRef<HTMLCanvasElement>;
  
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private simulationService = inject(SimulationService);
  private notificationService = inject(NotificationService);
  
  private scene!: THREE.Scene;
  private camera!: THREE.PerspectiveCamera;
  private renderer!: THREE.WebGLRenderer;
  private controls!: OrbitControls;
  private animationId: number = 0;
  private structure!: THREE.Group;
  
  isLoading = signal(false);
  loadError = signal<string | null>(null);
  simulationData = signal<SimulationResponse | null>(null);
  simulationName = signal('Simulation Results');
  simulationDate = signal(new Date());
  structureType = signal('Beam');
  material = signal('Steel');
  
  overallStatus = signal<'safe' | 'warning' | 'critical'>('safe');
  safetyFactor = signal(2.5);
  aiConfidence = signal(95);
  
  results = signal<AnalysisResult[]>([
    { id: '1', category: 'Stress Analysis', metric: 'Maximum Stress', value: 125, unit: 'MPa', status: 'safe', threshold: 250 },
    { id: '2', category: 'Deformation', metric: 'Maximum Deflection', value: 8.5, unit: 'mm', status: 'safe', threshold: 20 },
    { id: '3', category: 'Forces', metric: 'Maximum Bending Moment', value: 125, unit: 'kNm', status: 'safe', threshold: 500 },
    { id: '4', category: 'Forces', metric: 'Maximum Shear Force', value: 25, unit: 'kN', status: 'safe', threshold: 200 },
    { id: '5', category: 'Stability', metric: 'Safety Factor', value: 2.5, unit: '', status: 'safe', threshold: 1.5 }
  ]);
  
  recommendations = signal<{ type: string; title: string; description: string }[]>([
    { type: 'success', title: 'Structure is Safe', description: 'All stress values are within acceptable limits with good safety margins.' },
    { type: 'info', title: 'Optimization Opportunity', description: 'Consider reducing cross-section for cost savings while maintaining safety.' }
  ]);
  
  activeTab = signal<'stress' | 'deformation' | '3d'>('3d');
  showStressVisualization = signal(true);
  
  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    console.log('ResultsComponent: Loading simulation ID:', id);
    
    if (id) {
      // Load from API by ID
      this.isLoading.set(true);
      this.simulationService.getSimulation(id).subscribe({
        next: (sim) => {
          console.log('ResultsComponent: Loaded simulation:', sim);
          this.populateResults(sim);
          this.isLoading.set(false);
        },
        error: (error) => {
          console.error('ResultsComponent: Failed to load:', error);
          this.loadError.set('Failed to load simulation');
          this.isLoading.set(false);
          // Try localStorage as fallback
          this.loadFromLocalStorage();
        }
      });
    } else {
      // Check localStorage for last result
      this.loadFromLocalStorage();
    }
  }
  
  private loadFromLocalStorage(): void {
    const lastResult = localStorage.getItem('lastSimulationResult');
    if (lastResult) {
      try {
        console.log('ResultsComponent: Loading from localStorage');
        const sim = JSON.parse(lastResult) as SimulationResponse;
        this.populateResults(sim);
        localStorage.removeItem('lastSimulationResult');
      } catch (e) {
        console.error('ResultsComponent: Failed to parse localStorage:', e);
      }
    }
  }
  
  private populateResults(sim: SimulationResponse): void {
    this.simulationData.set(sim);
    this.simulationName.set(sim.name);
    this.simulationDate.set(new Date(sim.createdAt));
    this.structureType.set(sim.supportType);
    this.material.set(sim.materialType);
    
    if (sim.results) {
      const sf = sim.results.safetyFactor;
      this.safetyFactor.set(sf);
      this.overallStatus.set(sf >= 2.0 ? 'safe' : sf >= 1.0 ? 'warning' : 'critical');
      
      this.results.set([
        { id: '1', category: 'Stress', metric: 'Max Stress', value: sim.results.maxStress / 1e6, unit: 'MPa', status: this.getStatus(sim.results.maxStress / 1e6, 250), threshold: 250 },
        { id: '2', category: 'Deformation', metric: 'Max Deflection', value: sim.results.maxDeflection * 1000, unit: 'mm', status: this.getStatus(sim.results.maxDeflection * 1000, 20), threshold: 20 },
        { id: '3', category: 'Forces', metric: 'Max Bending', value: sim.results.maxBendingMoment / 1000, unit: 'kNm', status: 'safe', threshold: 500 },
        { id: '4', category: 'Forces', metric: 'Max Shear', value: sim.results.maxShearForce / 1000, unit: 'kN', status: 'safe', threshold: 200 },
        { id: '5', category: 'Stability', metric: 'Safety Factor', value: sf, unit: '', status: this.getStatus(sf, 1.5, true), threshold: 1.5 }
      ]);
    }
  }
  
  private getStatus(value: number, threshold: number, inverse = false): 'safe' | 'warning' | 'critical' {
    if (inverse) { return value >= threshold ? 'safe' : value >= threshold * 0.7 ? 'warning' : 'critical'; }
    return value <= threshold * 0.7 ? 'safe' : value <= threshold ? 'warning' : 'critical';
  }
  
  ngAfterViewInit(): void { setTimeout(() => this.initThreeJS(), 100); }
  ngOnDestroy(): void { if (this.animationId) cancelAnimationFrame(this.animationId); if (this.controls) this.controls.dispose(); if (this.renderer) this.renderer.dispose(); }
  
  private initThreeJS(): void {
    if (!this.structureCanvasRef?.nativeElement) return;
    const canvas = this.structureCanvasRef.nativeElement;
    const container = canvas.parentElement;
    if (!container) return;
    
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x0f172a);
    
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    this.camera = new THREE.PerspectiveCamera(50, width / height, 0.1, 1000);
    this.camera.position.set(15, 10, 15);
    this.camera.lookAt(0, 0, 0);
    
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    
    this.controls = new OrbitControls(this.camera, canvas);
    this.controls.enableDamping = true;
    this.controls.autoRotate = true;
    this.controls.autoRotateSpeed = 0.5;
    
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
    this.scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(10, 20, 10);
    this.scene.add(directionalLight);
    
    this.createStructure();
    this.animate();
  }
  
  private createStructure(): void {
    this.structure = new THREE.Group();
    const beamGeometry = new THREE.BoxGeometry(10, 0.8, 0.5);
    const beamMaterial = new THREE.MeshStandardMaterial({ color: 0x3b82f6, metalness: 0.3, roughness: 0.4 });
    const beam = new THREE.Mesh(beamGeometry, beamMaterial);
    beam.position.y = 1;
    this.structure.add(beam);
    
    // Supports
    const supportGeom = new THREE.ConeGeometry(0.4, 0.5, 4);
    const supportMat = new THREE.MeshStandardMaterial({ color: 0x374151 });
    const leftSupport = new THREE.Mesh(supportGeom, supportMat);
    leftSupport.position.set(-4.5, 0.25, 0);
    this.structure.add(leftSupport);
    const rightSupport = new THREE.Mesh(supportGeom, supportMat);
    rightSupport.position.set(4.5, 0.25, 0);
    this.structure.add(rightSupport);
    
    // Grid
    const grid = new THREE.GridHelper(20, 20, 0x374151, 0x1f2937);
    this.scene.add(grid);
    
    this.scene.add(this.structure);
  }
  
  private animate(): void {
    this.animationId = requestAnimationFrame(() => this.animate());
    if (this.controls) this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }
  
  setActiveTab(tab: 'stress' | 'deformation' | '3d'): void { this.activeTab.set(tab); }
  getStatusClass(status: string): string { return 'status-' + status; }
  getSafetyClass(factor: number): string { return factor >= 2.0 ? 'safe' : factor >= 1.0 ? 'warning' : 'critical'; }
  
  exportPDF(): void { console.log('UI Only: Export PDF'); }
  shareResults(): void { console.log('UI Only: Share results'); }
  newSimulation(): void { this.router.navigate(['/simulation']); }

  // Missing methods for template
  formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  }

  exportReport(format: 'pdf' | 'csv' | 'json'): void {
    console.log('UI Only: Export report as', format);
  }

  getStatusIcon(status: 'safe' | 'warning' | 'critical'): string {
    switch (status) {
      case 'safe': return '✓';
      case 'warning': return '⚠';
      case 'critical': return '✕';
      default: return '•';
    }
  }

  getSafetyBarWidth(): number {
    const sf = this.safetyFactor();
    return Math.min(sf / 3 * 100, 100);
  }

  toggleStressVisualization(): void {
    this.showStressVisualization.update(v => !v);
  }

  getValuePercentage(value: number, threshold: number): number {
    return Math.min((value / threshold) * 100, 100);
  }

  compareResults(): void {
    console.log('UI Only: Compare results');
    this.router.navigate(['/history']);
  }

  modifyParameters(): void {
    console.log('UI Only: Modify parameters');
    this.router.navigate(['/simulation']);
  }
}
