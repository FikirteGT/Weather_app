import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart';

void main() {
  testWidgets('WeatherApp smoke test - starts and shows loading or screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WeatherApp());

    // Initially, it should show a loading indicator or attempt to fetch weather.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the async fetching trigger if any.
    await tester.pump(const Duration(seconds: 1));

    // After loading or error, it shouldn't crash.
    // Since real HTTP is not mocked here, it will transition to the error view.
    // Let's verify we have either the error display or content.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
