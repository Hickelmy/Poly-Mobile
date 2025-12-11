import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/news_model.dart';
import '../../providers/news_provider.dart';

/// Card de notícia no estilo de rede social
class NewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.news,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newsProvider = context.watch<NewsProvider>();
    final isLiked = news.isLikedByMe == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate800 : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com autor
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar do autor
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    backgroundImage: news.author?.avatarUrl != null
                        ? NetworkImage(news.author!.avatarUrl!)
                        : null,
                    child: news.author?.avatarUrl == null
                        ? Text(
                            news.author?.name.isNotEmpty == true
                                ? news.author!.name[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Nome e data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              news.author?.name ?? 'Administrador',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.slate100 : AppColors.slate900,
                              ),
                            ),
                            if (news.isPinned) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.push_pin,
                                size: 14,
                                color: AppColors.warning,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              Formatters.relativeTime(news.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.slate400 : AppColors.slate500,
                              ),
                            ),
                            if (news.zoneName != null) ...[
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  news.zoneName!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    ),
                    onPressed: () {
                      // TODO: Show options menu
                    },
                  ),
                ],
              ),
            ),

            // Imagem (se houver)
            if (news.imageUrl != null)
              ClipRRect(
                child: Image.network(
                  news.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: isDark ? AppColors.slate700 : AppColors.slate200,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                    ),
                  ),
                ),
              ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.slate50 : AppColors.slate900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Resumo ou início do conteúdo
                  Text(
                    news.summary ?? news.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isDark ? AppColors.slate300 : AppColors.slate600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.slate700 : AppColors.slate200,
            ),

            // Ações
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Curtir
                  TextButton.icon(
                    onPressed: () {
                      if (isLiked) {
                        newsProvider.unlikeNews(news.id);
                      } else {
                        newsProvider.likeNews(news.id);
                      }
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isLiked
                          ? AppColors.error
                          : (isDark ? AppColors.slate400 : AppColors.slate500),
                    ),
                    label: Text(
                      news.likesCount > 0 ? '${news.likesCount}' : 'Curtir',
                      style: TextStyle(
                        color: isLiked
                            ? AppColors.error
                            : (isDark ? AppColors.slate400 : AppColors.slate500),
                      ),
                    ),
                  ),

                  // Comentar
                  TextButton.icon(
                    onPressed: onTap,
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    ),
                    label: Text(
                      news.commentsCount > 0
                          ? '${news.commentsCount}'
                          : 'Comentar',
                      style: TextStyle(
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Compartilhar
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    ),
                    onPressed: () {
                      // TODO: Share
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

