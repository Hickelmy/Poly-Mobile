import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/projects_provider.dart';
import 'presentation/providers/products_provider.dart';
import 'presentation/providers/services_provider.dart';
import 'presentation/providers/zones_provider.dart';
import 'presentation/providers/selected_zone_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/news_provider.dart';
import 'core/storage/secure_storage.dart';
import 'core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }
  
  // Inicializar locale data para formatação de datas
  await initializeDateFormatting('pt_BR', null);
  
  // Configurar orientação
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar estilo da status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Inicializar serviços
  final secureStorage = SecureStorage();
  final apiClient = ApiClient(secureStorage: secureStorage);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiClient: apiClient,
            secureStorage: secureStorage,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(apiClient: apiClient),
          update: (_, auth, user) => user!..updateAuth(auth),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectsProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ServicesProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ZonesProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SelectedZoneProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => NewsProvider(apiClient: apiClient),
        ),
      ],
      child: const PolysApp(),
    ),
  );
}
