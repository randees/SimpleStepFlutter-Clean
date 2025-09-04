-- Migration: 001_create_user_management_tables.sql
-- Description: Core user management and device tracking tables
-- Date: 2025-09-02 (Recreated from documentation)

-- Step 1: Core User Management Tables

-- 1.1 Users Table
CREATE TABLE IF NOT EXISTS users (
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

-- 1.2 User Devices Table
CREATE TABLE IF NOT EXISTS user_devices (
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