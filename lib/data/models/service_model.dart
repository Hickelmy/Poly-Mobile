/// Modelo de serviço
class ServiceModel {
  final String id;
  final String title;
  final String? description;
  final double? price;
  final String priceType; // hora, diaria, servico, orcamento
  final String? serviceType; // limpeza, manutencao, jardinagem, eletrica, encanamento, pintura, aulas, cuidados, transporte, outros
  final List<String> images;
  final bool active;
  final String? providerId;
  final String? providerEmail;
  final String? providerName;
  final String? zoneId;
  final String? zoneName;
  final double? lat;
  final double? lng;
  final double? rating;
  final int? reviewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.title,
    this.description,
    this.price,
    this.priceType = 'servico',
    this.serviceType,
    this.images = const [],
    this.active = true,
    this.providerId,
    this.providerEmail,
    this.providerName,
    this.zoneId,
    this.zoneName,
    this.lat,
    this.lng,
    this.rating,
    this.reviewsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria instância a partir de JSON
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final imagesList = <String>[];
    if (json['images'] != null) {
      for (final image in json['images']) {
        if (image is String) {
          imagesList.add(image);
        }
      }
    }

    return ServiceModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      price: _parseDouble(json['price']),
      priceType: json['priceType'] ?? json['price_type'] ?? 'servico',
      serviceType: json['serviceType'] ?? json['service_type'],
      images: imagesList,
      active: json['active'] ?? true,
      providerId: json['providerId'] ?? json['provider_id'],
      providerEmail: json['providerEmail'] ?? json['provider_email'],
      providerName: json['providerName'] ?? json['provider_name'],
      zoneId: json['zoneId'] ?? json['zone_id'],
      zoneName: json['zoneName'] ?? json['zone_name'],
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(json['reviewsCount'] ?? json['reviews_count']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'priceType': priceType,
      'serviceType': serviceType,
      'images': images,
      'active': active,
      'providerId': providerId,
      'providerEmail': providerEmail,
      'providerName': providerName,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'lat': lat,
      'lng': lng,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com campos alterados
  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? priceType,
    String? serviceType,
    List<String>? images,
    bool? active,
    String? providerId,
    String? providerEmail,
    String? providerName,
    String? zoneId,
    String? zoneName,
    double? lat,
    double? lng,
    double? rating,
    int? reviewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      serviceType: serviceType ?? this.serviceType,
      images: images ?? this.images,
      active: active ?? this.active,
      providerId: providerId ?? this.providerId,
      providerEmail: providerEmail ?? this.providerEmail,
      providerName: providerName ?? this.providerName,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se está disponível
  bool get isAvailable => active;

  /// Verifica se tem localização
  bool get hasLocation => lat != null && lng != null;

  /// Retorna a primeira imagem ou null
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  /// Verifica se tem preço definido
  bool get hasPrice => price != null && price! > 0;

  /// Nome traduzido do tipo de preço
  String get priceTypeName {
    switch (priceType.toLowerCase()) {
      case 'hora':
        return 'Por hora';
      case 'diaria':
        return 'Por dia';
      case 'servico':
        return 'Por serviço';
      case 'orcamento':
        return 'Sob orçamento';
      default:
        return priceType;
    }
  }

  /// Nome traduzido do tipo de serviço
  String get serviceTypeName {
    switch (serviceType?.toLowerCase()) {
      case 'limpeza':
        return 'Limpeza';
      case 'manutencao':
        return 'Manutenção';
      case 'jardinagem':
        return 'Jardinagem';
      case 'eletrica':
        return 'Elétrica';
      case 'encanamento':
        return 'Encanamento';
      case 'pintura':
        return 'Pintura';
      case 'aulas':
        return 'Aulas';
      case 'cuidados':
        return 'Cuidados';
      case 'transporte':
        return 'Transporte';
      case 'outros':
        return 'Outros';
      default:
        return serviceType ?? 'Não categorizado';
    }
  }

  /// Retorna a avaliação formatada
  String get formattedRating {
    if (rating == null) return 'Sem avaliação';
    return rating!.toStringAsFixed(1);
  }

  @override
  String toString() => 'ServiceModel(id: $id, title: $title, priceType: $priceType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
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

