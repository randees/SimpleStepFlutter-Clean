-- SQL Script to Delete Orphaned Health Data Records
-- This script removes all records from health data tables where user_id is NULL
-- Keeps the users table intact - only cleans up orphaned health data

-- WARNING: This will permanently delete data. Make sure to backup first!
-- Run each DELETE statement carefully and check row counts before proceeding.

-- Start transaction for safety (you can rollback if needed)
BEGIN;

-- Display current counts of orphaned records before deletion
SELECT 'BEFORE DELETION - Orphaned Records Count:' as status;

SELECT 
  'user_devices' as table_name, 
  COUNT(*) as orphaned_count 
FROM user_devices 
WHERE user_id IS NULL;

SELECT 
  'activity_data' as table_name, 
  COUNT(*) as orphaned_count 
FROM activity_data 
WHERE user_id IS NULL;

SELECT 
  'vital_signs' as table_name, 
  COUNT(*) as orphaned_count 
FROM vital_signs 
WHERE user_id IS NULL;

SELECT 
  'sleep_data' as table_name, 
  COUNT(*) as orphaned_count 
FROM sleep_data 
WHERE user_id IS NULL;

SELECT 
  'nutrition_data' as table_name, 
  COUNT(*) as orphaned_count 
FROM nutrition_data 
WHERE user_id IS NULL;

SELECT 
  'body_measurements' as table_name, 
  COUNT(*) as orphaned_count 
FROM body_measurements 
WHERE user_id IS NULL;

SELECT 
  'wellness_data' as table_name, 
  COUNT(*) as orphaned_count 
FROM wellness_data 
WHERE user_id IS NULL;

SELECT 
  'health_insights' as table_name, 
  COUNT(*) as orphaned_count 
FROM health_insights 
WHERE user_id IS NULL;

SELECT 
  'recommendations' as table_name, 
  COUNT(*) as orphaned_count 
FROM recommendations 
WHERE user_id IS NULL;

SELECT 
  'daily_summaries' as table_name, 
  COUNT(*) as orphaned_count 
FROM daily_summaries 
WHERE user_id IS NULL;

SELECT 
  'data_sync_log' as table_name, 
  COUNT(*) as orphaned_count 
FROM data_sync_log 
WHERE user_id IS NULL;

-- Pause here to review counts before deletion
-- If you want to proceed, run the DELETE statements below

-- Delete orphaned records from each health data table
-- (Uncomment the statements below to execute)

/*
DELETE FROM user_devices WHERE user_id IS NULL;
DELETE FROM activity_data WHERE user_id IS NULL;
DELETE FROM vital_signs WHERE user_id IS NULL;
DELETE FROM sleep_data WHERE user_id IS NULL;
DELETE FROM nutrition_data WHERE user_id IS NULL;
DELETE FROM body_measurements WHERE user_id IS NULL;
DELETE FROM wellness_data WHERE user_id IS NULL;
DELETE FROM health_insights WHERE user_id IS NULL;
DELETE FROM recommendations WHERE user_id IS NULL;
DELETE FROM daily_summaries WHERE user_id IS NULL;
DELETE FROM data_sync_log WHERE user_id IS NULL;
*/

-- Verify deletion results (uncomment after running DELETE statements)
/*
SELECT 'AFTER DELETION - Remaining Orphaned Records:' as status;

SELECT 'user_devices' as table_name, COUNT(*) as remaining_orphaned FROM user_devices WHERE user_id IS NULL
UNION ALL
SELECT 'activity_data' as table_name, COUNT(*) as remaining_orphaned FROM activity_data WHERE user_id IS NULL
UNION ALL
SELECT 'vital_signs' as table_name, COUNT(*) as remaining_orphaned FROM vital_signs WHERE user_id IS NULL
UNION ALL
SELECT 'sleep_data' as table_name, COUNT(*) as remaining_orphaned FROM sleep_data WHERE user_id IS NULL
UNION ALL
SELECT 'nutrition_data' as table_name, COUNT(*) as remaining_orphaned FROM nutrition_data WHERE user_id IS NULL
UNION ALL
SELECT 'body_measurements' as table_name, COUNT(*) as remaining_orphaned FROM body_measurements WHERE user_id IS NULL
UNION ALL
SELECT 'wellness_data' as table_name, COUNT(*) as remaining_orphaned FROM wellness_data WHERE user_id IS NULL
UNION ALL
SELECT 'health_insights' as table_name, COUNT(*) as remaining_orphaned FROM health_insights WHERE user_id IS NULL
UNION ALL
SELECT 'recommendations' as table_name, COUNT(*) as remaining_orphaned FROM recommendations WHERE user_id IS NULL
UNION ALL
SELECT 'daily_summaries' as table_name, COUNT(*) as remaining_orphaned FROM daily_summaries WHERE user_id IS NULL
UNION ALL
SELECT 'data_sync_log' as table_name, COUNT(*) as remaining_orphaned FROM data_sync_log WHERE user_id IS NULL;
*/

-- Commit the transaction (uncomment after running DELETE statements)
-- COMMIT;

-- If something goes wrong, you can rollback instead:
-- ROLLBACK;
