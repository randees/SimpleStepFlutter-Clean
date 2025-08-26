-- SQL script to disable Row Level Security (RLS) for debugging
-- Run this in your Supabase SQL editor to temporarily disable RLS

-- Option 1: Disable RLS on the users table completely
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- Option 2: Disable RLS on activity_data table as well
ALTER TABLE public.activity_data DISABLE ROW LEVEL SECURITY;

-- Option 3: Alternative - Create a permissive policy for anonymous access
-- (uncomment if you prefer this approach instead of disabling RLS)

-- For users table:
-- DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
-- CREATE POLICY "Allow anonymous read access to users" ON public.users
--   FOR SELECT USING (true);

-- For activity_data table:
-- DROP POLICY IF EXISTS "Users can view their own activity data" ON public.activity_data;
-- CREATE POLICY "Allow anonymous read access to activity_data" ON public.activity_data
--   FOR SELECT USING (true);

-- Check current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'activity_data');

-- Show existing policies (to see what was blocking access)
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('users', 'activity_data');
