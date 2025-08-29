# 🚀 Web Deployment Guide for SimpleStep Flutter

## ✅ Build Complete!

Your production web build is ready for deployment. The optimized files are located in:
```
c:\Projects\SimpleStepFlutter\build\web\
```

## 📦 What's Included

The build directory contains all the files needed for deployment:
- `index.html` - Main HTML file
- `main.dart.js` - Compiled Flutter app (2.7MB optimized)
- `flutter.js` & `flutter_bootstrap.js` - Flutter framework
- `flutter_service_worker.js` - PWA service worker
- `assets/` - Images, fonts, and app assets
- `canvaskit/` - Flutter's rendering engine
- `icons/` - App icons for different devices
- `manifest.json` - PWA manifest
- `favicon.png` - Website icon

## 🔧 Deployment Instructions

### Option 1: Upload to Web Server
1. **Copy all files** from `build\web\` to your web server's public directory
2. **Ensure your web server** serves static files correctly
3. **Configure CORS** if needed for API calls to Supabase

### Option 2: Using FTP/SFTP
```bash
# Example with scp
scp -r build/web/* user@yourserver.com:/var/www/html/

# Example with rsync
rsync -av build/web/ user@yourserver.com:/var/www/html/
```

### Option 3: Using Git Deployment
```bash
# If you have a git-based deployment setup
git add build/web/
git commit -m "Deploy web build v$(date +%Y%m%d-%H%M%S)"
git push origin deploy-branch
```

## ⚙️ Server Configuration

### Apache (.htaccess)
Create this `.htaccess` file in your web root:
```apache
# Enable GZIP compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>

# Set proper MIME types
AddType application/javascript .js
AddType text/css .css

# Cache static assets
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType application/wasm "access plus 1 year"
</IfModule>

# Fallback to index.html for SPA routing
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
</IfModule>
```

### Nginx
Add this to your nginx server block:
```nginx
location / {
    try_files $uri $uri/ /index.html;
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|wasm)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # GZIP compression
    gzip on;
    gzip_types text/plain application/javascript text/css application/json;
}

# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

## 🌐 Features Included in This Build

✅ **SimpleStep Flutter App** with all current features:
- Step counting and health data tracking
- User personas (Alex, Morgan, Jordan)
- AI/MCP testing widget with **new custom prompt feature**
- Supabase backend integration
- OpenAI API integration
- Real-time step data visualization

✅ **New Custom AI Prompt Feature**:
- Editable system prompt text field
- Reset to default button
- "Ask AI Custom" button alongside standard "Ask AI"
- Support for user context variables

✅ **Production Optimizations**:
- Tree-shaken icons (99.4% size reduction)
- Minified and compressed JavaScript
- Optimized asset loading
- PWA capabilities (service worker included)

## 🔍 Testing Your Deployment

1. **Upload the files** to your web server
2. **Visit your domain** in a web browser
3. **Test the AI/MCP widget**:
   - Click the 📡 API icon in the top-right
   - Switch to "AI & MCP Testing Mode"
   - Try both "Ask AI" and "Ask AI Custom" buttons
4. **Verify Supabase connectivity** in the Database Testing mode

## 📊 Build Stats

- **Total build time**: ~25.5 seconds
- **Main app size**: 2.7MB (highly optimized)
- **Font optimization**: 99.4% reduction in icon fonts
- **Assets included**: All necessary files for standalone deployment

## 🚨 Important Notes

1. **API Keys**: Make sure your OpenAI API key and Supabase credentials are properly configured
2. **CORS**: Ensure your web server allows cross-origin requests to Supabase
3. **HTTPS**: Use HTTPS in production for security and PWA features
4. **Base Path**: If deploying to a subdirectory, rebuild with `--base-href=/your-path/`

## 🎯 Quick Deploy Command

If you need to rebuild and deploy again:
```bash
cd /c/Projects/SimpleStepFlutter
flutter build web --release
# Then copy build/web/* to your server
```

Your SimpleStep Flutter web app is now ready for production deployment! 🎉
