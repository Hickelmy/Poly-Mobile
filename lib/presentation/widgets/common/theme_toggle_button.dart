import 'package:flutter/material.dart';
import '../../../app.dart' show ThemeModeProvider;
import '../../../core/constants/app_colors.dart';

/// Botão para alternar entre dark e light mode
class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
  });

  void _toggleTheme(BuildContext context) {
    final provider = ThemeModeProvider.of(context);
    if (provider == null) return;

    final currentMode = provider.themeMode;
    ThemeMode newMode;

    // Alternar direto: light <-> dark (simplificado para evitar confusão)
    if (currentMode == ThemeMode.dark) {
      newMode = ThemeMode.light;
    } else {
      newMode = ThemeMode.dark;
    }

    provider.updateThemeMode(newMode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ícone: se está dark, mostra sol para ir pro light; se está light, mostra lua para ir pro dark
    final icon = isDark ? Icons.light_mode : Icons.dark_mode;
    final tooltip = isDark ? 'Modo Claro' : 'Modo Escuro';

    if (showLabel) {
      return ListTile(
        leading: Icon(
          icon,
          color: isDark ? AppColors.slate200 : AppColors.slate700,
        ),
        title: Text(
          'Tema',
          style: TextStyle(
            color: isDark ? AppColors.slate200 : AppColors.slate800,
          ),
        ),
        subtitle: Text(
          isDark ? 'Modo Escuro' : 'Modo Claro',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.slate400 : AppColors.slate500,
          ),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (_) => _toggleTheme(context),
          activeThumbColor: AppColors.primary,
        ),
        onTap: () => _toggleTheme(context),
      );
    }

    return IconButton(
      icon: Icon(
        icon,
        color: isDark ? AppColors.slate200 : AppColors.slate700,
      ),
      tooltip: tooltip,
      onPressed: () => _toggleTheme(context),
    );
  }
}

/// Widget de toggle mais simples (apenas switch)
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = ThemeModeProvider.of(context);
    if (provider == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Switch(
      value: isDark,
      onChanged: (_) {
        final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
        provider.updateThemeMode(newMode);
      },
      activeThumbColor: AppColors.primary,
    );
  }
}
