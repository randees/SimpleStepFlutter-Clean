# Secure Deployment Guide

## ⚠️ SECURITY WARNING ⚠️

**NEVER commit API keys, secrets, or credentials to your repository!**

This project has been configured to handle environment variables securely:

## Local Development

1. Create a `.env` file in the project root (already in .gitignore):
```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# OpenAI Configuration  
OPENAI_API_KEY=your_openai_api_key

# Environment Settings
FLUTTER_ENV=development
DEBUG_MODE=true

# MCP Configuration (if using)
MCP_ENDPOINT=your_mcp_endpoint
MCP_SECRET=your_mcp_secret
```

2. The Flutter app will automatically load these variables through `flutter_dotenv`

## Web Deployment (Render)

### Setting Environment Variables in Render

1. Go to your Render dashboard
2. Select your web service
3. Go to **Environment** tab
4. Add the following environment variables:

```
SUPABASE_URL = your_supabase_project_url
SUPABASE_ANON_KEY = your_supabase_anon_key  
FLUTTER_ENV = production
DEBUG_MODE = false
```

### Important Security Notes

- **Never expose** `SUPABASE_SERVICE_ROLE_KEY` to the web client
- **Never expose** `OPENAI_API_KEY` to the web client
- These should only be used server-side in your Node.js backend

### How It Works

1. **Server (simple-server.js)**:
   - Reads environment variables from Render
   - Exposes safe variables via `/api/config` endpoint
   - Never exposes sensitive keys like service role or OpenAI keys

2. **Flutter Web Client**:
   - Fetches configuration from `/api/config` on startup
   - Only receives public/anon keys safe for client-side use
   - Falls back gracefully if config can't be loaded

## Deployment Steps

1. **Commit your code** (without secrets):
```bash
git add .
git commit -m "feat: secure environment variable handling for web deployment"
git push origin main
```

2. **Set environment variables in Render**:
   - Add `SUPABASE_URL`
   - Add `SUPABASE_ANON_KEY`
   - Add `FLUTTER_ENV=production`

3. **Deploy**:
   - Render will automatically redeploy when you push
   - Check logs to ensure environment variables are loaded

## Verification

After deployment, check your app's console logs:
- Should see "✅ Web configuration loaded successfully from server"
- Should see "Using Supabase URL: https://your-project.supabase.co"
- Should NOT see any raw API keys in console

## Troubleshooting

### App shows "Supabase client not initialized"
1. Check Render environment variables are set correctly
2. Check server logs for config loading errors
3. Verify `/api/config` endpoint returns expected data

### Environment variables not loading
1. Ensure variables are set in Render dashboard
2. Check server startup logs for environment status
3. Restart the Render service to reload variables

## Security Checklist

- [ ] `.env` file is in `.gitignore`
- [ ] No API keys committed to repository
- [ ] Service role keys never exposed to client
- [ ] OpenAI keys never exposed to client
- [ ] Environment variables set in Render
- [ ] Console logs don't show raw secrets
