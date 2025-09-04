-- Migration: 005_create_indexes_and_rls.sql
-- Description: Performance indexes and Row Level Security policies
-- Date: 2025-09-02 (Recreated from documentation)

-- Step 6: Indexes and Performance Optimization

-- User-based queries
CREATE INDEX IF NOT EXISTS idx_activity_data_user_date ON activity_data(user_id, start_time);
CREATE INDEX IF NOT EXISTS idx_vital_signs_user_date ON vital_signs(user_id, measured_at);
CREATE INDEX IF NOT EXISTS idx_sleep_data_user_date ON sleep_data(user_id, sleep_date);
CREATE INDEX IF NOT EXISTS idx_nutrition_data_user_date ON nutrition_data(user_id, logged_at);
CREATE INDEX IF NOT EXISTS idx_body_measurements_user_date ON body_measurements(user_id, measured_at);
CREATE INDEX IF NOT EXISTS idx_wellness_data_user_date ON wellness_data(user_id, recorded_at);

-- Data source queries
CREATE INDEX IF NOT EXISTS idx_activity_data_source ON activity_data(data_source);
CREATE INDEX IF NOT EXISTS idx_vital_signs_source ON vital_signs(data_source);

-- Analytics queries
CREATE INDEX IF NOT EXISTS idx_daily_summaries_user_date ON daily_summaries(user_id, summary_date);
CREATE INDEX IF NOT EXISTS idx_health_insights_user_type ON health_insights(user_id, insight_type);
CREATE INDEX IF NOT EXISTS idx_recommendations_user_priority ON recommendations(user_id, priority);

-- Step 7: Row Level Security (RLS) Policies

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