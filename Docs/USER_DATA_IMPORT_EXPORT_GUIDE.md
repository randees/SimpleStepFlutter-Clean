# Comprehensive User Data Import/Export Guide

## Overview

This guide provides complete documentation for the enhanced user data import/export functionality that includes ALL health data tables in the SimpleStep database.

## Export/Import Format Version 2.0

The enhanced system exports data from **11 comprehensive health data tables**:

1. **user_profile** - User account and health profile information
2. **user_devices** - Registered devices for health data collection
3. **activity_data** - Physical activities (steps, workouts, etc.)
4. **vital_signs** - Heart rate, blood pressure, temperature, etc.
5. **sleep_data** - Sleep stages, quality, and patterns
6. **nutrition_data** - Diet, calories, macronutrients, hydration
7. **body_measurements** - Weight, BMI, body composition
8. **wellness_data** - Stress, mood, energy levels, meditation
9. **health_insights** - AI-generated health patterns and trends
10. **recommendations** - Personalized health suggestions
11. **daily_summaries** - Aggregated daily health metrics
12. **data_sync_log** - Data synchronization tracking

## Export Data Structure

### Complete Export Format

```json
{
  "export_metadata": {
    "export_date": "2025-09-02T15:30:00.000Z",
    "app_version": "1.0.0",
    "export_format_version": "2.0",
    "exported_by": "SimpleStep Flutter App",
    "total_tables": 11,
    "user_id": "550e8400-e29b-41d4-a716-446655440000"
  },
  "user_profile": { /* User profile data */ },
  "user_devices": [ /* Device data */ ],
  "activity_data": [ /* Activity data */ ],
  "vital_signs": [ /* Vital signs data */ ],
  "sleep_data": [ /* Sleep data */ ],
  "nutrition_data": [ /* Nutrition data */ ],
  "body_measurements": [ /* Body measurements */ ],
  "wellness_data": [ /* Wellness data */ ],
  "health_insights": [ /* AI insights */ ],
  "recommendations": [ /* Recommendations */ ],
  "daily_summaries": [ /* Daily summaries */ ],
  "data_sync_log": [ /* Sync logs */ ]
}
```

## Complete Example Import File

### File: `complete_user_example.json`

