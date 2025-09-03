-- Migration: 007_add_user_name_columns.sql
-- Description: Add first_name, last_name, and display_name columns to users table
-- Date: 2025-09-02

-- Add name columns to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS first_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS last_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS display_name VARCHAR(200);

-- Create index on display_name for faster searches
CREATE INDEX IF NOT EXISTS idx_users_display_name ON users(display_name);

-- Create index on last_name for faster searches
CREATE INDEX IF NOT EXISTS idx_users_last_name ON users(last_name);

-- Add a comment to document the new columns
COMMENT ON COLUMN users.first_name IS 'User first name';
COMMENT ON COLUMN users.last_name IS 'User last name';
COMMENT ON COLUMN users.display_name IS 'User preferred display name (can be combination of first/last or custom)';
