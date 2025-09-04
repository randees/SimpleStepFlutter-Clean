-- Diagnostic query to check activity_data table
-- This will help us understand why the step analytics query is returning 0 results

-- 1. Check if activity_data table exists and has data
SELECT
    'Table exists and has data' as status,
    COUNT(*) as total_records
FROM activity_data;

-- 2. Check what user IDs exist in the table
SELECT DISTINCT
    user_id,
    COUNT(*) as records_for_user
FROM activity_data
GROUP BY user_id
ORDER BY records_for_user DESC;

-- 3. Check what activity types exist
SELECT DISTINCT
    activity_type,
    COUNT(*) as records
FROM activity_data
GROUP BY activity_type
ORDER BY records DESC;

-- 4. Check if there are any records with steps data
SELECT
    'Records with steps data' as status,
    COUNT(*) as records_with_steps
FROM activity_data
WHERE steps IS NOT NULL AND steps > 0;

-- 5. Check the date range of existing data
SELECT
    MIN(start_time) as earliest_date,
    MAX(start_time) as latest_date,
    COUNT(*) as total_records
FROM activity_data;

-- 6. Check a sample of recent records with steps
SELECT
    user_id,
    activity_type,
    start_time,
    steps,
    data_source
FROM activity_data
WHERE steps IS NOT NULL AND steps > 0
ORDER BY start_time DESC
LIMIT 10;

-- 7. Check if the specific user has any data
-- Replace 'USER_ID_HERE' with the actual user ID from the AI query
SELECT
    user_id,
    COUNT(*) as total_records,
    SUM(steps) as total_steps,
    MIN(start_time) as earliest_record,
    MAX(start_time) as latest_record
FROM activity_data
WHERE user_id = 'USER_ID_HERE'  -- Replace with actual user ID
GROUP BY user_id;
