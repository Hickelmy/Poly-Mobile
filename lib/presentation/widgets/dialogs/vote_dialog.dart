import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/projects_provider.dart';

/// Dialog de votação
class VoteDialog extends StatelessWidget {
  final String projectId;

  const VoteDialog({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final projectsProvider = context.read<ProjectsProvider>();
    final project = projectsProvider.selectedProject;

    return AlertDialog(
      title: const Text('Votar no Projeto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            project?.title ?? 'Projeto',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Votos atuais: ${project?.votesCount ?? 0}/${project?.minVotes ?? 0}',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _vote(context, authProvider, projectsProvider, 'up'),
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('Apoiar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _vote(context, authProvider, projectsProvider, 'down'),
                  icon: const Icon(Icons.thumb_down),
                  label: const Text('Rejeitar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  Future<void> _vote(
    BuildContext context,
    AuthProvider authProvider,
    ProjectsProvider projectsProvider,
    String type,
  ) async {
    final user = authProvider.user;
    if (user == null) return;

    final success = await projectsProvider.vote(
      projectId: projectId,
      userId: user.id,
      userEmail: user.email,
      type: type,
    );

    if (!context.mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Voto registrado!' : projectsProvider.error ?? 'Erro ao votar',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }
}

