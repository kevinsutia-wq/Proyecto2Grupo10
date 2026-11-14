# servidor de la pagina web

import json
import os
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

CARPETA = os.path.dirname(os.path.abspath(__file__))
ARCHIVO_PROLOG = os.path.join(CARPETA, "..", "prolog", "chatbot.pl")

# para usar el chatbot con llm
sys.path.append(os.path.join(CARPETA, "..", "llm"))
import chatbot_llm


def responder_prolog(pregunta):
    # llamar a swipl con la pregunta
    comando = ["swipl", "-q", "-s", ARCHIVO_PROLOG, "-g", "responder_una", "-t", "halt", "--", pregunta]
    try:
        resultado = subprocess.run(comando, capture_output=True, timeout=20)
    except FileNotFoundError:
        return "Error: no esta instalado swipl (SWI-Prolog)."
    texto = resultado.stdout.decode("utf-8", errors="replace").strip()
    return texto or "Prolog no devolvio respuesta."


class Servidor(BaseHTTPRequestHandler):
    # mostrar la pagina cuando el navegador la pide
    def do_GET(self):
        pagina = open(os.path.join(CARPETA, "index.html"), "rb").read()
        self.enviar("text/html; charset=utf-8", pagina)

    # recibir la pregunta del usuario
    def do_POST(self):
        largo = int(self.headers.get("Content-Length", 0))
        datos = json.loads(self.rfile.read(largo))
        pregunta = datos["pregunta"].strip()
        modo = datos["modo"]

        if pregunta == "":
            respuesta = "Escribe una pregunta."
        elif modo == "llm":
            respuesta = chatbot_llm.responder(pregunta)
        else:
            respuesta = responder_prolog(pregunta)

        cuerpo = json.dumps({"respuesta": respuesta}).encode("utf-8")
        self.enviar("application/json", cuerpo)

    # enviar la respuesta al navegador
    def enviar(self, tipo, cuerpo):
        self.send_response(200)
        self.send_header("Content-Type", tipo)
        self.send_header("Content-Length", str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)


# arrancar el servidor
if __name__ == "__main__":
    print("Servidor en http://localhost:8000  (Ctrl+C para detener)")
    HTTPServer(("localhost", 8000), Servidor).serve_forever()
