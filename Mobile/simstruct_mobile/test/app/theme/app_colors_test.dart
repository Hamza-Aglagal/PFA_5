import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/app/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('should have primary color', () {
        expect(AppColors.primary, isA<Color>());
        expect(AppColors.primary, const Color(0xFF2D3142));
      });

      test('should have primaryLight color', () {
        expect(AppColors.primaryLight, isA<Color>());
      });

      test('should have primaryDark color', () {
        expect(AppColors.primaryDark, isA<Color>());
      });

      test('should have primarySoft color', () {
        expect(AppColors.primarySoft, isA<Color>());
      });

      test('should have primaryMuted color', () {
        expect(AppColors.primaryMuted, isA<Color>());
      });
    });

    group('Secondary Colors', () {
      test('should have secondary color', () {
        expect(AppColors.secondary, isA<Color>());
      });

      test('should have secondaryLight color', () {
        expect(AppColors.secondaryLight, isA<Color>());
      });

      test('should have secondaryDark color', () {
        expect(AppColors.secondaryDark, isA<Color>());
      });

      test('should have secondarySoft color', () {
        expect(AppColors.secondarySoft, isA<Color>());
      });
    });

    group('Accent Colors', () {
      test('should have accent color', () {
        expect(AppColors.accent, isA<Color>());
      });

      test('should have accentLight color', () {
        expect(AppColors.accentLight, isA<Color>());
      });

      test('should have accentDark color', () {
        expect(AppColors.accentDark, isA<Color>());
      });
    });

    group('Material Colors', () {
      test('should have steel color', () {
        expect(AppColors.steel, isA<Color>());
      });

      test('should have concrete color', () {
        expect(AppColors.concrete, isA<Color>());
      });

      test('should have aluminum color', () {
        expect(AppColors.aluminum, isA<Color>());
      });

      test('should have wood color', () {
        expect(AppColors.wood, isA<Color>());
      });
    });

    group('Status Colors', () {
      test('should have success color', () {
        expect(AppColors.success, isA<Color>());
      });

      test('should have successLight color', () {
        expect(AppColors.successLight, isA<Color>());
      });

      test('should have successDark color', () {
        expect(AppColors.successDark, isA<Color>());
      });

      test('should have successSoft color', () {
        expect(AppColors.successSoft, isA<Color>());
      });

      test('should have warning color', () {
        expect(AppColors.warning, isA<Color>());
      });

      test('should have warningLight color', () {
        expect(AppColors.warningLight, isA<Color>());
      });

      test('should have warningDark color', () {
        expect(AppColors.warningDark, isA<Color>());
      });

      test('should have warningSoft color', () {
        expect(AppColors.warningSoft, isA<Color>());
      });

      test('should have error color', () {
        expect(AppColors.error, isA<Color>());
      });

      test('should have errorLight color', () {
        expect(AppColors.errorLight, isA<Color>());
      });

      test('should have errorDark color', () {
        expect(AppColors.errorDark, isA<Color>());
      });

      test('should have errorSoft color', () {
        expect(AppColors.errorSoft, isA<Color>());
      });

      test('should have info color', () {
        expect(AppColors.info, isA<Color>());
      });

      test('should have infoLight color', () {
        expect(AppColors.infoLight, isA<Color>());
      });

      test('should have infoDark color', () {
        expect(AppColors.infoDark, isA<Color>());
      });

      test('should have infoSoft color', () {
        expect(AppColors.infoSoft, isA<Color>());
      });
    });

    group('Dark Theme Colors', () {
      test('should have darkBackground color', () {
        expect(AppColors.darkBackground, isA<Color>());
      });

      test('should have darkSurface color', () {
        expect(AppColors.darkSurface, isA<Color>());
      });

      test('should have darkSurfaceLight color', () {
        expect(AppColors.darkSurfaceLight, isA<Color>());
      });

      test('should have darkSurfaceLighter color', () {
        expect(AppColors.darkSurfaceLighter, isA<Color>());
      });

      test('should have darkCard color', () {
        expect(AppColors.darkCard, isA<Color>());
      });

      test('should have darkCardHover color', () {
        expect(AppColors.darkCardHover, isA<Color>());
      });

      test('should have darkBorder color', () {
        expect(AppColors.darkBorder, isA<Color>());
      });

      test('should have darkDivider color', () {
        expect(AppColors.darkDivider, isA<Color>());
      });
    });

    group('Light Theme Colors', () {
      test('should have lightBackground color', () {
        expect(AppColors.lightBackground, isA<Color>());
      });

      test('should have lightSurface color', () {
        expect(AppColors.lightSurface, isA<Color>());
      });

      test('should have lightSurfaceSecondary color', () {
        expect(AppColors.lightSurfaceSecondary, isA<Color>());
      });

      test('should have lightCard color', () {
        expect(AppColors.lightCard, isA<Color>());
      });

      test('should have lightCardHover color', () {
        expect(AppColors.lightCardHover, isA<Color>());
      });

      test('should have lightBorder color', () {
        expect(AppColors.lightBorder, isA<Color>());
      });

      test('should have lightDivider color', () {
        expect(AppColors.lightDivider, isA<Color>());
      });
    });

    group('Text Colors', () {
      test('should have darkTextPrimary color', () {
        expect(AppColors.darkTextPrimary, isA<Color>());
      });

      test('should have darkTextSecondary color', () {
        expect(AppColors.darkTextSecondary, isA<Color>());
      });

      test('should have darkTextMuted color', () {
        expect(AppColors.darkTextMuted, isA<Color>());
      });

      test('should have darkTextDisabled color', () {
        expect(AppColors.darkTextDisabled, isA<Color>());
      });

      test('should have lightTextPrimary color', () {
        expect(AppColors.lightTextPrimary, isA<Color>());
      });

      test('should have lightTextSecondary color', () {
        expect(AppColors.lightTextSecondary, isA<Color>());
      });
    });

    group('Cyan Colors', () {
      test('should have cyan color', () {
        expect(AppColors.cyan, isA<Color>());
      });

      test('should have cyanLight color', () {
        expect(AppColors.cyanLight, isA<Color>());
      });

      test('should have cyanDark color', () {
        expect(AppColors.cyanDark, isA<Color>());
      });
    });

    group('Purple Colors', () {
      test('should have purple color', () {
        expect(AppColors.purple, isA<Color>());
      });

      test('should have purpleLight color', () {
        expect(AppColors.purpleLight, isA<Color>());
      });

      test('should have purpleDark color', () {
        expect(AppColors.purpleDark, isA<Color>());
      });

      test('should have purpleSoft color', () {
        expect(AppColors.purpleSoft, isA<Color>());
      });
    });
  });
}
