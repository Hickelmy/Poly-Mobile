import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/selected_zone_provider.dart';
import '../../widgets/common/app_bar_with_theme.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/cards/news_card.dart';

/// Tela de listagem de notícias/informações
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String? _lastZoneId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNews();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedZoneProvider = context.read<SelectedZoneProvider>();
    final currentZoneId = selectedZoneProvider.selectedZoneId;
    
    // Só recarrega se a zona realmente mudou
    if (_lastZoneId != currentZoneId) {
      _lastZoneId = currentZoneId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadNews();
        }
      });
    }
  }

  Future<void> _loadNews({bool refresh = false}) async {
    final selectedZoneProvider = context.read<SelectedZoneProvider>();
    final newsProvider = context.read<NewsProvider>();
    await newsProvider.loadNews(
      zoneId: selectedZoneProvider.selectedZoneId,
      refresh: refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final newsProvider = context.watch<NewsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canCreate = authProvider.isAdmin || authProvider.isManager;

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
      appBar: AppBarWithTheme(
        title: 'Informações',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNews(refresh: true),
        color: AppColors.primary,
        child: _buildContent(newsProvider, isDark),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateNewsScreen(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nova Notícia'),
              backgroundColor: AppColors.info,
            )
          : null,
    );
  }

  Widget _buildContent(NewsProvider provider, bool isDark) {
    if (provider.isLoading && provider.news.isEmpty) {
      return const LoadingWidget(message: 'Carregando notícias...');
    }

    if (provider.error != null && provider.news.isEmpty) {
      return CustomErrorWidget(
        message: provider.error,
        onRetry: () => provider.loadNews(refresh: true),
      );
    }

    if (provider.news.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.newspaper_outlined,
        title: 'Nenhuma notícia',
        message: 'Quando houver notícias e informações da sua área, elas aparecerão aqui.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.news.length,
      itemBuilder: (context, index) {
        final news = provider.news[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NewsCard(
            news: news,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewsDetailScreen(newsId: news.id),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tela de detalhe de notícia
class NewsDetailScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NewsProvider>();
      provider.loadNewsDetails(widget.newsId);
      provider.loadComments(widget.newsId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final newsProvider = context.watch<NewsProvider>();
    final news = newsProvider.selectedNews;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canManage = authProvider.isAdmin || authProvider.isManager;

    if (newsProvider.isLoading && news == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingWidget(),
      );
    }

    if (news == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const CustomErrorWidget(
          message: 'Notícia não encontrada',
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar com imagem
          SliverAppBar(
            expandedHeight: news.imageUrl != null ? 250 : 0,
            pinned: true,
            backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
            flexibleSpace: news.imageUrl != null
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          news.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: isDark ? AppColors.slate800 : AppColors.slate200,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: isDark ? AppColors.slate600 : AppColors.slate400,
                            ),
                          ),
                        ),
                        // Gradiente escuro
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
            actions: [
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => _handleMenuAction(value, news.id),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reports',
                      child: Row(
                        children: [
                          Icon(Icons.flag),
                          SizedBox(width: 8),
                          Text('Ver Denúncias'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.slate50 : AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta informações
                  Row(
                    children: [
                      if (news.author != null) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          backgroundImage: news.author!.avatarUrl != null
                              ? NetworkImage(news.author!.avatarUrl!)
                              : null,
                          child: news.author!.avatarUrl == null
                              ? Text(
                                  news.author!.name.isNotEmpty
                                      ? news.author!.name[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          news.author!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.slate300 : AppColors.slate700,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '• ${Formatters.relativeTime(news.createdAt)}',
                        style: TextStyle(
                          color: isDark ? AppColors.slate400 : AppColors.slate500,
                          fontSize: 13,
                        ),
                      ),
                      if (news.zoneName != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            news.zoneName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Conteúdo
                  Text(
                    news.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ações
                  _buildActions(news, isDark),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(
                    color: isDark ? AppColors.slate700 : AppColors.slate200,
                  ),
                  const SizedBox(height: 16),

                  // Comentários
                  _buildCommentsSection(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
      // Campo de comentário fixo
      bottomNavigationBar: _buildCommentInput(isDark),
    );
  }

  Widget _buildActions(dynamic news, bool isDark) {
    final newsProvider = context.watch<NewsProvider>();
    final isLiked = news.isLikedByMe == true;

    return Row(
      children: [
        // Curtir
        InkWell(
          onTap: () {
            if (isLiked) {
              newsProvider.unlikeNews(news.id);
            } else {
              newsProvider.likeNews(news.id);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isLiked
                  ? AppColors.error.withOpacity(0.1)
                  : (isDark ? AppColors.slate800 : AppColors.slate100),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked
                      ? AppColors.error
                      : (isDark ? AppColors.slate400 : AppColors.slate600),
                ),
                const SizedBox(width: 6),
                Text(
                  '${news.likesCount}',
                  style: TextStyle(
                    color: isLiked
                        ? AppColors.error
                        : (isDark ? AppColors.slate400 : AppColors.slate600),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Comentários
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : AppColors.slate100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
              const SizedBox(width: 6),
              Text(
                '${news.commentsCount}',
                style: TextStyle(
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Reportar
        IconButton(
          icon: Icon(
            Icons.flag_outlined,
            color: isDark ? AppColors.slate400 : AppColors.slate600,
          ),
          onPressed: () => _showReportDialog(news.id),
        ),

        // Compartilhar
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: isDark ? AppColors.slate400 : AppColors.slate600,
          ),
          onPressed: () {
            // TODO: Share
          },
        ),
      ],
    );
  }

  Widget _buildCommentsSection(bool isDark) {
    final newsProvider = context.watch<NewsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comentários',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.slate50 : AppColors.slate900,
          ),
        ),
        const SizedBox(height: 16),

        if (newsProvider.isLoadingComments)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (newsProvider.comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: isDark ? AppColors.slate600 : AppColors.slate400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum comentário ainda',
                    style: TextStyle(
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seja o primeiro a comentar!',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.slate500 : AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...newsProvider.comments.map((comment) => _buildCommentItem(comment, isDark)),
        
        // Espaço extra para o campo de input
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCommentItem(dynamic comment, bool isDark) {
    final authProvider = context.watch<AuthProvider>();
    final isOwner = comment.userId == authProvider.user?.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.slate700 : AppColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                backgroundImage: comment.user?.avatarUrl != null
                    ? NetworkImage(comment.user!.avatarUrl!)
                    : null,
                child: comment.user?.avatarUrl == null
                    ? Text(
                        comment.user?.name.isNotEmpty == true
                            ? comment.user!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user?.name ?? 'Usuário',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? AppColors.slate200 : AppColors.slate800,
                      ),
                    ),
                    Text(
                      Formatters.relativeTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.slate500 : AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: isDark ? AppColors.slate500 : AppColors.slate400,
                  ),
                  onPressed: () => _deleteComment(comment.id),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(
              color: isDark ? AppColors.slate300 : AppColors.slate700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(
                color: isDark ? AppColors.slate200 : AppColors.slate800,
              ),
              decoration: InputDecoration(
                hintText: 'Escreva um comentário...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
                filled: true,
                fillColor: isDark ? AppColors.slate900 : AppColors.slate100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _submitComment,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, String newsId) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit screen
        break;
      case 'delete':
        _confirmDelete(newsId);
        break;
      case 'reports':
        _showReportsDialog(newsId);
        break;
    }
  }

  void _confirmDelete(String newsId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir notícia'),
        content: const Text('Tem certeza que deseja excluir esta notícia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<NewsProvider>().deleteNews(newsId);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(String newsId) {
    String? selectedReason;
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reportar notícia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecione o motivo da denúncia:'),
              const SizedBox(height: 16),
              ...['Conteúdo inadequado', 'Informação falsa', 'Spam', 'Outro']
                  .map((reason) => RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) => setState(() => selectedReason = value),
                      )),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedReason != null
                  ? () async {
                      Navigator.pop(context);
                      final success = await context.read<NewsProvider>().reportNews(
                        newsId: newsId,
                        reason: selectedReason!,
                        description: descController.text.isNotEmpty
                            ? descController.text
                            : null,
                      );
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Denúncia enviada com sucesso'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportsDialog(String newsId) {
    final newsProvider = context.read<NewsProvider>();
    newsProvider.loadReports(newsId: newsId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Denúncias'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<NewsProvider>(
            builder: (context, provider, _) {
              if (provider.reports.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Nenhuma denúncia'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.reports.length,
                itemBuilder: (context, index) {
                  final report = provider.reports[index];
                  return ListTile(
                    title: Text(report.reason),
                    subtitle: Text(report.description ?? 'Sem descrição'),
                    trailing: Text(
                      report.status,
                      style: TextStyle(
                        color: report.status == 'pending'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final newsProvider = context.read<NewsProvider>();
    final result = await newsProvider.addComment(
      newsId: widget.newsId,
      content: content,
    );

    if (result != null) {
      _commentController.clear();
    }
  }

  void _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir comentário'),
        content: const Text('Tem certeza que deseja excluir este comentário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<NewsProvider>().deleteComment(widget.newsId, commentId);
    }
  }
}

/// Tela de criação de notícia
class CreateNewsScreen extends StatefulWidget {
  final String? newsId; // Se for edição

  const CreateNewsScreen({super.key, this.newsId});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isPublished = true;
  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate900 : AppColors.background,
      appBar: AppBar(
        title: Text(widget.newsId != null ? 'Editar Notícia' : 'Nova Notícia'),
        backgroundColor: isDark ? AppColors.slate900 : AppColors.surface,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: Text(
              'Publicar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              style: TextStyle(
                color: isDark ? AppColors.slate100 : AppColors.slate900,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Título da notícia...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
              ),
              validator: (v) => v?.isEmpty == true ? 'Informe o título' : null,
            ),
            const SizedBox(height: 16),

            // Resumo
            TextFormField(
              controller: _summaryController,
              style: TextStyle(
                color: isDark ? AppColors.slate300 : AppColors.slate700,
              ),
              decoration: InputDecoration(
                hintText: 'Resumo (opcional)...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
                border: InputBorder.none,
              ),
              maxLines: 2,
            ),
            const Divider(),
            const SizedBox(height: 16),

            // URL da imagem
            TextFormField(
              controller: _imageUrlController,
              style: TextStyle(
                color: isDark ? AppColors.slate300 : AppColors.slate700,
              ),
              decoration: InputDecoration(
                labelText: 'URL da imagem (opcional)',
                labelStyle: TextStyle(
                  color: isDark ? AppColors.slate400 : AppColors.slate600,
                ),
                prefixIcon: Icon(
                  Icons.image,
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Conteúdo
            TextFormField(
              controller: _contentController,
              style: TextStyle(
                color: isDark ? AppColors.slate200 : AppColors.slate800,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Escreva o conteúdo da notícia...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              validator: (v) => v?.isEmpty == true ? 'Informe o conteúdo' : null,
            ),
            const SizedBox(height: 24),

            // Opções
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate800 : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.slate700 : AppColors.slate200,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Publicar imediatamente',
                      style: TextStyle(
                        color: isDark ? AppColors.slate200 : AppColors.slate800,
                      ),
                    ),
                    subtitle: Text(
                      'Se desativado, a notícia ficará como rascunho',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                      ),
                    ),
                    value: _isPublished,
                    onChanged: (v) => setState(() => _isPublished = v),
                    activeColor: AppColors.primary,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: Text(
                      'Fixar no topo',
                      style: TextStyle(
                        color: isDark ? AppColors.slate200 : AppColors.slate800,
                      ),
                    ),
                    subtitle: Text(
                      'A notícia aparecerá sempre no início da lista',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.slate400 : AppColors.slate500,
                      ),
                    ),
                    value: _isPinned,
                    onChanged: (v) => setState(() => _isPinned = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newsProvider = context.read<NewsProvider>();
    final result = await newsProvider.createNews(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      summary: _summaryController.text.trim().isNotEmpty
          ? _summaryController.text.trim()
          : null,
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : null,
      isPublished: _isPublished,
      isPinned: _isPinned,
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notícia criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

