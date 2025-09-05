# Render Deployment Guide - Prebuilt Flutter Web App

## Overview

This guide shows how to prebuild your Flutter web app locally and deploy it to Render. **Important**: For proper environment variable handling, you need to deploy as a **Web Service** (not Static Site) because Flutter web apps need runtime access to environment variables.

## Step 1: Prebuild the App Locally

Run the build script to create a production-ready build:

```bash
./build_web.sh
```

This will:

- Build your Flutter web app with `flutter build web --release`
- Remove sensitive environment files
- Create necessary Render configuration files (`_headers`, `_redirects`)
- Output everything to `build/web/`

## Step 2: Deploy to Render (Web Service Required)

### Web Service Deployment (Required for Environment Variables)

1. Go to Render Dashboard
   - Visit [Render Dashboard](https://dashboard.render.com)
   - Click "New" → "Web Service"

2. Connect Your Repository
   - Connect your GitHub/GitLab repository
   - Set the **Root Directory** to: `.` (project root)
   - Set the **Runtime** to: `Node`
   - Set the **Build Command** to:

     ```bash
     npm install
     ```

   - Set the **Start Command** to:

     ```bash
     node simple-server.js
     ```

3. Environment Variables
   Add these environment variables in Render's dashboard:
   - `SUPABASE_URL` - Your Supabase project URL
   - `SUPABASE_ANON_KEY` - Your Supabase anonymous key
   - `SUPABASE_SERVICE_ROLE_KEY` - Your Supabase service role key (for admin operations)
   - `OPENAI_API_KEY` - Your OpenAI API key
   - `MCP_ENDPOINT` - Your MCP endpoint URL
   - `MCP_SECRET` - Your MCP secret
   - `FLUTTER_ENV=production`
   - `DEBUG_MODE=false`

### Why Web Service (Not Static Site)?

Flutter web apps cannot directly access Render's runtime environment variables. The `simple-server.js` provides:

- Static file serving for your Flutter app
- `/api/config` endpoint that securely provides environment variables to your Flutter app at runtime
- Proper handling of sensitive data (API keys are never exposed to the client)

## Step 3: Verify Deployment

After deployment:

1. Check that your app loads correctly
2. Test the conversation service functionality
3. Monitor the browser console for the new production logging we added
4. Verify that conversations are being saved properly

## Troubleshooting

### Build Issues

- Make sure Flutter is properly installed: `flutter doctor`
- Check that all dependencies are available: `flutter pub get`
- Ensure you're in the project root directory

### Deployment Issues

- Verify the `build/web` directory exists and contains files
- Check that `_headers` and `_redirects` files are present
- Ensure no sensitive files are in the build directory

### Runtime Issues

- Check browser console for the detailed logging we added
- Verify API endpoints are accessible
- Confirm environment variables are set correctly

### Environment Variable Issues

- Make sure all required environment variables are set in Render
- Check server logs for "Config API request" messages
- Verify the `/api/config` endpoint returns the expected JSON

## Files Created by Build Script

The build script creates these files in `build/web/`:

- `index.html` - Main HTML file
- `main.dart.js` - Compiled Flutter app
- `flutter.js` - Flutter web runtime
- `assets/` - Static assets
- `_headers` - Render headers configuration
- `_redirects` - SPA routing configuration

## Notes

- The build includes all your recent changes including the production logging
- Sensitive files (`.env`, etc.) are automatically removed
- The app is optimized for production deployment
- All conversation service code is compiled and ready to run
- **Environment variables are provided at runtime via the `/api/config` endpoint**
