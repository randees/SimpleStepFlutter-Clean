const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Set proper MIME types
app.use(express.static('build/web', {
  setHeaders: (res, path) => {
    if (path.endsWith('.js')) {
      res.setHeader('Content-Type', 'application/javascript');
    } else if (path.endsWith('.css')) {
      res.setHeader('Content-Type', 'text/css');
    } else if (path.endsWith('.wasm')) {
      res.setHeader('Content-Type', 'application/wasm');
    } else if (path.endsWith('.json')) {
      res.setHeader('Content-Type', 'application/json');
    }
    
    // Security headers
    res.setHeader('X-Frame-Options', 'SAMEORIGIN');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    
    // Cache headers for static assets
    if (path.includes('/assets/') || path.endsWith('.js') || path.endsWith('.css')) {
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
});
