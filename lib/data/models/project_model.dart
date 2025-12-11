/// Modelo de projeto
class ProjectModel {
  final String id;
  final String title;
  final String? shortDescription;
  final String? description;
  final String? category; // seguranca, infraestrutura, cultura, saude, educacao, lazer, outro
  final String status; // proposed, voting, funding, funded, in_progress, completed
  final String? imageUrl;
  final List<String> evidences;
  final double targetAmount;
  final double currentAmount;
  final int minVotes;
  final int votesCount;
  final DateTime? fundingDeadline;
  final String? ownerId;
  final String? ownerEmail;
  final String? ownerName;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final String? zoneId;
  final String? zoneName;
  final double expensesTotal;
  final List<ProjectExpenseModel> expenses;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    required this.id,
    required this.title,
    this.shortDescription,
    this.description,
    this.category,
    this.status = 'proposed',
    this.imageUrl,
    this.evidences = const [],
    this.targetAmount = 0,
    this.currentAmount = 0,
    this.minVotes = 0,
    this.votesCount = 0,
    this.fundingDeadline,
    this.ownerId,
    this.ownerEmail,
    this.ownerName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.zoneName,
    this.expensesTotal = 0,
    this.expenses = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria instância a partir de JSON
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final expensesList = <ProjectExpenseModel>[];
    if (json['expenses'] != null) {
      for (final expense in json['expenses']) {
        expensesList.add(ProjectExpenseModel.fromJson(expense));
      }
    }

    final evidencesList = <String>[];
    if (json['evidences'] != null) {
      for (final evidence in json['evidences']) {
        if (evidence is String) {
          evidencesList.add(evidence);
        }
      }
    }

    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'] ?? json['short_description'],
      description: json['description'],
      category: json['category'],
      status: json['status'] ?? 'proposed',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      evidences: evidencesList,
      targetAmount: _parseDouble(json['targetAmount'] ?? json['target_amount']) ?? 0,
      currentAmount: _parseDouble(json['currentAmount'] ?? json['current_amount']) ?? 0,
      minVotes: _parseInt(json['minVotes'] ?? json['min_votes']) ?? 0,
      votesCount: _parseInt(json['votesCount'] ?? json['votes_count']) ?? 0,
      fundingDeadline: json['fundingDeadline'] != null || json['funding_deadline'] != null
          ? _parseDateTime(json['fundingDeadline'] ?? json['funding_deadline'])
          : null,
      ownerId: json['ownerId'] ?? json['owner_id'],
      ownerEmail: json['ownerEmail'] ?? json['owner_email'],
      ownerName: json['ownerName'] ?? json['owner_name'],
      locationAddress: json['locationAddress'] ?? json['location_address'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      zoneId: json['zoneId'] ?? json['zone_id'],
      zoneName: json['zoneName'] ?? json['zone_name'],
      expensesTotal: _parseDouble(json['expensesTotal'] ?? json['expenses_total']) ?? 0,
      expenses: expensesList,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'evidences': evidences,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'minVotes': minVotes,
      'votesCount': votesCount,
      'fundingDeadline': fundingDeadline?.toIso8601String(),
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
      'locationAddress': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'expensesTotal': expensesTotal,
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com campos alterados
  ProjectModel copyWith({
    String? id,
    String? title,
    String? shortDescription,
    String? description,
    String? category,
    String? status,
    String? imageUrl,
    List<String>? evidences,
    double? targetAmount,
    double? currentAmount,
    int? minVotes,
    int? votesCount,
    DateTime? fundingDeadline,
    String? ownerId,
    String? ownerEmail,
    String? ownerName,
    String? locationAddress,
    double? latitude,
    double? longitude,
    String? zoneId,
    String? zoneName,
    double? expensesTotal,
    List<ProjectExpenseModel>? expenses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      evidences: evidences ?? this.evidences,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      minVotes: minVotes ?? this.minVotes,
      votesCount: votesCount ?? this.votesCount,
      fundingDeadline: fundingDeadline ?? this.fundingDeadline,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerName: ownerName ?? this.ownerName,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      expensesTotal: expensesTotal ?? this.expensesTotal,
      expenses: expenses ?? this.expenses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Progresso de votos (0 a 1)
  double get votesProgress {
    if (minVotes <= 0) return 0;
    return (votesCount / minVotes).clamp(0.0, 1.0);
  }

  /// Progresso de arrecadação (0 a 1)
  double get fundingProgress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// Verifica se está em votação
  bool get isVoting => status == 'voting';

  /// Verifica se está arrecadando
  bool get isFunding => status == 'funding';

  /// Verifica se pode receber votos
  bool get canVote => isVoting && votesCount < minVotes;

  /// Verifica se pode receber doações
  bool get canDonate => isFunding && currentAmount < targetAmount;

  /// Verifica se tem localização
  bool get hasLocation => latitude != null && longitude != null;

  /// Verifica se tem deadline de financiamento
  bool get hasDeadline => fundingDeadline != null;

  /// Verifica se o deadline passou
  bool get isDeadlinePassed =>
      fundingDeadline != null && DateTime.now().isAfter(fundingDeadline!);

  @override
  String toString() => 'ProjectModel(id: $id, title: $title, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Modelo de despesa do projeto
class ProjectExpenseModel {
  final String id;
  final String projectId;
  final String type;
  final String? description;
  final double cost;
  final int quantity;

  ProjectExpenseModel({
    required this.id,
    required this.projectId,
    required this.type,
    this.description,
    this.cost = 0,
    this.quantity = 1,
  });

  factory ProjectExpenseModel.fromJson(Map<String, dynamic> json) {
    return ProjectExpenseModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? json['project_id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      cost: _parseDouble(json['cost']) ?? 0,
      quantity: _parseInt(json['quantity']) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'type': type,
      'description': description,
      'cost': cost,
      'quantity': quantity,
    };
  }

  double get total => cost * quantity;
}

// Helpers para parsing
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

