import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/loading_widget.dart';

/// Tela de configurações do app (admin)
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    if (provider.isLoading && provider.settings == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configurações')),
        body: const LoadingWidget(),
      );
    }

    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Modo de manutenção
          Card(
            child: SwitchListTile(
              title: const Text('Modo de Manutenção'),
              subtitle: const Text(
                'Quando ativado, apenas admins podem acessar o app',
              ),
              value: settings?.maintenanceMode ?? false,
              onChanged: (v) => provider.toggleMaintenanceMode(v),
              secondary: Icon(
                Icons.construction,
                color: settings?.maintenanceMode == true
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Permitir cadastros
          Card(
            child: SwitchListTile(
              title: const Text('Permitir Novos Cadastros'),
              subtitle: const Text(
                'Controla se novos usuários podem se cadastrar',
              ),
              value: settings?.allowRegistrations ?? true,
              onChanged: (v) => provider.toggleRegistrations(v),
              secondary: const Icon(Icons.person_add),
            ),
          ),
          const SizedBox(height: 12),

          // Resumo diário
          Card(
            child: SwitchListTile(
              title: const Text('Resumo Diário por Email'),
              subtitle: const Text(
                'Envia relatório diário para administradores',
              ),
              value: settings?.dailySummaryEmail ?? false,
              onChanged: (v) =>
                  provider.updateSettings({'dailySummaryEmail': v}),
              secondary: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 24),

          // Taxa da plataforma
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.percent, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text(
                        'Taxa da Plataforma',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Porcentagem cobrada em cada transação',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings?.platformFeePercent ?? 5.0,
                          min: 0,
                          max: 20,
                          divisions: 40,
                          label: '${settings?.platformFeePercent ?? 5.0}%',
                          onChanged: (v) {
                            // Atualiza localmente
                          },
                          onChangeEnd: (v) => provider.updatePlatformFee(v),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${settings?.platformFeePercent ?? 5.0}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Informações
          Card(
            color: AppColors.infoLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Última atualização: ${settings?.updatedAt.toString().substring(0, 16) ?? '-'}',
                      style: const TextStyle(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
