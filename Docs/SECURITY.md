# Security & Environment Configuration

## Protected Files

This project's `.gitignore` is configured to protect sensitive information from being accidentally committed to version control.

### Environment Files (NEVER commit these)
- `supabase/.env.local` - Contains actual API keys and secrets
- `supabase/.env` - Production environment variables
- `.env*` - Any environment files in root directory

### Supabase Security
- `supabase/.env.local` - Local development environment with:
  - SUPABASE_URL
  - SUPABASE_ANON_KEY
  - SUPABASE_SERVICE_ROLE_KEY
  - OPENAI_API_KEY
  - MCP_SERVER_SECRET
- `supabase/.temp/` - Temporary CLI files
- `supabase/logs/` - Log files that may contain sensitive data

### API Keys & Tokens
- Any files containing `*_secret*`, `*_token*`, `*_key*`
- `**/api_keys.json`
- `**/credentials.json`
- `openai_key.txt`
- Health Connect certificates and keystores

### Configuration Files
- `lib/config/supabase_config.dart` - Contains hardcoded API endpoints
- `lib/config/openai_config.dart.local` - Local OpenAI configuration
- Any `*_config.dart` files in test directories

## Environment Setup

### 1. Copy Template Files
```bash
cp supabase/.env.example supabase/.env.local
```

### 2. Fill in Your Actual Values
Edit `supabase/.env.local` with your real:
- Supabase project URL and keys
- OpenAI API key
- MCP server secret (generate a secure random string)

### 3. Never Commit Secrets
- Always use `.env.local` for local development
- Use environment variables in production
- Keep API keys in secure secret management systems

## Security Best Practices

### For Developers
1. **Never hardcode secrets** in source code
2. **Always use environment variables** for sensitive configuration
3. **Rotate API keys regularly**
4. **Use different keys** for development, staging, and production
5. **Review commits** before pushing to ensure no secrets are included

### For Production
1. **Use secure secret management** (e.g., Supabase Vault, AWS Secrets Manager)
2. **Enable row-level security (RLS)** on all Supabase tables
3. **Limit API key permissions** to minimum required scope
4. **Monitor API usage** for unusual patterns
5. **Use HTTPS** for all API communications

## Environment Variables Reference

### Required for MCP Server
```bash
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# OpenAI Configuration  
OPENAI_API_KEY=sk-your-openai-api-key

# MCP Security
MCP_SERVER_SECRET=your-secure-random-string
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

### Optional for Development
```bash
# Debug and logging
DEBUG=true
LOG_LEVEL=debug

# Local development overrides
LOCAL_SUPABASE_URL=http://localhost:54321
```

## Checking Security

To verify your security setup:

```bash
# Check what files are being ignored
git status --ignored

# Verify no secrets in git history
git log --all --full-history -- "**/.env*"

# Check for potential secrets in code
grep -r "sk-" lib/ || echo "No OpenAI keys found in code"
grep -r "supabase.*key" lib/ || echo "No hardcoded Supabase keys"
```

## Emergency: If Secrets Are Committed

If you accidentally commit secrets:

1. **Immediately rotate all affected keys**
2. **Remove from git history**: `git filter-branch` or BFG Repo-Cleaner
3. **Force push** the cleaned history
4. **Update all environments** with new keys
5. **Review access logs** for unauthorized usage

---

⚠️ **Remember**: Security is everyone's responsibility. When in doubt, ask for a security review!
