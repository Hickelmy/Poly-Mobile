import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../routes/app_routes.dart';
import '../../providers/products_provider.dart';
import '../../providers/auth_provider.dart';
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

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocationService _locationService = LocationService();
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWithLocation();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        _loadProducts();
      } else {
        _loadMyProducts();
      }
    }
  }

  /// Inicializa verificando e solicitando localização
  Future<void> _initializeWithLocation() async {
    if (_locationLoaded) {
      await _loadProducts();
      return;
    }

    final productsProvider = context.read<ProductsProvider>();
    
    // Verifica o status da localização
    final status = await _locationService.checkLocationStatus();
    
    if (!mounted) return;
    
    if (status == LocationStatus.permissionDenied) {
      // Mostra dialog pedindo para habilitar permissão
      _showLocationPermissionDialog();
    } else if (status == LocationStatus.serviceDisabled) {
      // Mostra dialog pedindo para habilitar o GPS
      _showLocationServiceDialog();
    }
    
    // Tenta obter a localização
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        productsProvider.setUserLocation(position.latitude, position.longitude);
      }
    } catch (_) {
      // Ignora erros de localização - continua sem ordenar por proximidade
    }
    
    _locationLoaded = true;
    if (mounted) {
      await _loadProducts();
    }
  }

  void _showLocationPermissionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        icon: Icon(
          Icons.location_off,
          size: 48,
          color: AppColors.warning,
        ),
        title: Text(
          'Permissão de Localização',
          style: TextStyle(
            color: isDark ? AppColors.slate50 : AppColors.slate900,
          ),
        ),
        content: Text(
          'Para mostrar os produtos mais próximos de você, precisamos acessar sua localização.\n\nDeseja permitir o acesso?',
          style: TextStyle(
            color: isDark ? AppColors.slate300 : AppColors.slate700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Agora não',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final granted = await _locationService.requestPermission();
              if (granted && mounted) {
                _locationLoaded = false;
                _initializeWithLocation();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        icon: Icon(
          Icons.gps_off,
          size: 48,
          color: AppColors.warning,
        ),
        title: Text(
          'GPS Desativado',
          style: TextStyle(
            color: isDark ? AppColors.slate50 : AppColors.slate900,
          ),
        ),
        content: Text(
          'Para mostrar os produtos mais próximos, ative o GPS do seu dispositivo.',
          style: TextStyle(
            color: isDark ? AppColors.slate300 : AppColors.slate700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Agora não',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _locationService.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    final productsProvider = context.read<ProductsProvider>();
    await productsProvider.loadProducts(refresh: refresh);
  }

  Future<void> _loadMyProducts({bool refresh = false}) async {
    final authProvider = context.read<AuthProvider>();
    final productsProvider = context.read<ProductsProvider>();
    final user = authProvider.user;
    
    if (user != null) {
      await productsProvider.loadSellerProducts(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarWithTheme(
        title: 'Loja',
        showZoneSelector: false, // Ordenação por proximidade, não por zona
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilters,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.productColor,
          unselectedLabelColor: isDark ? AppColors.slate400 : AppColors.textSecondary,
          indicatorColor: AppColors.productColor,
          tabs: const [
            Tab(text: 'Produtos Disponíveis'),
            Tab(text: 'Meus Produtos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba: Produtos Disponíveis
          RefreshIndicator(
            onRefresh: () => _loadProducts(refresh: true),
            color: AppColors.primary,
            child: _buildContent(provider, showMyProducts: false),
          ),
          // Aba: Meus Produtos
          RefreshIndicator(
            onRefresh: () => _loadMyProducts(refresh: true),
            color: AppColors.primary,
            child: _buildMyProductsContent(provider),
          ),
        ],
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

  Widget _buildContent(ProductsProvider provider, {bool showMyProducts = false}) {
    final products = showMyProducts ? provider.sellerProducts : provider.products;

    if (provider.isLoading && products.isEmpty) {
      return const LoadingWidget(message: 'Carregando produtos...');
    }

    if (provider.error != null && products.isEmpty) {
      return CustomErrorWidget(
        message: provider.error,
        onRetry: () => showMyProducts ? _loadMyProducts(refresh: true) : _loadProducts(refresh: true),
      );
    }

    if (products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.store_outlined,
        title: showMyProducts ? 'Você ainda não possui produtos' : 'Nenhum produto encontrado',
        message: showMyProducts 
            ? 'Comece a vender anunciando seu primeiro produto!' 
            : 'Seja o primeiro a anunciar um produto na comunidade!',
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
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          showDeleteButton: showMyProducts,
          onDelete: showMyProducts ? () => _confirmDeleteProduct(products[index]) : null,
        );
      },
    );
  }

  Widget _buildMyProductsContent(ProductsProvider provider) {
    // Carrega produtos quando a aba é selecionada pela primeira vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.sellerProducts.isEmpty && !provider.isLoading) {
        _loadMyProducts();
      }
    });

    return _buildContent(provider, showMyProducts: true);
  }

  Future<void> _confirmDeleteProduct(product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: Text('Tem certeza que deseja excluir "${product.title}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<ProductsProvider>();
      final success = await provider.deleteProduct(product.id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto excluído com sucesso'),
              backgroundColor: AppColors.success,
            ),
          );
          // Recarrega os produtos
          _loadMyProducts(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Erro ao excluir produto'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
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
