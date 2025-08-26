const express = require('express');
const path = require('path');
const fs = require('fs');
const app = express();
const port = process.env.PORT || 3000;

// Find the build directory
let buildPath = 'build/web';
if (!fs.existsSync(buildPath)) {
  // Try alternative paths
  const alternatives = [
    '../build/web',
    '../../build/web',
    './build/web',
    '/opt/render/project/build/web'
  ];
  
  for (const alt of alternatives) {
    if (fs.existsSync(alt)) {
      buildPath = alt;
      break;
    }
  }
}

console.log(`Using build path: ${buildPath}`);
console.log(`Absolute build path: ${path.resolve(buildPath)}`);

// Set proper MIME types
app.use(express.static(buildPath, {
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
  const indexPath = path.join(buildPath, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(path.resolve(indexPath));
  } else {
    res.status(404).send('Flutter app not found. Build directory: ' + buildPath);
  }
});

app.listen(port, () => {
  console.log(`Flutter web app serving on port ${port}`);
  console.log(`Serving files from: ${path.resolve(buildPath)}`);
});
