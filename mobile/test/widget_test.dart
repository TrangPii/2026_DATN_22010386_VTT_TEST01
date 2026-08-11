import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('app starts with AuthProvider', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
        child: const SmartServiceApp(),
      ),
    );

    expect(find.byType(SmartServiceApp), findsOneWidget);

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
