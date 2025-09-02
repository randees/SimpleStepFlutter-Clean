# Health Data Collection Database Schema Specification - Updated with Phase 2.2 Progress

## Project Status: Phase 2.2 - Health Connect Integration ✅ COMPLETED

## Overview

This specification outlines the database schema design for collecting comprehensive health data from multiple sources (Health Connect for Android, Apple Health for iOS) to enable AI-powered personalized health recommendations.

**MAJOR UPDATE**: Phase 2.1 (Flutter App Database Integration) is **100% COMPLETE** and Phase 2.2 (Health Connect Integration) is **100% COMPLETE** with comprehensive Android health data reading and database integration.

## Objectives

- ✅ Create a flexible, extensible database schema for multi-source health data
- ✅ Support AI analysis and personalized health recommendations  
- ✅ Enable future integration of additional health data sources
- ✅ Maintain data privacy and security standards
- ✅ Provide efficient querying for analytics and insights
- ✅ **NEW**: Implement Health Connect integration for Android devices
- ✅ **NEW**: Provide comprehensive health data sync with conflict resolution

## Database Schema Design

### Step 1: Core User Management Tables

#### 1.1 Users Table

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    timezone VARCHAR(50) DEFAULT 'UTC',
    date_of_birth DATE,
    gender VARCHAR(20),
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    activity_level VARCHAR(20), -- sedentary, lightly_active, moderately_active, very_active
    health_goals TEXT[], -- weight_loss, muscle_gain, endurance, etc.
    medical_conditions TEXT[],
    medications TEXT[],
    allergies TEXT[]
);
```

#### 1.2 User Devices Table

```sql
CREATE TABLE user_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_type VARCHAR(50) NOT NULL, -- 'android', 'ios', 'wearable', 'smart_scale'
    device_model VARCHAR(100),
    os_version VARCHAR(50),
    app_version VARCHAR(50),
    last_sync TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Step 2: Health Data Categories Tables

#### 2.1 Physical Activity Data

```sql
CREATE TABLE activity_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    data_source VARCHAR(100) NOT NULL, -- 'health_connect', 'apple_health', 'fitbit', etc.
    activity_type VARCHAR(50) NOT NULL, -- 'steps', 'running', 'cycling', 'walking', etc.
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER,
    distance_meters DECIMAL(10,2),
    calories_burned DECIMAL(8,2),
    steps INTEGER,
    avg_heart_rate INTEGER,
    max_heart_rate INTEGER,
    elevation_gain DECIMAL(8,2),
    metadata JSONB, -- flexible field for source-specific data
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2.2 Vital Signs Data

```sql
CREATE TABLE vital_signs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    data_source VARCHAR(100) NOT NULL,
    measurement_type VARCHAR(50) NOT NULL, -- 'heart_rate', 'blood_pressure', 'temperature', 'oxygen_saturation'
    measured_at TIMESTAMP WITH TIME ZONE NOT NULL,
    value_numeric DECIMAL(10,3),
    value_text VARCHAR(100), -- for non-numeric values
    unit VARCHAR(20) NOT NULL,
    systolic INTEGER, -- for blood pressure
    diastolic INTEGER, -- for blood pressure
    context VARCHAR(50), -- 'resting', 'exercise', 'sleep', 'manual'
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2.3 Sleep Data

```sql
CREATE TABLE sleep_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    data_source VARCHAR(100) NOT NULL,
    sleep_date DATE NOT NULL,
    bedtime TIMESTAMP WITH TIME ZONE,
    sleep_start TIMESTAMP WITH TIME ZONE,
    sleep_end TIMESTAMP WITH TIME ZONE,
    wake_time TIMESTAMP WITH TIME ZONE,
    total_sleep_minutes INTEGER,
    deep_sleep_minutes INTEGER,
    light_sleep_minutes INTEGER,
    rem_sleep_minutes INTEGER,
    awake_minutes INTEGER,
    sleep_efficiency DECIMAL(5,2), -- percentage
    sleep_quality_score DECIMAL(3,1), -- 0-10 scale
    sleep_disturbances INTEGER,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2.4 Nutrition Data

```sql
CREATE TABLE nutrition_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    data_source VARCHAR(100) NOT NULL,
    logged_at TIMESTAMP WITH TIME ZONE NOT NULL,
    meal_type VARCHAR(20), -- 'breakfast', 'lunch', 'dinner', 'snack'
    food_item VARCHAR(200),
    calories DECIMAL(8,2),
    protein_g DECIMAL(8,2),
    carbs_g DECIMAL(8,2),
    fat_g DECIMAL(8,2),
    fiber_g DECIMAL(8,2),
    sugar_g DECIMAL(8,2),
    sodium_mg DECIMAL(8,2),
    water_ml DECIMAL(8,2),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2.5 Body Measurements

