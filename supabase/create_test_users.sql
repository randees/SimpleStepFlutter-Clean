-- Create users table and insert test personas
-- This will set up the three personas for testing

-- Create users table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    first_name TEXT,
    last_name TEXT,
    age INTEGER,
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    height_cm NUMERIC,
    weight_kg NUMERIC,
    activity_level TEXT CHECK (activity_level IN ('sedentary', 'lightly_active', 'moderately_active', 'very_active')),
    fitness_goals JSONB,
    health_conditions JSONB,
    medications JSONB,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policy for users to access their own data
CREATE POLICY "Users can access their own data" ON public.users
    FOR ALL USING (auth.uid() = id);

-- Create policy for service role (for MCP server)
CREATE POLICY "Service role can access all user data" ON public.users
    FOR ALL USING (auth.role() = 'service_role');

-- Insert the three test personas
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
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_activity_level ON public.users(activity_level);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON public.users(created_at);

-- Show the created users
SELECT id, email, display_name, activity_level FROM public.users ORDER BY created_at;
