/// Modelo de voto em projeto
class ProjectVoteModel {
  final String id;
  final String projectId;
  final String? userId;
  final String userEmail;
  final String type; // up, down
  final DateTime createdAt;

  ProjectVoteModel({
    required this.id,
    required this.projectId,
    this.userId,
    required this.userEmail,
    required this.type,
    required this.createdAt,
  });

  /// Cria instância a partir de JSON
  factory ProjectVoteModel.fromJson(Map<String, dynamic> json) {
    return ProjectVoteModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? json['project_id'] ?? '',
      userId: json['userId'] ?? json['user_id'],
      userEmail: json['userEmail'] ?? json['user_email'] ?? '',
      type: json['type'] ?? 'up',
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'userEmail': userEmail,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Verifica se é voto positivo
  bool get isUpvote => type == 'up';

  /// Verifica se é voto negativo
  bool get isDownvote => type == 'down';

  @override
  String toString() => 'ProjectVoteModel(id: $id, projectId: $projectId, type: $type)';
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