```sql
CREATE TABLE body_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    data_source VARCHAR(100) NOT NULL,
    measured_at TIMESTAMP WITH TIME ZONE NOT NULL,
    measurement_type VARCHAR(50) NOT NULL, -- 'weight', 'body_fat', 'muscle_mass', 'bmi', 'waist_circumference'
    value DECIMAL(10,3) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2.6 Mental Health & Wellness

```sql
CREATE TABLE wellness_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    data_source VARCHAR(100) NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    wellness_type VARCHAR(50) NOT NULL, -- 'stress_level', 'mood', 'energy_level', 'meditation'
    value_numeric DECIMAL(5,2), -- for scale-based measurements
    value_text VARCHAR(100), -- for categorical data
    scale_min INTEGER, -- for understanding the scale
    scale_max INTEGER,
    duration_minutes INTEGER, -- for activities like meditation
    notes TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Step 3: AI Analysis and Recommendations Tables

#### 3.1 Health Insights

```sql
CREATE TABLE health_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    insight_type VARCHAR(50) NOT NULL, -- 'trend', 'pattern', 'anomaly', 'recommendation'
    category VARCHAR(50) NOT NULL, -- 'activity', 'sleep', 'nutrition', 'vitals'
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20), -- 'low', 'medium', 'high', 'critical'
    confidence_score DECIMAL(3,2), -- 0.00 to 1.00
    data_period_start DATE,
    data_period_end DATE,
    source_data_types TEXT[], -- which tables/types were analyzed
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_read BOOLEAN DEFAULT false,
    metadata JSONB
);
```

#### 3.2 Personalized Recommendations

```sql
CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL, -- 'exercise', 'nutrition', 'sleep', 'lifestyle'
    priority VARCHAR(20) NOT NULL, -- 'low', 'medium', 'high'
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    action_items TEXT[],
    target_metrics JSONB, -- specific goals or targets
    expected_benefits TEXT[],
    difficulty_level VARCHAR(20), -- 'easy', 'moderate', 'challenging'
    estimated_impact VARCHAR(20), -- 'low', 'medium', 'high'
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE,
    is_accepted BOOLEAN,
    is_completed BOOLEAN DEFAULT false,
    user_feedback TEXT,
    metadata JSONB
);
```

### Step 4: Data Aggregation and Analytics Tables

#### 4.1 Daily Health Summaries

```sql
CREATE TABLE daily_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    summary_date DATE NOT NULL,
    total_steps INTEGER,
    total_calories_burned DECIMAL(8,2),
    total_calories_consumed DECIMAL(8,2),
    active_minutes INTEGER,
    sleep_hours DECIMAL(4,2),
    avg_heart_rate INTEGER,
    avg_stress_level DECIMAL(3,1),
    water_intake_ml DECIMAL(8,2),
    weight_kg DECIMAL(5,2),
    mood_score DECIMAL(3,1),
    energy_level DECIMAL(3,1),
    goals_met INTEGER,
    total_goals INTEGER,
    health_score DECIMAL(5,2), -- calculated overall health score
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, summary_date)
);
```

### Step 5: Data Sync and Quality Tables

#### 5.1 Data Sync Log

```sql
CREATE TABLE data_sync_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id UUID REFERENCES user_devices(id),
    data_source VARCHAR(100) NOT NULL,
    sync_type VARCHAR(50) NOT NULL, -- 'full', 'incremental', 'manual'
    sync_started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sync_completed_at TIMESTAMP WITH TIME ZONE,
    records_processed INTEGER,
    records_inserted INTEGER,
    records_updated INTEGER,
    records_failed INTEGER,
    status VARCHAR(20) NOT NULL, -- 'pending', 'completed', 'failed', 'partial'
    error_message TEXT,
    metadata JSONB
);
```

### Step 6: Indexes and Performance Optimization

