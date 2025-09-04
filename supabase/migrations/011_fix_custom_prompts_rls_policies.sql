-- Migration: 011_fix_custom_prompts_rls_policies.sql
-- Description: Fix RLS policies for custom_ai_prompts table
-- Date: 2025-09-03

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow authenticated users to read custom prompts" ON custom_ai_prompts;
DROP POLICY IF EXISTS "Allow authenticated users to insert custom prompts" ON custom_ai_prompts;
DROP POLICY IF EXISTS "Allow authenticated users to update custom prompts" ON custom_ai_prompts;
DROP POLICY IF EXISTS "Allow authenticated users to delete custom prompts" ON custom_ai_prompts;
DROP POLICY IF EXISTS "Allow service role full access to custom prompts" ON custom_ai_prompts;

-- Ensure RLS is enabled
ALTER TABLE custom_ai_prompts ENABLE ROW LEVEL SECURITY;

-- Policy for service role (bypasses authentication for admin operations)
CREATE POLICY "Allow service role full access to custom prompts" ON custom_ai_prompts
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Policies for authenticated users (when using regular client)
CREATE POLICY "Allow authenticated users to read custom prompts" ON custom_ai_prompts
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated users to insert custom prompts" ON custom_ai_prompts
    FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update custom prompts" ON custom_ai_prompts
    FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete custom prompts" ON custom_ai_prompts
    FOR DELETE TO authenticated USING (true);
