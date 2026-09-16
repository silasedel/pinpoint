#!/usr/bin/env python3
"""Tiny static server for Pinpoint that disables caching, so edits always show on reload.
Also accepts POST /_save?name=<file> (local dev only) so the page can write generated images into images/."""
import http.server, sys, os, re
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8791
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, must-revalidate')
        super().end_headers()
    def do_POST(self):
        m = re.match(r'/_save\?name=([A-Za-z0-9_.-]+)$', self.path)
        if not m or self.client_address[0] not in ('127.0.0.1', '::1'):
            self.send_response(403); self.end_headers(); return
        n = int(self.headers.get('Content-Length', 0)); data = self.rfile.read(n)
        os.makedirs('images', exist_ok=True)
        with open(os.path.join('images', m.group(1)), 'wb') as f: f.write(data)
        self.send_response(200); self.end_headers(); self.wfile.write(b'ok')
    def log_message(self, *a): pass
http.server.ThreadingHTTPServer(('', PORT), H).serve_forever()
