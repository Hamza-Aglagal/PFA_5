import { Component, signal, computed, ViewChild, ElementRef, AfterViewInit, OnDestroy, Renderer2, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { SimulationService, SimulationRequest } from '../../core/services/simulation.service';
import { NotificationService } from '../../core/services/notification.service';

interface SimulationParams {
  name: string;
  description: string;
  structureType: string;
  length: number;
  width: number;
  height: number;
  material: string;
  elasticModulus: number;
  density: number;
  yieldStrength: number;
  loadType: string;
  loadMagnitude: number;
  loadPosition: number;
  supportType: string;
}

@Component({
  selector: 'app-simulation',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './simulation.component.html',
  styleUrl: './simulation.component.scss'
})
export class SimulationComponent implements AfterViewInit, OnDestroy {
  @ViewChild('previewCanvas') previewCanvas!: ElementRef<HTMLCanvasElement>;

  private router = inject(Router);
  private domRenderer = inject(Renderer2);
  private simulationService = inject(SimulationService);
  private notificationService = inject(NotificationService);
  
  private scene!: THREE.Scene;
  private camera!: THREE.PerspectiveCamera;
  private threeRenderer!: THREE.WebGLRenderer;
  private controls!: OrbitControls;
  private animationId!: number;
  private structureMesh!: THREE.Group;
  private resizeObserver!: ResizeObserver;
  private autoRotate = signal(true);

  currentStep = signal(1);
  totalSteps = 4;
  isAnalyzing = signal(false);
  analysisProgress = signal(0);
  analysisStage = signal<'preprocessing' | 'inference' | 'postprocessing' | 'complete'>('preprocessing');
  isLightMode = signal(false);
  errorMessage = signal<string | null>(null);

  params = signal<SimulationParams>({
    name: '',
    description: '',
    structureType: 'beam',
    length: 10,
    width: 0.5,
    height: 0.8,
    material: 'steel',
    elasticModulus: 200,
    density: 7850,
    yieldStrength: 250,
    loadType: 'point',
    loadMagnitude: 50,
    loadPosition: 50,
    supportType: 'simply-supported'
  });

  structureTypes = [
    { id: 'beam', name: 'Beam', icon: '═══', description: 'Simple beam analysis' },
    { id: 'frame', name: 'Frame', icon: '╔═╗', description: 'Portal frame structure' },
    { id: 'truss', name: 'Truss', icon: '△△△', description: 'Truss bridge/roof' },
    { id: 'column', name: 'Column', icon: '║║║', description: 'Vertical column' }
  ];

  materials = [
    { id: 'steel', name: 'Steel', E: 200, density: 7850, fy: 250, color: '#60a5fa' },
    { id: 'concrete', name: 'Concrete', E: 30, density: 2400, fy: 30, color: '#9ca3af' },
    { id: 'aluminum', name: 'Aluminum', E: 70, density: 2700, fy: 280, color: '#c4b5fd' },
    { id: 'wood', name: 'Wood', E: 12, density: 600, fy: 40, color: '#fbbf24' }
  ];

  loadTypes = [
    { id: 'point', name: 'Point Load', icon: '↓' },
    { id: 'distributed', name: 'Distributed', icon: '↓↓↓' },
    { id: 'moment', name: 'Moment', icon: '↻' }
  ];

  supportTypes = [
    { id: 'simply-supported', name: 'Simply Supported', icon: '△ △' },
    { id: 'cantilever', name: 'Cantilever', icon: '▌ ' },
    { id: 'fixed-fixed', name: 'Fixed-Fixed', icon: '▌ ▐' }
  ];

  steps = [
    { number: 1, title: 'Structure', icon: '🏗️' },
    { number: 2, title: 'Material', icon: '🔩' },
    { number: 3, title: 'Loading', icon: '⚡' },
    { number: 4, title: 'Review', icon: '✓' }
  ];

  progressPercent = computed(() => ((this.currentStep() - 1) / (this.totalSteps - 1)) * 100);

  selectedMaterial = computed(() => 
    this.materials.find(m => m.id === this.params().material) || this.materials[0]
  );

  constructor() {
    this.isLightMode.set(document.body.classList.contains('light-mode'));
  }

  ngAfterViewInit(): void {
    setTimeout(() => this.initThreeJS(), 100);
  }

  ngOnDestroy(): void {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
    if (this.controls) {
      this.controls.dispose();
    }
    if (this.threeRenderer) {
      this.threeRenderer.dispose();
    }
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
  }

  private initThreeJS(): void {
    const canvas = this.previewCanvas.nativeElement;
    const container = canvas.parentElement;
    if (!container) return;
    
    const width = container.clientWidth;
    const height = container.clientHeight;

    this.scene = new THREE.Scene();
    const bgColor = this.isLightMode() ? 0xe2e8f0 : 0x0f172a;
    this.scene.background = new THREE.Color(bgColor);

    this.camera = new THREE.PerspectiveCamera(50, width / height, 0.1, 1000);
    this.camera.position.set(15, 10, 15);
    this.camera.lookAt(0, 0, 0);

    this.threeRenderer = new THREE.WebGLRenderer({ canvas, antialias: true });
    this.threeRenderer.setSize(width, height);
    this.threeRenderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    // OrbitControls for mouse interaction
    this.controls = new OrbitControls(this.camera, canvas);
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.05;
    this.controls.enableZoom = true;
    this.controls.enablePan = true;
    this.controls.minDistance = 5;
    this.controls.maxDistance = 50;
    this.controls.autoRotate = true;
    this.controls.autoRotateSpeed = 0.5;
    
    // Stop auto-rotate when user interacts
    this.controls.addEventListener('start', () => {
      this.controls.autoRotate = false;
      this.autoRotate.set(false);
    });

    // Lights
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
    this.scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(10, 20, 10);
    this.scene.add(directionalLight);

    // Grid
    const gridColor = this.isLightMode() ? 0xcccccc : 0x374151;
    const gridCenterColor = this.isLightMode() ? 0x999999 : 0x1f2937;
    const grid = new THREE.GridHelper(20, 20, gridColor, gridCenterColor);
    this.scene.add(grid);

    // Axes
    const axesHelper = new THREE.AxesHelper(5);
    this.scene.add(axesHelper);

    this.updateStructurePreview();
    this.animate();
    
    // Setup resize observer
    this.resizeObserver = new ResizeObserver(() => {
      this.onResize();
    });
    this.resizeObserver.observe(container);
  }
  
  private onResize(): void {
    const canvas = this.previewCanvas?.nativeElement;
    if (!canvas) return;
    
    const container = canvas.parentElement;
    if (!container) return;
    
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.threeRenderer.setSize(width, height);
  }

  private animate(): void {
    this.animationId = requestAnimationFrame(() => this.animate());
    
    // Update controls
    if (this.controls) {
      this.controls.update();
    }
    
    this.threeRenderer.render(this.scene, this.camera);
  }

  updateStructurePreview(): void {
    if (!this.scene) return;

    // Remove existing structure
    if (this.structureMesh) {
      this.scene.remove(this.structureMesh);
    }

    this.structureMesh = new THREE.Group();
    const p = this.params();
    const material = this.selectedMaterial();
    const color = new THREE.Color(material.color);

    const mainMaterial = new THREE.MeshStandardMaterial({
      color: color,
      metalness: 0.3,
      roughness: 0.4
    });

    const supportMaterial = new THREE.MeshStandardMaterial({
      color: 0x374151,
      metalness: 0.5,
      roughness: 0.5
    });

    switch (p.structureType) {
      case 'beam':
        this.createBeam(p, mainMaterial, supportMaterial);
        break;
      case 'frame':
        this.createFrame(p, mainMaterial, supportMaterial);
        break;
      case 'truss':
        this.createTruss(p, mainMaterial, supportMaterial);
        break;
      case 'column':
        this.createColumn(p, mainMaterial, supportMaterial);
        break;
    }

    // Add load indicator
    this.addLoadIndicator(p);

    this.scene.add(this.structureMesh);
  }

  private createBeam(p: SimulationParams, mainMat: THREE.Material, supportMat: THREE.Material): void {
    const beamGeometry = new THREE.BoxGeometry(p.length, p.height, p.width);
    const beam = new THREE.Mesh(beamGeometry, mainMat);
    beam.position.y = p.height / 2 + 0.5;
    this.structureMesh.add(beam);

    // Supports
    if (p.supportType === 'simply-supported' || p.supportType === 'fixed-fixed') {
      const supportGeom = new THREE.ConeGeometry(0.4, 0.5, 4);
      
      const leftSupport = new THREE.Mesh(supportGeom, supportMat);
      leftSupport.position.set(-p.length / 2 + 0.5, 0.25, 0);
      this.structureMesh.add(leftSupport);
      
      const rightSupport = new THREE.Mesh(supportGeom, supportMat);
      rightSupport.position.set(p.length / 2 - 0.5, 0.25, 0);
      this.structureMesh.add(rightSupport);
    }

    if (p.supportType === 'cantilever' || p.supportType === 'fixed-fixed') {
      const fixedGeom = new THREE.BoxGeometry(0.5, 1.5, 0.8);
      const fixedSupport = new THREE.Mesh(fixedGeom, supportMat);
      fixedSupport.position.set(-p.length / 2 - 0.25, 0.75, 0);
      this.structureMesh.add(fixedSupport);
    }
  }

  private createFrame(p: SimulationParams, mainMat: THREE.Material, supportMat: THREE.Material): void {
    const columnGeom = new THREE.BoxGeometry(0.5, p.height, 0.5);
    const beamGeom = new THREE.BoxGeometry(p.length, 0.5, 0.5);
    
    // Left column
    const leftColumn = new THREE.Mesh(columnGeom, mainMat);
    leftColumn.position.set(-p.length / 2, p.height / 2, 0);
    this.structureMesh.add(leftColumn);
    
    // Right column
    const rightColumn = new THREE.Mesh(columnGeom, mainMat);
    rightColumn.position.set(p.length / 2, p.height / 2, 0);
    this.structureMesh.add(rightColumn);
    
    // Top beam
    const topBeam = new THREE.Mesh(beamGeom, mainMat);
    topBeam.position.set(0, p.height, 0);
    this.structureMesh.add(topBeam);

    // Supports
    const supportGeom = new THREE.BoxGeometry(0.8, 0.3, 0.8);
    [-p.length / 2, p.length / 2].forEach(x => {
      const support = new THREE.Mesh(supportGeom, supportMat);
      support.position.set(x, 0.15, 0);
      this.structureMesh.add(support);
    });
  }

  private createTruss(p: SimulationParams, mainMat: THREE.Material, supportMat: THREE.Material): void {
    const barRadius = 0.1;
    const segments = 4;
    const segmentLength = p.length / segments;
    
    // Bottom chord
    const bottomGeom = new THREE.CylinderGeometry(barRadius, barRadius, p.length, 8);
    bottomGeom.rotateZ(Math.PI / 2);
    const bottomChord = new THREE.Mesh(bottomGeom, mainMat);
    bottomChord.position.y = 0.5;
    this.structureMesh.add(bottomChord);

    // Top chord
    const topChord = new THREE.Mesh(bottomGeom.clone(), mainMat);
    topChord.position.y = p.height + 0.5;
    this.structureMesh.add(topChord);

    // Verticals and diagonals
    for (let i = 0; i <= segments; i++) {
      const x = -p.length / 2 + i * segmentLength;
      
      // Vertical
      const vertGeom = new THREE.CylinderGeometry(barRadius, barRadius, p.height, 8);
      const vertical = new THREE.Mesh(vertGeom, mainMat);
      vertical.position.set(x, p.height / 2 + 0.5, 0);
      this.structureMesh.add(vertical);
      
      // Diagonals
      if (i < segments) {
        const diagLength = Math.sqrt(segmentLength ** 2 + p.height ** 2);
        const diagGeom = new THREE.CylinderGeometry(barRadius * 0.8, barRadius * 0.8, diagLength, 8);
        const angle = Math.atan2(p.height, segmentLength);
        
        const diag = new THREE.Mesh(diagGeom, mainMat);
        diag.rotation.z = i % 2 === 0 ? -angle : angle;
        diag.position.set(x + segmentLength / 2, p.height / 2 + 0.5, 0);
        this.structureMesh.add(diag);
      }
    }
  }

  private createColumn(p: SimulationParams, mainMat: THREE.Material, supportMat: THREE.Material): void {
    const columnGeom = new THREE.BoxGeometry(p.width, p.height, p.width);
    const column = new THREE.Mesh(columnGeom, mainMat);
    column.position.y = p.height / 2;
    this.structureMesh.add(column);

    // Base
    const baseGeom = new THREE.BoxGeometry(p.width * 2, 0.3, p.width * 2);
    const base = new THREE.Mesh(baseGeom, supportMat);
    base.position.y = 0.15;
    this.structureMesh.add(base);
  }

  private addLoadIndicator(p: SimulationParams): void {
    const arrowMat = new THREE.MeshStandardMaterial({ color: 0xef4444 });
    const arrowGeom = new THREE.ConeGeometry(0.2, 0.6, 8);
    
    const loadX = (p.loadPosition / 100 - 0.5) * p.length;
    const loadY = p.structureType === 'frame' ? p.height + 1 : p.height + 1;

    if (p.loadType === 'point') {
      const arrow = new THREE.Mesh(arrowGeom, arrowMat);
      arrow.rotation.x = Math.PI;
      arrow.position.set(loadX, loadY, 0);
      this.structureMesh.add(arrow);
      
      // Arrow stem
      const stemGeom = new THREE.CylinderGeometry(0.05, 0.05, 0.8, 8);
      const stem = new THREE.Mesh(stemGeom, arrowMat);
      stem.position.set(loadX, loadY + 0.7, 0);
      this.structureMesh.add(stem);
    } else if (p.loadType === 'distributed') {
      for (let i = -2; i <= 2; i++) {
        const arrow = new THREE.Mesh(arrowGeom.clone(), arrowMat);
        arrow.rotation.x = Math.PI;
        arrow.scale.set(0.5, 0.5, 0.5);
        arrow.position.set(i * (p.length / 5), loadY, 0);
        this.structureMesh.add(arrow);
      }
    }
  }

  updateParam<K extends keyof SimulationParams>(key: K, value: SimulationParams[K]): void {
    this.params.update(p => ({ ...p, [key]: value }));
    this.updateStructurePreview();
  }

  selectStructureType(type: string): void {
    this.updateParam('structureType', type);
  }

  selectMaterial(materialId: string): void {
    const mat = this.materials.find(m => m.id === materialId);
    if (mat) {
      this.params.update(p => ({
        ...p,
        material: materialId,
        elasticModulus: mat.E,
        density: mat.density,
        yieldStrength: mat.fy
      }));
      this.updateStructurePreview();
    }
  }

  nextStep(): void {
    if (this.currentStep() < this.totalSteps) {
      this.currentStep.update(s => s + 1);
    }
  }

  prevStep(): void {
    if (this.currentStep() > 1) {
      this.currentStep.update(s => s - 1);
    }
  }

  goToStep(step: number): void {
    if (step >= 1 && step <= this.totalSteps) {
      this.currentStep.set(step);
    }
  }
  
  goBack(): void {
    this.router.navigate(['/dashboard']);
  }
  
  toggleTheme(): void {
    this.isLightMode.update(v => !v);
    
    if (this.isLightMode()) {
      this.domRenderer.addClass(document.body, 'light-mode');
      localStorage.setItem('simstruct-theme', 'light');
    } else {
      this.domRenderer.removeClass(document.body, 'light-mode');
      localStorage.setItem('simstruct-theme', 'dark');
    }
    
    // Update Three.js scene background
    if (this.scene) {
      const bgColor = this.isLightMode() ? 0xe2e8f0 : 0x0f172a;
      this.scene.background = new THREE.Color(bgColor);
    }
  }

  async runAnalysis(): Promise<void> {
    this.isAnalyzing.set(true);
    this.analysisProgress.set(0);
    this.analysisStage.set('preprocessing');
    this.errorMessage.set(null);

    // Prepare simulation request for backend
    const p = this.params();
    const request: SimulationRequest = {
      name: p.name || `${p.structureType} Simulation`,
      description: p.description || `${p.material} ${p.structureType} analysis`,
      beamLength: p.length,
      beamHeight: p.height,
      beamWidth: p.width,
      materialType: this.mapMaterial(p.material),
      elasticModulus: p.elasticModulus * 1e9, // Convert GPa to Pa
      loadType: this.mapLoadType(p.loadType),
      loadMagnitude: p.loadMagnitude * 1000, // Convert kN to N
      loadPosition: p.loadPosition / 100 * p.length, // Convert percentage to meters
      supportType: this.mapSupportType(p.supportType),
      isPublic: false
    };

    console.log('SimulationComponent: Starting analysis with request:', request);

    // Simulate preprocessing stage
    await this.simulateProgress('preprocessing', 30, 800);

    // Call backend API
    this.analysisStage.set('inference');
    
    this.simulationService.createSimulation(request).subscribe({
      next: async (result) => {
        console.log('SimulationComponent: Simulation result:', result);

        // Continue progress animation
        await this.simulateProgress('inference', 70, 600);
        await this.simulateProgress('postprocessing', 95, 400);
        await this.simulateProgress('complete', 100, 200);

        // Store result and navigate
        localStorage.setItem('lastSimulationResult', JSON.stringify(result));
        
        this.notificationService.success('Success', 'Simulation completed successfully!');

        setTimeout(() => {
          this.isAnalyzing.set(false);
          this.router.navigate(['/results', result.id]);
        }, 600);
      },
      error: (error) => {
        console.error('SimulationComponent: Simulation failed:', error);
        this.isAnalyzing.set(false);
        this.errorMessage.set(error.error?.message || error.message || 'Failed to run simulation. Please try again.');
        this.notificationService.error('Error', 'Simulation failed. Please try again.');
      }
    });
  }

  private async simulateProgress(stage: 'preprocessing' | 'inference' | 'postprocessing' | 'complete', target: number, duration: number): Promise<void> {
    this.analysisStage.set(stage);
    
    const startProgress = this.analysisProgress();
    const steps = duration / 50;
    const increment = (target - startProgress) / steps;
    
    for (let i = 0; i < steps; i++) {
      await new Promise(resolve => setTimeout(resolve, 50));
      this.analysisProgress.update(p => Math.min(p + increment + (Math.random() - 0.5) * 2, target));
    }
    
    this.analysisProgress.set(target);
    await new Promise(resolve => setTimeout(resolve, 100));
  }

  private mapMaterial(material: string): 'CONCRETE' | 'STEEL' | 'WOOD' | 'ALUMINUM' | 'COMPOSITE' {
    const map: Record<string, 'CONCRETE' | 'STEEL' | 'WOOD' | 'ALUMINUM' | 'COMPOSITE'> = {
      'steel': 'STEEL',
      'concrete': 'CONCRETE',
      'aluminum': 'ALUMINUM',
      'wood': 'WOOD'
    };
    return map[material] || 'STEEL';
  }

  private mapLoadType(loadType: string): 'POINT' | 'UNIFORM' | 'DISTRIBUTED' | 'MOMENT' {
    const map: Record<string, 'POINT' | 'UNIFORM' | 'DISTRIBUTED' | 'MOMENT'> = {
      'point': 'POINT',
      'distributed': 'UNIFORM',
      'moment': 'MOMENT'
    };
    return map[loadType] || 'POINT';
  }

  private mapSupportType(supportType: string): 'SIMPLY_SUPPORTED' | 'FIXED_FIXED' | 'FIXED_FREE' | 'FIXED_PINNED' {
    const map: Record<string, 'SIMPLY_SUPPORTED' | 'FIXED_FIXED' | 'FIXED_FREE' | 'FIXED_PINNED'> = {
      'simply-supported': 'SIMPLY_SUPPORTED',
      'cantilever': 'FIXED_FREE',
      'fixed-fixed': 'FIXED_FIXED'
    };
    return map[supportType] || 'SIMPLY_SUPPORTED';
  }
}
