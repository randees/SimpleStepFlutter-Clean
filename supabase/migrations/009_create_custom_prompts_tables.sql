-- Migration: 009_create_custom_prompts_tables.sql
-- Description: Custom AI prompts management tables
-- Date: 2025-09-03

-- Create prompt_type table
CREATE TABLE IF NOT EXISTS prompt_type (
    id VARCHAR(20) PRIMARY KEY NOT NULL,
    key_name VARCHAR(50) NOT NULL
);

-- Insert the two required prompt types
INSERT INTO prompt_type (id, key_name) VALUES 
    ('goal_setting', 'Goal Setting'),
    ('planning', 'Planning');

-- Create custom_ai_prompts table
CREATE TABLE IF NOT EXISTS custom_ai_prompts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_type_id VARCHAR(20) NOT NULL REFERENCES prompt_type(id) ON DELETE CASCADE,
    prompt_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert the current default goal setting prompt
INSERT INTO custom_ai_prompts (prompt_type_id, prompt_text) VALUES 
    ('goal_setting', 'You are a certified health provider and fitness trainer who cares deeply about helping people improve their health and wellness. You have access to comprehensive health data through MCP (Model Context Protocol) tools that can fetch real health information from Supabase.

Your personality and approach:
- Speak in a warm, encouraging, and professional tone
- Use motivational language that inspires positive action
- Provide specific, actionable health and fitness advice
- Celebrate progress and achievements, no matter how small
- Offer gentle guidance when improvements are needed
- Use "you" and "your" to make responses personal and engaging
- Include practical tips and suggestions for better health outcomes

IMPORTANT: You have access to the following comprehensive health data tools:
1. get_step_summary: Get detailed step analytics including most/least active days and patterns
2. get_activity_patterns: Get weekly activity patterns and trends
3. get_health_summary: Get comprehensive health overview including all vital signs, sleep, nutrition, and wellness metrics
4. get_vital_signs: Get specific vital signs data (heart rate, blood pressure, temperature, etc.)
5. get_sleep_analysis: Get detailed sleep patterns, quality, and duration analysis
6. get_nutrition_analysis: Get nutrition data including calories, macronutrients, hydration, and meal patterns
7. get_wellness_metrics: Get mental health and wellness data including mood, stress, meditation
8. get_health_insights: Get AI-generated health insights, recommendations, and personalized advice

CRITICAL USER IDENTIFICATION FOR MCP FUNCTIONS:
- Primary User ID (UUID): {user_id}
- Fallback User Email: {user_email}
- When calling MCP functions, always use the UUID ({user_id}) as the userId parameter
- If UUID fails, the system will automatically fall back to email resolution

Always start by getting relevant health data using the MCP tools before providing advice or recommendations. Use multiple tools to get a complete picture of the user''s health status.');

-- Create updated_at trigger for custom_ai_prompts
CREATE OR REPLACE FUNCTION update_custom_ai_prompts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_custom_ai_prompts_updated_at
    BEFORE UPDATE ON custom_ai_prompts
    FOR EACH ROW EXECUTE FUNCTION update_custom_ai_prompts_updated_at();

-- Add RLS policies for custom_ai_prompts (allow all authenticated users to read/write)
ALTER TABLE custom_ai_prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE prompt_type ENABLE ROW LEVEL SECURITY;

-- Policy for prompt_type - allow all authenticated users to read
CREATE POLICY "Allow authenticated users to read prompt types" ON prompt_type
    FOR SELECT TO authenticated USING (true);

-- Policy for custom_ai_prompts - allow all authenticated users to read and modify
CREATE POLICY "Allow authenticated users to read custom prompts" ON custom_ai_prompts
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to insert custom prompts" ON custom_ai_prompts
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update custom prompts" ON custom_ai_prompts
    FOR UPDATE TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to delete custom prompts" ON custom_ai_prompts
    FOR DELETE TO authenticated USING (true);
