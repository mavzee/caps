import 'package:flutter_test/flutter_test.dart';
import 'package:wastescan/main.dart';  // Ensure this import matches your app's package name

void main() {
  testWidgets('Waste Scanner app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EcoQuestApp());

    // Verify that the app title is displayed.
    expect(find.text('Waste Scanner'), findsOneWidget);

    // Verify that the "Take a Picture" button is displayed.
    expect(find.text('Take a Picture'), findsOneWidget);

    // Verify that the initial state shows "No image selected."
    expect(find.text('No image selected.'), findsOneWidget);

    // Verify that the prediction text is initially empty.
    expect(find.text('Prediction:'), findsNothing);
  });
}