```json
{
  "export_metadata": {
    "export_date": "2025-09-02T15:30:00.000Z",
    "app_version": "1.0.0",
    "export_format_version": "2.0",
    "exported_by": "SimpleStep Flutter App",
    "total_tables": 11,
    "user_id": "550e8400-e29b-41d4-a716-446655440000"
  },
  "user_profile": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john.example@healthtest.com",
    "created_at": "2025-09-01T10:00:00.000Z",
    "updated_at": "2025-09-02T15:30:00.000Z",
    "timezone": "America/New_York",
    "date_of_birth": "1985-06-15",
    "gender": "male",
    "height_cm": 178.5,
    "weight_kg": 75.2,
    "activity_level": "moderately_active",
    "health_goals": ["weight_loss", "muscle_gain", "cardiovascular_health"],
    "medical_conditions": ["mild_hypertension"],
    "medications": ["lisinopril_10mg"],
    "allergies": ["peanuts", "shellfish"]
  },
  "user_devices": [
    {
      "id": "device-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_type": "android",
      "device_model": "Samsung Galaxy S23",
      "os_version": "Android 14",
      "app_version": "1.0.0",
      "last_sync": "2025-09-02T15:25:00.000Z",
      "is_active": true,
      "created_at": "2025-09-01T10:00:00.000Z"
    },
    {
      "id": "device-002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_type": "wearable",
      "device_model": "Samsung Galaxy Watch 6",
      "os_version": "Wear OS 4.0",
      "app_version": "1.0.0",
      "last_sync": "2025-09-02T15:20:00.000Z",
      "is_active": true,
      "created_at": "2025-09-01T10:15:00.000Z"
    }
  ],
  "activity_data": [
    {
      "id": "activity-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "health_connect",
      "activity_type": "steps",
      "start_time": "2025-09-02T00:00:00.000Z",
      "end_time": "2025-09-02T23:59:59.000Z",
      "duration_minutes": 1440,
      "distance_meters": 7200.5,
      "calories_burned": 320.5,
      "steps": 9500,
      "avg_heart_rate": 72,
      "max_heart_rate": 145,
      "elevation_gain": 150.0,
      "metadata": {
        "source": "samsung_health",
        "confidence": 0.95
      },
      "created_at": "2025-09-02T23:59:59.000Z"
    },
    {
      "id": "activity-002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-002",
      "data_source": "galaxy_watch",
      "activity_type": "running",
      "start_time": "2025-09-02T07:00:00.000Z",
      "end_time": "2025-09-02T07:30:00.000Z",
      "duration_minutes": 30,
      "distance_meters": 4000.0,
      "calories_burned": 280.0,
      "steps": 4200,
      "avg_heart_rate": 155,
      "max_heart_rate": 175,
      "elevation_gain": 45.0,
      "metadata": {
        "workout_type": "outdoor_run",
        "gps_enabled": true
      },
      "created_at": "2025-09-02T07:30:00.000Z"
    }
  ],
  "vital_signs": [
    {
      "id": "vital-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-002",
      "data_source": "galaxy_watch",
      "measurement_type": "heart_rate",
      "measured_at": "2025-09-02T08:00:00.000Z",
      "value_numeric": 68.0,
      "value_text": null,
      "unit": "bpm",
      "systolic": null,
      "diastolic": null,
      "context": "resting",
      "metadata": {
        "measurement_duration": 60,
        "confidence": 0.98
      },
      "created_at": "2025-09-02T08:00:30.000Z"
    },
    {
      "id": "vital-002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "manual_entry",
      "measurement_type": "blood_pressure",
      "measured_at": "2025-09-02T09:00:00.000Z",
      "value_numeric": null,
      "value_text": "125/82",
      "unit": "mmHg",
      "systolic": 125,
      "diastolic": 82,
      "context": "manual",
      "metadata": {
        "cuff_size": "medium",
        "position": "sitting"
      },
      "created_at": "2025-09-02T09:01:00.000Z"
    }
  ],
  "sleep_data": [
    {
      "id": "sleep-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-002",
      "data_source": "galaxy_watch",
      "sleep_date": "2025-09-01",
      "bedtime": "2025-09-01T22:30:00.000Z",
      "sleep_start": "2025-09-01T23:00:00.000Z",
      "sleep_end": "2025-09-02T06:30:00.000Z",
      "wake_time": "2025-09-02T07:00:00.000Z",
      "total_sleep_minutes": 450,
      "deep_sleep_minutes": 110,
      "light_sleep_minutes": 280,
      "rem_sleep_minutes": 60,
      "awake_minutes": 30,
      "sleep_efficiency": 88.5,
      "sleep_quality_score": 7.8,
      "sleep_disturbances": 2,
      "metadata": {
        "sleep_stages_detected": true,
        "movement_data": true
      },
      "created_at": "2025-09-02T07:00:30.000Z"
    }
  ],
  "nutrition_data": [
    {
      "id": "nutrition-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "myfitnesspal",
      "logged_at": "2025-09-02T07:30:00.000Z",
      "meal_type": "breakfast",
      "food_item": "Oatmeal with berries and almonds",
      "calories": 320.0,
      "protein_g": 12.5,
      "carbs_g": 45.0,
      "fat_g": 8.5,
      "fiber_g": 6.0,
      "sugar_g": 15.0,
      "sodium_mg": 150.0,
      "water_ml": 0.0,
      "metadata": {
        "meal_photo": false,
        "barcode_scanned": false
      },
      "created_at": "2025-09-02T07:35:00.000Z"
    },
    {
      "id": "nutrition-002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "manual_entry",
      "logged_at": "2025-09-02T10:00:00.000Z",
      "meal_type": "snack",
      "food_item": "Water",
      "calories": 0.0,
      "protein_g": 0.0,
      "carbs_g": 0.0,
      "fat_g": 0.0,
      "fiber_g": 0.0,
      "sugar_g": 0.0,
      "sodium_mg": 0.0,
      "water_ml": 500.0,
      "metadata": {
        "hydration_reminder": true
      },
      "created_at": "2025-09-02T10:01:00.000Z"
    }
  ],
  "body_measurements": [
    {
      "id": "measurement-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "smart_scale",
      "measured_at": "2025-09-02T07:00:00.000Z",
      "measurement_type": "weight",
      "value": 75.2,
      "unit": "kg",
      "metadata": {
        "scale_model": "Withings Body+",
        "body_composition": false
      },
      "created_at": "2025-09-02T07:00:30.000Z"
    },
    {
      "id": "measurement-002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "smart_scale",
      "measured_at": "2025-09-02T07:00:00.000Z",
      "measurement_type": "body_fat",
      "value": 15.8,
      "unit": "percent",
      "metadata": {
        "scale_model": "Withings Body+",
        "bioelectrical_impedance": true
      },
      "created_at": "2025-09-02T07:00:30.000Z"
    }
  ],
  "wellness_data": [
    {
      "id": "wellness-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "mindfulness_app",
      "recorded_at": "2025-09-02T08:30:00.000Z",
      "wellness_type": "meditation",
      "value_numeric": 10.0,
      "value_text": "focused_breathing",
      "scale_min": 1,
      "scale_max": 60,
      "duration_minutes": 10,
      "notes": "Morning meditation session - feeling calm and focused",
      "metadata": {
        "guided": true,
        "instructor": "Headspace"
      },
      "created_at": "2025-09-02T08:40:00.000Z"
    },
    {
      "id": "wellness-002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "manual_entry",
      "recorded_at": "2025-09-02T20:00:00.000Z",
      "wellness_type": "mood",
      "value_numeric": 8.0,
      "value_text": "good",
      "scale_min": 1,
      "scale_max": 10,
      "duration_minutes": null,
      "notes": "Had a productive day, feeling positive",
      "metadata": {
        "prompt": "How are you feeling today?"
      },
      "created_at": "2025-09-02T20:00:30.000Z"
    }
  ],
  "health_insights": [
    {
      "id": "insight-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "insight_type": "trend",
      "category": "activity",
      "title": "Increasing Daily Steps",
      "description": "Your daily step count has increased by 15% over the past week, showing great progress toward your fitness goals.",
      "severity": "low",
      "confidence_score": 0.85,
      "data_period_start": "2025-08-26",
      "data_period_end": "2025-09-02",
      "source_data_types": ["activity_data"],
      "generated_at": "2025-09-02T23:00:00.000Z",
      "expires_at": "2025-09-09T23:00:00.000Z",
      "is_read": false,
      "metadata": {
        "algorithm": "trend_analysis_v2",
        "baseline_period": "2025-08-19_2025-08-25"
      }
    },
    {
      "id": "insight-002",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "insight_type": "pattern",
      "category": "sleep",
      "title": "Consistent Sleep Schedule",
      "description": "You've maintained a consistent bedtime within 30 minutes for the past 5 days, which promotes better sleep quality.",
      "severity": "low",
      "confidence_score": 0.92,
      "data_period_start": "2025-08-28",
      "data_period_end": "2025-09-02",
      "source_data_types": ["sleep_data"],
      "generated_at": "2025-09-02T23:00:00.000Z",
      "expires_at": "2025-09-09T23:00:00.000Z",
      "is_read": false,
      "metadata": {
        "algorithm": "sleep_pattern_analysis",
        "variance_threshold": 30
      }
    }
  ],
  "recommendations": [
    {
      "id": "recommendation-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "recommendation_type": "exercise",
      "priority": "medium",
      "title": "Add Strength Training",
      "description": "Based on your activity data, consider adding 2 strength training sessions per week to complement your cardio routine and support your muscle gain goals.",
      "action_items": [
        "Schedule 2 strength training sessions per week",
        "Focus on compound movements (squats, deadlifts, bench press)",
        "Start with bodyweight exercises if new to strength training",
        "Consider working with a personal trainer initially"
      ],
      "target_metrics": {
        "weekly_strength_sessions": 2,
        "session_duration": 45,
        "progressive_overload": true
      },
      "expected_benefits": [
        "Increased muscle mass",
        "Improved bone density",
        "Better metabolic health",
        "Enhanced functional strength"
      ],
      "difficulty_level": "moderate",
      "estimated_impact": "high",
      "generated_at": "2025-09-02T23:00:00.000Z",
      "valid_until": "2025-10-02T23:00:00.000Z",
      "is_accepted": null,
      "is_completed": false,
      "user_feedback": null,
      "metadata": {
        "based_on": "activity_trends",
        "confidence": 0.88
      }
    }
  ],
  "daily_summaries": [
    {
      "id": "summary-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "summary_date": "2025-09-02",
      "total_steps": 9500,
      "total_calories_burned": 600.5,
      "total_calories_consumed": 1850.0,
      "active_minutes": 45,
      "sleep_hours": 7.5,
      "avg_heart_rate": 72,
      "avg_stress_level": 3.2,
      "water_intake_ml": 2100.0,
      "weight_kg": 75.2,
      "mood_score": 8.0,
      "energy_level": 7.5,
      "goals_met": 4,
      "total_goals": 5,
      "health_score": 82.5,
      "last_updated": "2025-09-02T23:59:59.000Z"
    }
  ],
  "data_sync_log": [
    {
      "id": "sync-001",
      "user_id": "550e8400-e29b-41d4-a716-446655440000",
      "device_id": "device-001",
      "data_source": "health_connect",
      "sync_type": "incremental",
      "sync_started_at": "2025-09-02T23:55:00.000Z",
      "sync_completed_at": "2025-09-02T23:56:30.000Z",
      "records_processed": 125,
      "records_inserted": 45,
      "records_updated": 12,
      "records_failed": 0,
      "status": "completed",
      "error_message": null,
      "metadata": {
        "data_types": ["steps", "heart_rate", "sleep"],
        "sync_duration_seconds": 90
      }
    }
  ]
}
```

