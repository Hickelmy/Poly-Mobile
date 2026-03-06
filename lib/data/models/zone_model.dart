/// Modelo de zona geográfica
class ZoneModel {
  final String id;
  final String name;
  final String? description;
  final String color; // Hex color
  final bool active;
  final bool isPublic; // Se a zona é pública ou precisa de código
  final Map<String, dynamic>? polygonGeojson; // GeoJSON polygon
  final double? centerLat;
  final double? centerLng;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? joinedAt; // Quando o usuário entrou na zona (se privada)

  ZoneModel({
    required this.id,
    required this.name,
    this.description,
    this.color = '#14B8A6',
    this.active = true,
    this.isPublic = true,
    this.polygonGeojson,
    this.centerLat,
    this.centerLng,
    required this.createdAt,
    required this.updatedAt,
    this.joinedAt,
  });

  /// Cria instância a partir de JSON
  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      color: json['color'] ?? '#14B8A6',
      active: json['active'] ?? true,
      isPublic: json['isPublic'] ?? json['is_public'] ?? true,
      polygonGeojson: json['polygonGeojson'] ?? json['polygon_geojson'],
      centerLat: _parseDouble(json['centerLat'] ?? json['center_lat']),
      centerLng: _parseDouble(json['centerLng'] ?? json['center_lng']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
      joinedAt: json['joined_at'] != null ? _parseDateTime(json['joined_at']) : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'active': active,
      'is_public': isPublic,
      'polygonGeojson': polygonGeojson,
      'centerLat': centerLat,
      'centerLng': centerLng,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com campos alterados
  ZoneModel copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    bool? active,
    bool? isPublic,
    Map<String, dynamic>? polygonGeojson,
    double? centerLat,
    double? centerLng,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? joinedAt,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      active: active ?? this.active,
      isPublic: isPublic ?? this.isPublic,
      polygonGeojson: polygonGeojson ?? this.polygonGeojson,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  /// Retorna a cor como Color do Flutter
  int get colorValue {
    String hex = color.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return int.parse(hex, radix: 16);
  }

  /// Verifica se tem coordenadas de centro
  bool get hasCenter => centerLat != null && centerLng != null;

  /// Verifica se tem polígono definido
  bool get hasPolygon => polygonGeojson != null && polygonGeojson!.isNotEmpty;

  @override
  String toString() => 'ZoneModel(id: $id, name: $name, active: $active)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneModel && runtimeType == other.runtimeType && id == other.id;

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

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

