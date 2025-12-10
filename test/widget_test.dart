import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telecommande/main.dart';

void main() {
  testWidgets('App démarre correctement', (WidgetTester tester) async {
    await tester.pumpWidget(const TelecommandeApp());

    expect(find.text('Télécommande'), findsOneWidget);
  });
}
