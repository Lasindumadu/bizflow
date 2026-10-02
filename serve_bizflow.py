
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from functools import partial

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header(
            'Cross-Origin-Opener-Policy',
            'same-origin',
        )
        self.send_header(
            'Cross-Origin-Embedder-Policy',
            'require-corp',
        )
        self.send_header(
            'Cross-Origin-Resource-Policy',
            'same-origin',
        )
        super().end_headers()

server = ThreadingHTTPServer(
    ('localhost', 8080),
    partial(Handler, directory='build/web'),
)

print('BizFlow production server: http://localhost:8080')
server.serve_forever()

