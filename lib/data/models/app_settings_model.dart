/// Modelo de configurações do app
class AppSettingsModel {
  final String id;
  final bool maintenanceMode;
  final bool allowRegistrations;
  final bool dailySummaryEmail;
  final String defaultLanguage;
  final double platformFeePercent;
  final String? primaryColor;
  final String? secondaryColor;
  final String? logoUrl;
  final DateTime updatedAt;

  AppSettingsModel({
    this.id = 'default',
    this.maintenanceMode = false,
    this.allowRegistrations = true,
    this.dailySummaryEmail = false,
    this.defaultLanguage = 'pt-BR',
    this.platformFeePercent = 5.0,
    this.primaryColor,
    this.secondaryColor,
    this.logoUrl,
    required this.updatedAt,
  });

  /// Cria instância a partir de JSON
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      id: json['id'] ?? 'default',
      maintenanceMode: json['maintenanceMode'] ?? json['maintenance_mode'] ?? false,
      allowRegistrations: json['allowRegistrations'] ?? json['allow_registrations'] ?? true,
      dailySummaryEmail: json['dailySummaryEmail'] ?? json['daily_summary_email'] ?? false,
      defaultLanguage: json['defaultLanguage'] ?? json['default_language'] ?? 'pt-BR',
      platformFeePercent: _parseDouble(json['platformFeePercent'] ?? json['platform_fee_percent']) ?? 5.0,
      primaryColor: json['primaryColor'] ?? json['primary_color'],
      secondaryColor: json['secondaryColor'] ?? json['secondary_color'],
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maintenanceMode': maintenanceMode,
      'allowRegistrations': allowRegistrations,
      'dailySummaryEmail': dailySummaryEmail,
      'defaultLanguage': defaultLanguage,
      'platformFeePercent': platformFeePercent,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'logoUrl': logoUrl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com campos alterados
  AppSettingsModel copyWith({
    String? id,
    bool? maintenanceMode,
    bool? allowRegistrations,
    bool? dailySummaryEmail,
    String? defaultLanguage,
    double? platformFeePercent,
    String? primaryColor,
    String? secondaryColor,
    String? logoUrl,
    DateTime? updatedAt,
  }) {
    return AppSettingsModel(
      id: id ?? this.id,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      allowRegistrations: allowRegistrations ?? this.allowRegistrations,
      dailySummaryEmail: dailySummaryEmail ?? this.dailySummaryEmail,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      platformFeePercent: platformFeePercent ?? this.platformFeePercent,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Configurações padrão
  factory AppSettingsModel.defaults() {
    return AppSettingsModel(
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'AppSettingsModel(maintenanceMode: $maintenanceMode, allowRegistrations: $allowRegistrations)';
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

