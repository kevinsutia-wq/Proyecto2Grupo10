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
    except subprocess.TimeoutExpired:
        return "Error: Prolog se demoro demasiado."
    texto = resultado.stdout.decode("utf-8", errors="replace").strip()
    return texto or "Prolog no devolvio respuesta."


class Servidor(BaseHTTPRequestHandler):
    # mostrar la pagina cuando el navegador la pide
    def do_GET(self):
        # solo existe la pagina principal
        if self.path != "/":
            self.enviar_json({"respuesta": "Pagina no encontrada."}, 404)
            return
        with open(os.path.join(CARPETA, "index.html"), "rb") as archivo:
            pagina = archivo.read()
        self.enviar("text/html; charset=utf-8", pagina)

    # recibir la pregunta del usuario
    def do_POST(self):
        # si los datos llegan mal se avisa en vez de caerse
        try:
            largo = int(self.headers.get("Content-Length", 0))
            datos = json.loads(self.rfile.read(largo))
            pregunta = datos["pregunta"].strip()
            modo = datos["modo"]
        except Exception:
            self.enviar_json({"respuesta": "Error: la pregunta no llego bien."}, 400)
            return

        if pregunta == "":
            respuesta = "Escribe una pregunta."
        elif modo == "llm":
            respuesta = chatbot_llm.responder(pregunta)
        else:
            respuesta = responder_prolog(pregunta)

        self.enviar_json({"respuesta": respuesta})

    # pasar los datos a json y enviarlos
    def enviar_json(self, datos, codigo=200):
        cuerpo = json.dumps(datos).encode("utf-8")
        self.enviar("application/json", cuerpo, codigo)

    # enviar la respuesta al navegador
    def enviar(self, tipo, cuerpo, codigo=200):
        self.send_response(codigo)
        self.send_header("Content-Type", tipo)
        self.send_header("Content-Length", str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)


# arrancar el servidor
if __name__ == "__main__":
    print("Servidor en http://localhost:8000  (Ctrl+C para detener)")
    try:
        HTTPServer(("localhost", 8000), Servidor).serve_forever()
    except KeyboardInterrupt:
        print("Servidor detenido.")
