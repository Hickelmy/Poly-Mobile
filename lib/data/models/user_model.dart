/// Modelo de usuário
class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // USER, ADMIN, gestor, suporte
  final String? avatarUrl;
  final String? bannerUrl;
  final String? phone;
  final String? cep;
  final String? state;
  final String? city;
  final String? neighborhood;
  final String? street;
  final String? houseNumber;
  final String? pixKeyRandom;
  final String? pixKeyPhone;
  final String? pixKeyEmail;
  final String? pixKeyCpf;
  final double? residenceLat;
  final double? residenceLng;
  final String? residenceZoneId;
  final String? currentZoneId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'USER',
    this.avatarUrl,
    this.bannerUrl,
    this.phone,
    this.cep,
    this.state,
    this.city,
    this.neighborhood,
    this.street,
    this.houseNumber,
    this.pixKeyRandom,
    this.pixKeyPhone,
    this.pixKeyEmail,
    this.pixKeyCpf,
    this.residenceLat,
    this.residenceLng,
    this.residenceZoneId,
    this.currentZoneId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria instância a partir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'USER',
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      bannerUrl: json['bannerUrl'] ?? json['banner_url'],
      phone: json['phone'],
      cep: json['cep'],
      state: json['state'],
      city: json['city'],
      neighborhood: json['neighborhood'],
      street: json['street'],
      houseNumber: json['houseNumber'] ?? json['house_number'],
      pixKeyRandom: json['pixKeyRandom'] ?? json['pix_key_random'],
      pixKeyPhone: json['pixKeyPhone'] ?? json['pix_key_phone'],
      pixKeyEmail: json['pixKeyEmail'] ?? json['pix_key_email'],
      pixKeyCpf: json['pixKeyCpf'] ?? json['pix_key_cpf'],
      residenceLat: _parseDouble(json['residenceLat'] ?? json['residence_lat']),
      residenceLng: _parseDouble(json['residenceLng'] ?? json['residence_lng']),
      residenceZoneId: json['residenceZoneId'] ?? json['residence_zone_id'],
      currentZoneId: json['currentZoneId'] ?? json['current_zone_id'],
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'phone': phone,
      'cep': cep,
      'state': state,
      'city': city,
      'neighborhood': neighborhood,
      'street': street,
      'houseNumber': houseNumber,
      'pixKeyRandom': pixKeyRandom,
      'pixKeyPhone': pixKeyPhone,
      'pixKeyEmail': pixKeyEmail,
      'pixKeyCpf': pixKeyCpf,
      'residenceLat': residenceLat,
      'residenceLng': residenceLng,
      'residenceZoneId': residenceZoneId,
      'currentZoneId': currentZoneId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com campos alterados
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? avatarUrl,
    String? bannerUrl,
    String? phone,
    String? cep,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? houseNumber,
    String? pixKeyRandom,
    String? pixKeyPhone,
    String? pixKeyEmail,
    String? pixKeyCpf,
    double? residenceLat,
    double? residenceLng,
    String? residenceZoneId,
    String? currentZoneId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      phone: phone ?? this.phone,
      cep: cep ?? this.cep,
      state: state ?? this.state,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      pixKeyRandom: pixKeyRandom ?? this.pixKeyRandom,
      pixKeyPhone: pixKeyPhone ?? this.pixKeyPhone,
      pixKeyEmail: pixKeyEmail ?? this.pixKeyEmail,
      pixKeyCpf: pixKeyCpf ?? this.pixKeyCpf,
      residenceLat: residenceLat ?? this.residenceLat,
      residenceLng: residenceLng ?? this.residenceLng,
      residenceZoneId: residenceZoneId ?? this.residenceZoneId,
      currentZoneId: currentZoneId ?? this.currentZoneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se é administrador
  bool get isAdmin => role.toLowerCase() == 'admin' || role.toLowerCase() == 'administrador';

  /// Verifica se é gestor
  bool get isGestor => role.toLowerCase() == 'gestor';

  /// Verifica se é suporte
  bool get isSuporte => role.toLowerCase() == 'suporte';

  /// Verifica se pode criar projetos
  bool get canCreateProjects => isAdmin || isGestor;

  /// Verifica se pode gerenciar usuários
  bool get canManageUsers => isAdmin;

  /// Verifica se pode gerenciar zonas
  bool get canManageZones => isAdmin;

  /// Verifica se tem chave PIX configurada
  bool get hasPixKey =>
      (pixKeyRandom != null && pixKeyRandom!.isNotEmpty) ||
      (pixKeyPhone != null && pixKeyPhone!.isNotEmpty) ||
      (pixKeyEmail != null && pixKeyEmail!.isNotEmpty) ||
      (pixKeyCpf != null && pixKeyCpf!.isNotEmpty);

  /// Retorna o endereço formatado
  String? get formattedAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (houseNumber != null && houseNumber!.isNotEmpty) parts.add(houseNumber!);
    if (neighborhood != null && neighborhood!.isNotEmpty) parts.add(neighborhood!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  /// Retorna o primeiro nome
  String get firstName => name.split(' ').first;

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

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

