const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Set proper MIME types
app.use(express.static('build/web', {
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('.js')) {
      res.setHeader('Content-Type', 'application/javascript');
    } else if (filePath.endsWith('.css')) {
      res.setHeader('Content-Type', 'text/css');
    } else if (filePath.endsWith('.wasm')) {
      res.setHeader('Content-Type', 'application/wasm');
    } else if (filePath.endsWith('.json')) {
      res.setHeader('Content-Type', 'application/json');
    }
    
    // Security headers
    res.setHeader('X-Frame-Options', 'SAMEORIGIN');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    
    // Cache headers for static assets
    if (filePath.includes('/assets/') || filePath.endsWith('.js') || filePath.endsWith('.css')) {
      res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
    }
  }
}));

// Handle client-side routing (SPA)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

app.listen(port, () => {
  console.log(`Flutter web app serving on port ${port}`);
  console.log(`Serving files from: ${path.join(__dirname, 'build/web')}`);
});
