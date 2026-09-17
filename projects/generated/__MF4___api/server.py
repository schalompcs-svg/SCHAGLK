from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class Handler(BaseHTTPRequestHandler):
    def send_json(self, data):
        body=json.dumps(data).encode()
        self.send_response(200)
        self.send_header("Content-Type","application/json")
        self.send_header("Content-Length",str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        self.send_json({
            "app":"SCHAGLK API",
            "status":"ok",
            "route":self.path
        })

HTTPServer(("127.0.0.1", 8765), Handler).serve_forever()
