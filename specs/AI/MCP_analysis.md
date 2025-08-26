# High Level Objective
 
 - Add a ReAct interface to the "AI & MCP Testing Mode" Widget

## Basic Implementation

- This should use The OpenAI with the provided key to interface with the user.
- The AI should use our Supabase Edge Functions to interface with our database to retrieve health information about the users
- The AI should keep the responses to 1000 characters and use a maximum of 5 tries to formulate any single response


## UX/UI

### features
- dropdown that lists each user in the database so that I can choose a user to be the context for the questions
- text area so that the user can submit a question to the AI with a standard submit type interface
- colapseable area that displays the history of questions and responses for this conversation
- A way to reset the conversation so that we can test from the start of a new converstation.

## Notes

- Make sure to follow recomendations for tests and documentation