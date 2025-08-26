import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Widget for displaying step count (Single Responsibility)
class StepCountDisplay extends StatelessWidget {
  final int stepCount;
  final bool isLoading;

  const StepCountDisplay({
    super.key,
    required this.stepCount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator(color: Colors.black)
        : Text(
            '$stepCount',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
  }
}

/// Widget for displaying debug information (Single Responsibility)
class DebugInfoPanel extends StatelessWidget {
  final String debugInfo;
  final bool healthServiceAvailable;
  final bool permissionsGranted;
  final String? connectionMethod; // New: Show connection method

  const DebugInfoPanel({
    super.key,
    required this.debugInfo,
    required this.healthServiceAvailable,
    required this.permissionsGranted,
    this.connectionMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final platformName = isIOS ? 'iOS HealthKit' : 'Android Health Connect';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Information ($platformName):',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            debugInfo,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            '$platformName Available: $healthServiceAvailable',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          Text(
            'Permissions Granted: $permissionsGranted',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          Text(
            'Platform: ${(!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ? 'iOS' : 'Android'}',
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          if (connectionMethod != null)
            Text(
              'Connection Method: $connectionMethod',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget for date range selection and sync (Single Responsibility)
class SyncPanel extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int daysToSync;
  final int syncedDays;
  final bool isSyncing;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final VoidCallback onSync;

  const SyncPanel({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.daysToSync,
    required this.syncedDays,
    required this.isSyncing,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supabase Data Sync (Last 90 Days):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateSelector(
                  label: 'Start Date:',
                  date: startDate,
                  onTap: isSyncing ? null : onSelectStartDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateSelector(
                  label: 'End Date:',
                  date: endDate,
                  onTap: isSyncing ? null : onSelectEndDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Days to sync: $daysToSync',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          if (syncedDays > 0)
            Text(
              'Last sync: $syncedDays days successfully uploaded',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSyncing ? null : onSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSyncing ? Colors.grey : Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: Text(isSyncing ? 'Syncing...' : 'Sync to Supabase'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Private widget for date selection
class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback? onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget for action buttons when permissions are not granted
class PermissionActionButtons extends StatelessWidget {
  final VoidCallback onRetryPermissions;
  final VoidCallback onCheckStatus;
  final VoidCallback onOpenSettings;

  const PermissionActionButtons({
    super.key,
    required this.onRetryPermissions,
    required this.onCheckStatus,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final platformName = isIOS ? 'HealthKit' : 'Health Connect';

    return Column(
      children: [
        ElevatedButton(
          onPressed: onRetryPermissions,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text('Retry Permissions'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onCheckStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Check $platformName Status'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onOpenSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text('Open $platformName Settings'),
        ),
        const SizedBox(height: 10),
        Text(
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
              ? 'Manual Steps for iOS:\n1. Open Health app\n2. Go to "Sharing" tab\n3. Find "Simple Step Flutter"\n4. Grant "Steps" permission\n5. Return and retry'
              : 'Manual Steps for Android:\n1. Open Health Connect app\n2. Go to "App permissions"\n3. Find "Simple Step Flutter"\n4. Grant "Steps" permission\n5. Return and retry',
          style: const TextStyle(fontSize: 10, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget for action buttons when permissions are granted
class DataActionButtons extends StatelessWidget {
  final int stepCount;
  final VoidCallback onRefreshSteps;

  const DataActionButtons({
    super.key,
    required this.stepCount,
    required this.onRefreshSteps,
  });

  @override
  Widget build(BuildContext context) {
    if (stepCount == 0) {
      return ElevatedButton(
        onPressed: onRefreshSteps,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: const Text('Refresh Step Data'),
      );
    }
    return const SizedBox.shrink();
  }
}
