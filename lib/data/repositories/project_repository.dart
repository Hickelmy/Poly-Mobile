import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/project_model.dart';
import '../models/project_vote_model.dart';
import '../models/project_payment_model.dart';

/// Repositório de projetos
class ProjectRepository {
  final ApiClient _apiClient;

  ProjectRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Lista projetos com filtros
  Future<List<ProjectModel>> getProjects({
    String? status,
    String? category,
    String? zoneId,
    String? sort,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (sort != null) queryParams['sort'] = sort;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiClient.get(
        ApiEndpoints.projects,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
      
      if (data is Map && data.containsKey('data')) {
        final list = data['data'] as List;
        return list.map((json) => ProjectModel.fromJson(json)).toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar projetos',
        details: e.toString(),
      );
    }
  }

  /// Obtém projeto por ID
  Future<ProjectModel> getProjectById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.projectById(id));
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao obter projeto',
        details: e.toString(),
      );
    }
  }

  /// Cria novo projeto
  Future<ProjectModel> createProject({
    required String title,
    String? shortDescription,
    String? description,
    String? category,
    String? imageUrl,
    double? targetAmount,
    int? minVotes,
    DateTime? fundingDeadline,
    String? locationAddress,
    double? latitude,
    double? longitude,
    String? zoneId,
    List<Map<String, dynamic>>? expenses,
  }) async {
    try {
      final data = <String, dynamic>{
        'title': title,
      };
      
      if (shortDescription != null) data['shortDescription'] = shortDescription;
      if (description != null) data['description'] = description;
      if (category != null) data['category'] = category;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      if (targetAmount != null) data['targetAmount'] = targetAmount;
      if (minVotes != null) data['minVotes'] = minVotes;
      if (fundingDeadline != null) data['fundingDeadline'] = fundingDeadline.toIso8601String();
      if (locationAddress != null) data['locationAddress'] = locationAddress;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (zoneId != null) data['zoneId'] = zoneId;
      if (expenses != null) data['expenses'] = expenses;

      final response = await _apiClient.post(
        ApiEndpoints.projects,
        data: data,
      );
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar projeto',
        details: e.toString(),
      );
    }
  }

  /// Atualiza projeto
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.projectById(id),
        data: data,
      );
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao atualizar projeto',
        details: e.toString(),
      );
    }
  }

  /// Remove projeto
  Future<void> deleteProject(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.projectById(id));
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao remover projeto',
        details: e.toString(),
      );
    }
  }

  // ============ VOTOS ============

  /// Vota em um projeto
  Future<ProjectVoteModel> vote({
    required String projectId,
    required String userId,
    required String userEmail,
    required String type, // 'up' ou 'down'
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.projectVotes,
        data: {
          'project_id': projectId,
          'user_id': userId,
          'user_email': userEmail,
          'type': type,
        },
      );
      return ProjectVoteModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao votar',
        details: e.toString(),
      );
    }
  }

  /// Remove voto
  Future<void> removeVote({
    required String projectId,
    required String userEmail,
  }) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.projectVotes,
        queryParameters: {
          'project_id': projectId,
          'user_email': userEmail,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao remover voto',
        details: e.toString(),
      );
    }
  }

  /// Obtém voto do usuário em um projeto
  Future<ProjectVoteModel?> getUserVote({
    required String projectId,
    required String userEmail,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.projectVotes,
        queryParameters: {
          'project_id': projectId,
          'user_email': userEmail,
        },
      );

      final data = response.data;
      if (data is List && data.isNotEmpty) {
        return ProjectVoteModel.fromJson(data.first);
      }
      if (data is Map && data.isNotEmpty) {
        return ProjectVoteModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ============ PAGAMENTOS/DOAÇÕES ============

  /// Cria pagamento/doação
  Future<ProjectPaymentModel> createPayment({
    required String projectId,
    required double amount,
    String? userId,
    String? userEmail,
    String paymentMethod = 'pix',
    bool anonymous = false,
    bool isSubscription = false,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.projectPayments,
        data: {
          'projectId': projectId,
          'amount': amount,
          'userId': userId,
          'userEmail': userEmail,
          'paymentMethod': paymentMethod,
          'anonymous': anonymous,
          'isSubscription': isSubscription,
        },
      );
      return ProjectPaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao criar pagamento',
        details: e.toString(),
      );
    }
  }

  /// Lista pagamentos de um projeto
  Future<List<ProjectPaymentModel>> getProjectPayments(String projectId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.projectPayments,
        queryParameters: {'project_id': projectId},
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => ProjectPaymentModel.fromJson(json)).toList();
      }
      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar pagamentos',
        details: e.toString(),
      );
    }
  }

  /// Lista doações do usuário
  Future<List<ProjectPaymentModel>> getUserDonations(String userEmail) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.projectPayments,
        queryParameters: {'user_email': userEmail},
      );

      final data = response.data;
      if (data is List) {
        return data.map((json) => ProjectPaymentModel.fromJson(json)).toList();
      }
      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao listar doações',
        details: e.toString(),
      );
    }
  }

  /// Gera PIX para pagamento
  Future<Map<String, dynamic>> generatePix({
    required String paymentId,
    required double amount,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createPix,
        data: {
          'paymentId': paymentId,
          'amount': amount,
        },
      );
      return response.data as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Erro ao gerar PIX',
        details: e.toString(),
      );
    }
  }

  /// Verifica status do pagamento
  Future<String> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.paymentStatus(paymentId),
      );
      return (response.data as Map<String, dynamic>)['status'] ?? 'pending';
    } catch (_) {
      return 'pending';
    }
  }
}

