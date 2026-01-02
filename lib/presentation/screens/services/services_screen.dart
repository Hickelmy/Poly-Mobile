import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../providers/services_provider.dart';
import '../../providers/selected_zone_provider.dart';
import '../../widgets/cards/service_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_bar_with_theme.dart';

/// Tela de serviços
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String? _lastZoneId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
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
          _loadServices();
        }
      });
    }
  }

  Future<void> _loadServices({bool refresh = false}) async {
    final selectedZoneProvider = context.read<SelectedZoneProvider>();
    final servicesProvider = context.read<ServicesProvider>();
    servicesProvider.setZoneFilter(selectedZoneProvider.selectedZoneId);
    await servicesProvider.loadServices(refresh: refresh);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicesProvider>();

    return Scaffold(
      appBar: AppBarWithTheme(
        title: 'Serviços',
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
        onRefresh: () => _loadServices(refresh: true),
        color: AppColors.primary,
        child: _buildContent(provider),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'services_fab',
        onPressed: () => AppRoutes.navigateTo(AppRoutes.sellerDashboard),
        backgroundColor: AppColors.serviceColor,
        tooltip: 'Oferecer Serviço',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(ServicesProvider provider) {
    if (provider.isLoading && provider.services.isEmpty) {
      return const LoadingWidget(message: 'Carregando serviços...');
    }

    if (provider.error != null && provider.services.isEmpty) {
      return CustomErrorWidget(
        message: provider.error,
        onRetry: () => provider.loadServices(refresh: true),
      );
    }

    if (provider.services.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.handyman_outlined,
        title: 'Nenhum serviço encontrado',
        message: 'Seja o primeiro a oferecer um serviço na comunidade!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return ServiceCard(service: provider.services[index]);
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
    final provider = context.watch<ServicesProvider>();

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
          const Text('Tipo de Serviço',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Todos',
                selected: provider.serviceTypeFilter == null,
                onTap: () => provider.setServiceTypeFilter(null),
              ),
              _FilterChip(
                label: 'Limpeza',
                selected: provider.serviceTypeFilter == 'limpeza',
                onTap: () => provider.setServiceTypeFilter('limpeza'),
              ),
              _FilterChip(
                label: 'Manutenção',
                selected: provider.serviceTypeFilter == 'manutencao',
                onTap: () => provider.setServiceTypeFilter('manutencao'),
              ),
              _FilterChip(
                label: 'Elétrica',
                selected: provider.serviceTypeFilter == 'eletrica',
                onTap: () => provider.setServiceTypeFilter('eletrica'),
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
      selectedColor: AppColors.serviceColor.withOpacity(0.2),
      checkmarkColor: AppColors.serviceColor,
    );
  }
}
