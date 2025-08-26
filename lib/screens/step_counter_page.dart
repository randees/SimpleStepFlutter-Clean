import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/app_widgets.dart';
import '../utils/app_icons.dart';

/// Step Counter page - Main functionality for health data tracking
class StepCounterPage extends StatefulWidget {
  const StepCounterPage({super.key});

  @override
  State<StepCounterPage> createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    print('🔄 StepCounterPage: Creating AppState...');
    _appState = AppState();
    _appState.addListener(_onStateChanged);
    print('🔄 StepCounterPage: Calling initializeApp()...');
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

            const SizedBox(height: 20),

            // Health services controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _appState.healthServicesEnabled
                        ? AppIcons.health()
                        : AppIcons.healthOutlined(),
                    color: _appState.healthServicesEnabled
                        ? Colors.green
                        : Colors.grey,
                    size: 32,
                  ),
                  tooltip: _appState.healthServicesEnabled
                      ? 'Disable Health Services'
                      : 'Enable Health Services',
                  onPressed: () {
                    _appState.toggleHealthServices(
                      !_appState.healthServicesEnabled,
                    );
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(AppIcons.refresh(), color: Colors.blue, size: 32),
                  tooltip: 'Refresh Data',
                  onPressed: () {
                    _appState.initializeApp();
                  },
                ),
              ],
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
