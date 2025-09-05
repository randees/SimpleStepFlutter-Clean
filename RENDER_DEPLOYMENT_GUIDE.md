# Render Deployment Guide - Prebuilt Flutter Web App

## Overview

This guide shows how to prebuild your Flutter web app locally and deploy it to Render as a static site.

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

## Step 2: Deploy to Render

### Option A: Static Site Deployment (Recommended)

1. Go to Render Dashboard
   - Visit [Render Dashboard](https://dashboard.render.com)
   - Click "New" → "Static Site"

2. Connect Your Repository
   - Connect your GitHub/GitLab repository
   - Set the **Root Directory** to: `build/web`
   - Set the **Build Command** to: (leave empty)
   - Set the **Publish Directory** to: `.` (current directory)

3. Environment Variables
   Add any necessary environment variables in Render's dashboard:
   - `FLUTTER_ENV=production`
   - Any API keys your app needs (if not using the server proxy)

### Option B: Web Service with Prebuilt Files

If you prefer to use a web service instead:

1. Update render.yaml (if using YAML config):

   ```yaml
   services:
     - type: web
       name: simple-step-flutter
       env: static-site
       buildCommand: ""  # No build needed
       staticSitePath: build/web
       startCommand: ""  # Static files don't need a start command
   ```

2. Deploy
   - Push the prebuilt `build/web` directory to your repository
   - Render will serve the static files directly

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
