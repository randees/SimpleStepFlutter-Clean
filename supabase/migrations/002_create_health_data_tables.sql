-- Migration: 002_create_health_data_tables.sql
-- Description: Core health data collection tables
-- Date: 2025-09-02 (Recreated from documentation)

-- Step 2: Health Data Categories Tables

-- 2.1 Physical Activity Data
CREATE TABLE IF NOT EXISTS activity_data (
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

-- 2.2 Vital Signs Data
CREATE TABLE IF NOT EXISTS vital_signs (
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

-- 2.3 Sleep Data
CREATE TABLE IF NOT EXISTS sleep_data (
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

-- 2.4 Nutrition Data
CREATE TABLE IF NOT EXISTS nutrition_data (
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

-- 2.5 Body Measurements
CREATE TABLE IF NOT EXISTS body_measurements (
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

-- 2.6 Mental Health & Wellness
CREATE TABLE IF NOT EXISTS wellness_data (
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