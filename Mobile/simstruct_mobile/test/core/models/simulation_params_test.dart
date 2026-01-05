import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/core/models/simulation_params.dart';

void main() {
  group('StructureType', () {
    test('should have all enum values', () {
      expect(StructureType.values.length, 4);
      expect(StructureType.beam, isNotNull);
      expect(StructureType.frame, isNotNull);
      expect(StructureType.truss, isNotNull);
      expect(StructureType.column, isNotNull);
    });

    test('should have correct display names', () {
      expect(StructureType.beam.displayName, 'Beam');
      expect(StructureType.frame.displayName, 'Frame');
      expect(StructureType.truss.displayName, 'Truss');
      expect(StructureType.column.displayName, 'Column');
    });

    test('should have icon strings', () {
      expect(StructureType.beam.icon, isNotEmpty);
      expect(StructureType.frame.icon, isNotEmpty);
      expect(StructureType.truss.icon, isNotEmpty);
      expect(StructureType.column.icon, isNotEmpty);
    });

    test('should have descriptions', () {
      expect(StructureType.beam.description, contains('beam'));
      expect(StructureType.frame.description, contains('frame'));
      expect(StructureType.truss.description, contains('Truss'));
      expect(StructureType.column.description, contains('column'));
    });

    test('should have iconData', () {
      expect(StructureType.beam.iconData, isA<IconData>());
      expect(StructureType.frame.iconData, isA<IconData>());
      expect(StructureType.truss.iconData, isA<IconData>());
      expect(StructureType.column.iconData, isA<IconData>());
    });
  });

  group('StructuralMaterial', () {
    test('should have all enum values', () {
      expect(StructuralMaterial.values.length, 4);
      expect(StructuralMaterial.steel, isNotNull);
      expect(StructuralMaterial.concrete, isNotNull);
      expect(StructuralMaterial.aluminum, isNotNull);
      expect(StructuralMaterial.wood, isNotNull);
    });

    test('should have correct display names', () {
      expect(StructuralMaterial.steel.displayName, 'Steel');
      expect(StructuralMaterial.concrete.displayName, 'Concrete');
      expect(StructuralMaterial.aluminum.displayName, 'Aluminum');
      expect(StructuralMaterial.wood.displayName, 'Wood');
    });

    test('should have colors', () {
      expect(StructuralMaterial.steel.color, isA<Color>());
      expect(StructuralMaterial.concrete.color, isA<Color>());
      expect(StructuralMaterial.aluminum.color, isA<Color>());
      expect(StructuralMaterial.wood.color, isA<Color>());
    });

    test('should have descriptions', () {
      expect(StructuralMaterial.steel.description, isNotEmpty);
      expect(StructuralMaterial.concrete.description, isNotEmpty);
      expect(StructuralMaterial.aluminum.description, isNotEmpty);
      expect(StructuralMaterial.wood.description, isNotEmpty);
    });

    test('should have iconData', () {
      expect(StructuralMaterial.steel.iconData, isA<IconData>());
      expect(StructuralMaterial.concrete.iconData, isA<IconData>());
      expect(StructuralMaterial.aluminum.iconData, isA<IconData>());
      expect(StructuralMaterial.wood.iconData, isA<IconData>());
    });
  });

  group('LoadType', () {
    test('should have all enum values', () {
      expect(LoadType.values.length, 3);
      expect(LoadType.point, isNotNull);
      expect(LoadType.distributed, isNotNull);
      expect(LoadType.moment, isNotNull);
    });

    test('should have correct display names', () {
      expect(LoadType.point.displayName, 'Point Load');
      expect(LoadType.distributed.displayName, 'Distributed');
      expect(LoadType.moment.displayName, 'Moment');
    });

    test('should have icons', () {
      expect(LoadType.point.icon, isNotEmpty);
      expect(LoadType.distributed.icon, isNotEmpty);
      expect(LoadType.moment.icon, isNotEmpty);
    });

    test('should have iconData', () {
      expect(LoadType.point.iconData, isA<IconData>());
      expect(LoadType.distributed.iconData, isA<IconData>());
      expect(LoadType.moment.iconData, isA<IconData>());
    });
  });

  group('SupportType', () {
    test('should have all enum values', () {
      expect(SupportType.values.length, greaterThanOrEqualTo(3));
      expect(SupportType.simplySupported, isNotNull);
      expect(SupportType.cantilever, isNotNull);
      expect(SupportType.fixed, isNotNull);
    });

    test('should have correct display names', () {
      expect(SupportType.simplySupported.displayName, 'Simply Supported');
      expect(SupportType.cantilever.displayName, 'Cantilever');
      expect(SupportType.fixed.displayName, isNotEmpty);
    });
  });

  group('DimensionUnits', () {
    test('should have all enum values', () {
      expect(DimensionUnits.values.length, 4);
      expect(DimensionUnits.meters, isNotNull);
      expect(DimensionUnits.centimeters, isNotNull);
      expect(DimensionUnits.feet, isNotNull);
      expect(DimensionUnits.inches, isNotNull);
    });

    test('should have correct display names', () {
      expect(DimensionUnits.meters.displayName, 'Meters');
      expect(DimensionUnits.centimeters.displayName, 'Centimeters');
      expect(DimensionUnits.feet.displayName, 'Feet');
      expect(DimensionUnits.inches.displayName, 'Inches');
    });

    test('should have symbols', () {
      expect(DimensionUnits.meters.symbol, 'm');
      expect(DimensionUnits.centimeters.symbol, 'cm');
      expect(DimensionUnits.feet.symbol, 'ft');
      expect(DimensionUnits.inches.symbol, 'in');
    });
  });

  group('LoadUnits', () {
    test('should have all enum values', () {
      expect(LoadUnits.values.length, 4);
      expect(LoadUnits.kN, isNotNull);
      expect(LoadUnits.N, isNotNull);
      expect(LoadUnits.lbs, isNotNull);
      expect(LoadUnits.kips, isNotNull);
    });

    test('should have correct display names', () {
      expect(LoadUnits.kN.displayName, 'Kilonewtons');
      expect(LoadUnits.N.displayName, 'Newtons');
      expect(LoadUnits.lbs.displayName, 'Pounds');
      expect(LoadUnits.kips.displayName, 'Kips');
    });

    test('should have symbols', () {
      expect(LoadUnits.kN.symbol, 'kN');
      expect(LoadUnits.N.symbol, 'N');
      expect(LoadUnits.lbs.symbol, 'lbs');
      expect(LoadUnits.kips.symbol, 'kips');
    });
  });

  group('SimulationParams', () {
    test('should create with default values', () {
      const params = SimulationParams();
      
      expect(params.structureType, StructureType.beam);
      expect(params.length, 10.0);
      expect(params.width, 0.5);
      expect(params.height, 0.8);
      expect(params.material, StructuralMaterial.steel);
      expect(params.loadType, LoadType.point);
      expect(params.supportType, SupportType.simplySupported);
    });

    test('should create with custom values', () {
      const params = SimulationParams(
        structureType: StructureType.frame,
        length: 15.0,
        width: 1.0,
        height: 2.0,
        material: StructuralMaterial.concrete,
        loadType: LoadType.distributed,
        supportType: SupportType.fixed,
      );
      
      expect(params.structureType, StructureType.frame);
      expect(params.length, 15.0);
      expect(params.width, 1.0);
      expect(params.height, 2.0);
      expect(params.material, StructuralMaterial.concrete);
      expect(params.loadType, LoadType.distributed);
      expect(params.supportType, SupportType.fixed);
    });

    test('should have elastic modulus default', () {
      const params = SimulationParams();
      expect(params.elasticModulus, 200);
    });

    test('should have density default', () {
      const params = SimulationParams();
      expect(params.density, 7850);
    });

    test('should have yield strength default', () {
      const params = SimulationParams();
      expect(params.yieldStrength, 250);
    });

    test('should have load magnitude default', () {
      const params = SimulationParams();
      expect(params.loadMagnitude, 50);
    });

    test('should have load position default', () {
      const params = SimulationParams();
      expect(params.loadPosition, 50);
    });

    test('should have dimension units default', () {
      const params = SimulationParams();
      expect(params.dimensionUnits, DimensionUnits.meters);
    });

    test('should have load units default', () {
      const params = SimulationParams();
      expect(params.loadUnits, LoadUnits.kN);
    });

    test('should have AI building parameters', () {
      const params = SimulationParams();
      expect(params.numFloors, 5);
      expect(params.floorHeight, 3.0);
      expect(params.numBeams, 50);
      expect(params.numColumns, 20);
      expect(params.beamSection, 40);
      expect(params.columnSection, 50);
      expect(params.concreteStrength, 30);
      expect(params.steelGrade, 355);
      expect(params.windLoad, 1.5);
      expect(params.liveLoad, 3.0);
      expect(params.deadLoad, 5.0);
    });

    test('should create custom AI building parameters', () {
      const params = SimulationParams(
        numFloors: 10,
        floorHeight: 4.0,
        numBeams: 100,
        numColumns: 40,
        beamSection: 50,
        columnSection: 60,
        concreteStrength: 40,
        steelGrade: 400,
        windLoad: 2.0,
        liveLoad: 4.0,
        deadLoad: 6.0,
      );
      
      expect(params.numFloors, 10);
      expect(params.floorHeight, 4.0);
      expect(params.numBeams, 100);
      expect(params.numColumns, 40);
      expect(params.beamSection, 50);
      expect(params.columnSection, 60);
      expect(params.concreteStrength, 40);
      expect(params.steelGrade, 400);
      expect(params.windLoad, 2.0);
      expect(params.liveLoad, 4.0);
      expect(params.deadLoad, 6.0);
    });
  });
}
