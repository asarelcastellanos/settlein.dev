#!/usr/bin/env python3
import http.server
import os
import re
import sys
from urllib.parse import parse_qs, urlparse

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build")
FILES = {
    "/SettleIn.dmg": ("SettleIn.dmg", "application/x-apple-diskimage"),
}
EXAMPLE_APPS = "iterm2,rectangle,obsidian"
VALID = re.compile(r"[a-z0-9-]+(,[a-z0-9-]+)*")


def clean(query):
    values = parse_qs(query).get("apps")
    if values and VALID.fullmatch(values[0]):
        return values[0]
    return None


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        apps = clean(url.query)
        if url.path == "/":
            if apps is None:
                body = (
                    "<!doctype html><title>SettleIn test download</title>"
                    "<h1>Choose a selection</h1>"
                    f'<p><a href="/?apps={EXAMPLE_APPS}">Example: {EXAMPLE_APPS}</a></p>'
                ).encode()
            else:
                body = (
                    "<!doctype html><title>SettleIn test download</title>"
                    f"<h1>Selection: {apps}</h1>"
                    f'<p><a href="/SettleIn.dmg?apps={apps}">Download disk image</a></p>'
                ).encode()
            self.send(200, "text/html; charset=utf-8", body)
            return
        if url.path in FILES:
            if apps is None:
                self.send(400, "text/plain", b"Missing or invalid apps\n")
                return
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
    print(f"Open http://localhost:{port}/?apps={EXAMPLE_APPS}")
    server.serve_forever()
