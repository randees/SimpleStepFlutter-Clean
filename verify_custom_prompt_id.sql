-- SQL Query to verify custom AI prompt ID is being captured
-- Run this in Supabase SQL editor to check recent conversation records

SELECT 
  id,
  user_id,
  session_id,
  custom_ai_prompt_id,
  message_content,
  message_type,
  created_at
FROM conversation_history 
WHERE created_at >= NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC
LIMIT 20;

-- Additional query to check custom prompts being referenced
SELECT 
  ch.id as conversation_id,
  ch.message_content,
  ch.message_type,
  ch.custom_ai_prompt_id,
  cap.prompt_name,
  cap.prompt_text,
  ch.created_at
FROM conversation_history ch
LEFT JOIN custom_ai_prompts cap ON ch.custom_ai_prompt_id = cap.id
WHERE ch.created_at >= NOW() - INTERVAL '1 hour'
ORDER BY ch.created_at DESC
LIMIT 10;
