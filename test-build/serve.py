#!/usr/bin/env python3
import http.server
import os
import re
import sys
from urllib.parse import parse_qs, urlparse

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build")
FILES = {
    "/Settlein.dmg": ("Settlein.dmg", "application/x-apple-diskimage"),
    "/Settlein.zip": ("Settlein.zip", "application/zip"),
}
DEFAULT_APPS = "firefox,raycast,vlc"
VALID = re.compile(r"[a-z0-9-]+(,[a-z0-9-]+)*")


def clean(query):
    value = parse_qs(query).get("apps", [DEFAULT_APPS])[0]
    return value if VALID.fullmatch(value) else DEFAULT_APPS


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        apps = clean(url.query)
        if url.path == "/":
            body = (
                "<!doctype html><title>Settlein test download</title>"
                f"<h1>Selection: {apps}</h1>"
                f'<p><a href="/Settlein.dmg?apps={apps}">Download disk image</a></p>'
                f'<p><a href="/Settlein.zip?apps={apps}">Download zip</a></p>'
            ).encode()
            self.send(200, "text/html; charset=utf-8", body)
            return
        if url.path in FILES:
            name, mime = FILES[url.path]
            path = os.path.join(ROOT, name)
            if not os.path.isfile(path):
                self.send(404, "text/plain", b"Run test-build/build.sh first\n")
                return
            with open(path, "rb") as handle:
                body = handle.read()
            self.send(
                200,
                mime,
                body,
                {"Content-Disposition": f'attachment; filename="{name}"'},
            )
            return
        self.send(404, "text/plain", b"Not found\n")

    def send(self, status, mime, body, headers=None):
        self.send_response(status)
        self.send_header("Content-Type", mime)
        self.send_header("Content-Length", str(len(body)))
        for key, value in (headers or {}).items():
            self.send_header(key, value)
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    server = http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"Open http://localhost:{port}/?apps={DEFAULT_APPS}")
    server.serve_forever()
