import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maps_pachuca/main.dart';

void main() {
  testWidgets('App se inicia correctamente', (WidgetTester tester) async {
    // Build your app.
    await tester.pumpWidget(const MyApp());

    // Verifica que un widget clave de tu app existe (ej: un Text o AppBar).
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
