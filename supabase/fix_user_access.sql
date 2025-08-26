-- Fix user access for anonymous users (for testing purposes)
-- This allows the Flutter app to read users with the anonymous key

-- First, run the user creation script if users don't exist
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

-- Add policy to allow anonymous users to read the users table (for testing)
CREATE POLICY "Anonymous users can read user data for testing" ON public.users
    FOR SELECT USING (true);

-- Show the users that were created
SELECT id, email, display_name, activity_level FROM public.users ORDER BY created_at;
