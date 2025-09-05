-- Migration: 013_create_conversation_history_table.sql
-- Description: Create conversation_history table for storing AI chat conversations
-- Date: 2025-09-05

-- Create conversation_history table
CREATE TABLE IF NOT EXISTS conversation_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Allow NULL for deleted users
    session_id UUID NOT NULL DEFAULT gen_random_uuid(), -- Group messages by conversation session
    message_content TEXT NOT NULL,
    message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('user', 'assistant', 'system')),
    message_role VARCHAR(20) NOT NULL CHECK (message_role IN ('user', 'assistant', 'system')),
    model_used VARCHAR(50), -- AI model used (e.g., 'gpt-3.5-turbo', 'gpt-4')
    tokens_used INTEGER, -- Token count for the message
    metadata JSONB, -- Additional data (confidence, function calls, etc.)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_conversation_history_user_id ON conversation_history(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_history_session_id ON conversation_history(session_id);
CREATE INDEX IF NOT EXISTS idx_conversation_history_created_at ON conversation_history(created_at);
CREATE INDEX IF NOT EXISTS idx_conversation_history_user_session ON conversation_history(user_id, session_id);
CREATE INDEX IF NOT EXISTS idx_conversation_history_message_type ON conversation_history(message_type);

-- Add comments for documentation
COMMENT ON TABLE conversation_history IS 'Stores complete conversation history between users and AI assistant';
COMMENT ON COLUMN conversation_history.id IS 'Primary key - unique identifier for each message';
COMMENT ON COLUMN conversation_history.user_id IS 'Foreign key to users table - can be NULL if user is deleted';
COMMENT ON COLUMN conversation_history.session_id IS 'Groups messages by conversation session for context';
COMMENT ON COLUMN conversation_history.message_content IS 'The actual message text content';
COMMENT ON COLUMN conversation_history.message_type IS 'Type of message: user, assistant, or system';
COMMENT ON COLUMN conversation_history.message_role IS 'Role for OpenAI API: user, assistant, or system';
COMMENT ON COLUMN conversation_history.model_used IS 'AI model used for generating the response';
COMMENT ON COLUMN conversation_history.tokens_used IS 'Number of tokens used in this message';
COMMENT ON COLUMN conversation_history.metadata IS 'JSON object for additional data (function calls, confidence scores, etc.)';
COMMENT ON COLUMN conversation_history.created_at IS 'Timestamp when this message was created';
COMMENT ON COLUMN conversation_history.updated_at IS 'Timestamp when this message was last updated';

-- Enable Row Level Security
ALTER TABLE conversation_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for conversation_history table
-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view their own conversation history" ON conversation_history;
DROP POLICY IF EXISTS "Users can insert their own conversation history" ON conversation_history;
DROP POLICY IF EXISTS "Service role has full access to conversation history" ON conversation_history;

-- Policy for service role (bypasses authentication for admin operations)
CREATE POLICY "Service role has full access to conversation history" ON conversation_history
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Policies for authenticated users (when using regular client)
CREATE POLICY "Users can view their own conversation history" ON conversation_history
    FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own conversation history" ON conversation_history
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Create trigger to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_conversation_history_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_conversation_history_updated_at
    BEFORE UPDATE ON conversation_history
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_history_updated_at();

-- Create a view for conversation sessions (optional but useful)
CREATE OR REPLACE VIEW conversation_sessions AS
SELECT
    session_id,
    user_id,
    MIN(created_at) as session_start,
    MAX(created_at) as session_end,
    COUNT(*) as message_count,
    SUM(tokens_used) as total_tokens,
    ARRAY_AGG(message_type ORDER BY created_at) as message_types
FROM conversation_history
WHERE user_id IS NOT NULL
GROUP BY session_id, user_id
ORDER BY session_start DESC;

-- Grant permissions on the view
GRANT SELECT ON conversation_sessions TO authenticated;
GRANT SELECT ON conversation_sessions TO service_role;
