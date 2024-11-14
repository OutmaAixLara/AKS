from flask import Flask, request
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello_world():
    hostname = socket.gethostname()
    client_ip = request.remote_addr

    return f"""
    <html>
        <body>
            <h1>Hello!</h1>
            <p>Hostname: {hostname}</p>
            <p>Client IP: {client_ip}</p>
            <p>This is part of the AKS tests project.</p>
        </body>
    </html>
    """

if __name__ == "__main__":
    # Start the Flask app on port 5000
    app.run(host='0.0.0.0', port=5000)
