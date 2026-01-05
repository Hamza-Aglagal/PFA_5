import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simstruct_mobile/shared/widgets/custom_text_field.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('CustomTextField Widget', () {
    testWidgets('should render text field with label', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Email',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should render text field with hint', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Name',
            hint: 'Enter your name',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('should allow text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomTextField(
            label: 'Input',
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test input');
      await tester.pump();

      expect(controller.text, 'Test input');
    });

    testWidgets('should display initial value from controller', (tester) async {
      final controller = TextEditingController(text: 'Initial value');

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomTextField(
            label: 'Field',
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Initial value'), findsOneWidget);
    });

    testWidgets('should call onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomTextField(
            label: 'Field',
            onChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'New value');
      await tester.pump();

      expect(changedValue, 'New value');
    });

    testWidgets('should display prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Email',
            prefixIcon: Icons.email,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should display suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Search',
            suffixIcon: Icons.search,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should obscure text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Password',
            obscureText: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });

    testWidgets('should not obscure text when obscureText is false', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Email',
            obscureText: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, false);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Disabled',
            enabled: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('should display error text when provided', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Email',
            errorText: 'Invalid email address',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('should support multiline when maxLines > 1', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Description',
            maxLines: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 5);
    });

    testWidgets('should limit input length when maxLength is set', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Short Field',
            maxLength: 10,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 10);
    });

    testWidgets('should use correct keyboard type', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('should use number keyboard type', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Phone',
            keyboardType: TextInputType.phone,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.phone);
    });

    testWidgets('should call onSubmitted when submitted', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomTextField(
            label: 'Search',
            onSubmitted: (value) {
              submittedValue = value;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Search term');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'Search term');
    });

    testWidgets('should apply custom text input action', (tester) async {
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: const CustomTextField(
            label: 'Next Field',
            textInputAction: TextInputAction.next,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, TextInputAction.next);
    });

    testWidgets('should focus when focusNode requests focus', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: CustomTextField(
            label: 'Focus Test',
            focusNode: focusNode,
          ),
        ),
      );
      await tester.pumpAndSettle();

      focusNode.requestFocus();
      await tester.pump();

      expect(focusNode.hasFocus, true);
    });

    testWidgets('should validate with custom validator', (tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        createSimpleTestableWidget(
          child: Form(
            key: formKey,
            child: CustomTextField(
              label: 'Required',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });
  });
}
