import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/shared/widgets/custom_button.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('ButtonType enum', () {
    test('should have all expected values', () {
      expect(ButtonType.values.length, 6);
      expect(ButtonType.primary.name, 'primary');
      expect(ButtonType.secondary.name, 'secondary');
      expect(ButtonType.outline.name, 'outline');
      expect(ButtonType.ghost.name, 'ghost');
      expect(ButtonType.danger.name, 'danger');
      expect(ButtonType.gradient.name, 'gradient');
    });
  });

  group('ButtonSize enum', () {
    test('should have all expected values', () {
      expect(ButtonSize.values.length, 3);
      expect(ButtonSize.small.name, 'small');
      expect(ButtonSize.medium.name, 'medium');
      expect(ButtonSize.large.name, 'large');
    });
  });

  group('CustomButton Widget', () {
    testWidgets('should render button with text', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Test Button',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should be tappable when onPressed is provided', (tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Tap Me',
            onPressed: () {
              wasTapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('should not be tappable when onPressed is null', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomButton(
            text: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.ancestor(
        of: find.text('Disabled Button'),
        matching: find.byType(ElevatedButton),
      );
      
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('should not be tappable when isLoading is true', (tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Loading Button',
            isLoading: true,
            onPressed: () {
              wasTapped = true;
            },
          ),
        ),
      );
      // Don't use pumpAndSettle for loading indicator (infinite animation)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasTapped, false);
    });

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );
      // Don't use pumpAndSettle for loading indicator (infinite animation)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'With Icon',
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should be full width when isFullWidth is true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: SizedBox(
            width: 300,
            child: CustomButton(
              text: 'Full Width',
              isFullWidth: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sizedBox = find.ancestor(
        of: find.byType(ElevatedButton),
        matching: find.byType(SizedBox),
      ).first;
      
      expect(sizedBox, findsOneWidget);
    });

    testWidgets('should render with primary type by default', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Primary',
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render with secondary type', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Secondary',
            type: ButtonType.secondary,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render with outline type', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Outline',
            type: ButtonType.outline,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render with danger type', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Danger',
            type: ButtonType.danger,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render with small size', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Small',
            size: ButtonSize.small,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render with large size', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Large',
            size: ButtonSize.large,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display icon on the right when iconRight is true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Icon Right',
            icon: Icons.arrow_forward,
            iconRight: true,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.text('Icon Right'), findsOneWidget);
    });

    testWidgets('should respect custom width when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomButton(
            text: 'Custom Width',
            width: 200,
            onPressed: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Width'), findsOneWidget);
    });
  });
}
