-- Migration: Update existing users with proper name fields
-- This populates the new name columns for existing test users

-- Update Margaret Elderly
UPDATE users 
SET 
  first_name = 'Margaret',
  last_name = 'Elderly', 
  display_name = 'Margaret Elderly'
WHERE email = 'margaret.elderly@healthtest.com';

-- Update David Middleaged  
UPDATE users
SET
  first_name = 'David',
  last_name = 'Williams',
  display_name = 'David Williams'
WHERE email = 'david.middleaged@healthtest.com';

-- Update Alex Bodybuilder
UPDATE users
SET
  first_name = 'Alex', 
  last_name = 'Rodriguez',
  display_name = 'Alex Rodriguez'
WHERE email = 'alex.bodybuilder@healthtest.com';

-- Add comments
COMMENT ON COLUMN users.first_name IS 'User first name - populated for existing test users';
COMMENT ON COLUMN users.last_name IS 'User last name - populated for existing test users';
COMMENT ON COLUMN users.display_name IS 'User display name - populated for existing test users';
