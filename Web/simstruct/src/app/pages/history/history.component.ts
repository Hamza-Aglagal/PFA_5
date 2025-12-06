import { Component, signal, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ModalService } from '../../shared/components/confirm-modal/confirm-modal.component';
import { SimulationService, SimulationResponse } from '../../core/services/simulation.service';
import { NotificationService } from '../../core/services/notification.service';

interface Simulation {
  id: string;
  name: string;
  type: string;
  material: string;
  status: 'completed' | 'failed' | 'pending';
  safetyFactor: number;
  date: Date;
  thumbnail?: string;
}

@Component({
  selector: 'app-history',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule],
  templateUrl: './history.component.html',
  styleUrl: './history.component.scss'
})
export class HistoryComponent implements OnInit {
  private router = inject(Router);
  private modalService = inject(ModalService);
  private simulationService = inject(SimulationService);
  private notificationService = inject(NotificationService);
  
  searchQuery = signal('');
  selectedFilter = signal('all');
  selectedSort = signal('newest');
  viewMode = signal<'grid' | 'list'>('grid');
  isLoading = signal(false);
  
  filters = [
    { value: 'all', label: 'All', count: 0 },
    { value: 'completed', label: 'Completed', count: 0 },
    { value: 'failed', label: 'Failed', count: 0 },
    { value: 'pending', label: 'Pending', count: 0 }
  ];
  
  sortOptions = [
    { value: 'newest', label: 'Newest First' },
    { value: 'oldest', label: 'Oldest First' },
    { value: 'name', label: 'Name A-Z' },
    { value: 'safety', label: 'Safety Factor' }
  ];
  
  simulations = signal<Simulation[]>([]);
  selectedSimulations = signal<Set<string>>(new Set());
  
  ngOnInit(): void {
    this.loadSimulations();
  }
  
  private loadSimulations(): void {
    console.log('HistoryComponent: Loading simulations');
    this.isLoading.set(true);
    
    this.simulationService.getUserSimulations().subscribe({
      next: (response) => {
        console.log('HistoryComponent: Loaded', response.length, 'simulations');
        
        // Map API response to local format
        const mapped = response.map((sim: SimulationResponse) => ({
          id: sim.id,
          name: sim.name,
          type: sim.supportType || 'Beam',
          material: sim.materialType,
          status: this.mapStatus(sim.status),
          safetyFactor: sim.results?.safetyFactor || 0,
          date: new Date(sim.createdAt)
        }));
        
        this.simulations.set(mapped);
        this.updateFilterCounts();
        this.isLoading.set(false);
      },
      error: (error) => {
        console.error('HistoryComponent: Failed to load:', error);
        this.notificationService.error('Load Failed', 'Failed to load simulations');
        this.isLoading.set(false);
      }
    });
  }
  
  private mapStatus(status: string): 'completed' | 'failed' | 'pending' {
    switch (status) {
      case 'COMPLETED': return 'completed';
      case 'FAILED': return 'failed';
      case 'RUNNING': return 'pending';
      case 'PENDING': return 'pending';
      default: return 'completed';
    }
  }
  
  private updateFilterCounts(): void {
    const sims = this.simulations();
    this.filters = [
      { value: 'all', label: 'All', count: sims.length },
      { value: 'completed', label: 'Completed', count: sims.filter(s => s.status === 'completed').length },
      { value: 'failed', label: 'Failed', count: sims.filter(s => s.status === 'failed').length },
      { value: 'pending', label: 'Pending', count: sims.filter(s => s.status === 'pending').length }
    ];
  }
  
  get filteredSimulations(): Simulation[] {
    let results = this.simulations();
    if (this.selectedFilter() !== 'all') {
      results = results.filter(s => s.status === this.selectedFilter());
    }
    const query = this.searchQuery().toLowerCase();
    if (query) {
      results = results.filter(s => 
        s.name.toLowerCase().includes(query) || 
        s.type.toLowerCase().includes(query) || 
        s.material.toLowerCase().includes(query)
      );
    }
    switch (this.selectedSort()) {
      case 'newest': return [...results].sort((a, b) => b.date.getTime() - a.date.getTime());
      case 'oldest': return [...results].sort((a, b) => a.date.getTime() - b.date.getTime());
      case 'name': return [...results].sort((a, b) => a.name.localeCompare(b.name));
      case 'safety': return [...results].sort((a, b) => b.safetyFactor - a.safetyFactor);
      default: return results;
    }
  }
  
