import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/cards/service_card.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Vendedor'),
        bottom: TabBar(
          controller: _tabController,
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

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          await provider.loadSellerProducts(user.id);
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Adicionar Produto',
              icon: Icons.add,
              onPressed: () => _showAddProductDialog(),
              isFullWidth: true,
              backgroundColor: AppColors.productColor,
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const LoadingWidget()
                : provider.sellerProducts.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.store_outlined,
                        title: 'Nenhum produto',
                        message: 'Adicione seu primeiro produto!',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.sellerProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: provider.sellerProducts[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final provider = context.watch<ServicesProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          await provider.loadProviderServices(user.id);
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Adicionar Serviço',
              icon: Icons.add,
              onPressed: () => _showAddServiceDialog(),
              isFullWidth: true,
              backgroundColor: AppColors.serviceColor,
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const LoadingWidget()
                : provider.providerServices.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.handyman_outlined,
                        title: 'Nenhum serviço',
                        message: 'Ofereça seu primeiro serviço!',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.providerServices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return ServiceCard(
                            service: provider.providerServices[index],
                          );
                        },
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

  void _showAddProductDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddProductSheet(),
    );
  }

  void _showAddServiceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddServiceSheet(),
    );
  }
}

class _AddProductSheet extends StatefulWidget {
  const _AddProductSheet();

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Text(
                'Adicionar Produto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<ProductsProvider>(
                builder: (context, provider, _) {
                  return CustomButton(
                    text: 'Criar Produto',
                    onPressed: () => _createProduct(provider),
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

  Future<void> _createProduct(ProductsProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final product = await provider.createProduct(
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      quantityAvailable: int.parse(_quantityController.text),
    );

    if (!mounted) return;

    if (product != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto criado!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _AddServiceSheet extends StatefulWidget {
  const _AddServiceSheet();

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
  Widget build(BuildContext context) {
    return Container(
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
              const Text(
                'Adicionar Serviço',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Serviço criado!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

