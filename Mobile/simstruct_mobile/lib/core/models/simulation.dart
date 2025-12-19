import 'package:flutter/material.dart';
import 'simulation_params.dart';
import '../../app/theme/app_colors.dart';

/// Simulation Status Enum
enum SimulationStatus {
  draft,
  running,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case SimulationStatus.draft:
        return 'Draft';
      case SimulationStatus.running:
        return 'Running';
      case SimulationStatus.completed:
        return 'Completed';
      case SimulationStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case SimulationStatus.draft:
        return AppColors.warning;
      case SimulationStatus.running:
        return AppColors.info;
      case SimulationStatus.completed:
        return AppColors.success;
      case SimulationStatus.failed:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case SimulationStatus.draft:
        return Icons.edit_outlined;
      case SimulationStatus.running:
        return Icons.sync;
      case SimulationStatus.completed:
        return Icons.check_circle_outline;
      case SimulationStatus.failed:
        return Icons.error_outline;
    }
  }
}

/// Result Status Enum - Safety Rating
enum ResultStatus {
  safe,
  warning,
  critical;

  String get displayName {
    switch (this) {
      case ResultStatus.safe:
        return 'Safe';
      case ResultStatus.warning:
        return 'Warning';
      case ResultStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case ResultStatus.safe:
        return AppColors.success;
      case ResultStatus.warning:
        return AppColors.warning;
      case ResultStatus.critical:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case ResultStatus.safe:
        return Icons.check_circle;
      case ResultStatus.warning:
        return Icons.warning_amber;
      case ResultStatus.critical:
        return Icons.dangerous;
    }
  }

  String get description {
    switch (this) {
      case ResultStatus.safe:
        return 'Structure meets safety requirements';
      case ResultStatus.warning:
        return 'Caution advised - review recommendations';
      case ResultStatus.critical:
        return 'Structure does not meet safety standards';
    }
  }
}

/// Analysis Result Model
class AnalysisResult {
  final double safetyFactor;
  final double maxDeflection;
  final double maxStress;
  final double bucklingLoad;
  final double naturalFrequency;
  final ResultStatus status;
  final List<String> recommendations;
  final List<StressPoint> stressDistribution;
  final List<DeflectionPoint> deflectionCurve;
  final AIInsight? aiInsight;
  
  // Additional metrics from backend
  final double? maxBendingMoment;
  final double? maxShearForce;
  final double? weight;
  
  // AI Model Predictions
  final double? stabilityIndex;
  final double? seismicResistance;
  final double? crackRisk;
  final double? foundationStability;

  const AnalysisResult({
    required this.safetyFactor,
    required this.maxDeflection,
    required this.maxStress,
    required this.bucklingLoad,
    required this.naturalFrequency,
    required this.status,
    this.recommendations = const [],
    this.stressDistribution = const [],
    this.deflectionCurve = const [],
    this.aiInsight,
    this.maxBendingMoment,
    this.maxShearForce,
    this.weight,
    this.stabilityIndex,
    this.seismicResistance,
    this.crackRisk,
    this.foundationStability,
  });

  /// Check if has AI predictions
  bool get hasAIPredictions => stabilityIndex != null || seismicResistance != null;

  /// Calculate status from safety factor
  static ResultStatus calculateStatus(double safetyFactor) {
    if (safetyFactor >= 2.0) return ResultStatus.safe;
    if (safetyFactor >= 1.5) return ResultStatus.warning;
    return ResultStatus.critical;
  }

  Map<String, dynamic> toJson() {
    return {
      'safetyFactor': safetyFactor,
      'maxDeflection': maxDeflection,
      'maxStress': maxStress,
      'bucklingLoad': bucklingLoad,
      'naturalFrequency': naturalFrequency,
      'status': status.name,
      'recommendations': recommendations,
      'stressDistribution': stressDistribution.map((e) => e.toJson()).toList(),
      'deflectionCurve': deflectionCurve.map((e) => e.toJson()).toList(),
      'aiInsight': aiInsight?.toJson(),
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      safetyFactor: (json['safetyFactor'] as num?)?.toDouble() ?? 0.0,
      maxDeflection: (json['maxDeflection'] as num?)?.toDouble() ?? 0.0,
      maxStress: (json['maxStress'] as num?)?.toDouble() ?? 0.0,
      bucklingLoad: (json['bucklingLoad'] ?? json['criticalLoad'] as num?)?.toDouble() ?? 0.0,
      naturalFrequency: (json['naturalFrequency'] as num?)?.toDouble() ?? 0.0,
      status: ResultStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ResultStatus.warning,
      ),
      recommendations: json['recommendations'] is String 
          ? [json['recommendations']] 
          : List<String>.from(json['recommendations'] ?? []),
      stressDistribution: (json['stressDistribution'] as List?)
              ?.map((e) => StressPoint.fromJson(e))
              .toList() ??
          [],
      deflectionCurve: (json['deflectionCurve'] as List?)
              ?.map((e) => DeflectionPoint.fromJson(e))
              .toList() ??
          [],
      aiInsight: json['aiInsight'] != null
          ? AIInsight.fromJson(json['aiInsight'])
          : null,
      maxBendingMoment: (json['maxBendingMoment'] as num?)?.toDouble(),
      maxShearForce: (json['maxShearForce'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      stabilityIndex: (json['stabilityIndex'] as num?)?.toDouble(),
      seismicResistance: (json['seismicResistance'] as num?)?.toDouble(),
      crackRisk: (json['crackRisk'] as num?)?.toDouble(),
      foundationStability: (json['foundationStability'] as num?)?.toDouble(),
    );
  }
}

/// Stress Point for Visualization
class StressPoint {
  final double position;
  final double stress;
  final double normalizedStress; // 0.0 - 1.0 for color mapping

