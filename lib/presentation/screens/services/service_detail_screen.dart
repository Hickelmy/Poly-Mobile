import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/image_utils.dart';
import '../../providers/services_provider.dart';
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
    _loadService();
  }

  Future<void> _loadService() async {
    await context.read<ServicesProvider>().loadServiceDetails(widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicesProvider>();
    final service = provider.selectedService;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            flexibleSpace: FlexibleSpaceBar(
              background: service.primaryImage != null
                  ? ImageUtils.buildImage(
                      imageUrl: service.primaryImage!,
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (service.reviewsCount != null)
                        Text(
                          ' (${service.reviewsCount})',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Título
                Text(
                  service.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                          color: AppColors.textSecondary,
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
                const Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description ?? 'Sem descrição',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Prestador
                if (service.providerName != null) ...[
                  const Text(
                    'Prestador',
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
                          backgroundColor: AppColors.serviceColor,
                          child: Text(
                            Helpers.getInitials(service.providerName!),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.providerName!,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (service.zoneName != null)
                                Text(
                                  service.zoneName!,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
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
          child: CustomButton(
            text: 'Agendar Serviço',
            icon: Icons.calendar_today,
            onPressed: () => _showBookingDialog(),
            backgroundColor: AppColors.serviceColor,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.serviceColor.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.handyman,
          size: 60,
          color: AppColors.serviceColor,
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
            const Text('Em breve você poderá agendar serviços diretamente pelo app!'),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Entrar em Contato',
              icon: Icons.chat,
              onPressed: () {
                Navigator.pop(context);
                final service = context.read<ServicesProvider>().selectedService;
                if (service?.providerEmail != null) {
                  Helpers.openWhatsApp(
                    service!.providerEmail!,
                    message: 'Olá! Gostaria de agendar o serviço "${service.title}" do POLYS.',
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

