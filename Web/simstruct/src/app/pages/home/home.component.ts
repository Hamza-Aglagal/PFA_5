import { Component, OnInit, OnDestroy, ElementRef, ViewChild, AfterViewInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import * as THREE from 'three';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss'
})
export class HomeComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('heroCanvas') heroCanvas!: ElementRef<HTMLCanvasElement>;
  
  private scene!: THREE.Scene;
  private camera!: THREE.PerspectiveCamera;
  private renderer!: THREE.WebGLRenderer;
  private animationId!: number;
  private structures: THREE.Mesh[] = [];
  private particles!: THREE.Points;
  private mouseX = 0;
  private mouseY = 0;

  isLoaded = signal(false);
  activeFeature = signal(0);

  features = [
    {
      icon: '🤖',
      title: 'AI-Powered Analysis',
      description: 'Deep learning models trained on thousands of structural simulations for instant, accurate predictions.',
      color: '#3b82f6'
    },
    {
      icon: '⚡',
      title: 'Real-Time Results',
      description: 'Get stability analysis results in under 3 seconds, compared to hours with traditional FEM methods.',
      color: '#f97316'
    },
    {
      icon: '🔬',
      title: '3D Visualization',
      description: 'Interactive 3D rendering of stress distribution, deformation, and critical points.',
      color: '#22c55e'
    },
    {
      icon: '📊',
      title: 'Comprehensive Reports',
      description: 'Generate professional PDF reports with detailed analysis, graphs, and recommendations.',
      color: '#a855f7'
    },
    {
      icon: '🔒',
      title: 'Enterprise Security',
      description: 'Bank-level encryption, RGPD compliance, and secure cloud infrastructure.',
      color: '#ef4444'
    },
    {
      icon: '📱',
      title: 'Mobile Ready',
      description: 'Full-featured mobile app for iOS and Android. Analyze structures anywhere, anytime.',
      color: '#06b6d4'
    }
  ];

  stats = [
    { value: '95%+', label: 'AI Accuracy', icon: '🎯' },
    { value: '<3s', label: 'Response Time', icon: '⚡' },
    { value: '10K+', label: 'Simulations', icon: '📊' },
    { value: '99.9%', label: 'Uptime', icon: '🔒' }
  ];

  structureTypes = [
    { name: 'Beam', icon: '═══', description: 'Analyze beam deflection and stress distribution' },
    { name: 'Frame', icon: '╔═╗', description: 'Multi-story frame structural analysis' },
    { name: 'Truss', icon: '△△△', description: 'Truss bridge and roof structures' },
    { name: 'Slab', icon: '▬▬▬', description: 'Floor and foundation slab analysis' }
  ];

  ngOnInit(): void {
    this.initFeatureRotation();
  }

  ngAfterViewInit(): void {
    setTimeout(() => {
      this.initThreeJS();
      this.animate();
      this.isLoaded.set(true);
    }, 100);

    window.addEventListener('mousemove', this.onMouseMove.bind(this));
    window.addEventListener('resize', this.onResize.bind(this));
  }

  ngOnDestroy(): void {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
    if (this.renderer) {
      this.renderer.dispose();
    }
    window.removeEventListener('mousemove', this.onMouseMove.bind(this));
    window.removeEventListener('resize', this.onResize.bind(this));
  }

  private initFeatureRotation(): void {
    setInterval(() => {
      this.activeFeature.update(v => (v + 1) % this.features.length);
    }, 4000);
  }

  private initThreeJS(): void {
    const canvas = this.heroCanvas.nativeElement;
    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    // Scene
    this.scene = new THREE.Scene();
    this.scene.fog = new THREE.FogExp2(0x030712, 0.0008);

    // Camera
    this.camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
    this.camera.position.set(0, 5, 30);
    this.camera.lookAt(0, 0, 0);

    // Renderer
    this.renderer = new THREE.WebGLRenderer({ 
      canvas, 
      alpha: true, 
      antialias: true 
    });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setClearColor(0x030712, 1);

    // Lights
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
    this.scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    directionalLight.position.set(10, 20, 10);
    this.scene.add(directionalLight);

    const pointLight1 = new THREE.PointLight(0x3b82f6, 1, 50);
    pointLight1.position.set(-10, 10, 10);
    this.scene.add(pointLight1);

    const pointLight2 = new THREE.PointLight(0xf97316, 1, 50);
    pointLight2.position.set(10, -10, 10);
    this.scene.add(pointLight2);

    // Create structures
    this.createStructures();
    this.createParticles();
    this.createGrid();
  }

  private createStructures(): void {
    // Main Building Structure
    const buildingGroup = new THREE.Group();

    // Foundation
    const foundationGeometry = new THREE.BoxGeometry(12, 0.5, 8);
    const foundationMaterial = new THREE.MeshStandardMaterial({ 
      color: 0x374151,
      metalness: 0.3,
      roughness: 0.7
    });
    const foundation = new THREE.Mesh(foundationGeometry, foundationMaterial);
    foundation.position.y = -4;
    buildingGroup.add(foundation);

    // Columns
    const columnGeometry = new THREE.BoxGeometry(0.8, 8, 0.8);
    const columnMaterial = new THREE.MeshStandardMaterial({ 
      color: 0x3b82f6,
      metalness: 0.5,
      roughness: 0.3,
      emissive: 0x1d4ed8,
      emissiveIntensity: 0.1
    });

    const columnPositions = [
      [-5, 0, -3], [-5, 0, 3], [5, 0, -3], [5, 0, 3],
      [0, 0, -3], [0, 0, 3]
    ];

    columnPositions.forEach(pos => {
      const column = new THREE.Mesh(columnGeometry, columnMaterial);
      column.position.set(pos[0], pos[1], pos[2]);
      buildingGroup.add(column);
      this.structures.push(column);
    });

    // Beams
    const beamGeometry = new THREE.BoxGeometry(10.5, 0.6, 0.6);
    const beamMaterial = new THREE.MeshStandardMaterial({ 
      color: 0xf97316,
      metalness: 0.5,
      roughness: 0.3,
      emissive: 0xc2410c,
      emissiveIntensity: 0.1
    });

    [-3, 3].forEach(z => {
      const beam = new THREE.Mesh(beamGeometry, beamMaterial);
      beam.position.set(0, 4, z);
      buildingGroup.add(beam);
      this.structures.push(beam);
    });

    // Cross beams
    const crossBeamGeometry = new THREE.BoxGeometry(0.5, 0.5, 6.5);
    [-5, 0, 5].forEach(x => {
      const crossBeam = new THREE.Mesh(crossBeamGeometry, beamMaterial);
      crossBeam.position.set(x, 4, 0);
      buildingGroup.add(crossBeam);
    });

    // Roof slab
    const roofGeometry = new THREE.BoxGeometry(11.5, 0.4, 7);
    const roofMaterial = new THREE.MeshStandardMaterial({ 
      color: 0x22c55e,
      metalness: 0.4,
      roughness: 0.4,
      transparent: true,
      opacity: 0.8
    });
    const roof = new THREE.Mesh(roofGeometry, roofMaterial);
    roof.position.y = 4.5;
    buildingGroup.add(roof);

    // Add stress indicators (glowing spheres at joints)
    const jointGeometry = new THREE.SphereGeometry(0.3, 16, 16);
    const jointMaterial = new THREE.MeshStandardMaterial({ 
      color: 0xfbbf24,
      emissive: 0xfbbf24,
      emissiveIntensity: 0.5
    });

    columnPositions.forEach(pos => {
      const joint = new THREE.Mesh(jointGeometry, jointMaterial);
      joint.position.set(pos[0], 4, pos[2]);
      buildingGroup.add(joint);
    });

    buildingGroup.position.y = 0;
    this.scene.add(buildingGroup);
    this.structures.push(buildingGroup as any);
  }

  private createParticles(): void {
    const particleCount = 500;
    const positions = new Float32Array(particleCount * 3);
    const colors = new Float32Array(particleCount * 3);

    for (let i = 0; i < particleCount; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 100;
      positions[i * 3 + 1] = (Math.random() - 0.5) * 100;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 100;

      // Mix of blue and orange particles
      if (Math.random() > 0.5) {
        colors[i * 3] = 0.23;     // R
        colors[i * 3 + 1] = 0.51; // G
        colors[i * 3 + 2] = 0.96; // B (blue)
      } else {
        colors[i * 3] = 0.98;     // R
        colors[i * 3 + 1] = 0.45; // G
        colors[i * 3 + 2] = 0.09; // B (orange)
      }
    }

    const particleGeometry = new THREE.BufferGeometry();
    particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    particleGeometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

    const particleMaterial = new THREE.PointsMaterial({
      size: 0.5,
      vertexColors: true,
      transparent: true,
      opacity: 0.6,
      blending: THREE.AdditiveBlending
    });

    this.particles = new THREE.Points(particleGeometry, particleMaterial);
    this.scene.add(this.particles);
  }

  private createGrid(): void {
    const gridHelper = new THREE.GridHelper(100, 50, 0x1f2937, 0x111827);
    gridHelper.position.y = -4.5;
    this.scene.add(gridHelper);
  }

  private animate(): void {
    this.animationId = requestAnimationFrame(() => this.animate());

    const time = Date.now() * 0.001;

    // Rotate particles
    if (this.particles) {
      this.particles.rotation.y = time * 0.05;
      this.particles.rotation.x = time * 0.02;
    }

    // Animate structures (subtle floating)
    this.structures.forEach((structure, i) => {
      if (structure.position) {
        structure.position.y += Math.sin(time + i) * 0.001;
      }
    });

    // Camera follows mouse
    const targetX = this.mouseX * 0.001;
    const targetY = this.mouseY * 0.001;
    this.camera.position.x += (targetX * 5 - this.camera.position.x) * 0.02;
    this.camera.position.y += (-targetY * 3 + 5 - this.camera.position.y) * 0.02;
    this.camera.lookAt(0, 0, 0);

    this.renderer.render(this.scene, this.camera);
  }

  private onMouseMove(event: MouseEvent): void {
    this.mouseX = event.clientX - window.innerWidth / 2;
    this.mouseY = event.clientY - window.innerHeight / 2;
  }

  private onResize(): void {
    if (!this.heroCanvas?.nativeElement) return;
    
    const canvas = this.heroCanvas.nativeElement;
    const width = canvas.clientWidth;
    const height = canvas.clientHeight;

    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  setActiveFeature(index: number): void {
    this.activeFeature.set(index);
  }
}