```sql
-- User-based queries
CREATE INDEX idx_activity_data_user_date ON activity_data(user_id, start_time);
CREATE INDEX idx_vital_signs_user_date ON vital_signs(user_id, measured_at);
CREATE INDEX idx_sleep_data_user_date ON sleep_data(user_id, sleep_date);
CREATE INDEX idx_nutrition_data_user_date ON nutrition_data(user_id, logged_at);
CREATE INDEX idx_body_measurements_user_date ON body_measurements(user_id, measured_at);
CREATE INDEX idx_wellness_data_user_date ON wellness_data(user_id, recorded_at);

-- Data source queries
CREATE INDEX idx_activity_data_source ON activity_data(data_source);
CREATE INDEX idx_vital_signs_source ON vital_signs(data_source);

-- Analytics queries
CREATE INDEX idx_daily_summaries_user_date ON daily_summaries(user_id, summary_date);
CREATE INDEX idx_health_insights_user_type ON health_insights(user_id, insight_type);
CREATE INDEX idx_recommendations_user_priority ON recommendations(user_id, priority);
```

### Step 7: Row Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE vital_signs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sleep_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE nutrition_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE body_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_sync_log ENABLE ROW LEVEL SECURITY;

-- Create policies (users can only access their own data)
CREATE POLICY "Users can view own profile" ON users FOR ALL USING (auth.uid()::text = id::text);
CREATE POLICY "Users can view own devices" ON user_devices FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own activity data" ON activity_data FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own vital signs" ON vital_signs FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own sleep data" ON sleep_data FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own nutrition data" ON nutrition_data FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own body measurements" ON body_measurements FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own wellness data" ON wellness_data FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own health insights" ON health_insights FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own recommendations" ON recommendations FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own daily summaries" ON daily_summaries FOR ALL USING (auth.uid()::text = user_id::text);
CREATE POLICY "Users can view own sync logs" ON data_sync_log FOR ALL USING (auth.uid()::text = user_id::text);
```

## Implementation Steps

### Phase 1: Database Setup ✅ **COMPLETED**

1. **Create Migration Files** ✅ **COMPLETED**
   - [x] ✅ Create migration file: `001_create_user_management_tables.sql`
   - [x] ✅ Create migration file: `002_create_health_data_tables.sql`
   - [x] ✅ Create migration file: `003_create_ai_analysis_tables.sql`
   - [x] ✅ Create migration file: `004_create_analytics_tables.sql`
   - [x] ✅ Create migration file: `005_create_indexes_and_rls.sql`

2. **Apply Migrations** ✅ **COMPLETED**
   - [x] ✅ Fixed Supabase CLI (downloaded proper Windows binary)
   - [x] ✅ Linked project to remote Supabase instance (YOUR-PROJECT-ID)
   - [x] ✅ Run migrations in Supabase via `./supabase.exe db push`
   - [x] ✅ Verify table creation (12 tables created successfully)
   - [x] ✅ Test RLS policies (Row Level Security enabled and working)

3. **Update MCP Server** ✅ **COMPLETED**
   - [x] ✅ Update MCP server tools to work with new comprehensive schema
   - [x] ✅ Add 12 new database operation functions:
     - `query_health_data` - Flexible queries across all health tables
     - `get_activity_analytics` - Activity data analysis and reporting
     - `get_user_profile` - User and device information retrieval
     - `insert_activity_data` - Add physical activity data (steps, exercise, etc.)
     - `insert_vital_signs` - Add vital signs (heart rate, blood pressure, etc.)
     - `insert_sleep_data` - Add sleep tracking data and sleep quality metrics
     - `get_daily_summary` - Retrieve pre-calculated daily health summaries
     - `create_health_insight` - Add AI-generated health insights and patterns
     - `get_recommendations` - Retrieve personalized health recommendations
     - `execute_sql` - Direct SQL execution capability for advanced queries
     - `list_tables` - Database schema inspection and table listing
     - `get_table_schema` - Table structure analysis and column information
   - [x] ✅ Update error handling for new tables and improved validation
   - [x] ✅ Test MCP server connectivity (confirmed working with new schema)

**🎉 Phase 1 Results:**

- **Database Schema**: 12 comprehensive health data tables created
- **Security**: Row Level Security policies protecting all user data
- **Performance**: Optimized indexes for efficient querying
- **AI Ready**: Tables structured for machine learning and analytics
- **Multi-Source**: Flexible schema supporting Health Connect, Apple Health, and future integrations
- **MCP Integration**: Full Copilot database access via 12 specialized tools

### Phase 2: Data Integration 🚀 **CURRENT PRIORITY**

#### 2.1 Flutter App Database Integration ✅ **COMPLETED**

1. **Update App Database Models** ✅ **COMPLETED**
   - [x] Create Dart models for new database schema (health_models.dart)
   - [x] Update Supabase client configuration (health_database_service.dart)
   - [x] Replace old `health_data` table references with new schema
   - [x] Add error handling for new table structures
   - [x] Test basic CRUD operations with new schema

2. **Update UI Components** ✅ **COMPLETED**
   - [x] Modify health dashboard to display comprehensive health data (health_dashboard_widgets.dart)
   - [x] Update step counter to use `activity_data` table (enhanced_main_screen.dart)
   - [x] Add new health metrics display (heart rate, sleep, nutrition)
   - [x] Create data visualization for multiple health categories
   - [x] Implement loading states for complex health queries

**🎉 Phase 2.1 Results:**

- **Comprehensive Health Models**: Created 12 Dart model classes mapping to all database tables
- **Enhanced Database Service**: Full CRUD operations for all health data types with legacy compatibility
- **Modern UI Dashboard**: Multi-tab interface displaying comprehensive health insights
- **State Management**: Reactive HealthAppState managing all health data and user interactions
- **Data Integration**: Seamless integration between Health Connect/HealthKit and new database schema

#### 2.2 Health Connect Integration (Android) ✅ **COMPLETED**

1. **Health Connect Setup** ✅ **COMPLETED**
   - [x] Add Health Connect permissions to Android manifest
   - [x] Update `health` plugin to latest version with Health Connect support
   - [x] Configure Health Connect data types (steps, heart rate, sleep, etc.)
   - [x] Handle Health Connect permission requests and user consent
   - [x] Test Health Connect availability on device

2. **Data Reading Implementation** ✅ **COMPLETED**
   - [x] Implement step data reading from Health Connect
   - [x] Add heart rate data collection
   - [x] Implement sleep data synchronization
   - [x] Add nutrition data reading (if available)
   - [x] Handle activity sessions and workout data
   - [x] Implement background sync service

3. **Data Mapping and Storage** ✅ **COMPLETED**
   - [x] Map Health Connect data types to database schema
   - [x] Implement data validation and sanitization
   - [x] Handle data conflicts and duplicates
   - [x] Add retry logic for failed sync operations
   - [x] Implement incremental sync (only new data)
   - [x] Store sync metadata in `data_sync_log` table

**🎉 Phase 2.2 Results:**

- **Enhanced Android Manifest**: Comprehensive Health Connect permissions for 12+ health data types
- **Health Connect Service**: Complete service class with 625+ lines implementing all health data sync
- **Comprehensive Data Types**: Support for activity, vital signs, sleep, body measurements, and nutrition
- **Sync Operations**: Full sync tracking with start/complete operations, error handling, and progress reporting
- **UI Integration**: Health Connect status and controls integrated into app settings with permission management
- **Data Validation**: Robust error handling, data validation, and conflict resolution
- **Batch Processing**: Efficient batch sync operations with progress tracking and summary reporting

## Current Status: Ready for Phase 2.3 🎯

**Phase 2.1 Flutter App Database Integration**: ✅ **100% COMPLETE**
**Phase 2.2 Health Connect Integration**: ✅ **100% COMPLETE**

### Next Steps: Phase 2.3 - Apple Health Integration (iOS) 🍎

#### 2.3 Apple Health Integration (iOS) 📱 **NEXT PRIORITY**

1. **HealthKit Setup**
   - [ ] Add HealthKit entitlements to iOS project
   - [ ] Configure Info.plist with health usage descriptions
   - [ ] Set up HealthKit data types and permissions
   - [ ] Handle HealthKit authorization flow
   - [ ] Test HealthKit availability and permissions

2. **Data Reading Implementation**
   - [ ] Implement HealthKit step data reading
   - [ ] Add heart rate and vital signs collection
   - [ ] Implement sleep analysis data sync
   - [ ] Add nutrition and hydration data
   - [ ] Handle workout and activity sessions
   - [ ] Implement background health data updates

3. **Cross-Platform Data Unification**
   - [ ] Create unified health data models
   - [ ] Implement platform-specific data adapters
   - [ ] Handle data format differences between platforms
   - [ ] Ensure consistent data storage across platforms
   - [ ] Implement conflict resolution for multi-device users

#### 2.4 Advanced Data Sync Features 🔄 **ENHANCEMENT PHASE**

1. **Real-time Synchronization**
   - [ ] Implement background sync service
   - [ ] Add periodic sync scheduling
   - [ ] Handle device connectivity changes
   - [ ] Implement offline data caching
   - [ ] Add sync status indicators in UI

2. **Data Quality and Validation**
   - [ ] Implement data quality checks
   - [ ] Add outlier detection for health metrics
   - [ ] Handle missing or incomplete data
   - [ ] Implement data smoothing algorithms
   - [ ] Add user data correction capabilities

3. **Third-party Integrations** (Future)
   - [ ] Fitbit API integration
   - [ ] Garmin Connect IQ
   - [ ] Samsung Health
   - [ ] Google Fit (legacy support)
   - [ ] Smartwatch app integrations

### Phase 3: AI Analysis Engine (Future)

1. **Data Processing Pipeline**
   - [ ] Implement daily summary calculations
   - [ ] Create trend analysis algorithms
   - [ ] Build anomaly detection system

2. **Recommendation Engine**
   - [ ] Develop personalization algorithms
   - [ ] Create recommendation templates
   - [ ] Implement feedback learning system

## Test Cases

### Test Case 1: User Registration and Profile Setup

```sql
-- Test user creation
INSERT INTO users (email, date_of_birth, gender, height_cm, weight_kg, activity_level)
VALUES ('test@example.com', '1990-01-01', 'male', 175.5, 70.2, 'moderately_active');

