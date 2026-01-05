import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/app/theme/app_text_styles.dart';
import 'package:simstruct_mobile/app/theme/app_colors.dart';

void main() {
  // Note: AppTextStyles static properties use GoogleFonts which requires
  // asset loading that doesn't work reliably in unit tests.
  // We focus on testing the TextStyleX extension which is testable.
  
  group('TextStyleX Extension', () {
    final baseStyle = const TextStyle(fontSize: 16);

    group('Color Extensions', () {
      test('primary should apply primary color', () {
        final styled = baseStyle.primary;
        expect(styled.color, equals(AppColors.primary));
      });

      test('secondary should apply secondary color', () {
        final styled = baseStyle.secondary;
        expect(styled.color, equals(AppColors.secondary));
      });

      test('accent should apply accent color', () {
        final styled = baseStyle.accent;
        expect(styled.color, equals(AppColors.accent));
      });

      test('success should apply success color', () {
        final styled = baseStyle.success;
        expect(styled.color, equals(AppColors.success));
      });

      test('warning should apply warning color', () {
        final styled = baseStyle.warning;
        expect(styled.color, equals(AppColors.warning));
      });

      test('error should apply error color', () {
        final styled = baseStyle.error;
        expect(styled.color, equals(AppColors.error));
      });

      test('info should apply info color', () {
        final styled = baseStyle.info;
        expect(styled.color, equals(AppColors.info));
      });
    });

    group('Dark Theme Color Extensions', () {
      test('darkPrimary should apply dark text primary color', () {
        final styled = baseStyle.darkPrimary;
        expect(styled.color, equals(AppColors.darkTextPrimary));
      });

      test('darkSecondary should apply dark text secondary color', () {
        final styled = baseStyle.darkSecondary;
        expect(styled.color, equals(AppColors.darkTextSecondary));
      });

      test('darkMuted should apply dark text muted color', () {
        final styled = baseStyle.darkMuted;
        expect(styled.color, equals(AppColors.darkTextMuted));
      });
    });

    group('Light Theme Color Extensions', () {
      test('lightPrimary should apply light text primary color', () {
        final styled = baseStyle.lightPrimary;
        expect(styled.color, equals(AppColors.lightTextPrimary));
      });

      test('lightSecondary should apply light text secondary color', () {
        final styled = baseStyle.lightSecondary;
        expect(styled.color, equals(AppColors.lightTextSecondary));
      });

      test('lightMuted should apply light text muted color', () {
        final styled = baseStyle.lightMuted;
        expect(styled.color, equals(AppColors.lightTextMuted));
      });
    });

    group('Utility Extensions', () {
      test('white should apply white color', () {
        final styled = baseStyle.white;
        expect(styled.color, equals(Colors.white));
      });

      test('bold should apply w700 font weight', () {
        final styled = baseStyle.bold;
        expect(styled.fontWeight, equals(FontWeight.w700));
      });

      test('semiBold should apply w600 font weight', () {
        final styled = baseStyle.semiBold;
        expect(styled.fontWeight, equals(FontWeight.w600));
      });

      test('medium should apply w500 font weight', () {
        final styled = baseStyle.medium;
        expect(styled.fontWeight, equals(FontWeight.w500));
      });

      test('regular should apply w400 font weight', () {
        final styled = baseStyle.regular;
        expect(styled.fontWeight, equals(FontWeight.w400));
      });
    });

    group('Chained Extensions', () {
      test('should allow chaining multiple extensions', () {
        final styled = baseStyle.primary.bold;
        expect(styled.color, equals(AppColors.primary));
        expect(styled.fontWeight, equals(FontWeight.w700));
      });

      test('should preserve original properties when chaining', () {
        final styled = baseStyle.success.semiBold;
        expect(styled.fontSize, equals(16));
        expect(styled.color, equals(AppColors.success));
        expect(styled.fontWeight, equals(FontWeight.w600));
      });
      
      test('should chain three extensions', () {
        final base = const TextStyle(fontSize: 20, letterSpacing: 0.5);
        final styled = base.error.bold.white;
        expect(styled.fontSize, equals(20));
        expect(styled.letterSpacing, equals(0.5));
        // Last color wins
        expect(styled.color, equals(Colors.white));
        expect(styled.fontWeight, equals(FontWeight.w700));
      });
      
      test('should chain all dark theme colors', () {
        expect(baseStyle.darkPrimary.color, equals(AppColors.darkTextPrimary));
        expect(baseStyle.darkSecondary.color, equals(AppColors.darkTextSecondary));
        expect(baseStyle.darkMuted.color, equals(AppColors.darkTextMuted));
      });
      
      test('should chain all light theme colors', () {
        expect(baseStyle.lightPrimary.color, equals(AppColors.lightTextPrimary));
        expect(baseStyle.lightSecondary.color, equals(AppColors.lightTextSecondary));
        expect(baseStyle.lightMuted.color, equals(AppColors.lightTextMuted));
      });
      
      test('should chain font weight modifiers', () {
        final styledBold = baseStyle.bold;
        final styledSemiBold = baseStyle.semiBold;
        final styledMedium = baseStyle.medium;
        final styledRegular = baseStyle.regular;
        
        expect(styledBold.fontWeight, equals(FontWeight.w700));
        expect(styledSemiBold.fontWeight, equals(FontWeight.w600));
        expect(styledMedium.fontWeight, equals(FontWeight.w500));
        expect(styledRegular.fontWeight, equals(FontWeight.w400));
      });
    });

    group('Extension on Different Base Styles', () {
      test('should work on style with color', () {
        const coloredStyle = TextStyle(fontSize: 14, color: Colors.red);
        final styled = coloredStyle.primary;
        expect(styled.fontSize, equals(14));
        expect(styled.color, equals(AppColors.primary)); // Overridden
      });

      test('should work on style with font weight', () {
        const weightedStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w300);
        final styled = weightedStyle.bold;
        expect(styled.fontSize, equals(14));
        expect(styled.fontWeight, equals(FontWeight.w700)); // Overridden
      });

      test('should preserve other properties', () {
        const complexStyle = TextStyle(
          fontSize: 18,
          letterSpacing: 1.5,
          height: 1.4,
          decoration: TextDecoration.underline,
        );
        final styled = complexStyle.primary.bold;
        
        expect(styled.fontSize, equals(18));
        expect(styled.letterSpacing, equals(1.5));
        expect(styled.height, equals(1.4));
        expect(styled.decoration, equals(TextDecoration.underline));
        expect(styled.color, equals(AppColors.primary));
        expect(styled.fontWeight, equals(FontWeight.w700));
      });
    });
  });
}
