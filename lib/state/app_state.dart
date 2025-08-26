import 'package:flutter/foundation.dart';
import '../services/health_service.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import 'dart:io' show Platform;

/// App state management following Observer pattern
class AppState extends ChangeNotifier {
  final HealthDataService _healthService = HealthService();

  // User selection state
  UserModel? _selectedUser;
  List<UserModel> _availableUsers = [];
  bool _healthServicesEnabled = AppConfig.defaultHealthServicesEnabled;

  // Health-related state
  int _stepCount = 0;
  bool _isLoading = true;
  String _debugInfo = 'Initializing...';
  bool _healthServiceAvailable = false;
  bool _permissionsGranted = false;

  // Sync-related state
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();
  bool _isSyncing = false;
  int _syncedDays = 0;

  // Getters (Open/Closed Principle - open for extension via getters)
  UserModel? get selectedUser => _selectedUser;
  List<UserModel> get availableUsers => _availableUsers;
  bool get healthServicesEnabled => _healthServicesEnabled;
  int get stepCount => _stepCount;
  bool get isLoading => _isLoading;
  String get debugInfo => _debugInfo;
  bool get healthServiceAvailable => _healthServiceAvailable;
  bool get permissionsGranted => _permissionsGranted;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isSyncing => _isSyncing;
  int get syncedDays => _syncedDays;
  String get platformName => _healthService.platformName;
  bool _showDebugInfo = false;

  // Additional state getters
  bool get showDebugInfo => _showDebugInfo;
  String get connectionMethod => _healthService.connectionMethod;

  /// Set start date for sync range
  void setStartDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  /// Set end date for sync range
  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  /// Select a user for data display
  void selectUser(UserModel user) {
    _selectedUser = user;
    _debugInfo = 'Selected user: ${user.friendlyName}';
    notifyListeners();

    // Load data for the selected user
    _loadDataForUser(user);
  }

  /// Toggle health services on/off
  void toggleHealthServices(bool enabled) {
    _healthServicesEnabled = enabled;
    notifyListeners();

    if (enabled) {
      initializeApp();
    } else {
      _healthServiceAvailable = false;
      _permissionsGranted = false;
      _debugInfo = 'Health services disabled';
    }
  }

  /// Load step data for the selected user from database
  Future<void> _loadDataForUser(UserModel user) async {
    try {
      print('🔄 AppState: Loading step data for ${user.friendlyName}...');
      _isLoading = true;
      _debugInfo = 'Loading step data for ${user.friendlyName}...';
      notifyListeners();

      // Try to get data from database first
      _stepCount = await SupabaseService.fetchUserStepCount(user.id);
      print(
        '📊 AppState: Loaded step count for ${user.friendlyName}: $_stepCount steps',
      );

      _isLoading = false;
      _debugInfo = 'Loaded data for ${user.friendlyName}: $_stepCount steps';
      notifyListeners();
    } catch (e) {
      print('❌ AppState: Error loading data for user: $e');
      _isLoading = false;
      _debugInfo = 'Error loading data: $e';
      notifyListeners();
    }
  }

