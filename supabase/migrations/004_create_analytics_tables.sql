-- Migration: 004_create_analytics_tables.sql
-- Description: Data aggregation and sync tracking tables
-- Date: 2025-09-02 (Recreated from documentation)

-- Step 4: Data Aggregation and Analytics Tables

-- 4.1 Daily Health Summaries
CREATE TABLE IF NOT EXISTS daily_summaries (
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

-- Step 5: Data Sync and Quality Tables

-- 5.1 Data Sync Log
CREATE TABLE IF NOT EXISTS data_sync_log (
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