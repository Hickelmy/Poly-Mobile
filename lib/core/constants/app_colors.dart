import 'package:flutter/material.dart';

/// Paleta de cores do POLYS - Baseada no design system do Polys-Frontend
class AppColors {
  AppColors._();
  
  // ============ PRIMARY - TEAL ============
  static const Color teal500 = Color(0xFF14b8a6); // HSL: 168 85% 35%
  static const Color teal600 = Color(0xFF0d9488); // HSL: 168 85% 30%
  static const Color teal700 = Color(0xFF0f766e); // HSL: 168 85% 25%
  static const Color teal400 = Color(0xFF2dd4bf);
  static const Color teal300 = Color(0xFF5eead4); // HSL: 168 85% 60%
  
  // Aliases para compatibilidade
  static const Color primary = teal500;
  static const Color primaryDark = teal700;
  static const Color primaryLight = teal300;
  static const Color primarySurface = Color(0xFFCCFBF1);
  
  // ============ SECONDARY - EMERALD ============
  static const Color emerald500 = Color(0xFF10b981); // HSL: 160 60% 45%
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald400 = Color(0xFF34d399);
  static const Color emerald300 = Color(0xFF6ee7b7);
  
  // Aliases
  static const Color secondary = emerald500;
  static const Color secondaryDark = emerald600;
  static const Color secondaryLight = emerald300;
  
  // ============ ACCENT COLORS BY CATEGORY ============
  static const Color projectColor = Color(0xFF14B8A6);   // Teal
  static const Color productColor = Color(0xFF8B5CF6);   // Purple
  static const Color serviceColor = Color(0xFFF59E0B);   // Amber
  static const Color userLocation = Color(0xFF3B82F6);   // Blue
  
  // ============ STATUS COLORS ============
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // ============ PROJECT STATUS COLORS ============
  static const Color statusProposed = Color(0xFF6B7280); // Gray
  static const Color statusVoting = Color(0xFF8B5CF6); // Purple
  static const Color statusFunding = teal500; // Teal
  static const Color statusFunded = emerald500; // Emerald
  static const Color statusInProgress = Color(0xFFF59E0B); // Amber
  static const Color statusCompleted = Color(0xFF22C55E); // Green
  static const Color statusCancelled = error; // Red
  
  // ============ SLATE SCALE (Neutrals) ============
  static const Color slate50 = Color(0xFFf8fafc);
  static const Color slate100 = Color(0xFFf1f5f9);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate300 = Color(0xFFcbd5e1);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate500 = Color(0xFF64748b);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1e293b);
  static const Color slate900 = Color(0xFF0f172a);
  static const Color slate950 = Color(0xFF020617);
  
  // Aliases para compatibilidade
  static const Color background = slate50;
  static const Color backgroundDark = slate950;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = slate100;
  static const Color surfaceDark = slate900;
  
  static const Color textPrimary = slate900;
  static const Color textSecondary = slate500;
  static const Color textTertiary = slate400;
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDark = slate50;
  
  static const Color border = slate200;
  static const Color borderLight = slate100;
  static const Color divider = slate200;
  
  // ============ CATEGORY COLORS ============
  static const Map<String, Color> categoryColors = {
    'seguranca': Color(0xFFEF4444),
    'infraestrutura': Color(0xFF6366F1),
    'cultura': Color(0xFFF59E0B),
    'saude': Color(0xFF22C55E),
    'educacao': Color(0xFF3B82F6),
    'lazer': Color(0xFF8B5CF6),
    'outro': Color(0xFF6B7280),
  };
  
  // ============ CONDITION COLORS ============
  static const Map<String, Color> conditionColors = {
    'novo': Color(0xFF22C55E),
    'usado_otimo': Color(0xFF3B82F6),
    'usado_bom': Color(0xFFF59E0B),
    'usado_regular': Color(0xFFEF4444),
  };
  
  // ============ GRADIENTS ============
  /// Gradiente principal Teal → Emerald (como no frontend)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal500, emerald500],
  );
  
  /// Gradiente secundário
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal500, teal700],
  );
  
  /// Gradiente de background sutil
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0FDFA), Color(0xFFFFFFFF)],
  );
  
  /// Gradiente para dark mode
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [slate950, slate900, slate950],
  );
  
  /// Gradiente para progresso (teal → emerald)
  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [teal500, emerald500],
  );
  
  /// Retorna a cor do status do projeto
  static Color getProjectStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proposed':
        return statusProposed;
      case 'voting':
        return statusVoting;
      case 'funding':
        return statusFunding;
      case 'funded':
        return statusFunded;
      case 'in_progress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      default:
        return statusProposed;
    }
  }
  
  /// Retorna a cor da categoria
  static Color getCategoryColor(String? category) {
    if (category == null) return categoryColors['outro']!;
    return categoryColors[category.toLowerCase()] ?? categoryColors['outro']!;
  }
  
  /// Retorna a cor da condição do produto
  static Color getConditionColor(String? condition) {
    if (condition == null) return conditionColors['novo']!;
    return conditionColors[condition.toLowerCase()] ?? conditionColors['novo']!;
  }
}

