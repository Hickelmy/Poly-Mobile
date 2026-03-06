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
  final bool showDeleteButton;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.isCompact = false,
    this.onTap,
    this.showDeleteButton = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          InkWell(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Imagem - ocupa toda a largura no topo
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagem principal
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
              // Content - dados organizados embaixo
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Título
                      Flexible(
                        child: Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Preço
                      Text(
                        Formatters.currency(product.price),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.productColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Quantidade disponível
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${product.quantityAvailable} disp.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
            ),
          ),
          // Botão de deletar sobreposto (se necessário)
          if (showDeleteButton && onDelete != null)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (onDelete != null) {
                      onDelete!();
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.slate200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: AppColors.slate400,
            ),
            const SizedBox(height: 8),
            Text(
              'No image',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

