import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Structure Type Enum
enum StructureType {
  beam,
  frame,
  truss,
  column;

  String get displayName {
    switch (this) {
      case StructureType.beam:
        return 'Beam';
      case StructureType.frame:
        return 'Frame';
      case StructureType.truss:
        return 'Truss';
      case StructureType.column:
        return 'Column';
    }
  }

  String get icon {
    switch (this) {
      case StructureType.beam:
        return '═══';
      case StructureType.frame:
        return '╔═╗';
      case StructureType.truss:
        return '△△△';
      case StructureType.column:
        return '║║║';
    }
  }

  String get description {
    switch (this) {
      case StructureType.beam:
        return 'Simple beam analysis';
      case StructureType.frame:
        return 'Portal frame structure';
      case StructureType.truss:
        return 'Truss bridge/roof';
      case StructureType.column:
        return 'Vertical column';
    }
  }

  IconData get iconData {
    switch (this) {
      case StructureType.beam:
        return Icons.horizontal_rule;
      case StructureType.frame:
        return Icons.grid_4x4;
      case StructureType.truss:
        return Icons.change_history;
      case StructureType.column:
        return Icons.height;
    }
  }
}

/// Structural Material Type Enum (renamed to avoid Flutter conflict)
enum StructuralMaterial {
  steel,
  concrete,
  aluminum,
  wood;

  String get displayName {
    switch (this) {
      case StructuralMaterial.steel:
        return 'Steel';
      case StructuralMaterial.concrete:
        return 'Concrete';
      case StructuralMaterial.aluminum:
        return 'Aluminum';
      case StructuralMaterial.wood:
        return 'Wood';
    }
  }

  Color get color {
    switch (this) {
      case StructuralMaterial.steel:
        return AppColors.steel;
      case StructuralMaterial.concrete:
        return AppColors.concrete;
      case StructuralMaterial.aluminum:
        return AppColors.aluminum;
      case StructuralMaterial.wood:
        return AppColors.wood;
    }
  }

  String get description {
    switch (this) {
      case StructuralMaterial.steel:
        return 'High strength, widely used';
      case StructuralMaterial.concrete:
        return 'Cost-effective, durable';
      case StructuralMaterial.aluminum:
        return 'Lightweight, corrosion resistant';
      case StructuralMaterial.wood:
        return 'Natural, renewable resource';
    }
  }

  IconData get iconData {
    switch (this) {
      case StructuralMaterial.steel:
        return Icons.settings_applications;
      case StructuralMaterial.concrete:
        return Icons.square;
      case StructuralMaterial.aluminum:
        return Icons.layers;
      case StructuralMaterial.wood:
        return Icons.forest;
    }
  }

  /// Elastic Modulus in GPa
  double get elasticModulus {
    switch (this) {
      case StructuralMaterial.steel:
        return 200;
      case StructuralMaterial.concrete:
        return 30;
      case StructuralMaterial.aluminum:
        return 70;
      case StructuralMaterial.wood:
        return 12;
    }
  }

  /// Density in kg/m³
  double get density {
    switch (this) {
      case StructuralMaterial.steel:
        return 7850;
      case StructuralMaterial.concrete:
        return 2400;
      case StructuralMaterial.aluminum:
        return 2700;
      case StructuralMaterial.wood:
        return 600;
    }
  }

  /// Yield Strength in MPa
  double get yieldStrength {
    switch (this) {
      case StructuralMaterial.steel:
        return 250;
      case StructuralMaterial.concrete:
        return 30;
      case StructuralMaterial.aluminum:
        return 280;
      case StructuralMaterial.wood:
        return 40;
    }
  }
}

/// Load Type Enum
enum LoadType {
  point,
  distributed,
  moment;

  String get displayName {
    switch (this) {
      case LoadType.point:
        return 'Point Load';
      case LoadType.distributed:
        return 'Distributed';
      case LoadType.moment:
        return 'Moment';
    }
  }

