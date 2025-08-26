-- Fix RLS policies to allow MCP server access while maintaining security
-- This script creates additional policies for anonymous (MCP server) access

-- Re-enable RLS first (in case it was disabled)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.body_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wellness_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vital_signs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_sync_log ENABLE ROW LEVEL SECURITY;

-- Drop existing policies that might conflict
DROP POLICY IF EXISTS "MCP server can read users" ON public.users;
DROP POLICY IF EXISTS "MCP server can read activity data" ON public.activity_data;
DROP POLICY IF EXISTS "MCP server can read sleep data" ON public.sleep_data;
DROP POLICY IF EXISTS "MCP server can read nutrition data" ON public.nutrition_data;
DROP POLICY IF EXISTS "MCP server can read body measurements" ON public.body_measurements;
DROP POLICY IF EXISTS "MCP server can read wellness data" ON public.wellness_data;
DROP POLICY IF EXISTS "MCP server can read vital signs" ON public.vital_signs;
DROP POLICY IF EXISTS "MCP server can read health insights" ON public.health_insights;
DROP POLICY IF EXISTS "MCP server can read recommendations" ON public.recommendations;
DROP POLICY IF EXISTS "MCP server can read daily summaries" ON public.daily_summaries;

-- Create policies for MCP server (anonymous) access - READ ONLY for security
CREATE POLICY "MCP server can read users" ON public.users
  FOR SELECT 
  USING (true);  -- Allow anonymous read access

CREATE POLICY "MCP server can read activity data" ON public.activity_data
  FOR SELECT 
  USING (true);  -- Allow anonymous read access

CREATE POLICY "MCP server can read sleep data" ON public.sleep_data
  FOR SELECT 
  USING (true);

CREATE POLICY "MCP server can read nutrition data" ON public.nutrition_data
  FOR SELECT 
  USING (true);

CREATE POLICY "MCP server can read body measurements" ON public.body_measurements
  FOR SELECT 
  USING (true);

CREATE POLICY "MCP server can read wellness data" ON public.wellness_data
  FOR SELECT 
  USING (true);

CREATE POLICY "MCP server can read vital signs" ON public.vital_signs
  FOR SELECT 
  USING (true);

CREATE POLICY "MCP server can read health insights" ON public.health_insights
  FOR SELECT 
  USING (true);

CREATE POLICY "MCP server can read recommendations" ON public.recommendations
  FOR SELECT 
  USING (true);

CREATE POLICY "MCP server can read daily summaries" ON public.daily_summaries
  FOR SELECT 
  USING (true);

-- Note: We're NOT allowing INSERT/UPDATE/DELETE for anonymous access for security
-- If MCP server needs to write data, you should use service role key instead

-- Verify policies are active
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'activity_data', 'sleep_data');

-- Show all policies for verification
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'activity_data', 'sleep_data')
ORDER BY tablename, policyname;
