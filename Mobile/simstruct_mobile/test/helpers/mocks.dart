import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:simstruct_mobile/core/models/user.dart';
import 'package:simstruct_mobile/core/models/simulation.dart';
import 'package:simstruct_mobile/core/models/simulation_params.dart';
import 'package:simstruct_mobile/core/models/notification.dart';
import 'package:simstruct_mobile/core/services/api_service.dart';
import 'package:simstruct_mobile/core/services/auth_service.dart';
import 'package:simstruct_mobile/core/services/simulation_service.dart';
import 'package:simstruct_mobile/core/services/user_service.dart';
import 'package:simstruct_mobile/core/services/community_service.dart';
import 'package:simstruct_mobile/core/services/storage_service.dart';
import 'package:simstruct_mobile/core/services/notification_service.dart';

// ========== Mock Services ==========

class MockApiService extends Mock implements ApiService {}

class MockAuthService extends ChangeNotifier implements AuthService {
  AuthState _state = AuthState.unauthenticated;
  User? _user;
  String? _token;
  String? _error;
  bool _isLoading = false;
  NotificationService? _notificationService;

  @override
  AuthState get state => _state;
  
  @override
  User? get user => _user;
  
  @override
  String? get token => _token;
  
  @override
  String? get error => _error;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  void setUser(User? user) {
    _user = user;
    _state = user != null ? AuthState.authenticated : AuthState.unauthenticated;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  Future<void> init() async {}

  @override
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return true;
  }

  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return true;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _token = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  @override
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? jobTitle,
    String? bio,
    String? avatarUrl,
  }) async {
    return true;
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return true;
  }

  @override
  Future<bool> deleteAccount() async {
    return true;
  }

  @override
  void setNotificationService(NotificationService service) {
    _notificationService = service;
  }

  @override
  Future<bool> resetPassword({required String email}) async {
    return true;
  }

  @override
  Future<void> refreshUserData() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSimulationService extends ChangeNotifier implements SimulationService {
  List<Simulation> _simulations = [];
  Simulation? _currentSimulation;
  SimulationParams _currentParams = const SimulationParams();
  int _currentStep = 0;
  bool _isRunning = false;
  bool _isLoading = false;
  double _progress = 0.0;
  String? _error;

  @override
  List<Simulation> get simulations => List.unmodifiable(_simulations);

  @override
  Simulation? get currentSimulation => _currentSimulation;

  @override
  SimulationParams get currentParams => _currentParams;

  @override
  int get currentStep => _currentStep;

  @override
  bool get isRunning => _isRunning;

  @override
  bool get isLoading => _isLoading;

  @override
  double get progress => _progress;

  @override
  String? get error => _error;

  @override
  List<Simulation> get recentSimulations {
    final sorted = List<Simulation>.from(_simulations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  @override
  List<Simulation> get completedSimulations =>
      _simulations.where((s) => s.status == SimulationStatus.completed).toList();

  @override
  List<Simulation> get favoriteSimulations =>
      _simulations.where((s) => s.isFavorite).toList();

  @override
  int get totalSimulations => _simulations.length;

  @override
  int get completedCount => completedSimulations.length;

  @override
  List<Simulation> get favoriteSimulationsFromBackend => [];

  @override
  List<Simulation> get publicSimulations => [];

  void setSimulations(List<Simulation> simulations) {
    _simulations = simulations;
    notifyListeners();
  }

  void setCurrentSimulation(Simulation? simulation) {
    _currentSimulation = simulation;
    notifyListeners();
  }

  void setCurrentParams(SimulationParams params) {
    _currentParams = params;
    notifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setIsRunning(bool running) {
    _isRunning = running;
    notifyListeners();
  }

  void setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  Future<void> initialize(String userId) async {}

  @override
  Future<void> loadSimulations(String userId) async {}

  @override
  Future<void> loadFavoriteSimulations() async {}

  @override
  Future<void> loadPublicSimulations() async {}

  @override
  Simulation createSimulation({
    required String userId,
    String? name,
    SimulationParams? params,
  }) {
    final simulation = Simulation.create(
      userId: userId,
      name: name,
      params: params ?? _currentParams,
    );
    _simulations.insert(0, simulation);
    _currentSimulation = simulation;
    notifyListeners();
    return simulation;
  }

  @override
  Future<Simulation?> createSimulationOnBackend({
    required String name,
    String? description,
    required SimulationParams params,
    bool isPublic = false,
  }) async {
    return MockData.createSimulation(name: name);
  }

  @override
  void updateParams(SimulationParams params) {
    _currentParams = params;
    notifyListeners();
  }

  @override
  void setStep(int step) {
    _currentStep = step.clamp(0, 4);
    notifyListeners();
  }

  @override
  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  @override
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  @override
  void resetWizard() {
    _currentStep = 0;
    _currentParams = const SimulationParams();
    _currentSimulation = null;
    notifyListeners();
  }

  @override
  void selectSimulation(Simulation simulation) {
    _currentSimulation = simulation;
    notifyListeners();
  }

  @override
  void clearCurrentSimulation() {
    _currentSimulation = null;
    notifyListeners();
  }

  @override
  Future<bool> deleteSimulation(String id) async {
    return true;
  }

  @override
  Future<bool> toggleFavorite(String id) async {
    return true;
  }

  @override
  Future<Simulation?> runSimulation(String userId) async {
    return _currentSimulation;
  }

  @override
  Future<Simulation?> runSimulationOnBackend({
    required String userId,
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    return _currentSimulation;
  }

  @override
  Future<void> saveSimulation() async {}

  @override
  Future<Simulation?> getSimulation(String id) async {
    return _simulations.firstWhere((s) => s.id == id);
  }

  @override
  void cancelSimulation() {
    _isRunning = false;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserService extends Mock implements UserService {}

class MockCommunityService extends Mock implements CommunityService {}

class MockStorageService extends Mock implements StorageService {}

class MockNotificationService extends ChangeNotifier implements NotificationService {
  final List<AppNotification> _notifications = [];

  @override
  List<AppNotification> get notifications => _notifications;

  @override
  void showSuccess(String message, {VoidCallback? action, String? actionLabel}) {
    _notifications.add(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.success,
      title: 'Success',
      message: message,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  void showError(String message, {VoidCallback? action, String? actionLabel}) {
    _notifications.add(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.error,
      title: 'Error',
      message: message,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  void showWarning(String message, {VoidCallback? action, String? actionLabel}) {
    _notifications.add(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.warning,
      title: 'Warning',
      message: message,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  void showInfo(String message, {VoidCallback? action, String? actionLabel}) {
    _notifications.add(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.info,
      title: 'Info',
      message: message,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  @override
  void dismissAll() {
    _notifications.clear();
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ========== Mock Data Factories ==========

class MockData {
  static User createUser({
    String id = 'user-1',
    String email = 'test@example.com',
    String name = 'Test User',
    UserRole role = UserRole.user,
    SubscriptionPlan subscriptionPlan = SubscriptionPlan.free,
    bool emailVerified = true,
  }) {
    return User(
      id: id,
      email: email,
      name: name,
      role: role,
      subscriptionPlan: subscriptionPlan,
      emailVerified: emailVerified,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  static Simulation createSimulation({
    String id = 'sim-1',
    String name = 'Test Simulation',
    String? description,
    SimulationStatus status = SimulationStatus.completed,
    bool isFavorite = false,
    String userId = 'user-1',
  }) {
    return Simulation(
      id: id,
      userId: userId,
      name: name,
      description: description ?? 'A test simulation',
      status: status,
      params: const SimulationParams(),
      isFavorite: isFavorite,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  static List<Simulation> createSimulations({
    int count = 5,
    SimulationStatus? status,
  }) {
    return List.generate(count, (index) {
      return createSimulation(
        id: 'sim-${index + 1}',
        name: 'Simulation ${index + 1}',
        status: status ?? SimulationStatus.completed,
      );
    });
  }

  static AppNotification createNotification({
    String id = 'notif-1',
    NotificationType type = NotificationType.success,
    String title = 'Test Notification',
    String message = 'This is a test notification',
    NotificationCategory category = NotificationCategory.system,
    bool isRead = false,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      category: category,
      isRead: isRead,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  static List<AppNotification> createNotifications({int count = 5}) {
    return List.generate(count, (index) {
      return createNotification(
        id: 'notif-${index + 1}',
        title: 'Notification ${index + 1}',
      );
    });
  }
}