  /// Initialize available users from database
  Future<void> _initializeUsers() async {
    try {
      print('🔄 AppState: Loading users from database...');
      _debugInfo = 'Loading users from database...';
      notifyListeners();

      _availableUsers = await SupabaseService.fetchUsers();
      print(
        '📊 AppState: Fetched ${_availableUsers.length} users from database',
      );

      if (_availableUsers.isNotEmpty) {
        // Select first user by default
        _selectedUser = _availableUsers.first;
        _debugInfo = 'Loaded ${_availableUsers.length} users from database';
        print(
          '✅ AppState: Selected default user: ${_selectedUser!.friendlyName}',
        );
        // Load data for the selected user
        await _loadDataForUser(_selectedUser!);
      } else {
        print('⚠️ AppState: No users found in database');
        _selectedUser = null;
        _stepCount = 0;
        _debugInfo = 'No users found in database';
      }

      notifyListeners();
    } catch (e) {
      print('❌ AppState: Error initializing users: $e');
      _selectedUser = null;
      _stepCount = 0;

      // Check if this is a network connectivity issue
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        _debugInfo = 'Unable to connect to database (Network issue)';

        // For debugging: Show info about expected users when network is unavailable
        _debugInfo +=
            '\n\nExpected users in database:\n• Sarah (Very Active)\n• Mike (Moderately Active)\n• Emma (Sedentary)\n\nTap refresh when network is available.';
      } else {
        _debugInfo = 'Unable to connect to database';
      }

      _availableUsers = [];
      notifyListeners();
    }
  }

  /// Calculate days to sync
  int get daysToSync {
    return _endDate.difference(_startDate).inDays + 1;
  }

  /// Initialize the app by checking health service and requesting permissions
  Future<void> initializeApp() async {
    try {
      print('🔄 AppState: Starting initializeApp...');
      _isLoading = true;
      _debugInfo = 'Initializing app...';
      notifyListeners();

      // Initialize users first
      print('🔄 AppState: About to call _initializeUsers...');
      await _initializeUsers();
      print('✅ AppState: _initializeUsers completed');

      // Only initialize health services if enabled
      if (_healthServicesEnabled) {
        print('🔄 AppState: Health services enabled, initializing...');
        _debugInfo = 'Initializing ${_healthService.platformName}...';
        notifyListeners();

        // First initialize the health service
        _healthServiceAvailable = await _healthService.initialize();

        if (_healthServiceAvailable) {
          _debugInfo =
              '✅ ${_healthService.platformName} available. Method: ${_healthService.connectionMethod}';
          notifyListeners();

          // Check existing permissions
          bool hasPerms = await _healthService.hasPermissions();
          if (hasPerms) {
            _permissionsGranted = true;
            _debugInfo = '✅ Permissions already granted. Fetching step data...';
            notifyListeners();
            await fetchStepData();
          } else {
            _debugInfo = '⚠️ Permissions needed. Please grant permissions.';
            _isLoading = false;
            notifyListeners();
          }
        } else {
          _debugInfo =
              '❌ ${_healthService.platformName} not available. Method attempted: ${_healthService.connectionMethod}';
          _isLoading = false;
          notifyListeners();
        }
      } else {
        // Health services disabled - load data for selected user
        if (_selectedUser != null) {
          await _loadDataForUser(_selectedUser!);
          _debugInfo =
              'Showing data for ${_selectedUser!.friendlyName} (Health services disabled)';
        } else {
          _debugInfo = 'No user selected';
          _isLoading = false;
        }
        notifyListeners();
      }
    } catch (e) {
      _debugInfo = 'Error initializing app: $e';
      _healthServiceAvailable = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request health permissions
  Future<void> requestPermissions() async {
    try {
      _isLoading = true;
      _debugInfo = 'Requesting ${_healthService.platformName} permissions...';
      notifyListeners();

      final permissions = await _healthService.requestPermissions();
      _permissionsGranted = permissions;

      if (permissions) {
        _debugInfo =
            '✅ Permissions granted successfully!\nMethod used: ${_healthService.connectionMethod}\nFetching step data...';
        notifyListeners();
        await fetchStepData();
      } else {
        _debugInfo =
            '❌ Permission request failed.\nMethod attempted: ${_healthService.connectionMethod}\nPlease try manual steps below.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _debugInfo =
          'Error requesting permissions: $e\nMethod attempted: ${_healthService.connectionMethod}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch current step data
  Future<void> fetchStepData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final steps = await _healthService.getStepsToday();
      _stepCount = steps;
      _debugInfo = 'Successfully fetched $steps steps for today';
    } catch (e) {
      _debugInfo = 'Error fetching step data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open health settings
  Future<void> openHealthSettings() async {
    try {
      await _healthService.openHealthSettings();
      _debugInfo = 'Opened health settings';
    } catch (e) {
      _debugInfo = 'Error opening health settings: $e';
    }
    notifyListeners();
  }

  /// Sync data to Supabase
  Future<void> syncToSupabase() async {
    try {
      _isSyncing = true;
      notifyListeners();

      // TODO: Refactor sync functionality for activity_data schema
      // This requires user IDs and updated schema mapping
      print(
        '⚠️ Sync to Supabase temporarily disabled - needs activity_data schema update',
      );

      _syncedDays = 0;
      _debugInfo =
          'Sync temporarily disabled - activity_data schema update needed';
    } catch (e) {
      _debugInfo = 'Error syncing to Supabase: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Toggle debug info visibility
  void toggleDebugInfo() {
    _showDebugInfo = !_showDebugInfo;
    notifyListeners();
  }

  /// Initialize the app state
  Future<void> initialize() async {
    _updateDebugInfo('Initializing ${_healthService.platformName}...');

    try {
      _healthServiceAvailable = await _healthService.initialize();
      _updateDebugInfo(
        '${_healthService.platformName} initialized successfully',
      );

      await checkAndRequestPermissions();
    } catch (e) {
      _updateDebugInfo('Error initializing ${_healthService.platformName}: $e');
      _setLoading(false);
    }
  }

  /// Check and request health permissions
  Future<void> checkAndRequestPermissions() async {
    try {
      _updateDebugInfo(
        'Checking ${_healthService.platformName} permissions...',
      );

      bool hasPermissions = await _healthService.hasPermissions();
      _updateDebugInfo(
        '${_healthService.platformName} permissions already granted: $hasPermissions',
      );

      if (!hasPermissions) {
        hasPermissions = await _healthService.requestPermissions();
      }

      _permissionsGranted = hasPermissions;

      if (_permissionsGranted) {
        _updateDebugInfo('✅ SUCCESS: Permissions granted!');
        await fetchTodaySteps();
      } else {
        _updateDebugInfo(
          'All permission methods failed. Manual setup required.',
        );
        _setLoading(false);
      }
    } catch (e) {
      _updateDebugInfo(
        'Error checking ${_healthService.platformName} permissions: $e',
      );
      _setLoading(false);
    }
  }

  /// Fetch today's step count
  Future<void> fetchTodaySteps() async {
    try {
      _updateDebugInfo(
        'Fetching step data from ${_healthService.platformName}...',
      );

      int steps = await _healthService.getTodaySteps();

      _stepCount = steps;
      _updateDebugInfo('Total steps today: $steps');
      _setLoading(false);
    } catch (e) {
      _stepCount = 0;
      _updateDebugInfo(
        'Error fetching step data from ${_healthService.platformName}: $e',
      );
      _setLoading(false);
    }
  }

  /// Retry permissions
  Future<void> retryPermissions() async {
    _setLoading(true);
    _updateDebugInfo('Retrying...');
    await checkAndRequestPermissions();
  }

  /// Check health service status
  Future<void> checkHealthServiceStatus() async {
    try {
      _isLoading = true;
      _debugInfo = 'Checking ${_healthService.platformName} status...';
      notifyListeners();

      // Initialize health service first
      _healthServiceAvailable = await _healthService.initialize();

      if (_healthServiceAvailable) {
        _debugInfo =
            '✅ ${_healthService.platformName} status: Available\nConnection method: ${_healthService.connectionMethod}';

        // Check permissions
        bool hasPermissions = await _healthService.hasPermissions();
        _debugInfo += '\nPermissions granted: $hasPermissions';

        // Try to get today's steps to verify functionality
        int testSteps = await _healthService.getTodaySteps();
        _debugInfo += '\nToday\'s steps: $testSteps';

        if (hasPermissions || testSteps > 0) {
          _permissionsGranted = true;
          await fetchStepData();
        } else {
          _isLoading = false;
        }
      } else {
        _debugInfo =
            '❌ ${_healthService.platformName} status: Not available\nAttempted method: ${_healthService.connectionMethod}';
        _isLoading = false;
      }

      notifyListeners();
    } catch (e) {
      _debugInfo =
          'Error checking ${_healthService.platformName} status: $e\nConnection method: ${_healthService.connectionMethod}';
      _healthServiceAvailable = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Open health service settings (attempt)
  Future<void> openHealthServiceSettings() async {
    _updateDebugInfo(
      'Trying to open ${_healthService.platformName} settings...',
    );

    try {
      bool result = await _healthService.requestPermissions();
      _updateDebugInfo(
        result
            ? 'Permission request sent successfully'
            : 'Could not open permissions automatically. Please follow manual steps.',
      );
    } catch (e) {
      _updateDebugInfo(
        'Could not open permissions automatically. Please follow manual steps.',
      );
    }
  }

  /// Sync step data to Supabase
  Future<void> syncStepDataToSupabase() async {
    if (!_permissionsGranted) {
      _updateDebugInfo('Cannot sync: Health permissions not granted');
      return;
    }

    _setSyncing(true);
    _syncedDays = 0;
    _updateDebugInfo('Starting sync to Supabase...');

    try {
      // Test Supabase connection first
      bool connectionOk = await SupabaseService.testConnection();
      if (!connectionOk) {
        _updateDebugInfo('Supabase connection failed. Check configuration.');
        _setSyncing(false);
        return;
      }

      // Get step data for date range
      List<HealthStepData> healthData = await _healthService
          .getStepsForDateRange(_startDate, _endDate);

      // Convert to Supabase format
      List<StepDataEntry> entries = healthData
          .map(
            (data) => StepDataEntry(
              date: data.date,
              stepCount: data.stepCount,
              platform: Platform.isIOS
                  ? 'iOS HealthKit'
                  : 'Android Health Connect',
            ),
          )
          .toList();

      _updateDebugInfo(
        'Uploading ${entries.length} days of data to Supabase...',
      );

      // TODO: Update to use activity_data schema with user IDs
      // int successCount = await SupabaseService.insertMultipleActivityData(userId, entries);
      print(
        '⚠️ Sync to Supabase temporarily disabled - needs activity_data schema update',
      );
      int successCount = 0;

      _syncedDays = successCount;
      _updateDebugInfo(
        'Sync temporarily disabled - activity_data schema update needed',
      );
      _setSyncing(false);
    } catch (e) {
      _updateDebugInfo('Sync failed: $e');
      _setSyncing(false);
    }
  }

  /// Update start date
  void updateStartDate(DateTime date) {
    _startDate = date;
    if (_startDate.isAfter(_endDate)) {
      _endDate = _startDate;
    }
    notifyListeners();
  }

  /// Update end date
  void updateEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  // Private helper methods
  void _updateDebugInfo(String info) {
    _debugInfo = info;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSyncing(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }
}
