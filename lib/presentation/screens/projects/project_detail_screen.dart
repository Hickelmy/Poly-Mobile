import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/projects_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/dialogs/donation_dialog.dart';

/// Tela de detalhes do projeto
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    final provider = context.read<ProjectsProvider>();
    final authProvider = context.read<AuthProvider>();
    
    await provider.loadProjectDetails(widget.projectId);
    
    if (authProvider.user?.email != null) {
      await provider.loadUserVote(
        projectId: widget.projectId,
        userEmail: authProvider.user!.email,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsProvider = context.watch<ProjectsProvider>();
    final project = projectsProvider.selectedProject;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (projectsProvider.isLoading && project == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        ),
        body: const LoadingWidget(message: 'Carregando projeto...'),
      );
    }

    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        ),
        body: CustomErrorWidget(
          message: 'Projeto não encontrado',
          onRetry: _loadProject,
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar com imagem
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProjectImage(project, isDark),
            ),
          ),
          // Conteúdo
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status e categoria
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getProjectStatusColor(project.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppStrings.getProjectStatusName(project.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (project.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getCategoryColor(project.category),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppStrings.getCategoryName(project.category),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Título
                Text(
                  project.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate50 : AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 8),
                if (project.ownerName != null)
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Por ${project.ownerName}',
                        style: TextStyle(
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                // Progresso
                if (project.isVoting) _buildVotingProgress(project, isDark),
                if (project.isFunding) _buildFundingProgress(project, isDark),
                const SizedBox(height: 24),
                // Descrição
                Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate50 : AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  project.description ?? project.shortDescription ?? 'Sem descrição',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.slate300 : AppColors.slate700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Despesas
                if (project.expenses.isNotEmpty) ...[
                  Text(
                    'Despesas Previstas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.slate50 : AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...project.expenses.map((expense) => Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate800 : AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.slate700 : AppColors.slate200,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.type,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.slate200 : AppColors.slate800,
                                    ),
                                  ),
                                  if (expense.description != null)
                                    Text(
                                      expense.description!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.slate400 : AppColors.slate600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.currency(expense.total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
                const SizedBox(height: 80), // Espaço para botão
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(project, projectsProvider),
    );
  }

  Widget _buildProjectImage(project, bool isDark) {
    // Primeiro tenta usar evidences (múltiplas imagens)
    if (project.evidences.isNotEmpty) {
      return ImageUtils.buildImage(
        imageUrl: project.evidences.first,
        fit: BoxFit.cover,
        placeholder: _buildPlaceholder(isDark),
        errorWidget: _buildPlaceholder(isDark),
      );
    }
    // Se não tiver evidences, usa imageUrl
    if (project.imageUrl != null) {
      return ImageUtils.buildImage(
        imageUrl: project.imageUrl!,
        fit: BoxFit.cover,
        placeholder: _buildPlaceholder(isDark),
        errorWidget: _buildPlaceholder(isDark),
      );
    }
    // Se não tiver nenhuma imagem, mostra placeholder
    return _buildPlaceholder(isDark);
  }

  Widget _buildPlaceholder([bool isDark = false]) {
    return Container(
      color: isDark ? AppColors.slate800 : AppColors.primaryLight.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.rocket_launch,
          size: 60,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildVotingProgress(project, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.statusVoting.withOpacity(0.15)
            : AppColors.statusVoting.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusVoting.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso da Votação',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.slate200 : AppColors.slate800,
                ),
              ),
              Text(
                '${project.votesCount}/${project.minVotes}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.statusVoting,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: project.votesProgress,
              backgroundColor: AppColors.statusVoting.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusVoting),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingProgress(project, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.success.withOpacity(0.15)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Arrecadação',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.slate200 : AppColors.slate800,
                ),
              ),
              Text(
                Formatters.percentage(project.fundingProgress),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: project.fundingProgress,
              backgroundColor: AppColors.success.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.currency(project.currentAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              Text(
                'de ${Formatters.currency(project.targetAmount)}',
                style: TextStyle(
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(project, ProjectsProvider projectsProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botões de like/dislike
            Row(
              children: [
                Expanded(
                  child: _buildVoteButton(
                    icon: Icons.thumb_up_outlined,
                    label: 'Gostei',
                    color: AppColors.success,
                    onTap: () => _handleVote('up', projectsProvider),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVoteButton(
                    icon: Icons.thumb_down_outlined,
                    label: 'Não gostei',
                    color: AppColors.error,
                    onTap: () => _handleVote('down', projectsProvider),
                  ),
                ),
              ],
            ),
            if (project.isFunding) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Doar',
                  icon: Icons.volunteer_activism,
                  onPressed: () => _showDonationDialog(),
                  backgroundColor: AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDonationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DonationDialog(projectId: widget.projectId),
    );
  }

  Widget _buildVoteButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  void _handleVote(String type, ProjectsProvider projectsProvider) {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faça login para votar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    projectsProvider.vote(
      projectId: widget.projectId,
      userId: authProvider.user!.id,
      userEmail: authProvider.user?.email ?? '',
      type: type,
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(type == 'up' ? 'Você gostou deste projeto!' : 'Você não gostou deste projeto'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        // Recarrega os detalhes do projeto
        _loadProject();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(projectsProvider.error ?? 'Erro ao votar'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }
}

