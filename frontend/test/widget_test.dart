import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_app/main.dart'; // Adjust to your actual main file

void main() {
  testWidgets('App loads and shows homepage', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    expect(find.text('Ubuntu Interiors'), findsOneWidget); // Or whatever is in your home
  });
}
