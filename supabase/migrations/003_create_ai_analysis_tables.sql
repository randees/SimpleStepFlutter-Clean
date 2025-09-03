-- Migration: 003_create_ai_analysis_tables.sql
-- Description: AI analysis and recommendations tables
-- Date: 2025-09-02 (Recreated from documentation)

-- Step 3: AI Analysis and Recommendations Tables

-- 3.1 Health Insights
CREATE TABLE IF NOT EXISTS health_insights (
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

-- 3.2 Personalized Recommendations
CREATE TABLE IF NOT EXISTS recommendations (
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