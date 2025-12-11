import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Badge de status do projeto com cores específicas
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'proposed':
        return AppColors.statusProposed;
      case 'voting':
        return AppColors.statusVoting;
      case 'funding':
        return AppColors.statusFunding;
      case 'funded':
        return AppColors.statusFunded;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'completed':
        return AppColors.statusCompleted;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.statusProposed;
    }
  }

  String get _statusLabel {
    switch (status.toLowerCase()) {
      case 'proposed':
        return 'Proposto';
      case 'voting':
        return 'Em Votação';
      case 'funding':
        return 'Arrecadando';
      case 'funded':
        return 'Financiado';
      case 'in_progress':
        return 'Em Andamento';
      case 'completed':
        return 'Concluído';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: isCompact ? 10 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

