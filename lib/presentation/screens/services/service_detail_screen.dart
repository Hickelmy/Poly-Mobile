import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/image_utils.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';

/// Tela de detalhes do serviço
class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Aguarda o frame para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadService();
    });
  }

  Future<void> _loadService() async {
    if (!mounted) return;
    await context.read<ServicesProvider>().loadServiceDetails(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicesProvider>();
    final authProvider = context.watch<AuthProvider>();
    final service = provider.selectedService;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Verifica se o usuário atual é o dono do serviço
    final isOwner = service?.providerId != null && 
                    authProvider.user?.id != null &&
                    service!.providerId == authProvider.user!.id;

    if (provider.isLoading && service == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        ),
        body: const LoadingWidget(message: 'Carregando serviço...'),
      );
    }

    if (service == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        ),
        body: CustomErrorWidget(
          message: provider.error ?? 'Serviço não encontrado',
          onRetry: _loadService,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
            iconTheme: IconThemeData(
              color: isDark ? AppColors.slate100 : AppColors.textPrimary,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: service.primaryImage != null
                  ? ImageUtils.buildImage(
                      imageUrl: service.primaryImage!,
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
                // Tipo e avaliação
                Row(
                  children: [
                    if (service.serviceType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.serviceColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.serviceTypeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (service.rating != null) ...[
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        service.formattedRating,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                        ),
                      ),
                      if (service.reviewsCount != null)
                        Text(
                          ' (${service.reviewsCount})',
                          style: TextStyle(
                            color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Título
                Text(
                  service.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Preço
                if (service.hasPrice)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.currency(service.price!),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.serviceColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        service.priceTypeName,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Sob orçamento',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.serviceColor,
                    ),
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
                  service.description ?? 'Sem descrição',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.slate300 : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Prestador
                if (service.providerName != null) ...[
                  Text(
                    'Prestador',
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
                          backgroundColor: AppColors.serviceColor,
                          child: Text(
                            Helpers.getInitials(service.providerName!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.providerName!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.slate100 : AppColors.textPrimary,
                                ),
                              ),
                              if (service.zoneName != null)
                                Text(
                                  service.zoneName!,
                                  style: TextStyle(
                                    color: isDark ? AppColors.slate400 : AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
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
                child: CustomButton(
                  text: 'Agendar Serviço',
                  icon: Icons.calendar_today,
                  onPressed: () => _showBookingDialog(),
                  backgroundColor: AppColors.serviceColor,
                  isFullWidth: true,
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

  void _showBookingDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agendar Serviço',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
                'Em breve você poderá agendar serviços diretamente pelo app!'),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Entrar em Contato',
              icon: Icons.chat,
              onPressed: () {
                Navigator.pop(context);
                final service =
                    context.read<ServicesProvider>().selectedService;
                if (service?.providerEmail != null) {
                  Helpers.openWhatsApp(
                    service!.providerEmail!,
                    message:
                        'Olá! Gostaria de agendar o serviço "${service.title}" do POLYS.',
                  );
                }
              },
              isFullWidth: true,
              backgroundColor: AppColors.serviceColor,
            ),
          ],
        ),
      ),
    );
  }
}
