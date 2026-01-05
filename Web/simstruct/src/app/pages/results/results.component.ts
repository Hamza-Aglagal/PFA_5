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

  results = signal<AnalysisResult[]>([]);

  recommendations = signal<{ type: string; title: string; description: string }[]>([]);

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

      const baseResults: AnalysisResult[] = [
        { id: '1', category: 'Stress', metric: 'Max Stress', value: sim.results.maxStress / 1e6, unit: 'MPa', status: this.getStatus(sim.results.maxStress / 1e6, 250), threshold: 250 },
        { id: '2', category: 'Deformation', metric: 'Max Deflection', value: sim.results.maxDeflection * 1000, unit: 'mm', status: this.getStatus(sim.results.maxDeflection * 1000, 20), threshold: 20 },
        { id: '3', category: 'Forces', metric: 'Max Bending', value: sim.results.maxBendingMoment / 1000, unit: 'kNm', status: 'safe', threshold: 500 },
        { id: '4', category: 'Forces', metric: 'Max Shear', value: sim.results.maxShearForce / 1000, unit: 'kN', status: 'safe', threshold: 200 },
        { id: '5', category: 'Stability', metric: 'Safety Factor', value: sf, unit: '', status: this.getStatus(sf, 1.5, true), threshold: 1.5 }
      ];

      // Add AI predictions if available
      if (sim.results.aiPredictions) {
        console.log('AI Predictions found:', sim.results.aiPredictions);
        const ai = sim.results.aiPredictions;
        baseResults.push(
          { id: '6', category: 'AI Analysis', metric: 'Stability Index', value: ai.stabilityIndex * 100, unit: '%', status: this.getStatus(ai.stabilityIndex * 100, 70, true), threshold: 70 },
          { id: '7', category: 'AI Analysis', metric: 'Seismic Resistance', value: ai.seismicResistance * 100, unit: '%', status: this.getStatus(ai.seismicResistance * 100, 70, true), threshold: 70 },
          { id: '8', category: 'AI Analysis', metric: 'Crack Risk', value: ai.crackRisk * 100, unit: '%', status: this.getStatus(ai.crackRisk * 100, 30, false), threshold: 30 },
          { id: '9', category: 'AI Analysis', metric: 'Foundation Stability', value: ai.foundationStability * 100, unit: '%', status: this.getStatus(ai.foundationStability * 100, 70, true), threshold: 70 }
        );
        // Update AI confidence based on average of AI predictions
        const avgConfidence = ((ai.stabilityIndex + ai.seismicResistance + ai.foundationStability + (1 - ai.crackRisk)) / 4) * 100;
        this.aiConfidence.set(Math.round(avgConfidence));

        // Generate AI-specific recommendations
        this.generateAIRecommendations(ai, sf);
      } else {
        // Traditional recommendations when no AI
        this.recommendations.set([
          { type: sim.results.isSafe ? 'success' : 'warning', title: sim.results.isSafe ? 'Structure is Safe' : 'Safety Concerns Detected', description: sim.results.recommendations },
          { type: 'info', title: 'Traditional Analysis', description: 'This simulation used classical beam theory. Enable AI for advanced predictions including seismic resistance and crack risk analysis.' }
        ]);
      }

      this.results.set(baseResults);
    }
  }

  private generateAIRecommendations(ai: any, safetyFactor: number): void {
    const recs: { type: string; title: string; description: string }[] = [];

    // Overall safety
    if (safetyFactor >= 2.0 && ai.stabilityIndex >= 0.8) {
      recs.push({ type: 'success', title: 'Excellent Structural Performance', description: 'AI analysis confirms high stability and safety margins. Structure exceeds all safety requirements.' });
    } else if (safetyFactor >= 1.5) {
      recs.push({ type: 'success', title: 'Structure is Safe', description: 'Traditional and AI analysis both indicate acceptable performance within safety limits.' });
    } else {
      recs.push({ type: 'warning', title: 'Safety Review Recommended', description: 'Consider structural reinforcement to improve safety factors and stability indices.' });
    }

    // Seismic resistance
    if (ai.seismicResistance < 0.6) {
      recs.push({ type: 'warning', title: 'Seismic Vulnerability Detected', description: 'AI predicts low earthquake resistance. Consider seismic reinforcement or base isolation for high-risk zones.' });
    } else if (ai.seismicResistance >= 0.8) {
      recs.push({ type: 'success', title: 'Excellent Seismic Performance', description: 'Structure demonstrates high resistance to seismic loads based on AI analysis.' });
    }

    // Crack risk
    if (ai.crackRisk > 0.5) {
      recs.push({ type: 'warning', title: 'High Crack Risk Detected', description: 'AI predicts significant cracking potential. Review concrete mix design, reinforcement spacing, and consider crack control measures.' });
    } else if (ai.crackRisk < 0.2) {
      recs.push({ type: 'success', title: 'Low Crack Risk', description: 'AI analysis indicates minimal cracking potential with current design parameters.' });
    }

    // Foundation stability
    if (ai.foundationStability < 0.7) {
      recs.push({ type: 'warning', title: 'Foundation Concerns', description: 'AI suggests potential foundation stability issues. Consider soil investigation and foundation reinforcement.' });
    } else if (ai.foundationStability >= 0.85) {
      recs.push({ type: 'success', title: 'Stable Foundation Design', description: 'Foundation system shows excellent stability characteristics per AI predictions.' });
    }

    // General optimization
    if (safetyFactor > 3.0 && ai.stabilityIndex > 0.9) {
      recs.push({ type: 'info', title: 'Over-Design Detected', description: 'Structure is significantly over-designed. Material optimization could reduce costs while maintaining safety.' });
    }

    this.recommendations.set(recs);
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

  exportPDF(): void { this.exportReport('pdf'); }
  shareResults(): void {
    const sim = this.simulationData();
    if (sim) {
      // Toggle public status
      this.simulationService.togglePublic(sim.id).subscribe({
        next: (updated) => {
          this.notificationService.success('Shared', 'Simulation is now public and can be viewed by others.');
        },
        error: () => {
          this.notificationService.error('Error', 'Failed to share simulation.');
        }
      });
    }
  }
  newSimulation(): void { this.router.navigate(['/simulation']); }

  // Missing methods for template
  formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
  }

  exportReport(format: 'pdf' | 'csv' | 'json'): void {
    const sim = this.simulationData();
    if (!sim) {
      this.notificationService.error('Error', 'No simulation data to export.');
      return;
    }

    console.log('Exporting report as', format);

    switch (format) {
      case 'pdf':
        this.exportAsPDF(sim);
        break;
      case 'csv':
        this.exportAsCSV(sim);
        break;
      case 'json':
        this.exportAsJSON(sim);
        break;
    }
  }

  private exportAsPDF(sim: SimulationResponse): void {
    // Create a printable HTML document
    const content = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>SimStruct Report - ${sim.name}</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 40px; color: #333; }
          h1 { color: #3b82f6; border-bottom: 2px solid #3b82f6; padding-bottom: 10px; }
          h2 { color: #1e40af; margin-top: 30px; }
          .header { display: flex; justify-content: space-between; align-items: center; }
          .logo { font-size: 24px; font-weight: bold; color: #3b82f6; }
          .date { color: #666; }
          table { width: 100%; border-collapse: collapse; margin: 20px 0; }
          th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
          th { background: #f3f4f6; }
          .safe { color: #10b981; font-weight: bold; }
          .warning { color: #f59e0b; font-weight: bold; }
          .critical { color: #ef4444; font-weight: bold; }
          .summary-box { background: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .result-item { margin: 10px 0; }
          .footer { margin-top: 40px; text-align: center; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="header">
          <div class="logo">SimStruct</div>
          <div class="date">Report generated: ${new Date().toLocaleDateString()}</div>
        </div>
        
        <h1>Structural Analysis Report</h1>
        
        <h2>Simulation Details</h2>
        <table>
          <tr><th>Name</th><td>${sim.name}</td></tr>
          <tr><th>Description</th><td>${sim.description || 'N/A'}</td></tr>
          <tr><th>Material</th><td>${sim.materialType}</td></tr>
          <tr><th>Support Type</th><td>${sim.supportType}</td></tr>
          <tr><th>Status</th><td class="${sim.results?.isSafe ? 'safe' : 'critical'}">${sim.status}</td></tr>
        </table>
        
        <h2>Structure Parameters</h2>
        <table>
          <tr><th>Length</th><td>${sim.beamLength} m</td></tr>
          <tr><th>Width</th><td>${sim.beamWidth} m</td></tr>
          <tr><th>Height</th><td>${sim.beamHeight} m</td></tr>
          <tr><th>Elastic Modulus</th><td>${(sim.elasticModulus / 1e9).toFixed(0)} GPa</td></tr>
        </table>
        
        <h2>Loading</h2>
        <table>
          <tr><th>Load Type</th><td>${sim.loadType}</td></tr>
          <tr><th>Load Magnitude</th><td>${(sim.loadMagnitude / 1000).toFixed(1)} kN</td></tr>
          <tr><th>Load Position</th><td>${sim.loadPosition} m</td></tr>
        </table>
        
        <h2>Analysis Results</h2>
        <div class="summary-box">
          <h3>Safety Factor: <span class="${sim.results?.safetyFactor >= 1.5 ? 'safe' : 'critical'}">${sim.results?.safetyFactor.toFixed(2)}</span></h3>
          <p>Structure is: <strong class="${sim.results?.isSafe ? 'safe' : 'critical'}">${sim.results?.isSafe ? 'SAFE' : 'UNSAFE'}</strong></p>
        </div>
        
        <table>
          <tr><th>Metric</th><th>Value</th><th>Unit</th></tr>
          <tr><td>Maximum Deflection</td><td>${(sim.results?.maxDeflection * 1000).toFixed(4)}</td><td>mm</td></tr>
          <tr><td>Maximum Bending Moment</td><td>${(sim.results?.maxBendingMoment / 1000).toFixed(2)}</td><td>kNm</td></tr>
          <tr><td>Maximum Shear Force</td><td>${(sim.results?.maxShearForce / 1000).toFixed(2)}</td><td>kN</td></tr>
          <tr><td>Maximum Stress</td><td>${(sim.results?.maxStress / 1e6).toFixed(2)}</td><td>MPa</td></tr>
          <tr><td>Natural Frequency</td><td>${sim.results?.naturalFrequency?.toFixed(2) || 'N/A'}</td><td>Hz</td></tr>
          <tr><td>Structure Weight</td><td>${sim.results?.weight?.toFixed(1) || 'N/A'}</td><td>kg</td></tr>
        </table>
        
        <h2>Recommendations</h2>
        <p>${sim.results?.recommendations || 'No recommendations available.'}</p>
        
        <div class="footer">
          <p>Generated by SimStruct - AI-Powered Structural Analysis Platform</p>
          <p>© ${new Date().getFullYear()} SimStruct. All rights reserved.</p>
        </div>
      </body>
      </html>
    `;

    // Open print dialog
    const printWindow = window.open('', '_blank');
    if (printWindow) {
      printWindow.document.write(content);
      printWindow.document.close();
      printWindow.focus();
      setTimeout(() => {
        printWindow.print();
      }, 500);
    }

    this.notificationService.success('PDF Export', 'Print dialog opened. Save as PDF.');
  }

  private exportAsCSV(sim: SimulationResponse): void {
    const rows = [
      ['SimStruct Analysis Report'],
      [''],
      ['Simulation Details'],
      ['Name', sim.name],
      ['Description', sim.description || 'N/A'],
      ['Material', sim.materialType],
      ['Support Type', sim.supportType],
      ['Status', sim.status],
      [''],
      ['Structure Parameters'],
      ['Length (m)', sim.beamLength.toString()],
      ['Width (m)', sim.beamWidth.toString()],
      ['Height (m)', sim.beamHeight.toString()],
      ['Elastic Modulus (GPa)', (sim.elasticModulus / 1e9).toString()],
      [''],
      ['Loading'],
      ['Load Type', sim.loadType],
      ['Load Magnitude (kN)', (sim.loadMagnitude / 1000).toString()],
      ['Load Position (m)', sim.loadPosition.toString()],
      [''],
      ['Analysis Results'],
      ['Safety Factor', sim.results?.safetyFactor.toString() || 'N/A'],
      ['Is Safe', sim.results?.isSafe ? 'Yes' : 'No'],
      ['Max Deflection (mm)', (sim.results?.maxDeflection * 1000).toFixed(4)],
      ['Max Bending Moment (kNm)', (sim.results?.maxBendingMoment / 1000).toFixed(2)],
      ['Max Shear Force (kN)', (sim.results?.maxShearForce / 1000).toFixed(2)],
      ['Max Stress (MPa)', (sim.results?.maxStress / 1e6).toFixed(2)],
      ['Natural Frequency (Hz)', sim.results?.naturalFrequency?.toFixed(2) || 'N/A'],
      ['Weight (kg)', sim.results?.weight?.toFixed(1) || 'N/A']
    ];

    const csvContent = rows.map(row => row.join(',')).join('\n');
    this.downloadFile(csvContent, `simstruct-${sim.name.replaceAll(/\s+/g, '-')}.csv`, 'text/csv');
    this.notificationService.success('CSV Export', 'CSV file downloaded successfully.');
  }

  private exportAsJSON(sim: SimulationResponse): void {
    const jsonContent = JSON.stringify(sim, null, 2);
    this.downloadFile(jsonContent, `simstruct-${sim.name.replaceAll(/\s+/g, '-')}.json`, 'application/json');
    this.notificationService.success('JSON Export', 'JSON file downloaded successfully.');
  }

  private downloadFile(content: string, filename: string, mimeType: string): void {
    const blob = new Blob([content], { type: mimeType });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
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
