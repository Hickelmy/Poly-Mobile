import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/project_model.dart';
import '../../data/models/project_vote_model.dart';
import '../../data/models/project_payment_model.dart';
import '../../data/repositories/project_repository.dart';

/// Provider de projetos
class ProjectsProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  late final ProjectRepository _projectRepository;

  List<ProjectModel> _projects = [];
  List<ProjectModel> _votingProjects = [];
  List<ProjectModel> _fundingProjects = [];
  ProjectModel? _selectedProject;
  List<ProjectPaymentModel> _userDonations = [];
  ProjectVoteModel? _userVote;
  bool _isLoading = false;
  final bool _isLoadingMore = false;
  String? _error;

  // Filtros
  String? _statusFilter;
  String? _categoryFilter;
  String? _zoneFilter;
  String _sortBy = 'recent';

  ProjectsProvider({required ApiClient apiClient}) : _apiClient = apiClient {
    _projectRepository = ProjectRepository(apiClient: _apiClient);
  }

  // Getters
  List<ProjectModel> get projects => _projects;
  List<ProjectModel> get votingProjects => _votingProjects;
  List<ProjectModel> get fundingProjects => _fundingProjects;
  ProjectModel? get selectedProject => _selectedProject;
  List<ProjectPaymentModel> get userDonations => _userDonations;
  ProjectVoteModel? get userVote => _userVote;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;

  String? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;
  String? get zoneFilter => _zoneFilter;
  String get sortBy => _sortBy;

  /// Total arrecadado pelo usuário
  double get totalDonated {
    return _userDonations
        .where((d) => d.isConfirmed)
        .fold(0.0, (sum, d) => sum + d.amount);
  }

  /// Carrega lista de projetos
  Future<void> loadProjects({
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    if (refresh) _projects = [];
    notifyListeners();

    try {
      _projects = await _projectRepository.getProjects(
        status: _statusFilter,
        category: _categoryFilter,
        zoneId: _zoneFilter,
        sort: _sortBy,
      );
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Erro ao carregar projetos';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega projetos em votação
  Future<void> loadVotingProjects({String? zoneId}) async {
    try {
      _votingProjects = await _projectRepository.getProjects(
        status: 'voting',
        zoneId: zoneId ?? _zoneFilter,
        limit: 10,
      );
      notifyListeners();
    } catch (_) {}
  }

  /// Carrega projetos arrecadando
  Future<void> loadFundingProjects({String? zoneId}) async {
    try {
      _fundingProjects = await _projectRepository.getProjects(
        status: 'funding',
        zoneId: zoneId ?? _zoneFilter,
        limit: 10,
      );
      notifyListeners();
    } catch (_) {}
  }

  /// Carrega detalhes de um projeto
  Future<ProjectModel?> loadProjectDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProject = await _projectRepository.getProjectById(id);
      _isLoading = false;
      notifyListeners();
      return _selectedProject;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cria novo projeto
  Future<ProjectModel?> createProject({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final project = await _projectRepository.createProject(
        title: title,
        shortDescription: shortDescription,
        description: description,
        category: category,
        imageUrl: imageUrl,
        targetAmount: targetAmount,
        minVotes: minVotes,
        fundingDeadline: fundingDeadline,
        locationAddress: locationAddress,
        latitude: latitude,
        longitude: longitude,
        zoneId: zoneId,
        expenses: expenses,
      );

      _projects.insert(0, project);
      _isLoading = false;
      notifyListeners();
      return project;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Atualiza projeto
  Future<bool> updateProject(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _projectRepository.updateProject(id, data);

      // Atualiza na lista
      final index = _projects.indexWhere((p) => p.id == id);
      if (index != -1) {
        _projects[index] = updated;
      }

      // Atualiza selecionado se for o mesmo
      if (_selectedProject?.id == id) {
        _selectedProject = updated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove projeto
  Future<bool> deleteProject(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _projectRepository.deleteProject(id);
      _projects.removeWhere((p) => p.id == id);

      if (_selectedProject?.id == id) {
        _selectedProject = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Vota em um projeto
  Future<bool> vote({
    required String projectId,
    required String userId,
    required String userEmail,
    required String type,
  }) async {
    try {
      _userVote = await _projectRepository.vote(
        projectId: projectId,
        userId: userId,
        userEmail: userEmail,
        type: type,
      );

      // Atualiza contagem de votos localmente
      if (_selectedProject?.id == projectId) {
        _selectedProject = _selectedProject!.copyWith(
          votesCount: _selectedProject!.votesCount + 1,
        );
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Remove voto
  Future<bool> removeVote({
    required String projectId,
    required String userEmail,
  }) async {
    try {
      await _projectRepository.removeVote(
        projectId: projectId,
        userEmail: userEmail,
      );

      _userVote = null;

      // Atualiza contagem de votos localmente
      if (_selectedProject?.id == projectId &&
          _selectedProject!.votesCount > 0) {
        _selectedProject = _selectedProject!.copyWith(
          votesCount: _selectedProject!.votesCount - 1,
        );
      }

      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Carrega voto do usuário em um projeto
  Future<void> loadUserVote({
    required String projectId,
    required String userEmail,
  }) async {
    _userVote = await _projectRepository.getUserVote(
      projectId: projectId,
      userEmail: userEmail,
    );
    notifyListeners();
  }

  /// Cria doação
  Future<ProjectPaymentModel?> createDonation({
    required String projectId,
    required double amount,
    String? userId,
    String? userEmail,
    bool anonymous = false,
    bool isSubscription = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payment = await _projectRepository.createPayment(
        projectId: projectId,
        amount: amount,
        userId: userId,
        userEmail: userEmail,
        anonymous: anonymous,
        isSubscription: isSubscription,
      );

      _userDonations.insert(0, payment);
      _isLoading = false;
      notifyListeners();
      return payment;
    } on AppException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Carrega doações do usuário
  Future<void> loadUserDonations(String userEmail) async {
    try {
      _userDonations = await _projectRepository.getUserDonations(userEmail);
      notifyListeners();
    } catch (_) {}
  }

  /// Gera PIX para pagamento
  Future<Map<String, dynamic>?> generatePix({
    required String paymentId,
    required double amount,
  }) async {
    try {
      return await _projectRepository.generatePix(
        paymentId: paymentId,
        amount: amount,
      );
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  /// Verifica status do pagamento
  Future<String> checkPaymentStatus(String paymentId) async {
    return await _projectRepository.checkPaymentStatus(paymentId);
  }

  /// Define filtro de status
  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadProjects(refresh: true);
  }

  /// Define filtro de categoria
  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    loadProjects(refresh: true);
  }

  /// Define filtro de zona
  void setZoneFilter(String? zoneId) {
    if (_zoneFilter == zoneId) return;
    _zoneFilter = zoneId;
    // Não recarrega automaticamente - deixa a tela fazer isso
  }

  /// Define ordenação
  void setSortBy(String sort) {
    _sortBy = sort;
    loadProjects(refresh: true);
  }

  /// Limpa filtros
  void clearFilters() {
    _statusFilter = null;
    _categoryFilter = null;
    _zoneFilter = null;
    _sortBy = 'recent';
    loadProjects(refresh: true);
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Limpa projeto selecionado
  void clearSelectedProject() {
    _selectedProject = null;
    _userVote = null;
    notifyListeners();
  }
}
