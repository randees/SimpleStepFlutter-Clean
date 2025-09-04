-- Migration: 012_create_genetic_insights_table.sql
-- Description: Create genetic_insights table for storing genetic analysis data
-- Date: 2025-09-04

-- Create genetic_insights table
CREATE TABLE IF NOT EXISTS genetic_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    data JSONB, -- Genetic data as JSON object
    meta_data JSONB, -- Additional metadata about the genetic analysis
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_genetic_insights_user_id ON genetic_insights(user_id);
CREATE INDEX IF NOT EXISTS idx_genetic_insights_created_at ON genetic_insights(created_at);

-- Add comments for documentation
COMMENT ON TABLE genetic_insights IS 'Stores genetic analysis and insights data for users';
COMMENT ON COLUMN genetic_insights.id IS 'Primary key - unique identifier for each genetic insight record';
COMMENT ON COLUMN genetic_insights.user_id IS 'Foreign key reference to users table - identifies the user this genetic data belongs to';
COMMENT ON COLUMN genetic_insights.data IS 'JSON object containing the genetic analysis data and results';
COMMENT ON COLUMN genetic_insights.meta_data IS 'JSON object containing metadata about the genetic analysis (source, method, confidence, etc.)';
COMMENT ON COLUMN genetic_insights.created_at IS 'Timestamp when this genetic insight record was created';
COMMENT ON COLUMN genetic_insights.updated_at IS 'Timestamp when this genetic insight record was last updated';

-- Enable Row Level Security
ALTER TABLE genetic_insights ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for genetic_insights table
-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own genetic insights" ON genetic_insights;
DROP POLICY IF EXISTS "Users can insert their own genetic insights" ON genetic_insights;
DROP POLICY IF EXISTS "Users can update their own genetic insights" ON genetic_insights;
DROP POLICY IF EXISTS "Users can delete their own genetic insights" ON genetic_insights;
DROP POLICY IF EXISTS "Service role has full access to genetic insights" ON genetic_insights;

-- Policy for service role (bypasses authentication for admin operations)
CREATE POLICY "Service role has full access to genetic insights" ON genetic_insights
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Policies for authenticated users (when using regular client)
CREATE POLICY "Users can view their own genetic insights" ON genetic_insights
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own genetic insights" ON genetic_insights
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own genetic insights" ON genetic_insights
    FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own genetic insights" ON genetic_insights
    FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Create trigger to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_genetic_insights_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_genetic_insights_updated_at
    BEFORE UPDATE ON genetic_insights
    FOR EACH ROW
    EXECUTE FUNCTION update_genetic_insights_updated_at();
