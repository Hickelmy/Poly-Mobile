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

  const AppBarWithTheme({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final selectedZoneProvider = context.watch<SelectedZoneProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        
        // Select de Zona
        if (selectedZoneProvider.allZones.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: isDark ? AppColors.slate300 : AppColors.slate700,
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 100,
                    child: Text(
                      selectedZoneProvider.selectedZone?.name ?? 'Zona',
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
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.public, size: 18),
                      SizedBox(width: 8),
                      Text('Todas as zonas'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ...selectedZoneProvider.allZones.map((zone) => PopupMenuItem(
                  value: zone.id,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(zone.color),
                          shape: BoxShape.circle,
                        ),
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
              onSelected: (value) async {
                if (value == 'all') {
                  await selectedZoneProvider.clearSelectedZone();
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
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          Helpers.getInitials(user?.name ?? 'U'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
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

  @override
  Size get preferredSize {
    if (bottom != null) {
      return Size.fromHeight(kToolbarHeight + (bottom!.preferredSize.height));
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}