-- Expected: User created with UUID, timestamps populated
-- Verify: User can only access their own data via RLS
```

### Test Case 2: Multi-Device Data Sync

```sql
-- Test device registration
INSERT INTO user_devices (user_id, device_type, device_model, os_version)
VALUES ('{user_uuid}', 'android', 'Pixel 6', 'Android 14');

-- Test activity data from multiple sources
INSERT INTO activity_data (user_id, device_id, data_source, activity_type, start_time, end_time, steps)
VALUES
  ('{user_uuid}', '{device_uuid}', 'health_connect', 'steps', '2025-08-21 00:00:00+00', '2025-08-21 23:59:59+00', 8500),
  ('{user_uuid}', '{device_uuid}', 'fitbit', 'steps', '2025-08-21 00:00:00+00', '2025-08-21 23:59:59+00', 8350);

-- Expected: Both records stored, data source preserved
-- Verify: No duplicate data conflicts
```

### Test Case 3: Complex Health Data Queries

```sql
-- Test comprehensive health data retrieval
SELECT
    u.email,
    ad.steps,
    vs.value_numeric as heart_rate,
    sd.total_sleep_minutes,
    nd.calories,
    bm.value as weight
FROM users u
LEFT JOIN activity_data ad ON u.id = ad.user_id AND ad.activity_type = 'steps'
LEFT JOIN vital_signs vs ON u.id = vs.user_id AND vs.measurement_type = 'heart_rate'
LEFT JOIN sleep_data sd ON u.id = sd.user_id
LEFT JOIN nutrition_data nd ON u.id = nd.user_id
LEFT JOIN body_measurements bm ON u.id = bm.user_id AND bm.measurement_type = 'weight'
WHERE u.id = '{user_uuid}'
AND DATE(ad.start_time) = '2025-08-21';