## Import Instructions

### Prerequisites

1. **Backup Current Data**: Always export existing user data before importing
2. **User ID Uniqueness**: Ensure the user ID in the import file doesn't conflict with existing users
3. **Data Validation**: Verify all required fields are present and correctly formatted

### Step-by-Step Import Process

1. **Open User Management Modal**
   - Navigate to Goal Setting Agent page
   - Click "User Management" button

2. **Select Import Option**
   - Click the blue "Import" button
   - Choose your JSON file (must be .json extension)

3. **Validation & Import**
   - System validates file format and structure
   - Checks for user ID conflicts
   - Imports data in batches for large datasets

4. **Verification**
   - Import summary shows records imported per table
   - Search for imported user to verify data
   - Check that all health data categories are populated

### Data Validation Rules

#### Required Fields

**user_profile** (Required):
- `id`: Valid UUID
- `email`: Valid email format
- `created_at`: ISO 8601 timestamp
- `updated_at`: ISO 8601 timestamp

**All Health Data Tables** (Optional):
- `user_id`: Must match user_profile.id
- Appropriate data types for each field
- Valid timestamp formats for date fields

#### Data Type Validation

- **UUIDs**: Must be valid UUID format
- **Timestamps**: Must be ISO 8601 format with timezone
- **Decimals**: Numeric values with appropriate precision
- **Arrays**: JSON arrays for multi-value fields
- **JSONB**: Valid JSON objects for metadata fields

