import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/image_utils.dart';
import '../../../data/models/project_model.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/progress_bar.dart';
import '../../widgets/common/status_badge.dart';
import '../../providers/projects_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Card de projeto com design moderno e fluido
class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final bool isCompact;
  final VoidCallback? onTap;
  final bool userVoted;

  const ProjectCard({
    super.key,
    required this.project,
    this.isCompact = false,
    this.onTap,
    this.userVoted = false,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _images {
    if (widget.project.evidences.isNotEmpty) {
      return widget.project.evidences;
    }
    if (widget.project.imageUrl != null) {
      return [widget.project.imageUrl!];
    }
    return [];
  }

  bool get _hasMultipleImages => _images.length > 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canVote = ['proposed', 'voting'].contains(widget.project.status);
    final canDonate = ['funding', 'funded', 'in_progress', 'completed']
        .contains(widget.project.status);

    // Calcular votos (assumindo que temos up_votes e down_votes no modelo)
    final upVotes =
        widget.project.votesCount; // Simplificado - ajustar conforme modelo
    final downVotes = 0; // Ajustar conforme modelo real
    final totalVotes = upVotes + downVotes;
    final diff = upVotes - downVotes;
    final remainingVotes =
        (widget.project.minVotes - diff).clamp(0, widget.project.minVotes);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate900 : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.slate700 : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem com carousel - área não clicável para navegação
            GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                } else {
                  AppRoutes.navigateTo(
                    AppRoutes.projectDetail,
                    arguments: {'id': widget.project.id},
                  );
                }
              },
              child: AspectRatio(
                aspectRatio: widget.isCompact ? 2.2 : 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_images.isNotEmpty)
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemBuilder: (context, index) {
                          // Suporta base64 e URLs
                          final imageUrl = _images[index];
                          final provider =
                              ImageUtils.getImageProvider(imageUrl);

                          if (provider == null) {
                            return _buildPlaceholder();
                          }

                          if (ImageUtils.isBase64Image(imageUrl)) {
                            return Image(
                              image: provider,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            );
                          }

                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildPlaceholder(),
                            errorWidget: (context, url, error) =>
                                _buildPlaceholder(),
                          );
                        },
                      )
                    else
                      _buildPlaceholder(),

                    // Gradiente overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Status badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: StatusBadge(
                        status: widget.project.status,
                        isCompact: true,
                      ),
                    ),

                    // Categoria
                    if (widget.project.category != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getCategoryEmoji(widget.project.category!),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.getCategoryName(
                                    widget.project.category),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Controles de imagem (se múltiplas)
                    if (_hasMultipleImages)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildImageControl(
                              icon: Icons.chevron_left,
                              onTap: () {
                                if (_pageController.hasClients) {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentImageIndex + 1} / ${_images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            _buildImageControl(
                              icon: Icons.chevron_right,
                              onTap: () {
                                if (_pageController.hasClients) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                    // Título sobreposto
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Text(
                        widget.project.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content - área clicável
            GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                } else {
                  AppRoutes.navigateTo(
                    AppRoutes.projectDetail,
                    arguments: {'id': widget.project.id},
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isCompact &&
                        widget.project.shortDescription != null) ...[
                      Text(
                        widget.project.shortDescription!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.slate400
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Estatísticas
                    Row(
                      children: [
                        if (widget.project.fundingDeadline != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.date(widget.project.fundingDeadline!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.slate400
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.how_to_vote,
                          size: 14,
                          color: isDark
                              ? AppColors.slate400
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.project.minVotes > 0
                              ? '$diff/${widget.project.minVotes} votos úteis'
                              : '$diff votos úteis',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Barra de votação (tug-of-war) se em votação
                    if (canVote && totalVotes > 0) ...[
                      VotingProgressBar(
                        upVotes: upVotes,
                        downVotes: downVotes,
                      ),
                      if (remainingVotes > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Faltam $remainingVotes votos positivos para liberar doações.',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],

                    // Barra de progresso de financiamento
                    if (canDonate) ...[
                      ProgressBar(
                        current: widget.project.currentAmount,
                        target: widget.project.targetAmount,
                        height: 8,
                        showPercentage: false,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Formatters.currencyCompact(
                                widget.project.currentAmount),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.emerald500,
                            ),
                          ),
                          Text(
                            'de ${Formatters.currencyCompact(widget.project.targetAmount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.slate400
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Botões de ação - Like/Dislike e Saber Mais
                    if (!widget.isCompact) ...[
                      // Botões de like/dislike
                      Row(
                        children: [
                          Expanded(
                            child: _buildVoteButton(
                              icon: Icons.thumb_up_outlined,
                              label: 'Gostei',
                              color: AppColors.success,
                              onTap: () => _handleVote('up'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildVoteButton(
                              icon: Icons.thumb_down_outlined,
                              label: 'Não gostei',
                              color: AppColors.error,
                              onTap: () => _handleVote('down'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Botão Saber Mais
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onTap != null) {
                              widget.onTap!();
                            } else {
                              AppRoutes.navigateTo(
                                AppRoutes.projectDetail,
                                arguments: {'id': widget.project.id},
                              );
                            }
                          },
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: const Text('Saber Mais'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryLight.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.rocket_launch,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildImageControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        // Previne que o toque propague para o card pai
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    const emojis = {
      'seguranca': '🛡️',
      'infraestrutura': '🏗️',
      'cultura': '🎭',
      'saude': '🏥',
      'educacao': '📚',
      'lazer': '🎮',
      'outro': '📌',
    };
    return emojis[category.toLowerCase()] ?? '📌';
  }

  Widget _buildVoteButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  void _handleVote(String type) {
    final projectsProvider = context.read<ProjectsProvider>();
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

    // TODO: Implementar voto via API
    projectsProvider
        .vote(
      projectId: widget.project.id,
      userId: authProvider.user!.id,
      userEmail: authProvider.user?.email ?? '',
      type: type,
    )
        .then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(type == 'up'
                ? 'Você gostou deste projeto!'
                : 'Você não gostou deste projeto'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
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
