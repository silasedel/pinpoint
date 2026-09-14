#!/usr/bin/env python3
"""Tiny static server for Pinpoint that disables caching, so edits always show on reload."""
import http.server, sys
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8791
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, must-revalidate')
        super().end_headers()
    def log_message(self, *a): pass
pass
http.server.ThreadingHTTPServer(('', PORT), H).serve_forever()
