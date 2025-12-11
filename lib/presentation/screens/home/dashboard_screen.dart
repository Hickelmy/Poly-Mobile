import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/zones_provider.dart';
import '../../providers/selected_zone_provider.dart';
import '../../providers/news_provider.dart';
import '../../widgets/cards/kpi_card.dart';
import '../../widgets/cards/project_card.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/maps/zones_map.dart';

/// Tela de dashboard (início)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final projectsProvider = context.read<ProjectsProvider>();
    final zonesProvider = context.read<ZonesProvider>();
    final selectedZoneProvider = context.read<SelectedZoneProvider>();
    final newsProvider = context.read<NewsProvider>();
    final authProvider = context.read<AuthProvider>();

    final zoneId = selectedZoneProvider.selectedZoneId;

    await Future.wait([
      projectsProvider.loadVotingProjects(zoneId: zoneId),
      projectsProvider.loadFundingProjects(zoneId: zoneId),
      zonesProvider.loadZones(activeOnly: true),
      newsProvider.loadNews(zoneId: zoneId),
      if (authProvider.user?.email != null)
        projectsProvider.loadUserDonations(authProvider.user!.email),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final projectsProvider = context.watch<ProjectsProvider>();
    final zonesProvider = context.watch<ZonesProvider>();
    final user = authProvider.user;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar
            Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.slate900,
                              ]
                            : [
                                AppColors.primaryLight.withOpacity(0.3),
                                AppColors.surface,
                              ],
                      ),
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Helpers.getGreeting(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        user?.firstName ?? 'Usuário',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.slate50 : AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                ),
              actions: [
                // Theme Toggle e Avatar juntos
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Theme Toggle
                      const ThemeToggleButton(),
                      const SizedBox(width: 8),
                      // Avatar
                      GestureDetector(
                        onTap: () => AppRoutes.navigateTo(AppRoutes.profile),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null
                              ? Text(
                                  Helpers.getInitials(user?.name ?? 'U'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            );
            }),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // KPI Cards
                  _buildKpiSection(projectsProvider),
                  const SizedBox(height: 24),

                  // Ações rápidas
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Mapa de Zonas
                  _buildZonesMap(zonesProvider),
                  const SizedBox(height: 24),

                  // Projetos em votação
                  _buildVotingProjects(projectsProvider),
                  const SizedBox(height: 24),

                  // Projetos arrecadando
                  _buildFundingProjects(projectsProvider),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiSection(ProjectsProvider projectsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Minhas Doações',
                value: Formatters.currencyCompact(projectsProvider.totalDonated),
                icon: Icons.volunteer_activism,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'Projetos Ativos',
                value: '${projectsProvider.fundingProjects.length}',
                icon: Icons.rocket_launch,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard(
                title: 'Em Votação',
                value: '${projectsProvider.votingProjects.length}',
                icon: Icons.how_to_vote,
                color: AppColors.productColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                title: 'Notificações',
                value: '0',
                icon: Icons.notifications,
                color: AppColors.serviceColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final authProvider = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.slate50 : AppColors.slate900,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.volunteer_activism,
                label: 'Nova Doação',
                color: AppColors.success,
                onTap: () => AppRoutes.navigateTo(AppRoutes.projects),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_shopping_cart,
                label: 'Criar Produto',
                color: AppColors.productColor,
                onTap: () => AppRoutes.navigateTo(AppRoutes.sellerDashboard),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.support_agent,
                label: 'Abrir Chamado',
                color: AppColors.info,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            if (authProvider.canCreateProjects)
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_task,
                  label: 'Criar Projeto',
                  color: AppColors.primary,
                  onTap: () => AppRoutes.navigateTo(AppRoutes.createProject),
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildVotingProjects(ProjectsProvider projectsProvider) {
    final votingProjects = projectsProvider.votingProjects;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Em Votação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.slate50 : AppColors.slate900,
              ),
            ),
            TextButton(
              onPressed: () => AppRoutes.navigateTo(AppRoutes.projects),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (votingProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.how_to_vote_outlined,
                    size: 32,
                    color: isDark ? AppColors.slate500 : AppColors.slate400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum projeto em votação',
                    style: TextStyle(
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: votingProjects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 280,
                  child: ProjectCard(
                    project: votingProjects[index],
                    isCompact: true,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFundingProjects(ProjectsProvider projectsProvider) {
    final fundingProjects = projectsProvider.fundingProjects;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Arrecadando',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.slate50 : AppColors.slate900,
              ),
            ),
            TextButton(
              onPressed: () => AppRoutes.navigateTo(AppRoutes.projects),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (fundingProjects.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rocket_launch_outlined,
                    size: 32,
                    color: isDark ? AppColors.slate500 : AppColors.slate400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum projeto arrecadando',
                    style: TextStyle(
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fundingProjects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 280,
                  child: ProjectCard(
                    project: fundingProjects[index],
                    isCompact: true,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildZonesMap(ZonesProvider zonesProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeZones = zonesProvider.activeZones;
    final selectedZoneProvider = context.read<SelectedZoneProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Zonas da Comunidade',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.slate50 : AppColors.slate900,
              ),
            ),
            if (activeZones.isNotEmpty)
              TextButton(
                onPressed: () {
                  // TODO: Navegar para tela de zonas
                },
                child: const Text('Ver todas'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeZones.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.slate200,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 32,
                    color: isDark ? AppColors.slate500 : AppColors.slate400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma zona cadastrada',
                    style: TextStyle(
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ZonesMap(
            zones: activeZones,
            height: 250,
            onZoneTap: (zone) async {
              // Mostrar dialog de confirmação
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? AppColors.slate800 : Colors.white,
                  title: Text(
                    'Mudar para ${zone.name}?',
                    style: TextStyle(
                      color: isDark ? AppColors.slate50 : AppColors.slate900,
                    ),
                  ),
                  content: Text(
                    'Você deseja filtrar o conteúdo por esta zona?',
                    style: TextStyle(
                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Não',
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
                      child: const Text('Sim'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await selectedZoneProvider.selectZone(zone);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Filtrando por: ${zone.name}'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
      ],
    );
  }
}

/// Card de ação rápida
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? color.withOpacity(0.15) 
                : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                  ? color.withOpacity(0.3) 
                  : color.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark 
                      ? color.withOpacity(0.25) 
                      : color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

