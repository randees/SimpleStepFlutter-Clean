# Supabase Setup Guide

## Overview

This guide walks through setting up Supabase to store 90 days of step data from Health Connect/HealthKit.

## Step 1: Create Supabase Account

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub/Google/Email
4. Create a new organization (or use existing)

## Step 2: Create New Project

1. Click "New Project"
2. Choose your organization
3. Enter project details:
   - **Name**: `simple-step-flutter`
   - **Database Password**: Generate a strong password (save this!)
   - **Region**: Choose closest to your location
4. Click "Create new project"
5. Wait 2-3 minutes for project initialization

## Step 3: Create Database Table

1. Go to **Table Editor** in Supabase dashboard
2. Click "Create a new table"
3. Configure table:
   - **Name**: `step_data`
   - **Description**: "Daily step count data from health apps"

## Step 4: Define Table Schema

Create the following columns:

| Column Name | Type | Default | Nullable | Primary Key | Unique |
|-------------|------|---------|----------|-------------|--------|
| id | int8 | Auto-increment | No | Yes | Yes |
| date | date | - | No | No | Yes |
| step_count | int4 | 0 | No | No | No |
| platform | text | - | No | No | No |
| created_at | timestamptz | now() | No | No | No |
| updated_at | timestamptz | now() | No | No | No |

**SQL to create table:**
```sql
CREATE TABLE step_data (
  id BIGSERIAL PRIMARY KEY,
  date DATE NOT NULL UNIQUE,
  step_count INTEGER NOT NULL DEFAULT 0,
  platform TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster date queries
CREATE INDEX idx_step_data_date ON step_data(date);

-- Create trigger to update updated_at automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_step_data_updated_at 
    BEFORE UPDATE ON step_data 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Step 5: Configure Row Level Security (RLS)

1. Go to **Authentication** > **Policies**
2. Find your `step_data` table
3. Enable RLS (Row Level Security)
4. For proof of concept, create permissive policy:

```sql
-- Allow all operations for now (proof of concept)
CREATE POLICY "Allow all operations" ON step_data
FOR ALL USING (true);
```

## Step 6: Get API Keys

1. Go to **Settings** > **API**
2. Copy the following:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **anon public key**: `"YOUR-SUPABASE-ANON-KEY"
   - **service_role secret**: `<this is secured for the server>` (for server operations)

## Step 7: Test Database Connection

In Supabase SQL Editor, test with:
```sql
-- Insert test data
INSERT INTO step_data (date, step_count, platform) 
VALUES ('2025-08-19', 8500, 'Android Health Connect');

-- Query data
SELECT * FROM step_data ORDER BY date DESC;

-- Clean up test data
DELETE FROM step_data WHERE step_count = 8500;
```

## Step 8: Flutter Integration

Add these to your Flutter project:
1. Add dependencies to `pubspec.yaml`
2. Create environment configuration
3. Implement Supabase client
4. Add data sync functionality

## Security Notes

- **For Production**: Implement proper RLS policies
- **For Production**: Use authentication and user-specific data
- **For Proof of Concept**: Current setup allows open access
- **API Keys**: Keep secret keys secure, never commit to git

## Troubleshooting

### Common Issues:
1. **Connection refused**: Check project URL and API key
2. **Permission denied**: Verify RLS policies
3. **Table not found**: Ensure table creation was successful
4. **Invalid date format**: Use YYYY-MM-DD format

### Useful SQL Queries:
```sql
-- Check table structure
\d step_data

-- Count total records
SELECT COUNT(*) FROM step_data;

-- Get last 7 days
SELECT * FROM step_data 
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY date DESC;

-- Delete old data (older than 90 days)
DELETE FROM step_data 
WHERE date < CURRENT_DATE - INTERVAL '90 days';
```

## Next Steps

After setup:
1. Configure Flutter app with Supabase credentials
2. Test data insertion from app
3. Implement date range selection
4. Add duplicate prevention logic
5. Test with real health data
