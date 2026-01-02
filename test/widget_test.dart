// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:polys_mobile/app.dart';
import 'package:polys_mobile/presentation/providers/auth_provider.dart';
import 'package:polys_mobile/core/storage/secure_storage.dart';
import 'package:polys_mobile/core/network/api_client.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    // Setup required dependencies
    final secureStorage = SecureStorage();
    final apiClient = ApiClient(secureStorage: secureStorage);

    // Build our app with required providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(
              apiClient: apiClient,
              secureStorage: secureStorage,
            ),
          ),
        ],
        child: const PolysApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
