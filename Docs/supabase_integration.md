# Supabase Integration Documentation

## Overview

This document describes the Supabase integration for storing and syncing step data from Health Connect (Android) and HealthKit (iOS) to a PostgreSQL database.

## Features

### ✅ **Implemented Features:**

1. **Date Range Selection**: Choose start and end dates for data sync (up to 90 days)
2. **Duplicate Prevention**: Automatically skips existing data to prevent overwrites
3. **Cross-Platform Support**: Works with both Android Health Connect and iOS HealthKit
4. **Batch Sync**: Syncs multiple days of data efficiently
5. **Real-time Feedback**: Shows sync progress and status
6. **Connection Testing**: Verifies Supabase connection before syncing

### 🏗️ **Database Schema:**

```sql
CREATE TABLE step_data (
  id BIGSERIAL PRIMARY KEY,
  date DATE NOT NULL UNIQUE,
  step_count INTEGER NOT NULL DEFAULT 0,
  platform TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 📊 **Data Model:**

- **date**: The specific date for step data (YYYY-MM-DD format)
- **step_count**: Total steps for that date
- **platform**: Either "Android Health Connect" or "iOS HealthKit"
- **created_at**: When the record was first inserted
- **updated_at**: When the record was last modified

## Configuration

### **Required Files:**

1. **Template**: `lib/config/supabase_config_template.dart` (committed to git)
2. **Actual Config**: `lib/config/supabase_config.dart` (excluded from git)

### **Setup Steps:**

1. Copy template to actual config file:
   ```bash
   cp lib/config/supabase_config_template.dart lib/config/supabase_config.dart
   ```

2. Update `supabase_config.dart` with your actual Supabase credentials:
   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'https://your-project-id.supabase.co';
     static const String supabaseAnonKey = 'your-actual-anon-key-here';
   }
   ```

## Usage

### **In-App Workflow:**

1. **Grant Health Permissions**: Ensure Health Connect/HealthKit permissions are granted
2. **Select Date Range**: Use date pickers to choose sync period (default: last 90 days)
3. **Sync Data**: Click "Sync to Supabase" button to upload data
4. **Monitor Progress**: Watch real-time feedback during sync process

### **Sync Process:**

1. **Connection Test**: Verifies Supabase database connection
2. **Date Iteration**: Loops through each day in selected range
3. **Health Data Fetch**: Gets step data from Health Connect/HealthKit for each day
4. **Duplicate Check**: Verifies if data already exists in database
5. **Data Insert**: Adds new records to Supabase (skips existing ones)
6. **Progress Report**: Shows final count of successfully synced days

## Code Architecture

### **Service Layer:**

**`SupabaseService`** - Handles all database operations:
- Connection management
- Data insertion with duplicate prevention
- Date range queries
- Cleanup operations

### **Data Model:**

**`StepDataEntry`** - Represents a single day's step data:
```dart
class StepDataEntry {
  final DateTime date;
  final int stepCount;
  final String platform;
  final DateTime? createdAt;
}
```

### **UI Integration:**

- Date range picker components
- Sync progress indicators
- Real-time status updates
- Platform-specific messaging

## Security Considerations

### **Current Implementation (Proof of Concept):**

- ⚠️ **Open Access**: No user authentication required
- ⚠️ **Public Data**: All users share the same data table
- ⚠️ **API Keys**: Stored in client code (suitable for testing only)

### **Production Recommendations:**

1. **User Authentication**: Implement Supabase Auth
2. **Row Level Security**: Add user-specific data policies
3. **Environment Variables**: Move API keys to secure environment
4. **Data Isolation**: Separate data by user ID

## Error Handling

### **Common Scenarios:**

1. **Network Issues**: Graceful retry and user feedback
2. **Permission Errors**: Clear messaging for health permissions
3. **Database Errors**: Detailed error logging and user notification
4. **Duplicate Data**: Silent skip with success confirmation

### **Debugging:**

- Console logging for all database operations
- Real-time UI feedback during sync process
- Connection testing before sync operations
- Detailed error messages in debug info

## Performance Considerations

### **Optimization Features:**

1. **Duplicate Prevention**: Avoids unnecessary database writes
2. **Batch Processing**: Processes multiple days efficiently
3. **Date Indexing**: Database optimized for date-based queries
4. **Selective Sync**: Only specified date ranges

### **Limitations:**

- **Sequential Processing**: One day at a time (could be parallelized)
- **Client-Side Logic**: All processing done on device
- **Memory Usage**: Loads all health data before upload

## Troubleshooting

### **Common Issues:**

1. **Supabase Connection Failed**
   - Check internet connection
   - Verify Supabase URL and API key
   - Ensure project is active

2. **Health Permissions Denied**
   - Grant permissions through device settings
   - Retry permission requests in app

3. **Sync Partially Completed**
   - Normal behavior - skips existing data
   - Check debug info for specific errors

4. **No Data Found**
   - Verify health app has step data for selected dates
   - Check platform compatibility

### **Debug Commands:**

```dart
// Test Supabase connection
await SupabaseService.testConnection()

// Check existing data
await SupabaseService.getStepDataRange(startDate: date1, endDate: date2)

// Manual cleanup
await SupabaseService.cleanupOldData(90)
```

## Future Enhancements

### **Potential Improvements:**

1. **User Authentication**: Individual user accounts
2. **Data Visualization**: Charts and graphs
3. **Sync Scheduling**: Automatic background sync
4. **Data Export**: CSV/JSON export functionality
5. **Analytics**: Trends and insights
6. **Offline Support**: Queue operations when offline

## Testing

### **Manual Testing Checklist:**

- [ ] Supabase connection test
- [ ] Date range selection
- [ ] Sync with existing data (should skip)
- [ ] Sync with new data (should insert)
- [ ] Error handling (network disconnected)
- [ ] Cross-platform compatibility

### **Database Verification:**

```sql
-- Check total records
SELECT COUNT(*) FROM step_data;

-- View recent data
SELECT * FROM step_data ORDER BY date DESC LIMIT 10;

-- Check platform distribution
SELECT platform, COUNT(*) FROM step_data GROUP BY platform;
```
