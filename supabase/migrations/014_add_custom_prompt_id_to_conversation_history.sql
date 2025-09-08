-- Migration: 014_add_custom_prompt_id_to_conversation_history.sql
-- Description: Add custom_ai_prompt_id column to conversation_history table
-- Date: 2025-09-08

-- Add the custom_ai_prompt_id column to conversation_history table
ALTER TABLE conversation_history 
ADD COLUMN custom_ai_prompt_id UUID REFERENCES custom_ai_prompts(id) ON DELETE SET NULL;

-- Add index for better query performance when filtering by custom prompt
CREATE INDEX IF NOT EXISTS idx_conversation_history_custom_prompt_id 
ON conversation_history(custom_ai_prompt_id);

-- Add comment for documentation
COMMENT ON COLUMN conversation_history.custom_ai_prompt_id IS 'Foreign key to custom_ai_prompts table - tracks which custom prompt was used for this conversation';

-- The column is nullable since:
-- 1. Existing conversations may not have used custom prompts
-- 2. Some conversations may use default system prompts instead of custom ones
-- 3. If a custom prompt is deleted, the conversation history should remain but lose the reference