  String get icon {
    switch (this) {
      case LoadType.point:
        return '↓';
      case LoadType.distributed:
        return '↓↓↓';
      case LoadType.moment:
        return '↻';
    }
  }

  IconData get iconData {
    switch (this) {
      case LoadType.point:
        return Icons.arrow_downward;
      case LoadType.distributed:
        return Icons.align_vertical_bottom;
      case LoadType.moment:
        return Icons.rotate_right;
    }
  }
}

/// Support Type Enum
enum SupportType {
  simplySupported,
  cantilever,
  fixedFixed,
  pinned,
  fixed,
  roller;

  String get displayName {
    switch (this) {
      case SupportType.simplySupported:
        return 'Simply Supported';
      case SupportType.cantilever:
        return 'Cantilever';
      case SupportType.fixedFixed:
        return 'Fixed-Fixed';
      case SupportType.pinned:
        return 'Pinned';
      case SupportType.fixed:
        return 'Fixed';
      case SupportType.roller:
        return 'Roller';
    }
  }

  String get icon {
    switch (this) {
      case SupportType.simplySupported:
        return '△ △';
      case SupportType.cantilever:
        return '▌  ';
      case SupportType.fixedFixed:
        return '▌ ▐';
      case SupportType.pinned:
        return '△';
      case SupportType.fixed:
        return '▌';
      case SupportType.roller:
        return '○';
    }
  }

  String get description {
    switch (this) {
      case SupportType.simplySupported:
        return 'Allows rotation, no translation';
      case SupportType.cantilever:
        return 'Fixed at one end';
      case SupportType.fixedFixed:
        return 'Fixed at both ends';
      case SupportType.pinned:
        return 'No translation, allows rotation';
      case SupportType.fixed:
        return 'No translation or rotation';
      case SupportType.roller:
        return 'One direction translation';
    }
  }
}

/// Dimension Units Enum
enum DimensionUnits {
  meters,
  feet,
  inches,
  centimeters;

  String get symbol {
    switch (this) {
      case DimensionUnits.meters:
        return 'm';
      case DimensionUnits.feet:
        return 'ft';
      case DimensionUnits.inches:
        return 'in';
      case DimensionUnits.centimeters:
        return 'cm';
    }
  }

  String get displayName {
    switch (this) {
      case DimensionUnits.meters:
        return 'Meters';
      case DimensionUnits.feet:
        return 'Feet';
      case DimensionUnits.inches:
        return 'Inches';
      case DimensionUnits.centimeters:
        return 'Centimeters';
    }
  }
}

/// Load Units Enum
enum LoadUnits {
  kN,
  lbs,
  N,
  kips;

  String get symbol {
    switch (this) {
      case LoadUnits.kN:
        return 'kN';
      case LoadUnits.lbs:
        return 'lbs';
      case LoadUnits.N:
        return 'N';
      case LoadUnits.kips:
        return 'kips';
    }
  }

  String get displayName {
    switch (this) {
      case LoadUnits.kN:
        return 'Kilonewtons';
      case LoadUnits.lbs:
        return 'Pounds';
      case LoadUnits.N:
        return 'Newtons';
      case LoadUnits.kips:
        return 'Kips';
    }
  }
}

/// Simulation Parameters Model
class SimulationParams {
  final StructureType structureType;
  final double length;
  final double width;
  final double height;
  final StructuralMaterial material;
  final double elasticModulus;
  final double density;
  final double yieldStrength;
  final LoadType loadType;
  final double loadMagnitude;
  final double loadPosition;
  final double loadValue;
  final SupportType supportType;
  final DimensionUnits dimensionUnits;
  final LoadUnits loadUnits;

