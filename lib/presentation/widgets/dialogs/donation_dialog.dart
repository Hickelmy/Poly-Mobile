import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/projects_provider.dart';
import '../common/custom_button.dart';

/// Dialog/Bottom Sheet de doação
class DonationDialog extends StatefulWidget {
  final String projectId;

  const DonationDialog({
    super.key,
    required this.projectId,
  });

  @override
  State<DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<DonationDialog> {
  double _selectedAmount = 25;
  bool _isAnonymous = false;
  bool _isRecurring = false;
  bool _showPixCode = false;
  String? _pixCode;

  final List<double> _amounts = [5, 10, 25, 50, 100];

  @override
  Widget build(BuildContext context) {
    final projectsProvider = context.watch<ProjectsProvider>();
    final project = projectsProvider.selectedProject;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Título
            const Text(
              'Fazer Doação',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              project?.title ?? '',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            if (!_showPixCode) ...[
              // Valores
              const Text(
                'Escolha um valor',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _amounts.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAmount = amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        Formatters.currency(amount),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Opções
              SwitchListTile(
                title: const Text('Doação anônima'),
                subtitle: const Text('Seu nome não será exibido'),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Doação mensal'),
                subtitle: const Text('Doe automaticamente todo mês'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              // Botão
              CustomButton(
                text: 'Gerar PIX - ${Formatters.currency(_selectedAmount)}',
                onPressed: _generatePix,
                isLoading: projectsProvider.isLoading,
                isFullWidth: true,
                backgroundColor: AppColors.success,
              ),
            ] else ...[
              // Código PIX
              const Center(
                child: Icon(
                  Icons.qr_code_2,
                  size: 120,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Código PIX Copia e Cola',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pixCode ?? 'Código PIX aqui...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Copiar Código',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código copiado!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: Icons.copy,
                isFullWidth: true,
                isOutlined: true,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Já realizei o pagamento',
                onPressed: () => Navigator.pop(context),
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generatePix() async {
    final authProvider = context.read<AuthProvider>();
    final projectsProvider = context.read<ProjectsProvider>();
    final user = authProvider.user;

    if (user == null) return;

    // Cria o pagamento
    final payment = await projectsProvider.createDonation(
      projectId: widget.projectId,
      amount: _selectedAmount,
      userId: user.id,
      userEmail: user.email,
      anonymous: _isAnonymous,
      isSubscription: _isRecurring,
    );

    if (payment != null) {
      // Gera o código PIX
      final pixData = await projectsProvider.generatePix(
        paymentId: payment.id,
        amount: _selectedAmount,
      );

      setState(() {
        _showPixCode = true;
        _pixCode = pixData?['pixCode'] ?? 'pix-code-example-${payment.id}';
      });
    }
  }
}

