import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/authentication/screens/sign_in_screen.dart';

void main() {
  testWidgets('Sign in screen shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignInScreen()),
    );

    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Kazi'), findsOneWidget);
    expect(find.text('Work made simple.'), findsOneWidget);
    expect(find.text('Continue with Email'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
  });
}
