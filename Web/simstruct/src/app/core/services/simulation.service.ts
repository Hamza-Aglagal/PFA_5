import { Injectable, inject, signal, computed } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, tap, catchError, throwError, map } from 'rxjs';

// API Response wrapper
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: string;
}

// Types for simulation
export interface SimulationRequest {
  name: string;
  description?: string;
  beamLength: number;
  beamWidth: number;
  beamHeight: number;
  materialType: MaterialType;
  elasticModulus?: number;
  density?: number;
  yieldStrength?: number;
  loadType: LoadType;
  loadMagnitude: number;
  loadPosition?: number;
  supportType: SupportType;
  isPublic?: boolean;
  // AI Building Parameters (Required for AI predictions)
  numFloors: number;
  floorHeight: number;
  numBeams: number;
  numColumns: number;
  beamSection: number;
  columnSection: number;
  concreteStrength: number;
  steelGrade: number;
  windLoad: number;
  liveLoad: number;
  deadLoad: number;
}

export interface AIPredictions {
  stabilityIndex: number;
  seismicResistance: number;
  crackRisk: number;
  foundationStability: number;
}

export interface SimulationResults {
  maxDeflection: number;
  maxBendingMoment: number;
  maxShearForce: number;
  maxStress: number;
  safetyFactor: number;
  isSafe: boolean;
  recommendations: string;
  naturalFrequency?: number;
  criticalLoad?: number;
  weight?: number;
  // AI Predictions (when AI parameters provided)
  aiPredictions?: AIPredictions;
}

export interface SimulationResponse {
  id: string;
  name: string;
  description: string;
  beamLength: number;
  beamWidth: number;
  beamHeight: number;
  materialType: MaterialType;
  elasticModulus: number;
  density: number;
  yieldStrength: number;
  loadType: LoadType;
  loadMagnitude: number;
  loadPosition: number;
  supportType: SupportType;
  status: SimulationStatus;
  isPublic: boolean;
  isFavorite: boolean;
  likesCount: number;
  results: SimulationResults;
  userId: string;
  userName: string;
  createdAt: string;
  updatedAt: string;
}

export type MaterialType = 'STEEL' | 'CONCRETE' | 'ALUMINUM' | 'WOOD' | 'COMPOSITE';
export type LoadType = 'POINT' | 'UNIFORM' | 'DISTRIBUTED' | 'MOMENT';
export type SupportType = 'SIMPLY_SUPPORTED' | 'FIXED_FIXED' | 'FIXED_FREE' | 'FIXED_PINNED';
export type SimulationStatus = 'PENDING' | 'RUNNING' | 'COMPLETED' | 'FAILED';

@Injectable({
  providedIn: 'root'
})
export class SimulationService {
  private http = inject(HttpClient);
  private readonly API_URL = 'http://localhost:8080/api/v1/simulations';

  // State signals
  private _simulations = signal<SimulationResponse[]>([]);
  private _currentSimulation = signal<SimulationResponse | null>(null);
  private _isLoading = signal(false);

  // Public computed
  simulations = computed(() => this._simulations());
  currentSimulation = computed(() => this._currentSimulation());
  isLoading = computed(() => this._isLoading());

  /**
   * Create new simulation
   */
  createSimulation(request: SimulationRequest): Observable<SimulationResponse> {
    console.log('SimulationService: Creating simulation', request);
    this._isLoading.set(true);

    return this.http.post<ApiResponse<SimulationResponse>>(this.API_URL, request).pipe(
      map(response => {
        console.log('SimulationService: API Response', response);
        // Extract data from wrapped response
        if (response && response.data) {
          return response.data;
        }
        // If not wrapped, return as-is (fallback)
        return response as unknown as SimulationResponse;
      }),
      tap(simulation => {
        console.log('SimulationService: Simulation created', simulation);
        this._currentSimulation.set(simulation);
        // Add to list
        this._simulations.update(list => [simulation, ...list]);
        this._isLoading.set(false);
      }),
      catchError(error => {
        console.error('SimulationService: Create failed', error);
        this._isLoading.set(false);
        return throwError(() => error);
      })
    );
  }

  /**
   * Get simulation by ID
   */
  getSimulation(id: string): Observable<SimulationResponse> {
    console.log('SimulationService: Getting simulation', id);
    this._isLoading.set(true);

    return this.http.get<ApiResponse<SimulationResponse>>(`${this.API_URL}/${id}`).pipe(
      map(response => {
        // Extract data from wrapped response
        if (response && response.data) {
          return response.data;
        }
        return response as unknown as SimulationResponse;
      }),
      tap(simulation => {
        console.log('SimulationService: Got simulation', simulation);
        this._currentSimulation.set(simulation);
        this._isLoading.set(false);
      }),
      catchError(error => {
        console.error('SimulationService: Get failed', error);
        this._isLoading.set(false);
        return throwError(() => error);
      })
    );
  }

  /**
   * Get all user simulations
   */
  getUserSimulations(): Observable<SimulationResponse[]> {
    console.log('SimulationService: Getting user simulations');
    this._isLoading.set(true);

    return this.http.get<SimulationResponse[]>(this.API_URL).pipe(
      tap(simulations => {
        console.log('SimulationService: Got', simulations.length, 'simulations');
        this._simulations.set(simulations);
        this._isLoading.set(false);
      }),
      catchError(error => {
        console.error('SimulationService: Get all failed', error);
        this._isLoading.set(false);
        return throwError(() => error);
      })
    );
  }

