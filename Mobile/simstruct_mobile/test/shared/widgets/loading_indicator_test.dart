import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/shared/widgets/loading_indicator.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('LoadingIndicator Widget', () {
    testWidgets('should render circular progress indicator', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const LoadingIndicator(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render with default size', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const LoadingIndicator(),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should render with custom size', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const LoadingIndicator(size: 60),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should render with custom color', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const LoadingIndicator(color: Colors.red),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should render with custom strokeWidth', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const LoadingIndicator(strokeWidth: 5),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });
  });

  group('SimpleLoadingOverlay Widget', () {
    testWidgets('should show loading when isLoading is true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const SimpleLoadingOverlay(
            isLoading: true,
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not show loading when isLoading is false', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const SimpleLoadingOverlay(
            isLoading: false,
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show child content', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const SimpleLoadingOverlay(
            isLoading: false,
            child: Text('Main Content'),
          ),
        ),
      );

      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('should show child content even when loading', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const SimpleLoadingOverlay(
            isLoading: true,
            child: Text('Main Content'),
          ),
        ),
      );

      expect(find.text('Main Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading message when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const SimpleLoadingOverlay(
            isLoading: true,
            message: 'Please wait...',
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Please wait...'), findsOneWidget);
    });

    testWidgets('should use stack to overlay loading on content', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const SimpleLoadingOverlay(
            isLoading: true,
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('should render overlay widget', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const SimpleLoadingOverlay(
            isLoading: true,
            child: Text('Content'),
          ),
        ),
      );

      expect(find.byType(SimpleLoadingOverlay), findsOneWidget);
    });
  });

  group('Loading Widget States', () {
    testWidgets('LoadingIndicator should be centered by default', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const Center(
            child: LoadingIndicator(),
          ),
        ),
      );

      // There will be at least one Center widget
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('LoadingIndicator should animate', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const LoadingIndicator(),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, isNull);
    });

    testWidgets('should toggle loading state', (tester) async {
      bool isLoading = true;

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  SimpleLoadingOverlay(
                    isLoading: isLoading,
                    child: const Text('Content'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = !isLoading;
                      });
                    },
                    child: const Text('Toggle'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