### Batch Processing

The import system handles large datasets efficiently:

- **Batch Size**: 100 records per batch
- **Progress Tracking**: Shows import progress for each table
- **Error Handling**: Continues processing even if individual records fail
- **Memory Management**: Processes large files without memory issues

### Error Handling

Common import errors and solutions:

1. **User Already Exists**
   - Solution: Delete existing user first or change user ID in import file

2. **Invalid JSON Format**
   - Solution: Validate JSON syntax and structure

3. **Missing Required Fields**
   - Solution: Ensure user_profile contains all required fields

4. **Foreign Key Violations**
   - Solution: Ensure user_devices.user_id matches user_profile.id

5. **Invalid Data Types**
   - Solution: Check timestamp formats and numeric values

### Export Format Compatibility

The system supports multiple export format versions:

- **Version 1.0**: Basic export (users + activity_data only)
- **Version 2.0**: Comprehensive export (all 11 health data tables)

Legacy v1.0 files can still be imported but will only contain basic data.

### Best Practices

1. **Regular Backups**: Export user data regularly for backup purposes
2. **Test Imports**: Test import files with sample data before production use
3. **Data Privacy**: Ensure exported files are securely stored and transmitted
4. **Incremental Updates**: For large datasets, consider exporting/importing specific date ranges
5. **Validation**: Always verify imported data completeness after import

### Troubleshooting

#### Import Failed Partially
- Check console logs for specific table errors
- Some tables may not exist in older database versions
- Continue with successful tables, manually address failed ones

#### Large File Performance
- Files over 50MB may take several minutes to import
- Progress is shown in the import dialog
- Don't close the app during large imports

#### Data Inconsistencies
- Check that device_id references exist in user_devices table
- Verify timestamp formats are consistent
- Ensure numeric values are within expected ranges

### Security Considerations

- **Data Encryption**: Consider encrypting export files for sensitive health data
- **Access Control**: Limit access to export/import functionality to authorized users
- **Audit Trail**: All import/export operations are logged in data_sync_log
- **Data Validation**: All imported data is validated before database insertion

This comprehensive guide ensures successful import/export of complete user health data across all available tables in the SimpleStep health tracking system.
