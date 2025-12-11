import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/news_model.dart';

/// Repositório de Notícias
class NewsRepository {
  final ApiClient _apiClient;

  NewsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Lista notícias
  Future<List<NewsModel>> getNews({
    String? zoneId,
    bool? publishedOnly = true,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (zoneId != null) queryParams['zoneId'] = zoneId;
    if (publishedOnly != null) queryParams['publishedOnly'] = publishedOnly;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _apiClient.get(
      ApiEndpoints.news,
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is List) {
      return data.map((e) => NewsModel.fromJson(e)).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => NewsModel.fromJson(e)).toList();
    }
    return [];
  }

  /// Busca notícia por ID
  Future<NewsModel> getNewsById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.newsById(id));
    return NewsModel.fromJson(response.data);
  }

  /// Cria notícia (Admin/Manager)
  Future<NewsModel> createNews({
    required String title,
    required String content,
    String? summary,
    String? imageUrl,
    List<String>? images,
    String? zoneId,
    bool isPublished = true,
    bool isPinned = false,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.news,
      data: {
        'title': title,
        'content': content,
        if (summary != null) 'summary': summary,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (images != null) 'images': images,
        if (zoneId != null) 'zoneId': zoneId,
        'isPublished': isPublished,
        'isPinned': isPinned,
      },
    );
    return NewsModel.fromJson(response.data);
  }

  /// Atualiza notícia (Admin/Manager)
  Future<NewsModel> updateNews(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      ApiEndpoints.newsById(id),
      data: data,
    );
    return NewsModel.fromJson(response.data);
  }

  /// Remove notícia (Admin/Manager)
  Future<void> deleteNews(String id) async {
    await _apiClient.delete(ApiEndpoints.newsById(id));
  }

  /// Curte notícia
  Future<void> likeNews(String id) async {
    await _apiClient.post(ApiEndpoints.newsLike(id));
  }

  /// Remove curtida
  Future<void> unlikeNews(String id) async {
    await _apiClient.delete(ApiEndpoints.newsLike(id));
  }

  /// Lista comentários de uma notícia
  Future<List<NewsCommentModel>> getComments(String newsId) async {
    final response = await _apiClient.get(ApiEndpoints.newsComments(newsId));
    final data = response.data;
    if (data is List) {
      return data.map((e) => NewsCommentModel.fromJson(e)).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => NewsCommentModel.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Adiciona comentário
  Future<NewsCommentModel> addComment({
    required String newsId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.newsComments(newsId),
      data: {'content': content},
    );
    return NewsCommentModel.fromJson(response.data);
  }

  /// Remove comentário
  Future<void> deleteComment(String newsId, String commentId) async {
    await _apiClient.delete('${ApiEndpoints.newsComments(newsId)}/$commentId');
  }

  /// Reporta notícia
  Future<void> reportNews({
    required String newsId,
    required String reason,
    String? description,
  }) async {
    await _apiClient.post(
      ApiEndpoints.newsReport(newsId),
      data: {
        'reason': reason,
        if (description != null) 'description': description,
      },
    );
  }

  /// Lista denúncias (Manager/Admin)
  Future<List<NewsReportModel>> getReports({String? newsId}) async {
    final queryParams = <String, dynamic>{};
    if (newsId != null) queryParams['newsId'] = newsId;

    final response = await _apiClient.get(
      '${ApiEndpoints.news}/reports',
      queryParameters: queryParams,
    );
    
    final data = response.data;
    if (data is List) {
      return data.map((e) => NewsReportModel.fromJson(e)).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => NewsReportModel.fromJson(e))
          .toList();
    }
    return [];
  }
}

