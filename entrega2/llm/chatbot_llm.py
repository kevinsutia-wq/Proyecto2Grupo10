# chatbot que usa un llm
# leer el archivo conocimiento y darselo al llm junto con la pregunta

import json
import os
import urllib.error
import urllib.request

# datos del llm que usamos
URL = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
MODELO = "gemini-flash-lite-latest"
CLAVE = os.environ.get("LLM_API_KEY", "")  # la clave esta en el archivo clave

# ruta del archivo con el conocimiento
CARPETA = os.path.dirname(os.path.abspath(__file__))
ARCHIVO = os.path.join(CARPETA, "..", "conocimiento.txt")


def responder(pregunta):
    # sin clave el llm no responde
    if CLAVE == "":
        return "Error: falta la clave del LLM, hay que hacer source clave.sh antes."

    # leer el conocimiento (with cierra el archivo solo)
    with open(ARCHIVO, encoding="utf-8") as archivo:
        conocimiento = archivo.read()

    # instrucciones para el llm
    instrucciones = (
        "Eres un asistente sobre mantencion y repuestos de vehiculos. "
        "Responde en espanol, de forma breve, usando SOLO la informacion de abajo. "
        "Si la respuesta no esta en la informacion, responde: 'No tengo esa informacion.'\n\n"
        + conocimiento
    )

    # datos que enviamos al llm
    datos = {
        "model": MODELO,
        "temperature": 0,  # con cero las respuestas casi no cambian
        "messages": [
            {"role": "system", "content": instrucciones},
            {"role": "user", "content": pregunta},
        ],
    }
    cabeceras = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + CLAVE,
    }

    # enviar y leer la respuesta
    peticion = urllib.request.Request(
        URL, data=json.dumps(datos).encode("utf-8"), headers=cabeceras
    )
    try:
        respuesta = urllib.request.urlopen(peticion, timeout=60)
        resultado = json.loads(respuesta.read().decode("utf-8"))
        return resultado["choices"][0]["message"]["content"].strip()
    except urllib.error.HTTPError as error:
        # el codigo dice que paso, por ejemplo 429 es que hicimos muchas peticiones
        return "Error del LLM, codigo " + str(error.code) + ": " + str(error.reason)
    except Exception as error:
        return "Error al llamar al LLM: " + str(error)


# probar el chatbot en la terminal
if __name__ == "__main__":
    print('Chatbot LLM. Escribe "salir" para terminar.')
    while True:
        try:
            texto = input("> ")
        except EOFError:  # si se aprieta ctrl+d
            break
        if texto.strip().lower() == "salir":
            break
        print(responder(texto))
