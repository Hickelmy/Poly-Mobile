import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/image_utils.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/app_bar_with_theme.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/cards/service_card.dart';

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
  late TextEditingController _biographyController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initControllers();
    _loadUserContent();
  }

  Future<void> _loadUserContent() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final productsProvider = context.read<ProductsProvider>();
      final servicesProvider = context.read<ServicesProvider>();
      
      // Carrega produtos e serviços do usuário
      if (mounted) {
        await Future.wait([
          productsProvider.loadSellerProducts(user.id),
          servicesProvider.loadProviderServices(user.id),
        ]);
      }
    }
  }

  void _initControllers() {
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(
      text: user?.phone != null && user!.phone!.isNotEmpty
          ? Formatters.phone(user.phone!)
          : null,
    );
    _cepController = TextEditingController(
      text: user?.cep != null && user!.cep!.isNotEmpty
          ? Formatters.cep(user.cep!)
          : null,
    );
    _stateController = TextEditingController(text: user?.state);
    _cityController = TextEditingController(text: user?.city);
    _neighborhoodController = TextEditingController(text: user?.neighborhood);
    _streetController = TextEditingController(text: user?.street);
    _numberController = TextEditingController(text: user?.houseNumber);
    _biographyController = TextEditingController(text: ''); // TODO: Adicionar campo biography ao UserModel
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
    _biographyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBarWithTheme(
        title: 'Meu Perfil',
        showZoneSelector: false,
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
            Tab(text: 'Dados'),
            Tab(text: 'Minhas Chaves'),
            Tab(text: 'Segurança'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPublicProfileTab(user, authProvider),
          _buildDataTab(user),
          _buildPaymentTab(user),
          _buildSecurityTab(authProvider),
        ],
      ),
    );
  }

  Widget _buildPublicProfileTab(user, AuthProvider authProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsProvider = context.watch<ProductsProvider>();
    final servicesProvider = context.watch<ServicesProvider>();
    
    return RefreshIndicator(
      onRefresh: _loadUserContent,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          // Banner simples
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner
                Container(
                  height: 200,
                  width: double.infinity,
                  color: isDark ? AppColors.slate800 : AppColors.slate200,
                  child: user?.bannerUrl != null
                      ? ImageUtils.buildImage(
                          imageUrl: user!.bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: isDark ? AppColors.slate800 : AppColors.slate200,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.photo_size_select_actual_outlined,
                            size: 60,
                            color: isDark ? AppColors.slate600 : AppColors.slate400,
                          ),
                        ),
                ),
                // Avatar na frente do banner à esquerda
                Positioned(
                  left: 20,
                  bottom: -60,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            Helpers.getInitials(user?.name ?? 'U'),
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo do perfil
          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Nome e informações básicas
                Text(
                  user?.name ?? 'Usuário',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate50 : AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Membro desde ${user?.createdAt != null ? Formatters.dateShort(user!.createdAt).substring(6) : "..."}',
                      style: TextStyle(
                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Biografia
                _buildBiographySection(user, isDark),
                
                const SizedBox(height: 24),
                
                // Estatísticas
                _buildStatsSection(
                  user,
                  productsProvider.sellerProducts.length,
                  servicesProvider.providerServices.length,
                  isDark,
                ),
                
                const SizedBox(height: 24),
                
                // Medalhas
                _buildBadgesSection(user, isDark),
                
                const SizedBox(height: 24),
                
                // Produtos
                if (productsProvider.sellerProducts.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meus Produtos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.slate50 : AppColors.slate900,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppRoutes.navigateTo(AppRoutes.sellerDashboard),
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: productsProvider.sellerProducts.length > 5 
                          ? 5 
                          : productsProvider.sellerProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = productsProvider.sellerProducts[index];
                        return SizedBox(
                          width: 180,
                          child: ProductCard(
                            product: product,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.productDetail,
                              arguments: {'id': product.id},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Serviços
                if (servicesProvider.providerServices.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meus Serviços',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.slate50 : AppColors.slate900,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppRoutes.navigateTo(AppRoutes.services),
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: servicesProvider.providerServices.length > 5 
                          ? 5 
                          : servicesProvider.providerServices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final service = servicesProvider.providerServices[index];
                        return SizedBox(
                          width: 180,
                          child: ServiceCard(
                            service: service,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.serviceDetail,
                              arguments: {'id': service.id},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBiographySection(user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biografia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.slate50 : AppColors.slate900,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showBiographyEditDialog(),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _biographyController.text.isEmpty
                ? 'Adicione uma biografia para que outros usuários conheçam você melhor.'
                : _biographyController.text,
            style: TextStyle(
              color: _biographyController.text.isEmpty
                  ? (isDark ? AppColors.slate500 : AppColors.slate500)
                  : (isDark ? AppColors.slate300 : AppColors.slate700),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsSection(user, int productsCount, int servicesCount, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.shopping_bag_outlined,
            label: 'Produtos',
            value: '$productsCount',
            color: AppColors.productColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.handyman_outlined,
            label: 'Serviços',
            value: '$servicesCount',
            color: AppColors.serviceColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBadgesSection(user, bool isDark) {
    // Placeholder para badges/medalhas - será implementado futuramente
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medalhas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.slate50 : AppColors.slate900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Em breve você poderá conquistar medalhas através de suas ações na comunidade!',
            style: TextStyle(
              color: isDark ? AppColors.slate400 : AppColors.slate600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  

  void _showBiographyEditDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: _biographyController.text);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.slate800 : Colors.white,
        title: Text(
          'Editar Biografia',
          style: TextStyle(
            color: isDark ? AppColors.slate50 : AppColors.slate900,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextFormField(
            controller: controller,
            maxLength: 500,
            maxLines: 8,
            minLines: 5,
            decoration: InputDecoration(
              labelText: 'Biografia',
              hintText: 'Conte um pouco sobre você, seus produtos e serviços...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? AppColors.slate700 : AppColors.slate100,
            ),
            style: TextStyle(
              color: isDark ? AppColors.slate50 : AppColors.slate900,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _biographyController.text = controller.text;
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab(user) {
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
                  child: Text(
                    Helpers.getInitials(user?.name ?? 'U'),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
                _PhoneInputFormatter(),
              ],
              validator: Validators.phoneOptional,
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
                _CepInputFormatter(),
              ],
              validator: Validators.cep,
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
                  _formatPixKeyForDisplay(value, keyType) ?? 'Não configurada',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determina o formatador e validador baseado no tipo
    String? Function(String?)? validator;
    List<TextInputFormatter>? inputFormatters;
    TextInputType? keyboardType;
    String hint;
    String? formattedValue = currentValue;
    
    switch (keyType) {
      case 'pixKeyRandom':
        validator = Validators.pixKeyRandom;
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f-]')),
          LengthLimitingTextInputFormatter(36), // UUID format: 32 + 4 hífens
          _PixRandomInputFormatter(),
        ];
        keyboardType = TextInputType.text;
        hint = 'Ex: 12345678-90ab-cdef-1234-567890abcdef';
        // Formata valor inicial se existir
        if (currentValue != null && currentValue.isNotEmpty) {
          formattedValue = Formatters.pixKeyRandom(currentValue);
        }
        break;
      case 'pixKeyPhone':
        validator = Validators.pixKeyPhone;
        inputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
          _PhoneInputFormatter(),
        ];
        keyboardType = TextInputType.phone;
        hint = 'Ex: (11) 99999-9999';
        formattedValue = currentValue != null && currentValue.isNotEmpty
            ? Formatters.phone(currentValue)
            : null;
        break;
      case 'pixKeyEmail':
        validator = Validators.pixKeyEmail;
        keyboardType = TextInputType.emailAddress;
        hint = 'Ex: exemplo@email.com';
        break;
      case 'pixKeyCpf':
        validator = Validators.pixKeyCpf;
        inputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
          _CpfInputFormatter(),
        ];
        keyboardType = TextInputType.number;
        hint = 'Ex: 123.456.789-00';
        formattedValue = currentValue != null && currentValue.isNotEmpty
            ? Formatters.cpf(currentValue)
            : null;
        break;
      default:
        hint = 'Digite a chave PIX';
    }
    
    final controller = TextEditingController(text: formattedValue);
    final formKey = GlobalKey<FormState>();
    
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
        content: Form(
          key: formKey,
          child: CustomTextField(
          controller: controller,
          label: title,
            hint: hint,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            autofocus: true,
          ),
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
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, true);
              }
            },
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
      
      String valueToSave = controller.text.trim();
      
      // Remove formatação antes de salvar (exceto email)
      if (keyType == 'pixKeyRandom') {
        valueToSave = Formatters.pixKeyRandomUnformat(valueToSave);
      } else if (keyType == 'pixKeyPhone' || keyType == 'pixKeyCpf') {
        valueToSave = valueToSave.replaceAll(RegExp(r'\D'), '');
      }
      
      final success = await userProvider.updateProfile(
        userId: authProvider.user!.id,
        pixKeyRandom: keyType == 'pixKeyRandom' ? valueToSave : null,
        pixKeyPhone: keyType == 'pixKeyPhone' ? valueToSave : null,
        pixKeyEmail: keyType == 'pixKeyEmail' ? valueToSave : null,
        pixKeyCpf: keyType == 'pixKeyCpf' ? valueToSave : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Chave PIX atualizada!' : 'Erro ao atualizar'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      
      // Atualiza o estado para refletir a mudança
      if (success) {
        setState(() {});
      }
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

    // Remove formatação antes de salvar
    final phoneClean = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final cepClean = _cepController.text.replaceAll(RegExp(r'\D'), '');

    final success = await userProvider.updateProfile(
      userId: authProvider.user!.id,
      name: _nameController.text,
      phone: phoneClean,
      cep: cepClean,
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
  
  /// Formata a chave PIX para exibição
  String? _formatPixKeyForDisplay(String? value, String keyType) {
    if (value == null || value.isEmpty) return null;
    
    switch (keyType) {
      case 'pixKeyRandom':
        return Formatters.pixKeyRandom(value);
      case 'pixKeyPhone':
        return Formatters.phone(value);
      case 'pixKeyCpf':
        return Formatters.cpf(value);
      case 'pixKeyEmail':
        return value; // Email não precisa formatação
      default:
        return value;
    }
  }
}

/// Formatador de entrada para telefone
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) return newValue;
    
    String formatted;
    if (text.length <= 2) {
      formatted = '($text';
    } else if (text.length <= 7) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2)}';
    } else if (text.length <= 11) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}';
    } else {
      formatted = oldValue.text;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de entrada para CPF
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) return newValue;
    
    String formatted;
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 3)}.${text.substring(3)}';
    } else if (text.length <= 9) {
      formatted = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6)}';
    } else if (text.length <= 11) {
      formatted = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9)}';
    } else {
      formatted = oldValue.text;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatador de entrada para chave PIX aleatória (UUID)
class _PixRandomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove tudo exceto letras, números e hífens
    final text = newValue.text.replaceAll(RegExp(r'[^0-9A-Fa-f-]'), '').toUpperCase();
    
    if (text.isEmpty) return newValue;
    
    // Remove hífens para contar caracteres
    final clean = text.replaceAll('-', '');
    
    // Limita a 32 caracteres hexadecimais
    if (clean.length > 32) {
      return oldValue;
    }
    
    String formatted = '';
    int charIndex = 0;
    
    // Formata como UUID: 8-4-4-4-12
    for (int i = 0; i < clean.length && charIndex < 32; i++) {
      if (i == 8 || i == 12 || i == 16 || i == 20) {
        formatted += '-';
      }
      formatted += clean[i];
      charIndex++;
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Card de estatística
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.slate100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.slate50 : AppColors.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.slate400 : AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formatador de entrada para CEP
class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) return newValue;
    
    if (text.length > 8) {
      return oldValue;
    }
    
    String formatted;
    if (text.length <= 5) {
      formatted = text;
    } else {
      formatted = '${text.substring(0, 5)}-${text.substring(5)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

