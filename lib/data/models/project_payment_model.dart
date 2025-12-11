/// Modelo de pagamento/doação de projeto
class ProjectPaymentModel {
  final String id;
  final String projectId;
  final String? userId;
  final String? userEmail;
  final String? userName;
  final double amount;
  final double? commissionAmount;
  final String paymentMethod; // pix, cartao, etc
  final String status; // pending, confirmed, failed, refunded
  final bool isSubscription;
  final bool anonymous;
  final String? transactionId;
  final String? pixCode;
  final String? pixQrCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectPaymentModel({
    required this.id,
    required this.projectId,
    this.userId,
    this.userEmail,
    this.userName,
    required this.amount,
    this.commissionAmount,
    this.paymentMethod = 'pix',
    this.status = 'pending',
    this.isSubscription = false,
    this.anonymous = false,
    this.transactionId,
    this.pixCode,
    this.pixQrCode,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria instância a partir de JSON
  factory ProjectPaymentModel.fromJson(Map<String, dynamic> json) {
    return ProjectPaymentModel(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? json['project_id'] ?? '',
      userId: json['userId'] ?? json['user_id'],
      userEmail: json['userEmail'] ?? json['user_email'],
      userName: json['userName'] ?? json['user_name'],
      amount: _parseDouble(json['amount']) ?? 0,
      commissionAmount: _parseDouble(json['commissionAmount'] ?? json['commission_amount']),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'pix',
      status: json['status'] ?? 'pending',
      isSubscription: json['isSubscription'] ?? json['is_subscription'] ?? false,
      anonymous: json['anonymous'] ?? false,
      transactionId: json['transactionId'] ?? json['transaction_id'],
      pixCode: json['pixCode'] ?? json['pix_code'],
      pixQrCode: json['pixQrCode'] ?? json['pix_qr_code'],
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'amount': amount,
      'commissionAmount': commissionAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'isSubscription': isSubscription,
      'anonymous': anonymous,
      'transactionId': transactionId,
      'pixCode': pixCode,
      'pixQrCode': pixQrCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria cópia com campos alterados
  ProjectPaymentModel copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? userEmail,
    String? userName,
    double? amount,
    double? commissionAmount,
    String? paymentMethod,
    String? status,
    bool? isSubscription,
    bool? anonymous,
    String? transactionId,
    String? pixCode,
    String? pixQrCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectPaymentModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      amount: amount ?? this.amount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      isSubscription: isSubscription ?? this.isSubscription,
      anonymous: anonymous ?? this.anonymous,
      transactionId: transactionId ?? this.transactionId,
      pixCode: pixCode ?? this.pixCode,
      pixQrCode: pixQrCode ?? this.pixQrCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica se está pendente
  bool get isPending => status == 'pending';

  /// Verifica se foi confirmado
  bool get isConfirmed => status == 'confirmed';

  /// Verifica se falhou
  bool get isFailed => status == 'failed';

  /// Verifica se foi reembolsado
  bool get isRefunded => status == 'refunded';

  /// Verifica se tem código PIX
  bool get hasPixCode => pixCode != null && pixCode!.isNotEmpty;

  /// Nome traduzido do status
  String get statusName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmado';
      case 'failed':
        return 'Falhou';
      case 'refunded':
        return 'Reembolsado';
      default:
        return status;
    }
  }

  /// Nome do doador para exibição
  String get displayName {
    if (anonymous) return 'Anônimo';
    return userName ?? userEmail ?? 'Doador';
  }

  @override
  String toString() => 'ProjectPaymentModel(id: $id, amount: $amount, status: $status)';
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

