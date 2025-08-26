import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/app_widgets.dart';
import '../widgets/mcp_test_widget.dart';

/// Main screen that orchestrates the UI components
/// Follows Open/Closed Principle - open for extension, closed for modification
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    print('🔄 MainScreen: Creating AppState...');
    _appState = AppState();
    _appState.addListener(_onStateChanged);
    print('🔄 MainScreen: Calling initializeApp()...');
    _appState.initializeApp();
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _appState.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Simple Step Counter',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            tooltip: 'Refresh Users',
            onPressed: () {
              _appState.initializeApp();
            },
          ),
          // Health services toggle
          IconButton(
            icon: Icon(
              _appState.healthServicesEnabled
                  ? Icons.health_and_safety
                  : Icons.health_and_safety_outlined,
              color: _appState.healthServicesEnabled
                  ? Colors.green
                  : Colors.grey,
            ),
            tooltip: _appState.healthServicesEnabled
                ? 'Disable Health Services'
                : 'Enable Health Services',
            onPressed: () {
              _appState.toggleHealthServices(!_appState.healthServicesEnabled);
            },
          ),
          IconButton(
            icon: const Icon(Icons.api, color: Colors.blue),
            tooltip: 'MCP Test Widget',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('MCP Test Widget'),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    body: const MCPTestWidget(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main step count display
            StepCountDisplay(
              stepCount: _appState.stepCount,
              isLoading: _appState.isLoading,
            ),

            const SizedBox(height: 30),

            // Action buttons based on app state
            if (!_appState.permissionsGranted)
              PermissionActionButtons(
                onRetryPermissions: () => _appState.requestPermissions(),
                onCheckStatus: () => _appState.checkHealthServiceStatus(),
                onOpenSettings: () => _appState.openHealthSettings(),
              )
            else
              DataActionButtons(
                stepCount: _appState.stepCount,
                onRefreshSteps: () => _appState.fetchStepData(),
              ),

            const SizedBox(height: 30),

            // Sync panel for Supabase integration
            if (_appState.permissionsGranted)
              SyncPanel(
                startDate: _appState.startDate,
                endDate: _appState.endDate,
                daysToSync: _appState.daysToSync,
                syncedDays: _appState.syncedDays,
                isSyncing: _appState.isSyncing,
                onSelectStartDate: () => _selectStartDate(context, _appState),
                onSelectEndDate: () => _selectEndDate(context, _appState),
                onSync: () => _appState.syncToSupabase(),
              ),

            const SizedBox(height: 20),

            // Debug information panel
            if (_appState.showDebugInfo)
              DebugInfoPanel(
                debugInfo: _appState.debugInfo,
                healthServiceAvailable: _appState.healthServiceAvailable,
                permissionsGranted: _appState.permissionsGranted,
                connectionMethod: _appState.connectionMethod,
              ),
            const SizedBox(height: 10),

            // Toggle debug info button
            ElevatedButton(
              onPressed: () => _appState.toggleDebugInfo(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
              ),
              child: Text(
                _appState.showDebugInfo ? 'Hide Debug Info' : 'Show Debug Info',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Date picker for start date selection
  Future<void> _selectStartDate(BuildContext context, AppState appState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: appState.startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: appState.endDate,
    );
    if (picked != null && picked != appState.startDate) {
      appState.setStartDate(picked);
    }
  }

  /// Date picker for end date selection
  Future<void> _selectEndDate(BuildContext context, AppState appState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: appState.endDate,
      firstDate: appState.startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != appState.endDate) {
      appState.setEndDate(picked);
    }
  }
}
