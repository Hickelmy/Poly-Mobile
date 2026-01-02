import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Tela que exige permissão de localização para usar o app
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestLocationPermission() async {
    setState(() => _isRequesting = true);

    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        // Permissão concedida, volta para o splash para continuar o fluxo
        if (mounted) {
          AppRoutes.navigateAndClear(AppRoutes.splash);
        }
      } else if (status.isPermanentlyDenied) {
        // Permissão negada permanentemente, precisa abrir configurações
        if (mounted) {
          _showOpenSettingsDialog();
        }
      } else {
        // Permissão negada temporariamente
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'A permissão de localização é obrigatória para usar o app'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao solicitar permissão de localização'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissão Necessária'),
        content: const Text(
          'A permissão de localização foi negada permanentemente. '
          'Por favor, abra as configurações do app e conceda a permissão de localização para continuar usando o POLYS.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.slate900,
                    AppColors.slate800,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF0FDFA),
                    Colors.white,
                  ],
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de localização
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  'Localização Necessária',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate50 : AppColors.slate900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Descrição
                Text(
                  'O POLYS precisa da sua localização em tempo real para funcionar corretamente.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.slate400 : AppColors.slate600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Isso nos permite mostrar projetos, produtos e serviços próximos a você.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.slate400 : AppColors.slate600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Lista de benefícios
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate800 : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.slate700 : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBenefitItem(
                        context,
                        Icons.near_me,
                        'Encontrar conteúdo próximo',
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        context,
                        Icons.map,
                        'Detectar sua zona automaticamente',
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        context,
                        Icons.explore,
                        'Melhor experiência no app',
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Botão de solicitar permissão
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isRequesting ? null : _requestLocationPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isRequesting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Permitir Localização',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Aviso
                Text(
                  'Você precisa permitir a localização para continuar',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.slate500 : AppColors.slate500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    IconData icon,
    String text,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.slate300 : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
