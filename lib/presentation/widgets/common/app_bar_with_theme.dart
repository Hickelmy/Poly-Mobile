import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/selected_zone_provider.dart';
import 'theme_toggle_button.dart';

/// AppBar customizado com botão de tema e avatar
class AppBarWithTheme extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final bool showZoneSelector;

  const AppBarWithTheme({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.showZoneSelector = true,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final selectedZoneProvider = context.watch<SelectedZoneProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoggedIn = authProvider.isAuthenticated;

    return AppBar(
      title: title != null ? Text(title!) : null,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
      foregroundColor: isDark ? AppColors.slate50 : AppColors.slate900,
      elevation: 0,
      bottom: bottom,
      actions: [
        // Ações customizadas (se houver)
        if (actions != null) ...actions!,
        
        // Select de Zona - só mostra se showZoneSelector for true
        if (showZoneSelector)
          Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.public,
                  size: 18,
                  color: isDark ? AppColors.slate300 : AppColors.slate700,
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 100,
                  child: Text(
                    selectedZoneProvider.selectedZone?.name ?? 'Todas as zonas',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                ),
              ],
            ),
            itemBuilder: (context) => [
              // Opção "Todas as zonas" sempre primeiro e marcada se nenhuma zona selecionada
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    const Icon(Icons.public, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Todas as zonas')),
                    if (selectedZoneProvider.selectedZone == null)
                      const Icon(Icons.check, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
              // Opção para inserir código (só para usuários logados)
              if (isLoggedIn) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'enter_code',
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Inserir código de zona',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
              // Lista de zonas disponíveis
              if (selectedZoneProvider.allZones.isNotEmpty) ...[
                const PopupMenuDivider(),
                ...selectedZoneProvider.allZones.map((zone) => PopupMenuItem(
                  value: zone.id,
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _parseColor(zone.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Ícone de cadeado para zonas privadas
                          if (!zone.isPublic)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: Icon(
                                Icons.lock,
                                size: 10,
                                color: isDark ? AppColors.slate400 : AppColors.slate600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          zone.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectedZoneProvider.selectedZone?.id == zone.id)
                        const Icon(Icons.check, size: 18, color: AppColors.primary),
                    ],
                  ),
                )),
              ],
            ],
            onSelected: (value) async {
              if (value == 'all') {
                await selectedZoneProvider.clearSelectedZone();
              } else if (value == 'enter_code') {
                _showEnterCodeDialog(context, selectedZoneProvider, isDark);
              } else {
                final zone = selectedZoneProvider.allZones.firstWhere(
                  (z) => z.id == value,
                );
                await selectedZoneProvider.selectZone(zone);
              }
            },
          ),
        ),
        
        // Theme Toggle e Avatar
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Toggle
              const ThemeToggleButton(),
              const SizedBox(width: 8),
              // Avatar
              GestureDetector(
                onTap: () => AppRoutes.navigateTo(AppRoutes.profile),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    Helpers.getInitials(user?.name ?? 'U'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    String hexColor = hex.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  void _showEnterCodeDialog(
    BuildContext context,
    SelectedZoneProvider provider,
    bool isDark,
  ) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.vpn_key, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Código de Zona',
              style: TextStyle(
                color: isDark ? AppColors.slate50 : AppColors.slate900,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digite o código de acesso para entrar em uma zona privada:',
              style: TextStyle(
                color: isDark ? AppColors.slate300 : AppColors.slate700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Ex: ABC123',
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: isDark ? AppColors.slate900 : AppColors.slate100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.slate50 : AppColors.slate900,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final code = controller.text.trim();
                        if (code.isEmpty) return;

                        final result = await provider.joinWithCode(code);
                        
                        if (!context.mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: result.success 
                                ? AppColors.success 
                                : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Entrar'),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize {
    if (bottom != null) {
      return Size.fromHeight(kToolbarHeight + (bottom!.preferredSize.height));
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}

