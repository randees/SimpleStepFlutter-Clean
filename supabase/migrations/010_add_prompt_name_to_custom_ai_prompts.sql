-- Migration: 010_add_prompt_name_to_custom_ai_prompts.sql
-- Description: Add prompt_name column to custom_ai_prompts table
-- Date: 2025-09-03

-- Add prompt_name column to custom_ai_prompts table
ALTER TABLE custom_ai_prompts 
ADD COLUMN prompt_name VARCHAR(255);

-- Update existing records with default names based on prompt_type_id
UPDATE custom_ai_prompts 
SET prompt_name = CASE 
    WHEN prompt_type_id = 'goal_setting' THEN 'Default Goal Setting Prompt'
    WHEN prompt_type_id = 'planning' THEN 'Default Planning Prompt'
    ELSE 'Custom Prompt'
END
WHERE prompt_name IS NULL;

-- Make prompt_name NOT NULL after updating existing records
ALTER TABLE custom_ai_prompts 
ALTER COLUMN prompt_name SET NOT NULL;

-- Add a unique constraint for prompt_name within the same prompt_type_id
ALTER TABLE custom_ai_prompts 
ADD CONSTRAINT unique_prompt_name_per_type 
UNIQUE (prompt_type_id, prompt_name);
