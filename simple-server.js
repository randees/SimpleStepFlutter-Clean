const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// API endpoint to provide environment variables to Flutter web
app.get('/api/config', (req, res) => {
  // Only provide configuration that's safe for client-side use
  const config = {
    supabaseUrl: process.env.SUPABASE_URL || '',
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY || '',
    openaiApiKey: process.env.OPENAI_API_KEY || '', // OpenAI key for client-side AI features
    mcpEndpoint: process.env.MCP_ENDPOINT || '',
    mcpSecret: process.env.MCP_SECRET || '',
    environment: process.env.FLUTTER_ENV || 'production',
    debugMode: process.env.DEBUG_MODE === 'true',
    // Note: Never expose service role keys to client - those stay server-side only
  };
  
  console.log('📋 Config request - providing client configuration:');
  console.log('- supabaseUrl:', config.supabaseUrl ? 'Set' : 'Not set');
  console.log('- supabaseAnonKey:', config.supabaseAnonKey ? 'Set' : 'Not set');  
  console.log('- openaiApiKey:', config.openaiApiKey ? `Set (${config.openaiApiKey.length} chars)` : 'Not set');
  console.log('- mcpEndpoint:', config.mcpEndpoint ? 'Set' : 'Not set');
  console.log('- mcpSecret:', config.mcpSecret ? 'Set' : 'Not set');
  console.log('- environment:', config.environment);
  console.log('- debugMode:', config.debugMode);
  
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
