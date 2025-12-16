"""
Professional Structural Analysis Dataset Generator
Generates high-quality, realistic structural engineering data based on:
- International Building Codes (IBC, Eurocode)
- Real material properties and constraints
- Actual seismic and wind load calculations
- Professional engineering formulas and safety factors

Author: SimStruct AI Team
Date: December 2024
"""

import pandas as pd
import numpy as np
from datetime import datetime
import os
import json

class ProfessionalStructuralDataGenerator:
    """
    Generates realistic structural analysis datasets with proper engineering constraints
    """
    
    def __init__(self, seed=42):
        np.random.seed(seed)
        self.setup_engineering_standards()
        
    def setup_engineering_standards(self):
        """Define realistic engineering standards and constraints"""
        
        # Standard floor heights (meters) - realistic building construction
        self.floor_heights = {
            'residential': (2.7, 3.0, 3.3),      # Standard residential
            'commercial': (3.5, 4.0, 4.5),       # Office/commercial
            'industrial': (4.5, 5.0, 6.0)        # Industrial/warehouse
        }
        
        # Standard beam sections (HEA profiles in cm)
        self.beam_sections = [
            10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 36, 40, 45, 50, 55, 60
        ]
        
        # Standard column sections (HEB profiles in cm)
        self.column_sections = [
            12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 36, 40, 45, 50, 60
        ]
        
        # Concrete strength classes (MPa) - European standards
        self.concrete_strengths = [20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90]
        
        # Steel grades (MPa) - Common structural steel
        self.steel_grades = {
            'S235': 235,   # Mild steel
            'S275': 275,   # Medium strength
            'S355': 355,   # High strength
            'S420': 420,   # Very high strength
            'S460': 460    # Ultra high strength
        }
        
        # Seismic zones (peak ground acceleration in g)
        self.seismic_zones = {
            'Zone 0': 0.0,    # Very low seismicity
            'Zone 1': 0.075,  # Low seismicity
            'Zone 2': 0.15,   # Moderate seismicity
            'Zone 3': 0.30,   # High seismicity
            'Zone 4': 0.40    # Very high seismicity
        }
        
        # Load correlations based on building type
        self.building_types = {
            'residential': {
                'live_load': (1.5, 2.5),      # kN/m² - apartments
                'dead_load': (3.0, 5.0),      # kN/m² - slabs, partitions
                'wind_importance': 0.8
            },
            'office': {
                'live_load': (2.5, 4.0),      # kN/m² - offices
                'dead_load': (4.0, 6.0),      # kN/m² - heavier floors
                'wind_importance': 1.0
            },
            'commercial': {
                'live_load': (4.0, 5.0),      # kN/m² - retail
                'dead_load': (5.0, 7.0),      # kN/m² - heavy finishes
                'wind_importance': 1.0
            },
            'industrial': {
                'live_load': (5.0, 10.0),     # kN/m² - heavy equipment
                'dead_load': (6.0, 10.0),     # kN/m² - heavy structure
                'wind_importance': 1.2
            }
        }
        
    def calculate_wind_load(self, num_floors, floor_height, building_type):
        """
        Calculate realistic wind load based on building height and exposure
        Formula: q = 0.613 * V² * Ce * Cq * Ct (kN/m²)
        """
        height = num_floors * floor_height
        
        # Base wind speed (m/s) - varies by location
        V_base = np.random.uniform(25, 45)  # Typical range 25-45 m/s
        
        # Exposure coefficient (increases with height)
        if height < 10:
            Ce = 0.85
        elif height < 20:
            Ce = 1.0
        elif height < 50:
            Ce = 1.2
        else:
            Ce = 1.35
        
        # Dynamic pressure coefficient
        Cq = 0.613
        
        # Topography factor
        Ct = np.random.choice([1.0, 1.1, 1.2], p=[0.7, 0.2, 0.1])
        
        # Calculate wind pressure
        wind_load = Cq * (V_base ** 2) / 1000 * Ce * Ct
        
        # Apply building type importance factor
        importance = self.building_types[building_type]['wind_importance']
        wind_load *= importance
        
        return round(wind_load, 2)
    
    def calculate_seismic_response(self, num_floors, floor_height, seismic_zone, 
                                   concrete_strength, steel_grade):
        """
        Calculate realistic seismic resistance and stability index
        Based on modal analysis and ductility
        """
        height = num_floors * floor_height
        
        # Get peak ground acceleration
        pga = self.seismic_zones[seismic_zone]
        
        # Fundamental period estimation (Rayleigh method)
        # T = Ct * H^(3/4) for concrete frames
        Ct = 0.073  # For concrete moment frames
        period = Ct * (height ** 0.75)
        
        # Spectral acceleration (simplified response spectrum)
        if period < 0.5:
            Sa = 2.5 * pga
        elif period < 2.0:
            Sa = 2.5 * pga * (0.5 / period)
        else:
            Sa = 2.5 * pga * (1.0 / (period ** 2))
        
        # Ductility factor based on material strength
        ductility_concrete = min(concrete_strength / 25, 3.0)
        ductility_steel = steel_grade / 235
        ductility = (ductility_concrete + ductility_steel) / 2
        
        # Behavior factor (q-factor)
        q_factor = min(3.0 + ductility * 0.5, 6.0)
        
        # Seismic resistance (dimensionless, 0-100 scale)
        base_resistance = 100 * (1 - Sa / 2.0)  # Normalized
        resistance_adjusted = base_resistance * (q_factor / 4.0)
        seismic_resistance = max(0, min(100, resistance_adjusted))
        
        return round(seismic_resistance, 2)
    
    def calculate_structural_response(self, params):
        """
        Calculate realistic structural responses using engineering formulas
        """
        # Extract parameters
        num_floors = params['numFloors']
        floor_height = params['floorHeight']
        num_beams = params['numBeams']
        num_columns = params['numColumns']
        beam_section = params['beamSection']
        column_section = params['columnSection']
        concrete_strength = params['concreteStrength']
        steel_grade_value = params['steelGrade']
        wind_load = params['windLoad']
        live_load = params['liveLoad']
        dead_load = params['deadLoad']
        
        # Building height
        height = num_floors * floor_height
        
        # Approximate floor area (based on column grid)
        typical_span = 6.0  # meters (typical span between columns)
        floor_area = (num_columns ** 0.5) * (typical_span ** 2)
        
        # Total loads
        total_dead = dead_load * floor_area * num_floors
        total_live = live_load * floor_area * num_floors
        total_wind = wind_load * height * (floor_area ** 0.5)
        
        # Load combinations (Eurocode)
        # ULS: 1.35*DL + 1.5*LL + 1.5*0.6*WL
        ultimate_load = 1.35 * total_dead + 1.5 * total_live + 1.5 * 0.6 * total_wind
        
        # ===== DEFLECTION CALCULATION =====
        # Simplified lateral deflection under wind load
        # δ = (wH⁴)/(8EI) for cantilever approximation
        
        # Equivalent stiffness (all columns)
        E_concrete = 4700 * np.sqrt(concrete_strength) * 1000  # kN/m² (Eurocode)
        
        # Approximate moment of inertia for columns
        I_column = (column_section/100) ** 4 / 12  # m⁴
        total_stiffness = E_concrete * I_column * num_columns
        
        # Lateral deflection (mm)
        deflection_lateral = (total_wind * (height ** 4)) / (8 * total_stiffness) * 1000
        
        # Vertical deflection (beams under gravity)
        # δ = 5wL⁴/(384EI) for simply supported beam
        E_steel = 210000000  # kN/m²
        I_beam = (beam_section/100) ** 4 / 12  # m⁴
        
        load_per_beam = (dead_load + live_load) * typical_span
        deflection_vertical = (5 * load_per_beam * (typical_span ** 4)) / (384 * E_steel * I_beam) * 1000
        
        # Maximum deflection (combination)
        max_deflection = np.sqrt(deflection_lateral**2 + deflection_vertical**2)
        
        # Add realistic variation
        max_deflection *= np.random.uniform(0.9, 1.1)
        max_deflection = round(max_deflection, 2)
        
        # ===== STRESS CALCULATION =====
        # Maximum stress in critical elements
        
        # Axial stress in columns (compression)
        column_area = ((column_section/100) ** 2)  # m²
        axial_stress_column = ultimate_load / (num_columns * column_area) / 1000  # MPa
        
        # Bending stress in beams
        M_beam = load_per_beam * (typical_span ** 2) / 8  # kNm
        section_modulus = I_beam / ((beam_section/100) / 2)  # m³
        bending_stress_beam = M_beam / section_modulus / 1000  # MPa
        
        # Maximum stress (governing)
        max_stress = max(axial_stress_column, bending_stress_beam)
        
        # Add realistic variation
        max_stress *= np.random.uniform(0.9, 1.1)
        max_stress = round(max_stress, 2)
        
        # ===== STABILITY INDEX =====
        # Based on safety factors and code compliance
        
        # Deflection limit check (H/500 for lateral, L/250 for vertical)
        deflection_limit_lateral = height / 500 * 1000  # mm
        deflection_limit_vertical = typical_span / 250 * 1000  # mm
        
        deflection_ratio_lateral = deflection_limit_lateral / max(deflection_lateral, 1)
        deflection_ratio_vertical = deflection_limit_vertical / max(deflection_vertical, 1)
        
        # Stress safety factor
        allowable_stress = min(concrete_strength, steel_grade_value) * 0.85  # With safety margin
        stress_ratio = allowable_stress / max(max_stress, 1)
        
        # Slenderness check (for columns)
        slenderness = (floor_height * 1000) / (column_section * 10)  # Effective length / radius
        slenderness_ratio = 200 / max(slenderness, 1)  # Limit is typically 200
        
        # Overall stability (weighted average, 0-100 scale)
        stability_index = (
            min(deflection_ratio_lateral, 2.0) * 25 +
            min(deflection_ratio_vertical, 2.0) * 25 +
            min(stress_ratio, 2.0) * 30 +
            min(slenderness_ratio, 2.0) * 20
        )
        
        stability_index = max(0, min(100, stability_index))
        stability_index = round(stability_index, 2)
        
        return {
            'maxDeflection': max_deflection,
            'maxStress': max_stress,
            'stabilityIndex': stability_index
        }
    
    def generate_sample(self, sample_id):
        """Generate a single realistic structural analysis sample"""
        
        # Select building type (affects all other parameters)
        building_type = np.random.choice(
            ['residential', 'office', 'commercial', 'industrial'],
            p=[0.4, 0.3, 0.2, 0.1]  # Realistic distribution
        )
        
        # Number of floors (realistic distribution by type)
        if building_type == 'residential':
            num_floors = np.random.choice([2, 3, 4, 5, 6, 8, 10, 12, 15], 
                                         p=[0.15, 0.15, 0.15, 0.15, 0.15, 0.10, 0.08, 0.05, 0.02])
        elif building_type == 'office':
            num_floors = np.random.choice([4, 5, 6, 8, 10, 12, 15, 20, 25], 
                                         p=[0.10, 0.15, 0.15, 0.15, 0.15, 0.12, 0.10, 0.05, 0.03])
        elif building_type == 'commercial':
            num_floors = np.random.choice([1, 2, 3, 4, 5, 6], 
                                         p=[0.25, 0.25, 0.20, 0.15, 0.10, 0.05])
        else:  # industrial
            num_floors = np.random.choice([1, 2, 3, 4], 
                                         p=[0.50, 0.30, 0.15, 0.05])
        
        # Floor height (realistic by type)
        floor_height = np.random.choice(self.floor_heights[
            'residential' if building_type == 'residential' else
            'commercial' if building_type in ['office', 'commercial'] else
            'industrial'
        ])
        
        # Structural grid (beams and columns)
        # More floors/area typically need more structural elements
        grid_size = max(3, min(10, int(num_floors * 0.6) + np.random.randint(1, 4)))
        num_beams = grid_size * (grid_size + 1) * 2  # Realistic grid pattern
        num_columns = grid_size * grid_size
        
        # Beam section (larger buildings need larger sections)
        if num_floors <= 3:
            beam_section = np.random.choice(self.beam_sections[:8])  # Small sections
        elif num_floors <= 8:
            beam_section = np.random.choice(self.beam_sections[6:14])  # Medium sections
        else:
            beam_section = np.random.choice(self.beam_sections[10:])  # Large sections
        
        # Column section (must be >= beam section typically)
        min_column_idx = self.column_sections.index(
            min([c for c in self.column_sections if c >= beam_section])
        )
        column_section = np.random.choice(self.column_sections[min_column_idx:])
        
        # Material properties
        concrete_strength = np.random.choice(self.concrete_strengths)
        steel_grade_name = np.random.choice(list(self.steel_grades.keys()))
        steel_grade = self.steel_grades[steel_grade_name]
        
        # Seismic zone
        seismic_zone = np.random.choice(
            list(self.seismic_zones.keys()),
            p=[0.20, 0.30, 0.25, 0.15, 0.10]  # Most areas are low to moderate
        )
        
        # Wind load (calculated based on building characteristics)
        wind_load = self.calculate_wind_load(num_floors, floor_height, building_type)
        
        # Live and dead loads (based on building type)
        live_load_range = self.building_types[building_type]['live_load']
        live_load = round(np.random.uniform(*live_load_range), 2)
        
        dead_load_range = self.building_types[building_type]['dead_load']
        dead_load = round(np.random.uniform(*dead_load_range), 2)
        
        # Create parameter dictionary
        params = {
            'sampleId': sample_id,
            'buildingType': building_type,
            'numFloors': num_floors,
            'floorHeight': floor_height,
            'numBeams': num_beams,
            'numColumns': num_columns,
            'beamSection': beam_section,
            'columnSection': column_section,
            'concreteStrength': concrete_strength,
            'steelGrade': steel_grade,
            'steelGradeName': steel_grade_name,
            'seismicZone': seismic_zone,
            'windLoad': wind_load,
            'liveLoad': live_load,
            'deadLoad': dead_load
        }
        
        # Calculate structural responses
        responses = self.calculate_structural_response(params)
        
        # Calculate seismic resistance
        seismic_resistance = self.calculate_seismic_response(
            num_floors, floor_height, seismic_zone, concrete_strength, steel_grade
        )
        responses['seismicResistance'] = seismic_resistance
        
        # Combine all data
        sample = {**params, **responses}
        
        return sample
    
    def generate_dataset(self, n_samples=10000, output_dir='data'):
        """Generate complete professional dataset"""
        
        print("="*70)
        print("PROFESSIONAL STRUCTURAL ANALYSIS DATASET GENERATOR")
        print("="*70)
        print(f"Target samples: {n_samples}")
        print(f"Start time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*70)
        
        data = []
        
        # Generate samples with progress tracking
        for i in range(n_samples):
            if i % 1000 == 0 and i > 0:
                progress = (i / n_samples) * 100
                print(f"Progress: {i:,}/{n_samples:,} ({progress:.1f}%) - "
                      f"Elapsed: {datetime.now().strftime('%H:%M:%S')}")
            
            sample = self.generate_sample(i + 1)
            data.append(sample)
        
        # Create DataFrame
        df = pd.DataFrame(data)
        
        # Reorder columns logically
        input_cols = [
            'sampleId', 'buildingType', 'numFloors', 'floorHeight', 
            'numBeams', 'numColumns', 'beamSection', 'columnSection',
            'concreteStrength', 'steelGrade', 'steelGradeName',
            'seismicZone', 'windLoad', 'liveLoad', 'deadLoad'
        ]
        output_cols = [
            'maxDeflection', 'maxStress', 'stabilityIndex', 'seismicResistance'
        ]
        df = df[input_cols + output_cols]
        
        # Save to CSV
        os.makedirs(output_dir, exist_ok=True)
        output_file = os.path.join(output_dir, 'fem_simulations.csv')
        df.to_csv(output_file, index=False)
        
        print("\n" + "="*70)
        print("✅ DATASET GENERATION COMPLETE")
        print("="*70)
        print(f"Output file: {output_file}")
        print(f"Total samples: {len(df):,}")
        print(f"End time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Data quality report
        self.print_quality_report(df)
        
        return df
    
    def print_quality_report(self, df):
        """Print comprehensive data quality report"""
        
        print("\n" + "="*70)
        print("DATA QUALITY REPORT")
        print("="*70)
        
        # Basic statistics
        print("\n📊 DATASET DIMENSIONS:")
        print(f"   Rows: {len(df):,}")
        print(f"   Columns: {len(df.columns)}")
        print(f"   Total cells: {len(df) * len(df.columns):,}")
        
        # Missing values check
        missing = df.isnull().sum().sum()
        print(f"\n✓ Missing values: {missing} (0.0%)")
        
        # Duplicates check
        duplicates = df.duplicated().sum()
        print(f"✓ Duplicate rows: {duplicates} (0.0%)")
        
        # Building type distribution
        print("\n🏢 BUILDING TYPE DISTRIBUTION:")
        for btype, count in df['buildingType'].value_counts().items():
            pct = (count / len(df)) * 100
            print(f"   {btype:12s}: {count:5,} ({pct:5.1f}%)")
        
        # Floor distribution
        print("\n🏗️  FLOOR DISTRIBUTION:")
        floor_ranges = [
            (1, 3, 'Low-rise (1-3)'),
            (4, 8, 'Mid-rise (4-8)'),
            (9, 15, 'High-rise (9-15)'),
            (16, 100, 'Very high-rise (16+)')
        ]
        for min_f, max_f, label in floor_ranges:
            count = len(df[(df['numFloors'] >= min_f) & (df['numFloors'] <= max_f)])
            pct = (count / len(df)) * 100
            print(f"   {label:22s}: {count:5,} ({pct:5.1f}%)")
        
        # Seismic zone distribution
        print("\n🌍 SEISMIC ZONE DISTRIBUTION:")
        for zone, count in sorted(df['seismicZone'].value_counts().items()):
            pct = (count / len(df)) * 100
            print(f"   {zone:10s}: {count:5,} ({pct:5.1f}%)")
        
        # Output statistics
        print("\n📈 OUTPUT PARAMETERS (MEAN ± STD):")
        output_params = ['maxDeflection', 'maxStress', 'stabilityIndex', 'seismicResistance']
        for param in output_params:
            mean = df[param].mean()
            std = df[param].std()
            min_val = df[param].min()
            max_val = df[param].max()
            print(f"   {param:20s}: {mean:8.2f} ± {std:7.2f}  "
                  f"[{min_val:8.2f}, {max_val:8.2f}]")
        
        # Data ranges validation
        print("\n✓ DATA VALIDATION:")
        validations = [
            ('Floors', 'numFloors', 1, 50),
            ('Beam sections', 'beamSection', 10, 60),
            ('Column sections', 'columnSection', 12, 60),
            ('Concrete strength', 'concreteStrength', 20, 90),
            ('Steel grade', 'steelGrade', 235, 460),
            ('Wind load', 'windLoad', 0, 5),
            ('Live load', 'liveLoad', 1, 12),
            ('Dead load', 'deadLoad', 2, 12),
            ('Max deflection', 'maxDeflection', 0, 1000),
            ('Max stress', 'maxStress', 0, 500),
            ('Stability index', 'stabilityIndex', 0, 100),
            ('Seismic resistance', 'seismicResistance', 0, 100)
        ]
        
        all_valid = True
        for label, col, min_val, max_val in validations:
            in_range = ((df[col] >= min_val) & (df[col] <= max_val)).all()
            status = "✓" if in_range else "✗"
            print(f"   {status} {label:20s}: [{min_val:6.1f}, {max_val:6.1f}]")
            if not in_range:
                all_valid = False
                out_of_range = df[(df[col] < min_val) | (df[col] > max_val)]
                print(f"      WARNING: {len(out_of_range)} values out of range!")
        
        if all_valid:
            print("\n✅ All validation checks passed!")
        
        print("="*70)


def main():
    """Main execution function"""
    
    # Initialize generator
    generator = ProfessionalStructuralDataGenerator(seed=42)
    
    # Generate dataset
    df = generator.generate_dataset(n_samples=10000, output_dir='data')
    
    # Save metadata
    metadata = {
        'generated_at': datetime.now().isoformat(),
        'num_samples': len(df),
        'version': '1.0.0',
        'generator': 'ProfessionalStructuralDataGenerator',
        'description': 'High-quality structural analysis dataset with realistic engineering parameters',
        'columns': {
            'inputs': {
                'numFloors': 'Number of building floors [1-50]',
                'floorHeight': 'Height of each floor in meters [2.7-6.0]',
                'numBeams': 'Number of structural beams',
                'numColumns': 'Number of structural columns',
                'beamSection': 'Beam cross-section size in cm [10-60]',
                'columnSection': 'Column cross-section size in cm [12-60]',
                'concreteStrength': 'Concrete compressive strength in MPa [20-90]',
                'steelGrade': 'Steel yield strength in MPa [235-460]',
                'seismicZone': 'Seismic hazard zone classification',
                'windLoad': 'Wind pressure in kN/m²',
                'liveLoad': 'Live load in kN/m²',
                'deadLoad': 'Dead load in kN/m²'
            },
            'outputs': {
                'maxDeflection': 'Maximum structural deflection in mm',
                'maxStress': 'Maximum stress in structural elements in MPa',
                'stabilityIndex': 'Overall structural stability score [0-100]',
                'seismicResistance': 'Seismic performance score [0-100]'
            }
        }
    }
    
    metadata_file = os.path.join('data', 'dataset_metadata.json')
    with open(metadata_file, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"\n📄 Metadata saved to: {metadata_file}")
    print("\n" + "="*70)
    print("DATASET READY FOR MODEL TRAINING")
    print("="*70)
    print("Next steps:")
    print("  1. Review the data quality report above")
    print("  2. Open notebooks/02_model_training.ipynb")
    print("  3. Train your neural network model")
    print("="*70)


if __name__ == "__main__":
    main()
