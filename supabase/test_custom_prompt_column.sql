-- Test script to verify the new custom_ai_prompt_id column works correctly
-- This can be run manually in the Supabase SQL editor

-- Test 1: Check that the column exists and has the correct structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'conversation_history' 
    AND column_name = 'custom_ai_prompt_id';

-- Test 2: Check that the foreign key constraint exists
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'conversation_history'
    AND kcu.column_name = 'custom_ai_prompt_id';

-- Test 3: Check that the index exists
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'conversation_history' 
    AND indexname = 'idx_conversation_history_custom_prompt_id';

-- Test 4: Insert a test conversation message with a custom prompt ID
-- (Assumes there's at least one user and one custom prompt in the database)
-- This will only run if test data exists
DO $$
DECLARE
    test_user_id UUID;
    test_prompt_id UUID;
BEGIN
    -- Get first user ID
    SELECT id INTO test_user_id FROM users LIMIT 1;
    
    -- Get first custom prompt ID
    SELECT id INTO test_prompt_id FROM custom_ai_prompts LIMIT 1;
    
    -- Only proceed if we have test data
    IF test_user_id IS NOT NULL AND test_prompt_id IS NOT NULL THEN
        -- Insert test conversation message
        INSERT INTO conversation_history (
            user_id,
            session_id,
            message_content,
            message_type,
            message_role,
            model_used,
            custom_ai_prompt_id
        ) VALUES (
            test_user_id,
            gen_random_uuid(),
            'This is a test message with custom prompt tracking',
            'assistant',
            'assistant',
            'gpt-3.5-turbo',
            test_prompt_id
        );
        
        RAISE NOTICE 'Successfully inserted test conversation message with custom_ai_prompt_id';
    ELSE
        RAISE NOTICE 'Skipping test insert - no test data available (users: %, prompts: %)', 
            CASE WHEN test_user_id IS NULL THEN 'none' ELSE 'found' END,
            CASE WHEN test_prompt_id IS NULL THEN 'none' ELSE 'found' END;
    END IF;
END $$;

-- Test 5: Query conversations with custom prompt information
SELECT 
    ch.id,
    ch.message_content,
    ch.message_type,
    ch.custom_ai_prompt_id,
    cap.prompt_name,
    pt.key_name as prompt_type_name,
    ch.created_at
FROM conversation_history ch
LEFT JOIN custom_ai_prompts cap ON ch.custom_ai_prompt_id = cap.id
LEFT JOIN prompt_type pt ON cap.prompt_type_id = pt.id
ORDER BY ch.created_at DESC
LIMIT 5;