  const StressPoint({
    required this.position,
    required this.stress,
    required this.normalizedStress,
  });

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'stress': stress,
      'normalizedStress': normalizedStress,
    };
  }

  factory StressPoint.fromJson(Map<String, dynamic> json) {
    return StressPoint(
      position: (json['position'] as num).toDouble(),
      stress: (json['stress'] as num).toDouble(),
      normalizedStress: (json['normalizedStress'] as num).toDouble(),
    );
  }
}

/// Deflection Point for Curve
class DeflectionPoint {
  final double position;
  final double deflection;

  const DeflectionPoint({
    required this.position,
    required this.deflection,
  });

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'deflection': deflection,
    };
  }

  factory DeflectionPoint.fromJson(Map<String, dynamic> json) {
    return DeflectionPoint(
      position: (json['position'] as num).toDouble(),
      deflection: (json['deflection'] as num).toDouble(),
    );
  }
}

/// AI-Generated Insight
class AIInsight {
  final String summary;
  final List<String> keyFindings;
  final List<String> improvements;
  final double confidenceScore;
  final DateTime generatedAt;

  const AIInsight({
    required this.summary,
    required this.keyFindings,
    required this.improvements,
    required this.confidenceScore,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'keyFindings': keyFindings,
      'improvements': improvements,
      'confidenceScore': confidenceScore,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      summary: json['summary'] ?? '',
      keyFindings: List<String>.from(json['keyFindings'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.85,
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Main Simulation Model
class Simulation {
  final String id;
  final String name;
  final String? description;
  final String userId;
  final SimulationParams params;
  final SimulationStatus status;
  final AnalysisResult? result;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isShared;
  final List<String> tags;

  const Simulation({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.params,
    this.status = SimulationStatus.draft,
    this.result,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isShared = false,
    this.tags = const [],
  });

  /// Check if simulation has results
  bool get hasResult => result != null && status == SimulationStatus.completed;

  /// Alias for isShared (for backward compatibility)
  bool get isPublic => isShared;

  /// Get display subtitle
  String get subtitle {
    return '${params.structureType.displayName} • ${params.material.displayName}';
  }

  /// Get time since creation
  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  Simulation copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    SimulationParams? params,
    SimulationStatus? status,
    AnalysisResult? result,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isShared,
    List<String>? tags,
  }) {
    return Simulation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      params: params ?? this.params,
      status: status ?? this.status,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isShared: isShared ?? this.isShared,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'params': params.toJson(),
      'status': status.name,
      'result': result?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isShared': isShared,
      'tags': tags,
    };
  }

  factory Simulation.fromJson(Map<String, dynamic> json) {
    return Simulation(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Untitled Simulation',
      description: json['description'],
      userId: json['userId'] ?? '',
      params: SimulationParams.fromJson(json['params'] ?? {}),
      status: SimulationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SimulationStatus.draft,
      ),
      result: json['result'] != null
          ? AnalysisResult.fromJson(json['result'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isFavorite: json['isFavorite'] ?? false,
      isShared: json['isShared'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Create a new draft simulation
  factory Simulation.create({
    required String userId,
    String? name,
    SimulationParams? params,
  }) {
    final now = DateTime.now();
    return Simulation(
      id: 'sim_${now.millisecondsSinceEpoch}',
      name: name ?? 'Simulation ${now.day}/${now.month}/${now.year}',
      userId: userId,
      params: params ?? const SimulationParams(),
      status: SimulationStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Simulation Summary for Lists
class SimulationSummary {
  final String id;
  final String name;
  final StructureType structureType;
  final StructuralMaterial material;
  final SimulationStatus status;
  final ResultStatus? resultStatus;
  final DateTime createdAt;
  final bool isFavorite;

  const SimulationSummary({
    required this.id,
    required this.name,
    required this.structureType,
    required this.material,
    required this.status,
    this.resultStatus,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory SimulationSummary.fromSimulation(Simulation sim) {
    return SimulationSummary(
      id: sim.id,
      name: sim.name,
      structureType: sim.params.structureType,
      material: sim.params.material,
      status: sim.status,
      resultStatus: sim.result?.status,
      createdAt: sim.createdAt,
      isFavorite: sim.isFavorite,
    );
  }

  factory SimulationSummary.fromJson(Map<String, dynamic> json) {
    return SimulationSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      structureType: StructureType.values.firstWhere(
        (e) => e.name == json['structureType'],
        orElse: () => StructureType.beam,
      ),
      material: StructuralMaterial.values.firstWhere(
        (e) => e.name == json['material'],
        orElse: () => StructuralMaterial.steel,
      ),
      status: SimulationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SimulationStatus.draft,
      ),
      resultStatus: json['resultStatus'] != null
          ? ResultStatus.values.firstWhere(
              (e) => e.name == json['resultStatus'],
              orElse: () => ResultStatus.warning,
            )
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