  const SimulationParams({
    this.structureType = StructureType.beam,
    this.length = 10.0,
    this.width = 0.5,
    this.height = 0.8,
    this.material = StructuralMaterial.steel,
    this.elasticModulus = 200,
    this.density = 7850,
    this.yieldStrength = 250,
    this.loadType = LoadType.point,
    this.loadMagnitude = 50,
    this.loadPosition = 50,
    this.loadValue = 100,
    this.supportType = SupportType.simplySupported,
    this.dimensionUnits = DimensionUnits.meters,
    this.loadUnits = LoadUnits.kN,
  });

  /// Create default params for a material
  factory SimulationParams.withMaterial(StructuralMaterial material) {
    return SimulationParams(
      material: material,
      elasticModulus: material.elasticModulus,
      density: material.density,
      yieldStrength: material.yieldStrength,
    );
  }

  SimulationParams copyWith({
    StructureType? structureType,
    double? length,
    double? width,
    double? height,
    StructuralMaterial? material,
    double? elasticModulus,
    double? density,
    double? yieldStrength,
    LoadType? loadType,
    double? loadMagnitude,
    double? loadPosition,
    double? loadValue,
    SupportType? supportType,
    DimensionUnits? dimensionUnits,
    LoadUnits? loadUnits,
  }) {
    final newMaterial = material ?? this.material;
    return SimulationParams(
      structureType: structureType ?? this.structureType,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      material: newMaterial,
      elasticModulus: material != null ? newMaterial.elasticModulus : (elasticModulus ?? this.elasticModulus),
      density: material != null ? newMaterial.density : (density ?? this.density),
      yieldStrength: material != null ? newMaterial.yieldStrength : (yieldStrength ?? this.yieldStrength),
      loadType: loadType ?? this.loadType,
      loadMagnitude: loadMagnitude ?? this.loadMagnitude,
      loadPosition: loadPosition ?? this.loadPosition,
      loadValue: loadValue ?? this.loadValue,
      supportType: supportType ?? this.supportType,
      dimensionUnits: dimensionUnits ?? this.dimensionUnits,
      loadUnits: loadUnits ?? this.loadUnits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'structureType': structureType.name,
      'length': length,
      'width': width,
      'height': height,
      'material': material.name,
      'elasticModulus': elasticModulus,
      'density': density,
      'yieldStrength': yieldStrength,
      'loadType': loadType.name,
      'loadMagnitude': loadMagnitude,
      'loadPosition': loadPosition,
      'loadValue': loadValue,
      'supportType': supportType.name,
      'dimensionUnits': dimensionUnits.name,
      'loadUnits': loadUnits.name,
    };
  }

  factory SimulationParams.fromJson(Map<String, dynamic> json) {
    return SimulationParams(
      structureType: StructureType.values.firstWhere(
        (e) => e.name == json['structureType'],
        orElse: () => StructureType.beam,
      ),
      length: (json['length'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      material: StructuralMaterial.values.firstWhere(
        (e) => e.name == json['material'],
        orElse: () => StructuralMaterial.steel,
      ),
      elasticModulus: (json['elasticModulus'] as num).toDouble(),
      density: (json['density'] as num).toDouble(),
      yieldStrength: (json['yieldStrength'] as num).toDouble(),
      loadType: LoadType.values.firstWhere(
        (e) => e.name == json['loadType'],
        orElse: () => LoadType.point,
      ),
      loadMagnitude: (json['loadMagnitude'] as num).toDouble(),
      loadPosition: (json['loadPosition'] as num).toDouble(),
      loadValue: (json['loadValue'] as num?)?.toDouble() ?? 100,
      supportType: SupportType.values.firstWhere(
        (e) => e.name == json['supportType'],
        orElse: () => SupportType.simplySupported,
      ),
      dimensionUnits: DimensionUnits.values.firstWhere(
        (e) => e.name == json['dimensionUnits'],
        orElse: () => DimensionUnits.meters,
      ),
      loadUnits: LoadUnits.values.firstWhere(
        (e) => e.name == json['loadUnits'],
        orElse: () => LoadUnits.kN,
      ),
    );
  }
}
