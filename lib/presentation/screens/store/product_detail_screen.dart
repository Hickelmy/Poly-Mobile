import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/image_utils.dart';
import '../../providers/products_provider.dart';
import '../../providers/auth_provider.dart';
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
    // Aguarda o frame para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  Future<void> _loadProduct() async {
    if (!mounted) return;
    await context.read<ProductsProvider>().loadProductDetails(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final product = provider.selectedProduct;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Verifica se o usuário atual é o dono do produto
    final isOwner = product?.sellerId != null && 
                    authProvider.user?.id != null &&
                    product!.sellerId == authProvider.user!.id;

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
            backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
            iconTheme: IconThemeData(
              color: isDark ? AppColors.slate100 : AppColors.textPrimary,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: product.primaryImage != null
                  ? ImageUtils.buildImage(
                      imageUrl: product.primaryImage!,
                      fit: BoxFit.cover,
                      placeholder: _buildPlaceholder(context),
                      errorWidget: _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate100 : AppColors.textPrimary,
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
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${product.quantityAvailable} unidades disponíveis',
                      style: TextStyle(
                        color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Descrição
                Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'Sem descrição',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.slate300 : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Vendedor
                if (product.sellerName != null) ...[
                  Text(
                    'Vendedor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate800 : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.slate700 : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.productColor,
                          child: Text(
                            Helpers.getInitials(product.sellerName!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          product.sellerName!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                          ),
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
      bottomNavigationBar: !isOwner
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
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
            )
          : null,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.slate800 : AppColors.slate200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 60,
              color: isDark ? AppColors.slate500 : AppColors.slate400,
            ),
            const SizedBox(height: 12),
            Text(
              'No image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.slate500 : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
