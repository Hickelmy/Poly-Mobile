import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_utils.dart';
import '../../../data/models/product_model.dart';
import '../../../routes/app_routes.dart';

/// Card de produto
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isCompact;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
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
                  AppRoutes.productDetail,
                  arguments: {'id': product.id},
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
                aspectRatio: isCompact ? 1.2 : 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (product.primaryImage != null)
                      ImageUtils.buildImage(
                        imageUrl: product.primaryImage!,
                        fit: BoxFit.cover,
                        placeholder: _buildPlaceholder(),
                        errorWidget: _buildPlaceholder(),
                      )
                    else
                      _buildPlaceholder(),
                    // Condição badge
                    if (product.condition != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.getConditionColor(product.condition),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.conditionName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Disponibilidade
                    if (!product.isAvailable)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Text(
                              'INDISPONÍVEL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                      product.title,
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(product.price),
                      style: TextStyle(
                        fontSize: isCompact ? 15 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.quantityAvailable} disponíveis',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (product.sellerName != null) ...[
                        const SizedBox(height: 4),
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
                                product.sellerName!,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.productColor.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 40,
          color: AppColors.productColor,
        ),
      ),
    );
  }
}

