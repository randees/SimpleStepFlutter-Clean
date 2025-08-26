#!/usr/bin/env python3
import http.server
import socketserver
import os
import mimetypes
from urllib.parse import unquote

# Set correct MIME types
mimetypes.add_type('application/javascript', '.js')
mimetypes.add_type('text/css', '.css')
mimetypes.add_type('application/wasm', '.wasm')

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='build/web', **kwargs)
    
    def end_headers(self):
        self.send_header('X-Frame-Options', 'SAMEORIGIN')
        self.send_header('X-Content-Type-Options', 'nosniff')
        super().end_headers()
    
    def do_GET(self):
        # Handle SPA routing - serve index.html for all routes that don't exist as files
        path = self.translate_path(self.path)
        if not os.path.exists(path) and not self.path.startswith('/assets'):
            self.path = '/index.html'
        
        return super().do_GET()

if __name__ == "__main__":
    PORT = int(os.environ.get('PORT', 8000))
    
    with socketserver.TCPServer(("", PORT), CustomHTTPRequestHandler) as httpd:
        print(f"Flutter web app serving on port {PORT}")
        print(f"Serving files from: {os.path.abspath('build/web')}")
        httpd.serve_forever()
