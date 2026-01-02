import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../providers/products_provider.dart';
import '../../providers/selected_zone_provider.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_bar_with_theme.dart';

/// Tela da loja (produtos)
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String? _lastZoneId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedZoneProvider = context.read<SelectedZoneProvider>();
    final currentZoneId = selectedZoneProvider.selectedZoneId;

    // Só recarrega se a zona realmente mudou
    if (_lastZoneId != currentZoneId) {
      _lastZoneId = currentZoneId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadProducts();
        }
      });
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    final selectedZoneProvider = context.read<SelectedZoneProvider>();
    final productsProvider = context.read<ProductsProvider>();
    productsProvider.setZoneFilter(selectedZoneProvider.selectedZoneId);
    await productsProvider.loadProducts(refresh: refresh);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBarWithTheme(
        title: 'Loja',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProducts(refresh: true),
        color: AppColors.primary,
        child: _buildContent(provider),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'store_fab',
        onPressed: () => AppRoutes.navigateTo(AppRoutes.sellerDashboard),
        backgroundColor: AppColors.productColor,
        tooltip: 'Vender',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(ProductsProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const LoadingWidget(message: 'Carregando produtos...');
    }

    if (provider.error != null && provider.products.isEmpty) {
      return CustomErrorWidget(
        message: provider.error,
        onRetry: () => provider.loadProducts(refresh: true),
      );
    }

    if (provider.products.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.store_outlined,
        title: 'Nenhum produto encontrado',
        message: 'Seja o primeiro a anunciar um produto na comunidade!',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: provider.products[index]);
      },
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text('Condição', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todos',
                selected: provider.conditionFilter == null,
                onTap: () => provider.setConditionFilter(null),
              ),
              _FilterChip(
                label: 'Novo',
                selected: provider.conditionFilter == 'novo',
                onTap: () => provider.setConditionFilter('novo'),
              ),
              _FilterChip(
                label: 'Usado',
                selected: provider.conditionFilter == 'usado_bom',
                onTap: () => provider.setConditionFilter('usado_bom'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Limpar Filtros'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.productColor.withOpacity(0.2),
      checkmarkColor: AppColors.productColor,
    );
  }
}
