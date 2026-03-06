import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/selected_zone_provider.dart';

/// Tela de splash com verificação de autenticação
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initialize();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _initialize() async {
    final authProvider = context.read<AuthProvider>();

    // Espera a animação inicial
    await Future.delayed(const Duration(milliseconds: 1000));

    // Verifica permissão de localização ANTES de tudo
    final locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      // Se não tem permissão, redireciona para tela de permissão
      if (mounted) {
        AppRoutes.navigateAndClear(AppRoutes.locationPermission);
      }
      return;
    }

    // Inicializa autenticação
    await authProvider.initialize();

    // Se autenticado, inicializa zona selecionada
    if (authProvider.isAuthenticated) {
      final selectedZoneProvider = context.read<SelectedZoneProvider>();
      await selectedZoneProvider.initialize();
    }

    // Espera mais um pouco para UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Navega baseado no estado de autenticação
    if (authProvider.isAuthenticated) {
      AppRoutes.navigateAndClear(AppRoutes.main);
    } else {
      AppRoutes.navigateAndClear(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F766E), // primaryDark
              Color(0xFF14B8A6), // primary
              Color(0xFF10B981), // secondary
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AssetPaths.logo,
                          width: 220,
                          height: 85,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback se a imagem não carregar
                            return const Text(
                              'POLYS',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 4,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Tagline
                      Text(
                        'Conectando comunidades',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

