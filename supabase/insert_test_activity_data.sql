-- Insert sample activity data for testing step analytics
-- This will help us verify that the step analytics function works correctly

-- First, let's check if we have any users
SELECT id, email, display_name FROM users LIMIT 5;

-- Insert sample activity data for Margaret Elderly (user ID from logs)
INSERT INTO activity_data (
    user_id,
    data_source,
    activity_type,
    start_time,
    end_time,
    duration_minutes,
    steps,
    calories_burned,
    metadata
) VALUES
-- Today's data (September 4, 2025)
(
    '230a6a21-0d15-4ec1-a088-1156c1208664', -- Margaret Elderly
    'test_data',
    'walking',
    '2025-09-04T08:00:00Z',
    '2025-09-04T08:30:00Z',
    30,
    2500,
    125.5,
    '{"test": true}'
),
(
    '230a6a21-0d15-4ec1-a088-1156c1208664', -- Margaret Elderly
    'test_data',
    'walking',
    '2025-09-04T12:00:00Z',
    '2025-09-04T12:45:00Z',
    45,
    3200,
    160.0,
    '{"test": true}'
),
(
    '230a6a21-0d15-4ec1-a088-1156c1208664', -- Margaret Elderly
    'test_data',
    'running',
    '2025-09-04T18:00:00Z',
    '2025-09-04T18:30:00Z',
    30,
    2800,
    280.0,
    '{"test": true}'
),
-- Yesterday's data (September 3, 2025)
(
    '230a6a21-0d15-4ec1-a088-1156c1208664', -- Margaret Elderly
    'test_data',
    'walking',
    '2025-09-03T09:00:00Z',
    '2025-09-03T09:30:00Z',
    30,
    2100,
    105.0,
    '{"test": true}'
),
(
    '230a6a21-0d15-4ec1-a088-1156c1208664', -- Margaret Elderly
    'test_data',
    'walking',
    '2025-09-03T14:00:00Z',
    '2025-09-03T14:30:00Z',
    30,
    1900,
    95.0,
    '{"test": true}'
),
(
    '230a6a21-0d15-4ec1-a088-1156c1208664', -- Margaret Elderly
    'test_data',
    'steps',
    '2025-09-03T20:00:00Z',
    '2025-09-03T20:30:00Z',
    30,
    1500,
    75.0,
    '{"test": true}'
);

-- Verify the data was inserted
SELECT
    user_id,
    activity_type,
    start_time,
    steps,
    data_source
FROM activity_data
WHERE user_id = '230a6a21-0d15-4ec1-a088-1156c1208664'
ORDER BY start_time DESC;

-- Show summary
SELECT
    user_id,
    COUNT(*) as total_records,
    SUM(steps) as total_steps,
    MIN(start_time) as earliest_date,
    MAX(start_time) as latest_date
FROM activity_data
WHERE user_id = '230a6a21-0d15-4ec1-a088-1156c1208664'
GROUP BY user_id;