  /**
   * Get recent simulations (last 5)
   */
  getRecentSimulations(): Observable<SimulationResponse[]> {
    console.log('SimulationService: Getting recent simulations');

    return this.http.get<SimulationResponse[]>(`${this.API_URL}/recent`).pipe(
      tap(simulations => {
        console.log('SimulationService: Got', simulations.length, 'recent simulations');
      }),
      catchError(error => {
        console.error('SimulationService: Get recent failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Get favorite simulations
   */
  getFavoriteSimulations(): Observable<SimulationResponse[]> {
    console.log('SimulationService: Getting favorites');

    return this.http.get<SimulationResponse[]>(`${this.API_URL}/favorites`).pipe(
      tap(simulations => {
        console.log('SimulationService: Got', simulations.length, 'favorites');
      }),
      catchError(error => {
        console.error('SimulationService: Get favorites failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Get public simulations
   */
  getPublicSimulations(): Observable<SimulationResponse[]> {
    console.log('SimulationService: Getting public simulations');

    return this.http.get<SimulationResponse[]>(`${this.API_URL}/public`).pipe(
      tap(simulations => {
        console.log('SimulationService: Got', simulations.length, 'public simulations');
      }),
      catchError(error => {
        console.error('SimulationService: Get public failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Search public simulations
   */
  searchPublicSimulations(query: string): Observable<SimulationResponse[]> {
    console.log('SimulationService: Searching public for', query);
    const params = new HttpParams().set('q', query);

    return this.http.get<SimulationResponse[]>(`${this.API_URL}/public/search`, { params }).pipe(
      tap(simulations => {
        console.log('SimulationService: Found', simulations.length, 'results');
      }),
      catchError(error => {
        console.error('SimulationService: Search failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Search user simulations
   */
  searchUserSimulations(query: string): Observable<SimulationResponse[]> {
    console.log('SimulationService: Searching user simulations for', query);
    const params = new HttpParams().set('q', query);

    return this.http.get<SimulationResponse[]>(`${this.API_URL}/search`, { params }).pipe(
      tap(simulations => {
        console.log('SimulationService: Found', simulations.length, 'results');
        this._simulations.set(simulations);
      }),
      catchError(error => {
        console.error('SimulationService: Search failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Update simulation
   */
  updateSimulation(id: string, request: SimulationRequest): Observable<SimulationResponse> {
    console.log('SimulationService: Updating simulation', id);
    this._isLoading.set(true);

    return this.http.put<SimulationResponse>(`${this.API_URL}/${id}`, request).pipe(
      tap(simulation => {
        console.log('SimulationService: Updated', simulation);
        this._currentSimulation.set(simulation);
        // Update in list
        this._simulations.update(list =>
          list.map(s => s.id === id ? simulation : s)
        );
        this._isLoading.set(false);
      }),
      catchError(error => {
        console.error('SimulationService: Update failed', error);
        this._isLoading.set(false);
        return throwError(() => error);
      })
    );
  }

  /**
   * Delete simulation
   */
  deleteSimulation(id: string): Observable<{ message: string }> {
    console.log('SimulationService: Deleting simulation', id);

    return this.http.delete<{ message: string }>(`${this.API_URL}/${id}`).pipe(
      tap(() => {
        console.log('SimulationService: Deleted');
        // Remove from list
        this._simulations.update(list => list.filter(s => s.id !== id));
        if (this._currentSimulation()?.id === id) {
          this._currentSimulation.set(null);
        }
      }),
      catchError(error => {
        console.error('SimulationService: Delete failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Toggle favorite
   */
  toggleFavorite(id: string): Observable<SimulationResponse> {
    console.log('SimulationService: Toggling favorite for', id);

    return this.http.post<SimulationResponse>(`${this.API_URL}/${id}/favorite`, {}).pipe(
      tap(simulation => {
        console.log('SimulationService: Favorite toggled to', simulation.isFavorite);
        // Update in list
        this._simulations.update(list =>
          list.map(s => s.id === id ? simulation : s)
        );
        if (this._currentSimulation()?.id === id) {
          this._currentSimulation.set(simulation);
        }
      }),
      catchError(error => {
        console.error('SimulationService: Toggle favorite failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Toggle public
   */
  togglePublic(id: string): Observable<SimulationResponse> {
    console.log('SimulationService: Toggling public for', id);

    return this.http.post<SimulationResponse>(`${this.API_URL}/${id}/public`, {}).pipe(
      tap(simulation => {
        console.log('SimulationService: Public toggled to', simulation.isPublic);
        // Update in list
        this._simulations.update(list =>
          list.map(s => s.id === id ? simulation : s)
        );
        if (this._currentSimulation()?.id === id) {
          this._currentSimulation.set(simulation);
        }
      }),
      catchError(error => {
        console.error('SimulationService: Toggle public failed', error);
        return throwError(() => error);
      })
    );
  }

  /**
   * Clear current simulation
   */
  clearCurrentSimulation(): void {
    this._currentSimulation.set(null);
  }
}
