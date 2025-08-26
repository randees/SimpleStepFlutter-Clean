-- Simple script to add users and allow anonymous access for testing
-- Run this in your Supabase SQL editor

-- First, let's add an anonymous read policy to allow your app to see the users
DROP POLICY IF EXISTS "Allow anonymous read access" ON public.users;
CREATE POLICY "Allow anonymous read access" ON public.users
    FOR SELECT USING (true);

-- Insert the three test personas (with conflict handling)
INSERT INTO public.users (
    id,
    email,
    display_name,
    first_name,
    last_name,
    age,
    gender,
    height_cm,
    weight_kg,
    activity_level,
    fitness_goals,
    health_conditions,
    medications
) VALUES 
-- Persona 1: Sarah (Very Active Runner)
(
    '00000000-0000-0000-0000-000000000001',
    'sarah.runner@example.com',
    'Sarah (Very Active)',
    'Sarah',
    'Johnson',
    28,
    'female',
    165.0,
    58.0,
    'very_active',
    '["weight_loss", "marathon_training", "endurance"]',
    '[]',
    '[]'
),
-- Persona 2: Mike (Moderately Active Professional)
(
    '00000000-0000-0000-0000-000000000002',
    'mike.professional@example.com',
    'Mike (Moderately Active)',
    'Mike',
    'Chen',
    35,
    'male',
    175.0,
    72.0,
    'moderately_active',
    '["maintain_fitness", "stress_reduction", "muscle_building"]',
    '["mild_hypertension"]',
    '["lisinopril"]'
),
-- Persona 3: Emma (Sedentary Desk Worker)
(
    '00000000-0000-0000-0000-000000000003',
    'emma.deskworker@example.com',
    'Emma (Sedentary)',
    'Emma',
    'Davis',
    42,
    'female',
    160.0,
    65.0,
    'sedentary',
    '["increase_activity", "weight_management", "better_sleep"]',
    '["type_2_diabetes", "lower_back_pain"]',
    '["metformin", "ibuprofen"]'
)
ON CONFLICT (id) DO NOTHING;

-- Verify the users were created
SELECT 
    id, 
    email, 
    display_name, 
    activity_level,
    created_at
FROM public.users 
ORDER BY created_at;

-- Show the count to confirm
SELECT COUNT(*) as total_users FROM public.users;
