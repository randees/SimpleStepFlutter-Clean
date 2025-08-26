-- SQL script to check if users exist and understand the current state
-- Run this FIRST to see what's in your database

-- 1. Check if the users table exists
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public'
   AND table_name = 'users'
) as users_table_exists;

-- 2. Check if users table has any data (this might fail if RLS is blocking)
SELECT COUNT(*) as total_users FROM public.users;

-- 3. Check the structure of the users table
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'users'
ORDER BY ordinal_position;

-- 4. Try to see first few users (might fail due to RLS)
SELECT id, email, display_name, created_at 
FROM public.users 
LIMIT 5;

-- 5. Check current RLS status
SELECT schemaname, tablename, rowsecurity, hasoids 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename = 'users';

-- 6. Check what policies are currently active
SELECT policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'users';
