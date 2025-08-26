#!/bin/bash
echo "Building Flutter web app..."
flutter build web --release
echo "Removing sensitive files from build..."
rm -f build/web/assets/.env
echo "Adding Render configuration files..."
cp web_templates/_headers build/web/_headers
cp web_templates/_redirects build/web/_redirects
echo "Build complete and cleaned!"
