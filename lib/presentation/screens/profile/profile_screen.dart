import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/app_bar_with_theme.dart';
import '../../widgets/common/theme_toggle_button.dart';

/// Tela de perfil do usuário
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cepController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _neighborhoodController;
  late TextEditingController _streetController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initControllers();
  }

  void _initControllers() {
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phone);
    _cepController = TextEditingController(text: user?.cep);
    _stateController = TextEditingController(text: user?.state);
    _cityController = TextEditingController(text: user?.city);
    _neighborhoodController = TextEditingController(text: user?.neighborhood);
    _streetController = TextEditingController(text: user?.street);
    _numberController = TextEditingController(text: user?.houseNumber);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBarWithTheme(
        title: 'Meu Perfil',
        actions: [
          if (authProvider.isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.admin_panel_settings),
              onSelected: (value) {
                switch (value) {
                  case 'users':
                    AppRoutes.navigateTo(AppRoutes.adminUsers);
                    break;
                  case 'zones':
                    AppRoutes.navigateTo(AppRoutes.adminZones);
                    break;
                  case 'settings':
                    AppRoutes.navigateTo(AppRoutes.adminSettings);
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'users',
                  child: Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(width: 8),
                      Text('Usuários'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'zones',
                  child: Row(
                    children: [
                      Icon(Icons.map),
                      SizedBox(width: 8),
                      Text('Zonas'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Configurações'),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Perfil'),
            Tab(text: 'Pagamento'),
            Tab(text: 'Segurança'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(user),
          _buildPaymentTab(user),
          _buildSecurityTab(authProvider),
        ],
      ),
    );
  }

  Widget _buildProfileTab(user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user?.avatarUrl == null
                      ? Text(
                          Helpers.getInitials(user?.name ?? 'U'),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameController,
              label: 'Nome Completo',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: 'Telefone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Endereço',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.slate50 : AppColors.slate900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cepController,
              label: 'CEP',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    controller: _stateController,
                    label: 'Estado',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'Cidade',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _neighborhoodController,
              label: 'Bairro',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: _streetController,
                    label: 'Rua',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _numberController,
                    label: 'Nº',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<UserProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: 'Salvar Alterações',
                  onPressed: _saveProfile,
                  isLoading: provider.isLoading,
                  isFullWidth: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTab(user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chaves PIX',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.slate50 : AppColors.slate900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure suas chaves para receber pagamentos',
            style: TextStyle(
              color: isDark ? AppColors.slate400 : AppColors.slate600,
            ),
          ),
          const SizedBox(height: 24),
          _buildPixKeyTile(
            'Chave Aleatória',
            user?.pixKeyRandom,
            Icons.shuffle,
            'pixKeyRandom',
          ),
          _buildPixKeyTile(
            'Celular',
            user?.pixKeyPhone,
            Icons.phone_android,
            'pixKeyPhone',
          ),
          _buildPixKeyTile(
            'Email',
            user?.pixKeyEmail,
            Icons.email,
            'pixKeyEmail',
          ),
          _buildPixKeyTile(
            'CPF',
            user?.pixKeyCpf,
            Icons.badge,
            'pixKeyCpf',
          ),
        ],
      ),
    );
  }

  Widget _buildPixKeyTile(String title, String? value, IconData icon, String keyType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.slate200 : AppColors.slate800,
                  ),
                ),
                Text(
                  value ?? 'Não configurada',
                  style: TextStyle(
                    color: value != null
                        ? (isDark ? AppColors.slate400 : AppColors.slate600)
                        : (isDark ? AppColors.slate500 : AppColors.slate500),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: isDark ? AppColors.slate400 : AppColors.slate600,
            ),
            onPressed: () => _showEditPixKeyDialog(title, value, keyType),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPixKeyDialog(String title, String? currentValue, String keyType) async {
    final controller = TextEditingController(text: currentValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        title: Text(
          'Editar $title',
          style: TextStyle(
            color: isDark ? AppColors.slate50 : AppColors.slate900,
          ),
        ),
        content: CustomTextField(
          controller: controller,
          label: title,
          hint: 'Digite a chave PIX',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      
      final updateData = <String, String?>{};
      updateData[keyType] = controller.text.trim();
      
      final success = await userProvider.updateProfile(
        userId: authProvider.user!.id,
        pixKeyRandom: keyType == 'pixKeyRandom' ? controller.text.trim() : null,
        pixKeyPhone: keyType == 'pixKeyPhone' ? controller.text.trim() : null,
        pixKeyEmail: keyType == 'pixKeyEmail' ? controller.text.trim() : null,
        pixKeyCpf: keyType == 'pixKeyCpf' ? controller.text.trim() : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Chave PIX atualizada!' : 'Erro ao atualizar'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Widget _buildSecurityTab(AuthProvider authProvider) {
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Tema
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
              ),
            ),
            child: const ThemeToggleButton(showLabel: true),
          ),
          _buildInfoTile(
            'Email',
            user?.email ?? '',
            Icons.email_outlined,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Verificado',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _buildInfoTile(
            'Cargo',
            user?.role ?? 'USER',
            Icons.badge_outlined,
          ),
          _buildInfoTile(
            'Membro desde',
            user?.createdAt != null
                ? Formatters.dateShort(user!.createdAt)
                : '',
            Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Sair da Conta',
            icon: Icons.logout,
            onPressed: () => _handleLogout(authProvider),
            isFullWidth: true,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, {Widget? trailing}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.slate400 : AppColors.slate600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.slate200 : AppColors.slate800,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    final success = await userProvider.updateProfile(
      userId: authProvider.user!.id,
      name: _nameController.text,
      phone: _phoneController.text,
      cep: _cepController.text,
      state: _stateController.text,
      city: _cityController.text,
      neighborhood: _neighborhoodController.text,
      street: _streetController.text,
      houseNumber: _numberController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Perfil atualizado!' : userProvider.error ?? 'Erro'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _handleLogout(AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.logout();
      if (mounted) {
        AppRoutes.navigateAndClear(AppRoutes.login);
      }
    }
  }
}

