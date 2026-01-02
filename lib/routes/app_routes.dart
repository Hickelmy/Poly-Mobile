import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/main_screen.dart';
import '../presentation/screens/projects/projects_list_screen.dart';
import '../presentation/screens/projects/project_detail_screen.dart';
import '../presentation/screens/projects/create_project_screen.dart';
import '../presentation/screens/store/store_screen.dart';
import '../presentation/screens/store/product_detail_screen.dart';
import '../presentation/screens/services/services_screen.dart';
import '../presentation/screens/services/service_detail_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/seller/seller_dashboard_screen.dart';
import '../presentation/screens/admin/user_management_screen.dart';
import '../presentation/screens/admin/zone_management_screen.dart';
import '../presentation/screens/admin/app_settings_screen.dart';
import '../presentation/screens/news/news_screen.dart';
import '../presentation/screens/location/location_permission_screen.dart';

/// Gerenciador de rotas do app
class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Rotas
  static const String splash = '/';
  static const String locationPermission = '/location-permission';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetail = '/project';
  static const String createProject = '/create-project';
  static const String store = '/store';
  static const String productDetail = '/product';
  static const String services = '/services';
  static const String serviceDetail = '/service';
  static const String profile = '/profile';
  static const String sellerDashboard = '/seller';
  static const String adminUsers = '/admin/users';
  static const String adminZones = '/admin/zones';
  static const String adminSettings = '/admin/settings';
  static const String news = '/news';
  static const String newsDetail = '/news/detail';

  /// Gera rota baseada no nome
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);

      case locationPermission:
        return _fadeRoute(const LocationPermissionScreen(), settings);

      case login:
        return _slideRoute(const LoginScreen(), settings);

      case register:
        return _slideRoute(const RegisterScreen(), settings);

      case main:
        return _fadeRoute(const MainScreen(), settings);

      case projects:
        return _slideRoute(const ProjectsListScreen(), settings);

      case projectDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          ProjectDetailScreen(projectId: args?['id'] ?? ''),
          settings,
        );

      case createProject:
        return _slideRoute(const CreateProjectScreen(), settings);

      case store:
        return _slideRoute(const StoreScreen(), settings);

      case productDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          ProductDetailScreen(productId: args?['id'] ?? ''),
          settings,
        );

      case services:
        return _slideRoute(const ServicesScreen(), settings);

      case serviceDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          ServiceDetailScreen(serviceId: args?['id'] ?? ''),
          settings,
        );

      case profile:
        return _slideRoute(const ProfileScreen(), settings);

      case sellerDashboard:
        return _slideRoute(const SellerDashboardScreen(), settings);

      case adminUsers:
        return _slideRoute(const UserManagementScreen(), settings);

      case adminZones:
        return _slideRoute(const ZoneManagementScreen(), settings);

      case adminSettings:
        return _slideRoute(const AppSettingsScreen(), settings);

      case news:
        return _slideRoute(const NewsScreen(), settings);

      case newsDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slideRoute(
          NewsDetailScreen(newsId: args?['id'] ?? ''),
          settings,
        );

      default:
        return _fadeRoute(
          Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  /// Navegação com fade
  static PageRouteBuilder<dynamic> _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Navegação com slide
  static PageRouteBuilder<dynamic> _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Navega para uma rota
  static Future<T?> navigateTo<T>(String route, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(route, arguments: arguments);
  }

  /// Substitui a rota atual
  static Future<T?> replaceTo<T>(String route, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, dynamic>(
      route,
      arguments: arguments,
    );
  }

  /// Limpa pilha e navega
  static Future<T?> navigateAndClear<T>(String route, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      route,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Volta para rota anterior
  static void goBack<T>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  /// Verifica se pode voltar
  static bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }
}

