import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/selected_zone_provider.dart';
import '../../widgets/cards/project_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_bar_with_theme.dart';

/// Tela de listagem de projetos
class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  void _loadProjects() {
    final selectedZoneProvider = context.read<SelectedZoneProvider>();
    final projectsProvider = context.read<ProjectsProvider>();
    projectsProvider.setZoneFilter(selectedZoneProvider.selectedZoneId);
    projectsProvider.loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final projectsProvider = context.watch<ProjectsProvider>();
    final selectedZoneProvider = context.watch<SelectedZoneProvider>();

    // Recarrega quando a zona mudar
    if (selectedZoneProvider.selectedZoneId != projectsProvider.zoneFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        projectsProvider.setZoneFilter(selectedZoneProvider.selectedZoneId);
        projectsProvider.loadProjects(refresh: true);
      });
    }

    return Scaffold(
      appBar: AppBarWithTheme(
        title: 'Projetos',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => projectsProvider.loadProjects(refresh: true),
        color: AppColors.primary,
        child: _buildContent(projectsProvider),
      ),
      floatingActionButton: authProvider.canCreateProjects
          ? FloatingActionButton.extended(
              onPressed: () => AppRoutes.navigateTo(AppRoutes.createProject),
              icon: const Icon(Icons.add),
              label: const Text('Novo Projeto'),
            )
          : null,
    );
  }

  Widget _buildContent(ProjectsProvider provider) {
    if (provider.isLoading && provider.projects.isEmpty) {
      return const LoadingWidget(message: 'Carregando projetos...');
    }

    if (provider.error != null && provider.projects.isEmpty) {
      return CustomErrorWidget(
        message: provider.error,
        onRetry: () => provider.loadProjects(refresh: true),
      );
    }

    if (provider.projects.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.rocket_launch_outlined,
        title: 'Nenhum projeto encontrado',
        message: 'Quando houver projetos na comunidade, eles aparecerão aqui.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: provider.projects.length,
      itemBuilder: (context, index) {
        return ProjectCard(project: provider.projects[index]);
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
    final provider = context.watch<ProjectsProvider>();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todos',
                selected: provider.statusFilter == null,
                onTap: () => provider.setStatusFilter(null),
              ),
              _FilterChip(
                label: 'Em Votação',
                selected: provider.statusFilter == 'voting',
                onTap: () => provider.setStatusFilter('voting'),
              ),
              _FilterChip(
                label: 'Arrecadando',
                selected: provider.statusFilter == 'funding',
                onTap: () => provider.setStatusFilter('funding'),
              ),
              _FilterChip(
                label: 'Concluídos',
                selected: provider.statusFilter == 'completed',
                onTap: () => provider.setStatusFilter('completed'),
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
      selectedColor: AppColors.primarySurface,
      checkmarkColor: AppColors.primary,
    );
  }
}

