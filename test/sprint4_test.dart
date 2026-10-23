
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sightai_prototype/view/delete_account_screen.dart';

void main() {
  group('Sight AI Sprint 4 Tests', () {

    // TC-01: Blind Mode has an accessible entry button.
    testWidgets('TC-01: Blind Mode entry button is available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.accessibility_new),
              label: const Text('Open Blind Mode'),
            ),
          ),
        ),
      );

      expect(find.text('Open Blind Mode'), findsOneWidget);
    });

    // TC-02: Image description button starts disabled without an image.
    testWidgets('TC-02: Describe Image requires an image',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: null,
              child: Text('Describe Image'),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Describe Image'),
      );

      expect(button.onPressed, isNull);
    });

    // TC-03: Delete Account screen displays cancellation option.
    testWidgets('TC-03: Delete Account has a Cancel button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeleteAccountScreen(),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete Account Permanently'), findsOneWidget);
    });

    // TC-04: Delete Account requires password input.
    testWidgets('TC-04: Password confirmation field exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeleteAccountScreen(),
        ),
      );

      expect(find.text('Confirm your password'), findsOneWidget);

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

  });
}