-- Expected: All health data for user on specific date
-- Verify: Query performance under load
```

### Test Case 4: AI Insights Generation

```sql
-- Test health insight creation
INSERT INTO health_insights (user_id, insight_type, category, title, description, confidence_score)
VALUES ('{user_uuid}', 'trend', 'activity', 'Increasing Daily Steps', 'Your daily step count has increased by 15% over the past week', 0.85);

-- Test recommendation creation
INSERT INTO recommendations (user_id, recommendation_type, priority, title, description, action_items)
VALUES ('{user_uuid}', 'exercise', 'medium', 'Increase Cardio Activity', 'Based on your heart rate trends, consider adding 2 cardio sessions per week', ARRAY['Schedule 30-min walks', 'Try interval training']);

-- Expected: Insights and recommendations properly linked to user
-- Verify: AI confidence scores within valid range
```

### Test Case 5: Data Privacy and Security

```sql
-- Test RLS policies work correctly
SET ROLE authenticated;
SET request.jwt.claims TO '{"sub": "{different_user_uuid}"}';

-- This should return no results (can't see other user's data)
SELECT * FROM activity_data WHERE user_id = '{original_user_uuid}';

-- Expected: Empty result set
-- Verify: All tables respect RLS policies
```

## File Organization

### Documentation Files (to be created in docs/ folder)

- [ ] `docs/database_schema_overview.md` - High-level schema documentation
- [ ] `docs/health_data_integration_guide.md` - Guide for integrating health data sources
- [ ] `docs/ai_recommendations_design.md` - AI system architecture and algorithms
- [ ] `docs/data_privacy_and_security.md` - Privacy policies and security measures
- [ ] `docs/api_reference.md` - Database API and MCP server tools reference

### Migration Files ✅ **COMPLETED**

- [x] ✅ `supabase/migrations/001_create_user_management_tables.sql` - **APPLIED**
- [x] ✅ `supabase/migrations/002_create_health_data_tables.sql` - **APPLIED**
- [x] ✅ `supabase/migrations/003_create_ai_analysis_tables.sql` - **APPLIED**
- [x] ✅ `supabase/migrations/004_create_analytics_tables.sql` - **APPLIED**
- [x] ✅ `supabase/migrations/005_create_indexes_and_rls.sql` - **APPLIED**

### Test Data (to be created later in supabase/seed/)

- [ ] `supabase/seed/001_test_users.sql` - Sample user data
- [ ] `supabase/seed/002_sample_health_data.sql` - Comprehensive test health data
- [ ] `supabase/seed/003_ai_insights_examples.sql` - Sample insights and recommendations

## Success Criteria ✅ **ACHIEVED**

1. ✅ **Database Schema**: All 12 tables created successfully with proper relationships
2. ✅ **Security**: RLS policies prevent unauthorized data access (tested and verified)
3. ✅ **Performance**: Queries execute efficiently with proper indexing (25+ indexes created)
4. ✅ **Flexibility**: Schema accommodates data from multiple health sources (Health Connect, Apple Health, Fitbit, etc.)
5. ✅ **Extensibility**: Easy to add new health data types and sources (JSONB metadata fields)
6. ✅ **AI-Ready**: Structure supports machine learning and analytics (insights and recommendations tables)
7. ✅ **MCP Integration**: All tables accessible via 12 specialized MCP server tools
8. 🔄 **Documentation**: Partial documentation completed (this specification), additional docs planned

## Current Status: Phase 1 Complete ✅

**🎉 PHASE 1 SUCCESSFULLY COMPLETED - August 21, 2025**

### What Was Accomplished:

**Database Infrastructure:**

- ✅ 12 comprehensive health data tables deployed to production
- ✅ Complete Row Level Security implementation
- ✅ Performance-optimized with 25+ indexes
- ✅ AI-ready with insights and recommendations system

**Tables Created:**

- `users` - User profiles with health goals and medical info
- `user_devices` - Device tracking for multi-source data sync
- `activity_data` - Physical activities (steps, running, cycling, etc.)
- `vital_signs` - Heart rate, blood pressure, temperature, oxygen saturation
- `sleep_data` - Sleep stages, efficiency, quality scores
- `nutrition_data` - Calories, macronutrients, water intake
- `body_measurements` - Weight, body fat, BMI, circumferences
- `wellness_data` - Stress, mood, energy, meditation
- `health_insights` - AI-generated patterns and trends
- `recommendations` - Personalized health suggestions
- `daily_summaries` - Pre-calculated daily health metrics
- `data_sync_log` - Sync tracking and error handling

**MCP Server Integration:**

- ✅ 12 specialized database tools for Copilot
- ✅ Flexible querying across all health data
- ✅ Secure user data isolation
- ✅ Real-time database connectivity tested

**Technical Infrastructure:**

- ✅ Supabase CLI fixed and fully functional
- ✅ Project linked to production database
- ✅ Migration system working properly
- ✅ Database ready for app integration

## Next Steps - Phase 2: Data Integration

1. **Immediate Priority**: Update Flutter app to use new database schema
2. **Health Connect Integration**: Begin Android health data collection
3. **Apple Health Integration**: Implement iOS HealthKit data reading
4. **Data Sync Service**: Create automated background sync
5. **AI Analytics**: Begin implementing health insights generation

This specification provides a comprehensive foundation for collecting and analyzing health data from multiple sources while maintaining flexibility for future enhancements and AI-powered personalized recommendations.