  updateSearch(event: Event): void {
    this.searchQuery.set((event.target as HTMLInputElement).value);
  }
  
  setFilter(filter: string): void {
    this.selectedFilter.set(filter);
  }
  
  setSort(event: Event): void {
    this.selectedSort.set((event.target as HTMLSelectElement).value);
  }
  
  setViewMode(mode: 'grid' | 'list'): void {
    this.viewMode.set(mode);
  }
  
  toggleSelection(id: string): void {
    this.selectedSimulations.update(s => {
      const n = new Set(s);
      n.has(id) ? n.delete(id) : n.add(id);
      return n;
    });
  }
  
  selectAll(): void {
    if (this.selectedSimulations().size === this.filteredSimulations.length) {
      this.selectedSimulations.set(new Set());
    } else {
      this.selectedSimulations.set(new Set(this.filteredSimulations.map(s => s.id)));
    }
  }
  
  isSelected(id: string): boolean {
    return this.selectedSimulations().has(id);
  }
  
  async deleteSelected(): Promise<void> {
    const count = this.selectedSimulations().size;
    const confirmed = await this.modalService.confirm({
      title: 'Delete Simulations',
      message: 'Are you sure you want to delete ' + count + ' simulation(s)?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      type: 'danger'
    });
    
    if (confirmed) {
      const selected = Array.from(this.selectedSimulations());
      for (const id of selected) {
        this.simulationService.deleteSimulation(id).subscribe({
          next: () => console.log('HistoryComponent: Deleted simulation', id),
          error: (error) => console.error('Failed to delete:', error)
        });
      }
      // Update local list
      this.simulations.update(sims => sims.filter(s => !this.selectedSimulations().has(s.id)));
      this.selectedSimulations.set(new Set());
      this.updateFilterCounts();
      this.notificationService.success('Deleted', 'Deleted ' + count + ' simulation(s)');
    }
  }
  
  getStatusClass(status: string): string {
    return 'status-' + status;
  }
  
  getStatusIcon(status: string): string {
    switch (status) {
      case 'completed': return '✓';
      case 'failed': return '✕';
      case 'pending': return '⏳';
      default: return '?';
    }
  }
  
  getSafetyClass(factor: number): string {
    if (factor >= 2.5) return 'safety-excellent';
    if (factor >= 1.5) return 'safety-good';
    if (factor >= 1.0) return 'safety-warning';
    return 'safety-critical';
  }
  
  getTypeIcon(type: string): string {
    switch (type) {
      case 'Beam': return '═';
      case 'Frame': return '╔';
      case 'Truss': return '△';
      case 'Column': return '║';
      default: return '';
    }
  }
  
  formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }
  
  viewResults(sim: Simulation, event: Event): void {
    event.stopPropagation();
    this.router.navigate(['/results', sim.id]);
  }
  
  downloadSimulation(sim: Simulation, event: Event): void {
    event.stopPropagation();
    if (sim.status !== 'completed') return;
    console.log('Download:', sim.name);
  }
  
  duplicateSimulation(sim: Simulation, event: Event): void {
    event.stopPropagation();
    this.router.navigate(['/simulation'], { queryParams: { clone: sim.id } });
  }
  
  async deleteSingle(sim: Simulation, event: Event): Promise<void> {
    event.stopPropagation();
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
          console.log('HistoryComponent: Deleted', sim.name);
          this.simulations.update(sims => sims.filter(s => s.id !== sim.id));
          this.updateFilterCounts();
          this.notificationService.success('Deleted', 'Simulation deleted successfully');
        },
        error: (error) => {
          console.error('HistoryComponent: Delete failed:', error);
          this.notificationService.error('Error', 'Failed to delete simulation');
        }
      });
    }
  }
}
