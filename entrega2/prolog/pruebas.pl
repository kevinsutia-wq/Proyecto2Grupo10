% pruebas del chatbot en prolog
% se ejecutan con: swipl -g probar -t halt prolog/pruebas.pl

:- encoding(utf8).    % para leer bien las tildes de las preguntas
:- ensure_loaded(chatbot).

% prueba(Pregunta, Respuesta que deberia dar el chatbot)
prueba("¿Cada cuántos km se cambia el aceite?", "aceite: cada 10000 km.").
prueba("¿A qué sistema pertenece la batería?", "bateria: sistema electrico.").
prueba("¿Qué repuestos necesita el cambio de aceite?", "cambio aceite: aceite, filtro aceite.").
prueba("¿Sirve la bujía para un camión?", "No, bujia no sirve para camion.").
prueba("¿Para qué vehículos sirve el disco de freno?", "disco freno: sedan, suv.").
prueba("¿Debo cambiar las bujías si tengo 35000 km?", "Si, cambialo (bujia: cada 30000 km).").
prueba("¿Debo cambiar el aceite si tengo 8000 km?", "No, faltan 2000 km (aceite: cada 10000 km).").
prueba("¿Qué repuestos necesita el cambio de freno en un camión?", "cambio freno (camion): balata freno, liquido freno.").
prueba("Mi auto tiene 65000 km, ¿ya hay que cambiar los amortiguadores?", "No, faltan 15000 km (amortiguador: cada 80000 km).").
prueba("¿Cada cuántos km se cambia el limpiaparabrisas?", "No entendi. Escribe \"ayuda\".").
prueba("Debo cambiar la correa con 60000 kilometros", "Si, cambialo (correa distribucion: cada 60000 km).").
prueba("¿Cada cuántos km se cambia el filtro?", "Hay mas de un filtro: filtro aceite, filtro aire. Cual de ellos?").
prueba("Cuantos km dura el filtro de aire y el aceite?", "filtro aire: cada 15000 km.").
prueba("Debo cambiar el aceite si tengo 8000km?", "No, faltan 2000 km (aceite: cada 10000 km).").
prueba("¿Debo cambiar la bujía de mi camión si tengo 35000 km?", "No aplica, bujia no sirve para camion.").
prueba("Tengo un sedan con 30000 km, que debo cambiar?", "Con 30000 km en sedan debes cambiar: bujia, pastilla freno, aceite, filtro aceite, filtro aire.").
prueba("Tengo 5000 km, qué cambio?", "Con esos km todavia no toca cambiar nada.").
prueba("¿Qué mantenciones usan el filtro de aceite?", "filtro aceite se usa en: cambio aceite.").
prueba("¿Qué vehículos hay?", "Vehiculos: sedan, suv, camion.").

% with_output_to guarda en un texto lo que escribe responder
respuesta(Pregunta, Respuesta) :-
    limpiar(Pregunta, Texto),
    with_output_to(string(Salida), responder(Texto)),
    string_concat(Respuesta, "\n", Salida).

probar :-
    forall(prueba(Pregunta, Esperada), revisar(Pregunta, Esperada)).

revisar(Pregunta, Esperada) :-
    respuesta(Pregunta, Esperada),
    !,
    format('OK    ~w~n', [Pregunta]).
revisar(Pregunta, Esperada) :-
    respuesta(Pregunta, Obtenida),
    format('FALLA ~w~n      esperada: ~w~n      obtenida: ~w~n', [Pregunta, Esperada, Obtenida]).
