import 'package:flutter_test/flutter_test.dart';

import 'package:animal_fostering_app/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnimalFosteringApp()); // Removed 'const'

    // Verify that our app starts with the dashboard
    expect(find.text('Animal Fostering'), findsOneWidget);
  });
}