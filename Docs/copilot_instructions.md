# Copilot Instructions for SimpleStepFlutter-Clean

## Required Rules

- **Documentation**: All documents created should go into the `/docs` folder
- **Critical Thinking**: Be critical of questions I ask - if I'm not correct, give me better options
- **Security**: NEVER put any API keys or secrets into code - those should always be imported by environment variables

## Project-Specific Guidelines

### Code Organization
- Follow the established directory structure: `/lib`, `/tests`, `/docs`, `/supabase`
- Use meaningful file and directory names (lowercase with underscores/hyphens)
- Keep the root directory clean with only essential configuration files

### Flutter Development
- Use proper error handling and logging (currently using print statements for debugging)
- Follow Flutter/Dart naming conventions (camelCase for variables, PascalCase for classes)
- Implement proper state management patterns

### Security Best Practices
- Environment variables should be loaded via `EnvConfig` class
- API calls should use the security services (`OpenAISecurity`, `RateLimiter`)
- Never expose service role keys to client-side code

### Testing
- Place all tests in `/tests` directory
- Integration tests go in `/tests/integration`
- Test fixtures in `/tests/fixtures`

### Documentation
- Update relevant documentation when making significant changes
- Keep deployment and setup guides current
- Document API changes and new features

## Current Tech Stack

- **Frontend**: Flutter Web/Mobile
- **Backend**: Supabase (database), Node.js (simple-server.js)
- **AI Integration**: OpenAI GPT-3.5-turbo with ReAct pattern
- **Security**: Rate limiting, input sanitization, environment variable management
- **Deployment**: Render (web hosting)

## Development Priorities

1. Security and environment variable management
2. Clean, maintainable code organization  
3. Proper error handling and user feedback
4. Comprehensive testing coverage
5. Clear documentation and setup instructions
