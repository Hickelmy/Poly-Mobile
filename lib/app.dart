import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'routes/app_routes.dart';

class PolysApp extends StatefulWidget {
  const PolysApp({super.key});

  @override
  State<PolysApp> createState() => _PolysAppState();
}

class _PolysAppState extends State<PolysApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');
    setState(() {
      if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    setState(() {
      _themeMode = mode;
    });
  }

  // Método público para atualizar o tema de qualquer lugar
  void updateThemeMode(ThemeMode mode) {
    _setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'POLYS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
          navigatorKey: AppRoutes.navigatorKey,
          builder: (context, child) {
            return ThemeModeProvider(
              themeMode: _themeMode,
              setThemeMode: _setThemeMode,
              updateThemeMode: updateThemeMode,
              child: child!,
            );
          },
        );
      },
    );
  }
}

/// Provider para acessar o theme mode em qualquer lugar
class ThemeModeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) setThemeMode;
  final void Function(ThemeMode) updateThemeMode;

  const ThemeModeProvider({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required this.updateThemeMode,
    required super.child,
  });

  static ThemeModeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeModeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

