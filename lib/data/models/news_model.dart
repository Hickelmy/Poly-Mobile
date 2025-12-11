import 'user_model.dart';

/// Modelo de Notícia/Informação
class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;
  final List<String>? images;
  final String authorId;
  final UserModel? author;
  final String? zoneId;
  final String? zoneName;
  final bool isPublished;
  final bool isPinned;
  final int likesCount;
  final int commentsCount;
  final int reportsCount;
  final bool? isLikedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    this.imageUrl,
    this.images,
    required this.authorId,
    this.author,
    this.zoneId,
    this.zoneName,
    this.isPublished = true,
    this.isPinned = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.reportsCount = 0,
    this.isLikedByMe,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      summary: json['summary'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : null,
      authorId: json['authorId'] ?? json['author_id'] ?? '',
      author: json['author'] != null 
          ? UserModel.fromJson(json['author']) 
          : null,
      zoneId: json['zoneId'] ?? json['zone_id'],
      zoneName: json['zoneName'] ?? json['zone_name'] ?? json['zone']?['name'],
      isPublished: json['isPublished'] ?? json['is_published'] ?? true,
      isPinned: json['isPinned'] ?? json['is_pinned'] ?? false,
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? 0,
      reportsCount: json['reportsCount'] ?? json['reports_count'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? json['is_liked_by_me'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'imageUrl': imageUrl,
      'images': images,
      'authorId': authorId,
      'zoneId': zoneId,
      'isPublished': isPublished,
      'isPinned': isPinned,
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    String? imageUrl,
    List<String>? images,
    String? authorId,
    UserModel? author,
    String? zoneId,
    String? zoneName,
    bool? isPublished,
    bool? isPinned,
    int? likesCount,
    int? commentsCount,
    int? reportsCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      isPublished: isPublished ?? this.isPublished,
      isPinned: isPinned ?? this.isPinned,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      reportsCount: reportsCount ?? this.reportsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

/// Modelo de Comentário de Notícia
class NewsCommentModel {
  final String id;
  final String newsId;
  final String userId;
  final UserModel? user;
  final String content;
  final int likesCount;
  final bool? isLikedByMe;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsCommentModel({
    required this.id,
    required this.newsId,
    required this.userId,
    this.user,
    required this.content,
    this.likesCount = 0,
    this.isLikedByMe,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsCommentModel.fromJson(Map<String, dynamic> json) {
    return NewsCommentModel(
      id: json['id'] ?? json['_id'] ?? '',
      newsId: json['newsId'] ?? json['news_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      content: json['content'] ?? '',
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? json['is_liked_by_me'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newsId': newsId,
      'content': content,
    };
  }
}

/// Modelo de Denúncia de Notícia
class NewsReportModel {
  final String id;
  final String newsId;
  final String userId;
  final UserModel? user;
  final String reason;
  final String? description;
  final String status; // pending, reviewed, dismissed
  final DateTime createdAt;

  NewsReportModel({
    required this.id,
    required this.newsId,
    required this.userId,
    this.user,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
  });

  factory NewsReportModel.fromJson(Map<String, dynamic> json) {
    return NewsReportModel(
      id: json['id'] ?? json['_id'] ?? '',
      newsId: json['newsId'] ?? json['news_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

