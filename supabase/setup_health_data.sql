-- Create health_data table for MCP server testing
CREATE TABLE IF NOT EXISTS public.health_data (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL,
    data_type TEXT NOT NULL,
    value NUMERIC,
    date DATE NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_health_data_user_id ON public.health_data(user_id);
CREATE INDEX IF NOT EXISTS idx_health_data_type_date ON public.health_data(data_type, date);
CREATE INDEX IF NOT EXISTS idx_health_data_user_type_date ON public.health_data(user_id, data_type, date);

-- Enable Row Level Security
ALTER TABLE public.health_data ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users to access their own data
CREATE POLICY "Users can access their own health data" ON public.health_data
    FOR ALL USING (auth.uid() = user_id);

-- Create policy for service role (for MCP server)
CREATE POLICY "Service role can access all health data" ON public.health_data
    FOR ALL USING (auth.role() = 'service_role');

-- Insert some test data for demonstration
INSERT INTO public.health_data (user_id, data_type, value, date) VALUES
    ('00000000-0000-0000-0000-000000000001', 'steps', 8500, '2025-08-01'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 12000, '2025-08-02'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 6800, '2025-08-03'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 15000, '2025-08-04'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 9200, '2025-08-05'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 7500, '2025-08-06'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 11800, '2025-08-07'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 13500, '2025-08-08'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 8900, '2025-08-09'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 10200, '2025-08-10'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 14800, '2025-08-11'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 6200, '2025-08-12'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 9800, '2025-08-13'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 12500, '2025-08-14'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 8100, '2025-08-15'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 11200, '2025-08-16'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 13800, '2025-08-17'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 7900, '2025-08-18'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 10500, '2025-08-19'),
    ('00000000-0000-0000-0000-000000000001', 'steps', 9600, '2025-08-20');

-- Add some data for another test user
INSERT INTO public.health_data (user_id, data_type, value, date) VALUES
    ('test-user-123', 'steps', 7200, '2025-07-21'),
    ('test-user-123', 'steps', 9800, '2025-07-22'),
    ('test-user-123', 'steps', 12500, '2025-07-23'),
    ('test-user-123', 'steps', 6700, '2025-07-24'),
    ('test-user-123', 'steps', 11200, '2025-07-25'),
    ('test-user-123', 'steps', 8900, '2025-07-26'),
    ('test-user-123', 'steps', 13100, '2025-07-27'),
    ('test-user-123', 'steps', 10800, '2025-07-28'),
    ('test-user-123', 'steps', 9400, '2025-07-29'),
    ('test-user-123', 'steps', 12800, '2025-07-30'),
    ('test-user-123', 'steps', 7800, '2025-07-31'),
    ('test-user-123', 'steps', 10200, '2025-08-01'),
    ('test-user-123', 'steps', 13500, '2025-08-02'),
    ('test-user-123', 'steps', 8600, '2025-08-03'),
    ('test-user-123', 'steps', 11900, '2025-08-04'),
    ('test-user-123', 'steps', 9700, '2025-08-05'),
    ('test-user-123', 'steps', 14200, '2025-08-06'),
    ('test-user-123', 'steps', 8300, '2025-08-07'),
    ('test-user-123', 'steps', 10600, '2025-08-08'),
    ('test-user-123', 'steps', 12100, '2025-08-09'),
    ('test-user-123', 'steps', 9100, '2025-08-10'),
    ('test-user-123', 'steps', 11400, '2025-08-11'),
    ('test-user-123', 'steps', 7600, '2025-08-12'),
    ('test-user-123', 'steps', 13000, '2025-08-13'),
    ('test-user-123', 'steps', 10300, '2025-08-14'),
    ('test-user-123', 'steps', 8800, '2025-08-15'),
    ('test-user-123', 'steps', 12600, '2025-08-16'),
    ('test-user-123', 'steps', 9200, '2025-08-17'),
    ('test-user-123', 'steps', 11700, '2025-08-18'),
    ('test-user-123', 'steps', 10900, '2025-08-19'),
    ('test-user-123', 'steps', 8500, '2025-08-20');
