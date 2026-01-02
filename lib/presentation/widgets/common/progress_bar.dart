import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Barra de progresso com gradiente teal-emerald
class ProgressBar extends StatelessWidget {
  final double current;
  final double target;
  final double? height;
  final bool showPercentage;
  final Color? color;
  final String? label;

  const ProgressBar({
    super.key,
    required this.current,
    required this.target,
    this.height = 8.0,
    this.showPercentage = true,
    this.color,
    this.label,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = color ?? AppColors.teal500;
    final trackColor = isDark ? AppColors.slate700 : AppColors.slate200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.slate400 : AppColors.slate600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(height! / 2),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.progressGradient,
                    borderRadius: BorderRadius.circular(height! / 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
              if (target > 0)
                Text(
                  '${_formatCurrency(current)} / ${_formatCurrency(target)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.slate400 : AppColors.slate600,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'R\$ ${value.toStringAsFixed(0)}';
  }
}

/// Barra de progresso de votação (tug-of-war: verde/vermelho)
class VotingProgressBar extends StatelessWidget {
  final int upVotes;
  final int downVotes;
  final double? height;

  const VotingProgressBar({
    super.key,
    required this.upVotes,
    required this.downVotes,
    this.height = 6.0,
  });

  int get totalVotes => upVotes + downVotes;
  double get upPercent {
    if (totalVotes == 0) return 0.5;
    final bias = (upVotes - downVotes) / totalVotes;
    return (0.5 + bias * 0.5).clamp(0.0, 1.0);
  }

  double get downPercent => 1.0 - upPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('👍', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$upVotes',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.emerald500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '$downVotes',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('👎', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height! / 2),
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              Expanded(
                flex: (upPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.emerald500,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(height! / 2),
                      bottomLeft: Radius.circular(height! / 2),
                      topRight: upPercent < 1.0
                          ? Radius.zero
                          : Radius.circular(height! / 2),
                      bottomRight: upPercent < 1.0
                          ? Radius.zero
                          : Radius.circular(height! / 2),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: (downPercent * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(height! / 2),
                      bottomRight: Radius.circular(height! / 2),
                      topLeft: downPercent < 1.0
                          ? Radius.zero
                          : Radius.circular(height! / 2),
                      bottomLeft: downPercent < 1.0
                          ? Radius.zero
                          : Radius.circular(height! / 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
