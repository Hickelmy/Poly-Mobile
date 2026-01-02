import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/image_utils.dart';
import '../../providers/products_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';

/// Tela de detalhes do produto
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    await context.read<ProductsProvider>().loadProductDetails(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final product = provider.selectedProduct;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.isLoading && product == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        ),
        body: const LoadingWidget(message: 'Carregando produto...'),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        ),
        body: CustomErrorWidget(
          message: provider.error ?? 'Produto não encontrado',
          onRetry: _loadProduct,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: product.primaryImage != null
                  ? ImageUtils.buildImage(
                      imageUrl: product.primaryImage!,
                      fit: BoxFit.cover,
                      placeholder: _buildPlaceholder(),
                      errorWidget: _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Condição
                if (product.condition != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getConditionColor(product.condition),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.conditionName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // Título
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Preço
                Text(
                  Formatters.currency(product.price),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.productColor,
                  ),
                ),
                const SizedBox(height: 16),
                // Quantidade
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.quantityAvailable} unidades disponíveis',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Descrição
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'Sem descrição',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Vendedor
                if (product.sellerName != null) ...[
                  const Text(
                    'Vendedor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.productColor,
                          child: Text(
                            Helpers.getInitials(product.sellerName!),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          product.sellerName!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Entrar em Contato',
                  icon: Icons.chat_outlined,
                  onPressed: () {
                    if (product.sellerEmail != null) {
                      Helpers.openWhatsApp(
                        product.sellerEmail!,
                        message:
                            'Olá! Vi seu produto "${product.title}" no POLYS.',
                      );
                    }
                  },
                  backgroundColor: AppColors.productColor,
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
          size: 60,
          color: AppColors.productColor,
        ),
      ),
    );
  }
}
