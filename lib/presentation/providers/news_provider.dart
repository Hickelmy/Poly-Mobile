import 'package:flutter/foundation.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../data/models/news_model.dart';
import '../../data/repositories/news_repository.dart';

/// Provider de Notícias
class NewsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final NewsRepository _newsRepository;

  List<NewsModel> _news = [];
  NewsModel? _selectedNews;
  List<NewsCommentModel> _comments = [];
  List<NewsReportModel> _reports = [];
  bool _isLoading = false;
  bool _isLoadingComments = false;
  String? _error;

  NewsProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _newsRepository = NewsRepository(apiClient: _apiClient);
  }

  // Getters
  List<NewsModel> get news => _news;
  NewsModel? get selectedNews => _selectedNews;
  List<NewsCommentModel> get comments => _comments;
  List<NewsReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get isLoadingComments => _isLoadingComments;
  String? get error => _error;

  /// Carrega lista de notícias
  Future<void> loadNews({
    String? zoneId,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    if (refresh) _news = [];
    notifyListeners();

    try {
      _news = await _newsRepository.getNews(zoneId: zoneId);
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Erro ao carregar notícias';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega detalhes de uma notícia
  Future<NewsModel?> loadNewsDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedNews = await _newsRepository.getNewsById(id);
      _isLoading = false;
      notifyListeners();
      return _selectedNews;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cria notícia (Admin/Manager)
  Future<NewsModel?> createNews({
    required String title,
    required String content,
    String? summary,
    String? imageUrl,
    List<String>? images,
    String? zoneId,
    bool isPublished = true,
    bool isPinned = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newsItem = await _newsRepository.createNews(
        title: title,
        content: content,
        summary: summary,
        imageUrl: imageUrl,
        images: images,
        zoneId: zoneId,
        isPublished: isPublished,
        isPinned: isPinned,
      );

      _news.insert(0, newsItem);
      _isLoading = false;
      notifyListeners();
      return newsItem;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Atualiza notícia (Admin/Manager)
  Future<bool> updateNews(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _newsRepository.updateNews(id, data);

      // Atualiza na lista
      final index = _news.indexWhere((n) => n.id == id);
      if (index != -1) {
        _news[index] = updated;
      }

      // Atualiza selecionada se for a mesma
      if (_selectedNews?.id == id) {
        _selectedNews = updated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove notícia (Admin/Manager)
  Future<bool> deleteNews(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _newsRepository.deleteNews(id);
      _news.removeWhere((n) => n.id == id);

      if (_selectedNews?.id == id) {
        _selectedNews = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Curte notícia
  Future<bool> likeNews(String id) async {
    try {
      await _newsRepository.likeNews(id);

      // Atualiza localmente
      final index = _news.indexWhere((n) => n.id == id);
      if (index != -1) {
        _news[index] = _news[index].copyWith(
          likesCount: _news[index].likesCount + 1,
          isLikedByMe: true,
        );
      }

      if (_selectedNews?.id == id) {
        _selectedNews = _selectedNews!.copyWith(
          likesCount: _selectedNews!.likesCount + 1,
          isLikedByMe: true,
        );
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Remove curtida
  Future<bool> unlikeNews(String id) async {
    try {
      await _newsRepository.unlikeNews(id);

      // Atualiza localmente
      final index = _news.indexWhere((n) => n.id == id);
      if (index != -1 && _news[index].likesCount > 0) {
        _news[index] = _news[index].copyWith(
          likesCount: _news[index].likesCount - 1,
          isLikedByMe: false,
        );
      }

      if (_selectedNews?.id == id && _selectedNews!.likesCount > 0) {
        _selectedNews = _selectedNews!.copyWith(
          likesCount: _selectedNews!.likesCount - 1,
          isLikedByMe: false,
        );
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Carrega comentários
  Future<void> loadComments(String newsId) async {
    _isLoadingComments = true;
    notifyListeners();

    try {
      _comments = await _newsRepository.getComments(newsId);
    } catch (_) {
      _comments = [];
    }

    _isLoadingComments = false;
    notifyListeners();
  }

  /// Adiciona comentário
  Future<NewsCommentModel?> addComment({
    required String newsId,
    required String content,
  }) async {
    try {
      final comment = await _newsRepository.addComment(
        newsId: newsId,
        content: content,
      );

      _comments.insert(0, comment);

      // Atualiza contagem
      final index = _news.indexWhere((n) => n.id == newsId);
      if (index != -1) {
        _news[index] = _news[index].copyWith(
          commentsCount: _news[index].commentsCount + 1,
        );
      }

      if (_selectedNews?.id == newsId) {
        _selectedNews = _selectedNews!.copyWith(
          commentsCount: _selectedNews!.commentsCount + 1,
        );
      }

      notifyListeners();
      return comment;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  /// Remove comentário
  Future<bool> deleteComment(String newsId, String commentId) async {
    try {
      await _newsRepository.deleteComment(newsId, commentId);
      _comments.removeWhere((c) => c.id == commentId);

      // Atualiza contagem
      final index = _news.indexWhere((n) => n.id == newsId);
      if (index != -1 && _news[index].commentsCount > 0) {
        _news[index] = _news[index].copyWith(
          commentsCount: _news[index].commentsCount - 1,
        );
      }

      if (_selectedNews?.id == newsId && _selectedNews!.commentsCount > 0) {
        _selectedNews = _selectedNews!.copyWith(
          commentsCount: _selectedNews!.commentsCount - 1,
        );
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Reporta notícia
  Future<bool> reportNews({
    required String newsId,
    required String reason,
    String? description,
  }) async {
    try {
      await _newsRepository.reportNews(
        newsId: newsId,
        reason: reason,
        description: description,
      );
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Carrega denúncias (Manager/Admin)
  Future<void> loadReports({String? newsId}) async {
    try {
      _reports = await _newsRepository.getReports(newsId: newsId);
      notifyListeners();
    } catch (_) {
      _reports = [];
    }
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Limpa notícia selecionada
  void clearSelectedNews() {
    _selectedNews = null;
    _comments = [];
    notifyListeners();
  }
}

