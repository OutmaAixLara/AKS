import redis
from http.server import HTTPServer, BaseHTTPRequestHandler

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def _send_response(self, message, status_code):
        self.send_response(status_code)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(message.encode())

    def do_GET(self):
        if self.path == '/':
            self._send_response("Hello, Aachen!", 200)
        elif self.path == '/version':
            self._send_response("Version : 1.0.0.1", 200)
        elif self.path == '/healthz':
            try:
                r = redis.Redis(host='localhost', port=6379, socket_connect_timeout=1)
                r.ping()
                self._send_response("OK", 200)
            except Exception as e:
                self._send_response("Error: Could not connect to Redis", 500)

httpd = HTTPServer(('0.0.0.0', 8000), SimpleHTTPRequestHandler)
print("Server started at http://localhost:8000")
httpd.serve_forever()
