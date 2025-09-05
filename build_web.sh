#!/bin/bash
echo "Building Flutter web app for Render deployment..."
echo "Current directory: $(pwd)"

# Build Flutter web app
echo "Running flutter build web --release..."
flutter build web --release

# Check if build was successful
if [ $? -ne 0 ]; then
    echo "❌ Flutter build failed!"
    exit 1
fi

echo "✅ Flutter build completed successfully"

# Remove sensitive files from build
echo "Removing sensitive files from build..."
rm -f build/web/assets/.env
rm -f build/web/assets/env
rm -f build/web/assets/*.env

# Create basic Render configuration files if they don't exist
echo "Creating Render configuration files..."

# Create _headers file for proper routing
cat > build/web/_headers << 'EOF'
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin

# Cache static assets
/*.js
  Cache-Control: public, max-age=31536000, immutable

/*.css
  Cache-Control: public, max-age=31536000, immutable

/*.png
  Cache-Control: public, max-age=31536000, immutable

/*.jpg
  Cache-Control: public, max-age=31536000, immutable

/*.svg
  Cache-Control: public, max-age=31536000, immutable

/*.ico
  Cache-Control: public, max-age=31536000, immutable
EOF

# Create _redirects file for SPA routing
cat > build/web/_redirects << 'EOF'
/*    /index.html   200
EOF

echo "✅ Build complete and configured for Render!"
echo "Built files are in: build/web/"
echo ""
echo "To deploy to Render:"
echo "1. Push this build to your repository"
echo "2. Configure Render to serve static files from build/web/"
echo "3. Or use Render's static site deployment with the build/web directory"
