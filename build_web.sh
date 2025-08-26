#!/bin/bash
echo "Building Flutter web app..."
flutter build web --release
echo "Removing sensitive files from build..."
rm -f build/web/assets/.env
echo "Build complete and cleaned!"
