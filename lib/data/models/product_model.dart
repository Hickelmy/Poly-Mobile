/// Modelo de produto
class ProductModel {
  final String id;
  final String title;
  final String? description;
  final double price;
  final int quantityAvailable;
  final String? category; // eletronicos, moveis, vestuario, alimentos, servicos_domesticos, artesanato, outros
  final String? condition; // novo, usado_otimo, usado_bom, usado_regular
  final String? unitType; // unidade, kg, etc
  final List<String> images;
  final bool active;
  final String? sellerId;
  final String? sellerEmail;
  final String? sellerName;
  final String? zoneId;
  final String? zoneName;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.title,
    this.description,
    this.price = 0,
    this.quantityAvailable = 0,
    this.category,
    this.condition,
    this.unitType,
    this.images = const [],
    this.active = true,
    this.sellerId,
    this.sellerEmail,
    this.sellerName,
    this.zoneId,
    this.zoneName,
    this.lat,
    this.lng,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria instância a partir de JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesList = <String>[];
    if (json['images'] != null) {
      for (final image in json['images']) {
        if (image is String) {
          imagesList.add(image);
        }
      }
    }

    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      price: _parseDouble(json['price']) ?? 0,
      quantityAvailable: _parseInt(json['quantityAvailable'] ?? json['quantity_available']) ?? 0,
      category: json['category'],
      condition: json['condition'],
      unitType: json['unitType'] ?? json['unit_type'],
      images: imagesList,
      active: json['active'] ?? true,
      sellerId: json['sellerId'] ?? json['seller_id'],
      sellerEmail: json['sellerEmail'] ?? json['seller_email'],
      sellerName: json['sellerName'] ?? json['seller_name'],
      zoneId: json['zoneId'] ?? json['zone_id'],
      zoneName: json['zoneName'] ?? json['zone_name'],
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
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
      'quantityAvailable': quantityAvailable,
      'category': category,
      'condition': condition,
      'unitType': unitType,
      'images': images,
      'active': active,
      'sellerId': sellerId,
      'sellerEmail': sellerEmail,
      'sellerName': sellerName,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'lat': lat,
      'lng': lng,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com campos alterados
  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    int? quantityAvailable,
    String? category,
    String? condition,
    String? unitType,
    List<String>? images,
    bool? active,
    String? sellerId,
    String? sellerEmail,
    String? sellerName,
    String? zoneId,
    String? zoneName,
    double? lat,
    double? lng,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      unitType: unitType ?? this.unitType,
      images: images ?? this.images,
      active: active ?? this.active,
      sellerId: sellerId ?? this.sellerId,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      sellerName: sellerName ?? this.sellerName,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se está disponível
  bool get isAvailable => active && quantityAvailable > 0;

  /// Verifica se tem localização
  bool get hasLocation => lat != null && lng != null;

  /// Retorna a primeira imagem ou null
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  /// Nome traduzido da condição
  String get conditionName {
    switch (condition?.toLowerCase()) {
      case 'novo':
        return 'Novo';
      case 'usado_otimo':
        return 'Usado - Ótimo';
      case 'usado_bom':
        return 'Usado - Bom';
      case 'usado_regular':
        return 'Usado - Regular';
      default:
        return condition ?? 'Não informado';
    }
  }

  /// Nome traduzido da categoria
  String get categoryName {
    switch (category?.toLowerCase()) {
      case 'eletronicos':
        return 'Eletrônicos';
      case 'moveis':
        return 'Móveis';
      case 'vestuario':
        return 'Vestuário';
      case 'alimentos':
        return 'Alimentos';
      case 'servicos_domesticos':
        return 'Serviços Domésticos';
      case 'artesanato':
        return 'Artesanato';
      case 'outros':
        return 'Outros';
      default:
        return category ?? 'Não categorizado';
    }
  }

  @override
  String toString() => 'ProductModel(id: $id, title: $title, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && runtimeType == other.runtimeType && id == other.id;

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

