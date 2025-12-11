import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_utils.dart';
import '../../../data/models/service_model.dart';
import '../../../routes/app_routes.dart';

/// Card de serviço
class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final bool isCompact;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.service,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            () => AppRoutes.navigateTo(
                  AppRoutes.serviceDetail,
                  arguments: {'id': service.id},
                ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.slate700 : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem
              AspectRatio(
                aspectRatio: isCompact ? 1.5 : 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (service.primaryImage != null)
                      ImageUtils.buildImage(
                        imageUrl: service.primaryImage!,
                        fit: BoxFit.cover,
                        placeholder: _buildPlaceholder(),
                        errorWidget: _buildPlaceholder(),
                      )
                    else
                      _buildPlaceholder(),
                    // Tipo de serviço
                    if (service.serviceType != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.serviceColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            service.serviceTypeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Rating
                    if (service.rating != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                service.formattedRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(isCompact ? 10 : 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (service.hasPrice)
                      Row(
                        children: [
                          Text(
                            Formatters.currency(service.price!),
                            style: TextStyle(
                              fontSize: isCompact ? 15 : 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.serviceColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/${_getPriceTypeSuffix(service.priceType)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Sob orçamento',
                        style: TextStyle(
                          fontSize: isCompact ? 15 : 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.serviceColor,
                        ),
                      ),
                    if (!isCompact && service.providerName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              service.providerName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriceTypeSuffix(String priceType) {
    switch (priceType.toLowerCase()) {
      case 'hora':
        return 'hora';
      case 'diaria':
        return 'dia';
      case 'servico':
        return 'serviço';
      default:
        return priceType;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.serviceColor.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.handyman,
          size: 40,
          color: AppColors.serviceColor,
        ),
      ),
    );
  }
}

