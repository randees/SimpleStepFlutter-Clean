const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// API endpoint to provide environment variables to Flutter web
app.get('/api/config', (req, res) => {
  // Only provide non-sensitive configuration or properly managed secrets
  const config = {
    supabaseUrl: process.env.SUPABASE_URL || '',
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY || '',
    environment: process.env.FLUTTER_ENV || 'production',
    debugMode: process.env.DEBUG_MODE === 'true',
    // Note: Never expose service role keys or OpenAI keys to client!
    // These should only be used server-side
  };
  
  res.json(config);
});

// Serve static files with correct MIME types
app.use(express.static(path.join(__dirname, 'build/web'), {
  setHeaders: (res, filePath) => {
    if (filePath.endsWith('.js')) {
      res.setHeader('Content-Type', 'application/javascript');
    }
    if (filePath.endsWith('.css')) {
      res.setHeader('Content-Type', 'text/css');
    }
    if (filePath.endsWith('.wasm')) {
      res.setHeader('Content-Type', 'application/wasm');
    }
  }
}));

// SPA fallback
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web/index.html'));
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
  console.log('Environment variables loaded:');
  console.log('- SUPABASE_URL:', process.env.SUPABASE_URL ? 'Set' : 'Not set');
  console.log('- SUPABASE_ANON_KEY:', process.env.SUPABASE_ANON_KEY ? 'Set' : 'Not set');
  console.log('- FLUTTER_ENV:', process.env.FLUTTER_ENV || 'production');
});
