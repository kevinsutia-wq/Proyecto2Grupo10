Proyecto 2 grupo 10 - chatbot de mantencion y repuestos de vehiculos

Este proyecto es un chatbot que responde preguntas sobre mantencion y repuestos de vehiculos (sedan, suv y camion). Lo hicimos de dos formas, una con logica de primer orden en Prolog y otra con un LLM en Python. Ademas hicimos una pagina web simple para usar las dos versiones.

En la carpeta prolog esta el archivo chatbot.pl con los hechos, las reglas y el chatbot en Prolog. En la carpeta llm esta chatbot_llm.py, que es el chatbot con LLM, y el archivo conocimiento.txt tiene el mismo conocimiento pero escrito en frases para que lo lea el LLM. En la carpeta web esta la pagina (app.py e index.html).

Para usarlo se necesita Python 3 y SWI-Prolog. Python no necesita instalar nada mas. SWI-Prolog se instala con este comando:

sudo apt install swi-prolog

Para el LLM usamos Gemini, asi que hay que tener una clave de Google AI Studio (aistudio.google.com). Esa clave se pega entre las comillas en el archivo clave.sh. Ese archivo no se sube a git, y la clave nunca se debe escribir dentro del codigo. El modelo que se usa esta al comienzo de chatbot_llm.py, y si Google lo cambia hay que cambiar el nombre ahi.

Para abrir la pagina web, desde esta carpeta se escribe lo siguiente en la terminal:

source clave.sh
cd web
python3 app.py

Despues se abre http://localhost:8000 en el navegador, se elige Prolog o LLM en el menu, se escribe la pregunta y se aprieta Enviar.

Si solo se quiere probar Prolog en la terminal, se usa este comando y se escribe salir para terminar:

swipl -s prolog/chatbot.pl -g chatbot

Para revisar que el chatbot en Prolog sigue respondiendo bien estan las pruebas en prolog/pruebas.pl. Cada prueba muestra OK o FALLA. Se ejecutan con:

swipl -g probar -t halt prolog/pruebas.pl

Si se quiere cambiar el conocimiento, en Prolog se editan los hechos que estan al comienzo de chatbot.pl, y para el LLM se editan las frases de conocimiento.txt. Hay que cambiar los dos para que las dos versiones sepan lo mismo.
