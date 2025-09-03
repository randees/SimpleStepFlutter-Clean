-- Migration: 006_admin_policies.sql
-- Description: Add admin policies for user management operations
-- Date: 2025-09-02

-- Add admin policies that allow service role operations
-- These policies allow operations when using the service role key (bypass RLS)

-- Admin policies for users table
CREATE POLICY "Service role can manage all users" ON users FOR ALL 
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for user_devices table  
CREATE POLICY "Service role can manage all user devices" ON user_devices FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for activity_data table
CREATE POLICY "Service role can manage all activity data" ON activity_data FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for vital_signs table
CREATE POLICY "Service role can manage all vital signs" ON vital_signs FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for sleep_data table
CREATE POLICY "Service role can manage all sleep data" ON sleep_data FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for nutrition_data table
CREATE POLICY "Service role can manage all nutrition data" ON nutrition_data FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for body_measurements table
CREATE POLICY "Service role can manage all body measurements" ON body_measurements FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for wellness_data table
CREATE POLICY "Service role can manage all wellness data" ON wellness_data FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for health_insights table
CREATE POLICY "Service role can manage all health insights" ON health_insights FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for recommendations table
CREATE POLICY "Service role can manage all recommendations" ON recommendations FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for daily_summaries table
CREATE POLICY "Service role can manage all daily summaries" ON daily_summaries FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');

-- Admin policies for data_sync_log table
CREATE POLICY "Service role can manage all sync logs" ON data_sync_log FOR ALL
USING (current_setting('role') = 'service_role' OR auth.jwt() ->> 'role' = 'service_role');
