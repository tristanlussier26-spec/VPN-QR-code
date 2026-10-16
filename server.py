#!/usr/bin/env python3
"""Petit serveur pour la page des cartes VPN.

Sert index.html et vendor/, et garde les cartes dans un fichier JSON :
  GET  /api/cards  -> liste des cartes
  PUT  /api/cards  -> remplace la liste (JSON)

Aucune dépendance : Python 3.8+ suffit.
Usage : python3 server.py [--port 8080] [--data ./data]
"""
import argparse
import json
import os
import tempfile
import threading
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.dirname(os.path.abspath(__file__))
MAX_BODY = 5 * 1024 * 1024  # 5 Mo, largement assez pour des centaines de cartes
lock = threading.Lock()


def make_handler(data_file):
    class Handler(SimpleHTTPRequestHandler):
        def __init__(self, *a, **kw):
            super().__init__(*a, directory=ROOT, **kw)

        # On ne sert que la page et ses librairies, jamais les cartes ni le code.
        def _allowed_static(self):
            p = self.path.split("?", 1)[0]
            return p in ("/", "/index.html") or p.startswith("/vendor/")

        def _json(self, code, obj):
            body = json.dumps(obj, ensure_ascii=False).encode("utf-8")
            self.send_response(code)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def end_headers(self):
            if not self.path.startswith("/api/"):
                self.send_header("Cache-Control", "no-cache")
            super().end_headers()

        def do_GET(self):
            if self.path.split("?", 1)[0] == "/api/cards":
                with lock:
                    try:
                        with open(data_file, encoding="utf-8") as f:
                            cards = json.load(f)
                    except FileNotFoundError:
                        cards = []
                return self._json(200, cards)
            if not self._allowed_static():
                return self.send_error(404)
            return super().do_GET()

        def do_HEAD(self):
            if not self._allowed_static():
                return self.send_error(404)
            return super().do_HEAD()

        def do_PUT(self):
            if self.path.split("?", 1)[0] != "/api/cards":
                return self.send_error(404)
            n = int(self.headers.get("Content-Length") or 0)
            if n <= 0 or n > MAX_BODY:
                return self._json(413, {"error": "taille invalide"})
            try:
                cards = json.loads(self.rfile.read(n).decode("utf-8"))
                assert isinstance(cards, list) and all(isinstance(c, dict) for c in cards)
            except Exception:
                return self._json(400, {"error": "JSON invalide"})
            with lock:
                fd, tmp = tempfile.mkstemp(dir=os.path.dirname(data_file), suffix=".tmp")
                with os.fdopen(fd, "w", encoding="utf-8") as f:
                    json.dump(cards, f, ensure_ascii=False, indent=1)
                os.chmod(tmp, 0o600)
                os.replace(tmp, data_file)
            return self._json(200, {"ok": True, "count": len(cards)})

        def log_message(self, fmt, *args):
            pass  # pas de journal des requêtes

    return Handler


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=int(os.environ.get("PORT", 8080)))
    ap.add_argument("--data", default=os.environ.get("DATA_DIR", os.path.join(ROOT, "data")))
    a = ap.parse_args()
    os.makedirs(a.data, exist_ok=True)
    os.chmod(a.data, 0o700)
    data_file = os.path.join(a.data, "cards.json")
    srv = ThreadingHTTPServer(("0.0.0.0", a.port), make_handler(data_file))
    print(f"Cartes VPN : http://0.0.0.0:{a.port}  (cartes dans {data_file})", flush=True)
    srv.serve_forever()


if __name__ == "__main__":
    main()
