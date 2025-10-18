import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omspos/config/my_app.dart';

void main() {
  testWidgets('MyApp loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
