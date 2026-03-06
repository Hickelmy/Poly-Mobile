import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_utils.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';

/// Tela de dashboard do vendedor
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await Future.wait([
        context.read<ProductsProvider>().loadSellerProducts(user.id),
        context.read<ServicesProvider>().loadProviderServices(user.id),
      ]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
      appBar: AppBar(
        title: const Text('Painel do Vendedor'),
        backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.slate400 : AppColors.slate600,
          tabs: const [
            Tab(text: 'Produtos'),
            Tab(text: 'Serviços'),
            Tab(text: 'Pedidos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildServicesTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    final provider = context.watch<ProductsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final products = provider.sellerProducts;

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          await provider.loadSellerProducts(user.id);
        }
      },
      child: CustomScrollView(
        slivers: [
          // Botão adicionar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Adicionar Produto',
                icon: Icons.add,
                onPressed: _showAddProductDialog,
                isFullWidth: true,
                backgroundColor: AppColors.productColor,
              ),
            ),
          ),

          // Contador
          if (products.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 18,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${products.length} ${products.length == 1 ? 'produto' : 'produtos'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Conteúdo
          if (provider.isLoading && products.isEmpty)
            const SliverFillRemaining(child: LoadingWidget())
          else if (products.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.store_outlined,
                title: 'Nenhum produto',
                message: 'Adicione seu primeiro produto!',
              ),
            )
          else
            _buildProductsGrid(products, isDark),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(List<ProductModel> products, bool isDark) {
    // Usa grid para 3+ items, lista para menos
    final useGrid = products.length >= 3;

    if (useGrid) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildProductCard(products[index], isDark, isGrid: true),
            childCount: products.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductCard(products[index], isDark, isGrid: false),
            ),
            childCount: products.length,
          ),
        ),
      );
    }
  }

  Widget _buildProductCard(ProductModel product, bool isDark, {required bool isGrid}) {
    return Container(
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
      child: isGrid ? _buildGridProductContent(product, isDark) : _buildListProductContent(product, isDark),
    );
  }

  Widget _buildGridProductContent(ProductModel product, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Imagem
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (product.primaryImage != null)
                ImageUtils.buildImage(
                  imageUrl: product.primaryImage!,
                  fit: BoxFit.cover,
                  placeholder: _buildPlaceholder(Icons.shopping_bag_outlined),
                  errorWidget: _buildPlaceholder(Icons.shopping_bag_outlined),
                )
              else
                _buildPlaceholder(Icons.shopping_bag_outlined),

              // Badges
              if (product.condition != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            ],
          ),
        ),

        // Info
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.currency(product.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.productColor,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIconButton(
                          icon: Icons.edit_outlined,
                          color: AppColors.primary,
                          onTap: () => _editProduct(product),
                        ),
                        const SizedBox(width: 4),
                        _buildIconButton(
                          icon: Icons.delete_outline,
                          color: AppColors.error,
                          onTap: () => _confirmDeleteProduct(product),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListProductContent(ProductModel product, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Imagem
          SizedBox(
            width: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (product.primaryImage != null)
                  ImageUtils.buildImage(
                    imageUrl: product.primaryImage!,
                    fit: BoxFit.cover,
                    placeholder: _buildPlaceholder(Icons.shopping_bag_outlined),
                    errorWidget: _buildPlaceholder(Icons.shopping_bag_outlined),
                  )
                else
                  _buildPlaceholder(Icons.shopping_bag_outlined),

                if (product.condition != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.getConditionColor(product.condition),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        product.conditionName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.quantityAvailable} disponível(is)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.currency(product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.productColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.primary,
                        onTap: () => _editProduct(product),
                      ),
                      const SizedBox(width: 4),
                      _buildIconButton(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        onTap: () => _confirmDeleteProduct(product),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final provider = context.watch<ServicesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final services = provider.providerServices;

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          await provider.loadProviderServices(user.id);
        }
      },
      child: CustomScrollView(
        slivers: [
          // Botão adicionar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Adicionar Serviço',
                icon: Icons.add,
                onPressed: _showAddServiceDialog,
                isFullWidth: true,
                backgroundColor: AppColors.serviceColor,
              ),
            ),
          ),

          // Contador
          if (services.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.handyman,
                      size: 18,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${services.length} ${services.length == 1 ? 'serviço' : 'serviços'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Conteúdo
          if (provider.isLoading && services.isEmpty)
            const SliverFillRemaining(child: LoadingWidget())
          else if (services.isEmpty)
            const SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.handyman_outlined,
                title: 'Nenhum serviço',
                message: 'Ofereça seu primeiro serviço!',
              ),
            )
          else
            _buildServicesGrid(services, isDark),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(List<ServiceModel> services, bool isDark) {
    // Usa grid para 3+ items, lista para menos
    final useGrid = services.length >= 3;

    if (useGrid) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildServiceCard(services[index], isDark, isGrid: true),
            childCount: services.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildServiceCard(services[index], isDark, isGrid: false),
            ),
            childCount: services.length,
          ),
        ),
      );
    }
  }

  Widget _buildServiceCard(ServiceModel service, bool isDark, {required bool isGrid}) {
    return Container(
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
      child: isGrid ? _buildGridServiceContent(service, isDark) : _buildListServiceContent(service, isDark),
    );
  }

  Widget _buildGridServiceContent(ServiceModel service, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Imagem
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (service.primaryImage != null)
                ImageUtils.buildImage(
                  imageUrl: service.primaryImage!,
                  fit: BoxFit.cover,
                  placeholder: _buildPlaceholder(Icons.handyman_outlined),
                  errorWidget: _buildPlaceholder(Icons.handyman_outlined),
                )
              else
                _buildPlaceholder(Icons.handyman_outlined),

              // Badge tipo
              if (service.serviceType != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.serviceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.serviceTypeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Info
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        service.hasPrice ? Formatters.currency(service.price!) : 'Orçamento',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.serviceColor,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIconButton(
                          icon: Icons.edit_outlined,
                          color: AppColors.primary,
                          onTap: () => _editService(service),
                        ),
                        const SizedBox(width: 4),
                        _buildIconButton(
                          icon: Icons.delete_outline,
                          color: AppColors.error,
                          onTap: () => _confirmDeleteService(service),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListServiceContent(ServiceModel service, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Imagem
          SizedBox(
            width: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (service.primaryImage != null)
                  ImageUtils.buildImage(
                    imageUrl: service.primaryImage!,
                    fit: BoxFit.cover,
                    placeholder: _buildPlaceholder(Icons.handyman_outlined),
                    errorWidget: _buildPlaceholder(Icons.handyman_outlined),
                  )
                else
                  _buildPlaceholder(Icons.handyman_outlined),

                if (service.serviceType != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.serviceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        service.serviceTypeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (service.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          service.formattedRating,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.slate400 : AppColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.hasPrice ? Formatters.currency(service.price!) : 'Sob orçamento',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.serviceColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.edit_outlined,
                        color: AppColors.primary,
                        onTap: () => _editService(service),
                      ),
                      const SizedBox(width: 4),
                      _buildIconButton(
                        icon: Icons.delete_outline,
                        color: AppColors.error,
                        onTap: () => _confirmDeleteService(service),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return const EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'Nenhum pedido',
      message: 'Quando você receber pedidos, eles aparecerão aqui.',
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Container(
      color: AppColors.slate200,
      child: Center(
        child: Icon(
          icon,
          size: 40,
          color: AppColors.slate400,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showAddProductDialog() {
    Navigator.pushNamed(context, '/create-product').then((_) => _loadData());
  }

  void _editProduct(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditProductSheet(product: product, onUpdated: _loadData),
    );
  }

  void _confirmDeleteProduct(ProductModel product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        title: Text(
          'Excluir Produto',
          style: TextStyle(color: isDark ? AppColors.slate100 : AppColors.slate900),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${product.title}"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(color: isDark ? AppColors.slate300 : AppColors.slate700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<ProductsProvider>();
              final success = await provider.deleteProduct(product.id);

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produto excluído com sucesso'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? 'Erro ao excluir produto'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddServiceSheet(onCreated: _loadData),
    );
  }

  void _editService(ServiceModel service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditServiceSheet(service: service, onUpdated: _loadData),
    );
  }

  void _confirmDeleteService(ServiceModel service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        title: Text(
          'Excluir Serviço',
          style: TextStyle(color: isDark ? AppColors.slate100 : AppColors.slate900),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${service.title}"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(color: isDark ? AppColors.slate300 : AppColors.slate700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<ServicesProvider>();
              final success = await provider.deleteService(service.id);

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Serviço excluído com sucesso'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? 'Erro ao excluir serviço'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddServiceSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _AddServiceSheet({required this.onCreated});

  @override
  State<_AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<_AddServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _priceType = 'servico';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate600 : AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Adicionar Serviço',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.slate100 : AppColors.slate900,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título do Serviço'),
                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priceType,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(value: 'hora', child: Text('Por hora')),
                        DropdownMenuItem(value: 'diaria', child: Text('Por dia')),
                        DropdownMenuItem(value: 'servico', child: Text('Por serviço')),
                        DropdownMenuItem(value: 'orcamento', child: Text('Orçamento')),
                      ],
                      onChanged: (v) => setState(() => _priceType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Consumer<ServicesProvider>(
                builder: (context, provider, _) {
                  return CustomButton(
                    text: 'Criar Serviço',
                    onPressed: () => _createService(provider),
                    isLoading: provider.isLoading,
                    isFullWidth: true,
                    backgroundColor: AppColors.serviceColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createService(ServicesProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final service = await provider.createService(
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text),
      priceType: _priceType,
    );

    if (!mounted) return;

    if (service != null) {
      Navigator.pop(context);
      widget.onCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço criado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _EditServiceSheet extends StatefulWidget {
  final ServiceModel service;
  final VoidCallback onUpdated;

  const _EditServiceSheet({required this.service, required this.onUpdated});

  @override
  State<_EditServiceSheet> createState() => _EditServiceSheetState();
}

class _EditServiceSheetState extends State<_EditServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late String _priceType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service.title);
    _descriptionController = TextEditingController(text: widget.service.description);
    _priceController = TextEditingController(
      text: widget.service.price?.toString() ?? '',
    );
    _priceType = widget.service.priceType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate600 : AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Editar Serviço',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.slate100 : AppColors.slate900,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título do Serviço'),
                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priceType,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(value: 'hora', child: Text('Por hora')),
                        DropdownMenuItem(value: 'diaria', child: Text('Por dia')),
                        DropdownMenuItem(value: 'servico', child: Text('Por serviço')),
                        DropdownMenuItem(value: 'orcamento', child: Text('Orçamento')),
                      ],
                      onChanged: (v) => setState(() => _priceType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Consumer<ServicesProvider>(
                builder: (context, provider, _) {
                  return CustomButton(
                    text: 'Salvar Alterações',
                    onPressed: () => _updateService(provider),
                    isLoading: provider.isLoading,
                    isFullWidth: true,
                    backgroundColor: AppColors.serviceColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateService(ServicesProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await provider.updateService(
      widget.service.id,
      {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text),
        'priceType': _priceType,
      },
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      widget.onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _EditProductSheet extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onUpdated;

  const _EditProductSheet({required this.product, required this.onUpdated});

  @override
  State<_EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<_EditProductSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _quantityController = TextEditingController(
      text: widget.product.quantityAvailable.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate600 : AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Editar Produto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.slate100 : AppColors.slate900,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título do Produto'),
                validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty == true ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Consumer<ProductsProvider>(
                builder: (context, provider, _) {
                  return CustomButton(
                    text: 'Salvar Alterações',
                    onPressed: () => _updateProduct(provider),
                    isLoading: provider.isLoading,
                    isFullWidth: true,
                    backgroundColor: AppColors.productColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProduct(ProductsProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await provider.updateProduct(
      widget.product.id,
      {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'quantityAvailable': int.tryParse(_quantityController.text) ?? 1,
      },
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      widget.onUpdated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
