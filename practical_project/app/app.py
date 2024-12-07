import sqlite3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os

DATABASE_NAME = "app.db"

def check_db_health():
    try:
        conn = sqlite3.connect(DATABASE_NAME)
        conn.close()
        return True
    except sqlite3.Error as e:
        return False


class HTTPRequestHandler(BaseHTTPRequestHandler):
    def _respond(self, status_code, response):
        """Helper method to send JSON responses."""
        self.send_response(status_code)
        self.send_header("Content-type", 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response).encode("utf-8"))

    def do_GET(self):  
        """Handle GET requests."""
        if self.path == "/":
            self._respond(200, {"message": "Hello World!"})

        elif self.path == "/version":
            self._respond(200, {"Version": "1.0.0"})

        elif self.path == "/healthz":
            if check_db_health():
                self._respond(200, {"status": "OK", "message": "Database is healthy!"})
            else:
                self._respond(500, {"status": "FAIL", "message": "Database is unhealthy!"})

        elif self.path == "/create-db":
            if not os.path.exists(DATABASE_NAME):
                    conn = sqlite3.connect(DATABASE_NAME)
                    cursor = conn.cursor()
                    cursor.execute("CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT)")
                    cursor.execute("INSERT INTO test (name) VALUES ('Example')")
                    conn.commit()
                    conn.close()
                    self._respond(200, {"message": f"Database '{DATABASE_NAME}' created successfully!"})
            else:
                self._respond(200, {"message": f"Database '{DATABASE_NAME}' already exists!"})

        else:
            self._respond(404, {"message": "Not Found!"})


def run_server():
    """Start the HTTP server."""
    server_address = ("", 8000)
    httpd = HTTPServer(server_address, HTTPRequestHandler)
    print("Server running on port 8000...")
    httpd.serve_forever()

if __name__ == "__main__":
    run_server()
