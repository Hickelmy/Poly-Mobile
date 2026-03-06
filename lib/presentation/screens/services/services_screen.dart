import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../routes/app_routes.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';
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

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
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
        _loadServices();
      } else {
        _loadMyServices();
      }
    }
  }

  /// Inicializa verificando e solicitando localização
  Future<void> _initializeWithLocation() async {
    if (_locationLoaded) {
      await _loadServices();
      return;
    }

    final servicesProvider = context.read<ServicesProvider>();
    
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
        servicesProvider.setUserLocation(position.latitude, position.longitude);
      }
    } catch (_) {
      // Ignora erros de localização - continua sem ordenar por proximidade
    }
    
    _locationLoaded = true;
    if (mounted) {
      await _loadServices();
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
          'Para mostrar os serviços mais próximos de você, precisamos acessar sua localização.\n\nDeseja permitir o acesso?',
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
          'Para mostrar os serviços mais próximos, ative o GPS do seu dispositivo.',
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

  Future<void> _loadServices({bool refresh = false}) async {
    final servicesProvider = context.read<ServicesProvider>();
    await servicesProvider.loadServices(refresh: refresh);
  }

  Future<void> _loadMyServices({bool refresh = false}) async {
    final authProvider = context.read<AuthProvider>();
    final servicesProvider = context.read<ServicesProvider>();
    final user = authProvider.user;
    
    if (user != null) {
      await servicesProvider.loadProviderServices(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicesProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBarWithTheme(
        title: 'Serviços',
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
          labelColor: AppColors.serviceColor,
          unselectedLabelColor: isDark ? AppColors.slate400 : AppColors.textSecondary,
          indicatorColor: AppColors.serviceColor,
          tabs: const [
            Tab(text: 'Serviços Disponíveis'),
            Tab(text: 'Meus Serviços'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba: Serviços Disponíveis
          RefreshIndicator(
            onRefresh: () => _loadServices(refresh: true),
            color: AppColors.primary,
            child: _buildContent(provider, showMyServices: false),
          ),
          // Aba: Meus Serviços
          RefreshIndicator(
            onRefresh: () => _loadMyServices(refresh: true),
            color: AppColors.primary,
            child: _buildMyServicesContent(provider),
          ),
        ],
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

  Widget _buildContent(ServicesProvider provider, {bool showMyServices = false}) {
    final services = showMyServices ? provider.providerServices : provider.services;

    if (provider.isLoading && services.isEmpty) {
      return const LoadingWidget(message: 'Carregando serviços...');
    }

    if (provider.error != null && services.isEmpty) {
      return CustomErrorWidget(
        message: provider.error,
        onRetry: () => showMyServices ? _loadMyServices(refresh: true) : _loadServices(refresh: true),
      );
    }

    if (services.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.handyman_outlined,
        title: showMyServices ? 'Você ainda não possui serviços' : 'Nenhum serviço encontrado',
        message: showMyServices 
            ? 'Comece a oferecer serviços anunciando seu primeiro serviço!' 
            : 'Seja o primeiro a oferecer um serviço na comunidade!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return ServiceCard(
          service: services[index],
          showDeleteButton: showMyServices,
          onDelete: showMyServices ? () => _confirmDeleteService(services[index]) : null,
        );
      },
    );
  }

  Widget _buildMyServicesContent(ServicesProvider provider) {
    // Carrega serviços quando a aba é selecionada pela primeira vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.providerServices.isEmpty && !provider.isLoading) {
        _loadMyServices();
      }
    });

    return _buildContent(provider, showMyServices: true);
  }

  Future<void> _confirmDeleteService(service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text('Tem certeza que deseja excluir "${service.title}"? Esta ação não pode ser desfeita.'),
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
      final provider = context.read<ServicesProvider>();
      final success = await provider.deleteService(service.id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviço excluído com sucesso'),
              backgroundColor: AppColors.success,
            ),
          );
          // Recarrega os serviços
          _loadMyServices(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Erro ao excluir serviço'),
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
