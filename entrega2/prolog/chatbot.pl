

vehiculo(sedan).
vehiculo(suv).
vehiculo(camion).

sistema(motor).
sistema(frenos).
sistema(electrico).
sistema(suspension).
sistema(ruedas).
sistema(refrigeracion).

pertenece(aceite, motor).
pertenece(filtro_aceite, motor).
pertenece(filtro_aire, motor).
pertenece(bujia, motor).
pertenece(correa_distribucion, motor).
pertenece(pastilla_freno, frenos).
pertenece(disco_freno, frenos).
pertenece(balata_freno, frenos).
pertenece(liquido_freno, frenos).
pertenece(bateria, electrico).
pertenece(amortiguador, suspension).
pertenece(neumatico, ruedas).
pertenece(refrigerante, refrigeracion).

cambio_km(aceite, 10000).
cambio_km(filtro_aceite, 10000).
cambio_km(filtro_aire, 15000).
cambio_km(bujia, 30000).
cambio_km(correa_distribucion, 60000).
cambio_km(pastilla_freno, 30000).
cambio_km(disco_freno, 60000).
cambio_km(balata_freno, 40000).
cambio_km(liquido_freno, 40000).
cambio_km(bateria, 50000).
cambio_km(amortiguador, 80000).
cambio_km(neumatico, 50000).
cambio_km(refrigerante, 40000).

necesita(cambio_aceite, aceite).
necesita(cambio_aceite, filtro_aceite).
necesita(afinamiento, bujia).
necesita(afinamiento, filtro_aire).
necesita(cambio_freno, pastilla_freno).
necesita(cambio_freno, disco_freno).
necesita(cambio_freno, balata_freno).
necesita(cambio_freno, liquido_freno).
necesita(cambio_correa, correa_distribucion).
necesita(revision_bateria, bateria).
necesita(cambio_amortiguador, amortiguador).
necesita(cambio_neumatico, neumatico).
necesita(cambio_refrigerante, refrigerante).

para_todos(aceite).
para_todos(filtro_aceite).
para_todos(filtro_aire).
para_todos(correa_distribucion).
para_todos(liquido_freno).
para_todos(bateria).
para_todos(amortiguador).
para_todos(neumatico).
para_todos(refrigerante).

compatible(bujia, sedan).
compatible(bujia, suv).
compatible(pastilla_freno, sedan).
compatible(pastilla_freno, suv).
compatible(disco_freno, sedan).
compatible(disco_freno, suv).
compatible(balata_freno, camion).

compatible(R, V) :-
    para_todos(R),
    vehiculo(V).

% parte dos reglas

% reglas que necesitan buscar repuesto y buscar mantencion
repuesto(R) :- pertenece(R, _).
mantencion(M) :- necesita(M, _).

debe_cambiar(R, Km) :-
    cambio_km(R, Limite),
    Km >= Limite.

repuesto_mantencion(M, V, R) :-
    necesita(M, R),
    compatible(R, V).

% un repuesto se cambia en un vehiculo solo si ese repuesto sirve para el vehiculo
debe_cambiar_en(R, V, Km) :-
    compatible(R, V),
    debe_cambiar(R, Km).

% parte tres chatbot que conversa

% palabras cortas que la gente usa para nombrar un repuesto
alias(correa, correa_distribucion).
alias(pastilla, pastilla_freno).
alias(disco, disco_freno).
alias(balata, balata_freno).
alias(llanta, neumatico).
alias(anticongelante, refrigerante).

% palabras que pueden ser mas de un repuesto
ambiguo(filtro, [filtro_aceite, filtro_aire]).

chatbot :-
    writeln('Chatbot de repuestos. Escribe "ayuda" o "salir".'),
    ciclo.

ciclo :-
    write('> '),
    read_line_to_string(user_input, Entrada),
    procesar(Entrada).

procesar(end_of_file) :-
    !,
    writeln('Chao!').
procesar(Entrada) :-
    limpiar(Entrada, Texto),
    (   contiene(Texto, "salir")
    ->  writeln('Chao!')
    ;   responder(Texto),
        ciclo
    ).

limpiar(Entrada, Texto) :-
    string_lower(Entrada, Minusculas),
    string_codes(Minusculas, Codigos),
    maplist(sin_tilde, Codigos, SinTilde),
    exclude(=(46), SinTilde, SinPuntos),    % el codigo 46 es el punto y asi doce mil se lee sin punto
    string_codes(Texto, SinPuntos).

sin_tilde(225, 97) :- !.    % a con tilde
sin_tilde(233, 101) :- !.   % e con tilde
sin_tilde(237, 105) :- !.   % i con tilde
sin_tilde(243, 111) :- !.   % o con tilde
sin_tilde(250, 117) :- !.   % u con tilde
sin_tilde(252, 117) :- !.   % u con dieresis
sin_tilde(241, 110) :- !.   % enie
sin_tilde(191, 32) :- !.    % signo de pregunta al reves se cambia por espacio
sin_tilde(161, 32) :- !.    % signo de exclamacion al reves se cambia por espacio
sin_tilde(C, C).

contiene(Texto, Frase) :-
    sub_string(Texto, _, _, _, Frase).

contiene_alguna(Texto, Frases) :-
    member(F, Frases),
    contiene(Texto, F),
    !.

% separar el texto en palabras y quitar las palabras de relleno
palabras(Texto, Palabras) :-
    split_string(Texto, " ,;:?!", " ,;:?!", Todas),
    exclude(sin_valor, Todas, Palabras).

sin_valor("").
sin_valor("de").
sin_valor("del").
sin_valor("el").
sin_valor("la").
sin_valor("los").
sin_valor("las").

% una palabra es igual a una parte del nombre, tambien en plural (bujias = bujia)
misma_palabra(Palabra, Parte) :-
    atom_string(Parte, P),
    (   Palabra == P
    ;   string_concat(P, "s", Palabra)
    ;   string_concat(P, "es", Palabra)
    ),
    !.

% el texto menciona un atomo si sus partes aparecen seguidas (filtro de aire = filtro_aire)
menciona(Texto, Atomo) :-
    palabras(Texto, Palabras),
    atomic_list_concat(Partes, '_', Atomo),
    seguidas(Partes, Palabras).

% las partes estan al comienzo de la lista, o si no se sigue buscando en el resto
seguidas(Partes, Palabras) :-
    al_comienzo(Partes, Palabras),
    !.
seguidas(Partes, [_|Resto]) :-
    seguidas(Partes, Resto).

al_comienzo([], _).
al_comienzo([P|Partes], [W|Palabras]) :-
    misma_palabra(W, P),
    al_comienzo(Partes, Palabras).

% se busca el nombre mas largo y si no hay ninguno se busca un alias
buscar_repuesto(Texto, R) :-
    findall(L-X, (repuesto(X), menciona(Texto, X), atom_length(X, L)), Lista),
    Lista \= [],
    !,
    max_member(_-R, Lista).
buscar_repuesto(Texto, R) :-
    alias(Palabra, R),
    menciona(Texto, Palabra),
    !.

buscar_vehiculo(Texto, V) :-
    vehiculo(V),
    menciona(Texto, V),
    !.

buscar_sistema(Texto, S) :-
    sistema(S),
    contiene(Texto, S),
    !.

buscar_mantencion(Texto, M) :-
    mantencion(M),
    menciona(Texto, M),
    !.

% acepta "8000" y tambien "8000km" escrito junto
buscar_numero(Texto, N) :-
    palabras(Texto, Palabras),
    member(P, Palabras),
    (   number_string(N, P)
    ;   string_concat(Numero, "km", P),
        number_string(N, Numero)
    ),
    !.

bonito(Atomo, Texto) :-
    atomic_list_concat(Partes, '_', Atomo),
    atomic_list_concat(Partes, ' ', Texto).

lista_bonita(Atomos, Texto) :-
    maplist(bonito, Atomos, Bonitos),
    atomic_list_concat(Bonitos, ', ', Texto).

% cada regla de responder es un tipo de pregunta
% el orden importa: se usa la primera regla que sirve

% la palabra "filtro" sola no dice cual filtro es
responder(Texto) :-
    \+ buscar_repuesto(Texto, _),
    ambiguo(Palabra, Opciones),
    menciona(Texto, Palabra),
    !,
    lista_bonita(Opciones, NO),
    format('Hay mas de un ~w: ~w. Cual de ellos?~n', [Palabra, NO]).

% debo cambiar un repuesto con N km (revisa si sirve para el vehiculo)
responder(Texto) :-
    buscar_numero(Texto, Km),
    buscar_repuesto(Texto, R),
    cambio_km(R, Limite),
    !,
    bonito(R, NR),
    (   buscar_vehiculo(Texto, V),
        \+ compatible(R, V)
    ->  format('No aplica, ~w no sirve para ~w.~n', [NR, V])
    ;   debe_cambiar(R, Km)
    ->  format('Si, cambialo (~w: cada ~w km).~n', [NR, Limite])
    ;   Faltan is Limite - Km,
        format('No, faltan ~w km (~w: cada ~w km).~n', [Faltan, NR, Limite])
    ).

% que debo cambiar con N km (sin nombrar un repuesto)
responder(Texto) :-
    buscar_numero(Texto, Km),
    contiene_alguna(Texto, ["km", "kilometro"]),
    \+ buscar_mantencion(Texto, _),
    !,
    (   buscar_vehiculo(Texto, V)
    ->  findall(R, debe_cambiar_en(R, V, Km), Lista),
        mostrar_lista(Lista, 'Con ~w km en ~w debes cambiar: ~w.~n', [Km, V],
                      'Con esos km todavia no toca cambiar nada.~n')
    ;   findall(R, debe_cambiar(R, Km), Lista),
        mostrar_lista(Lista, 'Con ~w km debes cambiar: ~w.~n', [Km],
                      'Con esos km todavia no toca cambiar nada.~n')
    ).

responder(Texto) :-
    contiene_alguna(Texto, ["cuantos km", "cada cuanto", "kilometros"]),
    buscar_repuesto(Texto, R),
    cambio_km(R, Km),
    !,
    bonito(R, NR),
    format('~w: cada ~w km.~n', [NR, Km]).

responder(Texto) :-
    contiene(Texto, "sistema"),
    contiene(Texto, "pertenece"),
    buscar_repuesto(Texto, R),
    !,
    pertenece(R, S),
    bonito(R, NR),
    format('~w: sistema ~w.~n', [NR, S]).

responder(Texto) :-
    buscar_mantencion(Texto, M),
    !,
    bonito(M, NM),
    (   buscar_vehiculo(Texto, V)
    ->  findall(R, repuesto_mantencion(M, V, R), Lista),
        mostrar_lista(Lista, '~w (~w): ~w.~n', [NM, V],
                      'Ninguno para ese vehiculo.~n')
    ;   findall(R, necesita(M, R), Lista),
        mostrar_lista(Lista, '~w: ~w.~n', [NM],
                      'Sin repuestos registrados.~n')
    ).

% en que mantenciones se usa un repuesto
responder(Texto) :-
    contiene(Texto, "mantencion"),
    buscar_repuesto(Texto, R),
    !,
    bonito(R, NR),
    findall(M, necesita(M, R), Lista),
    mostrar_lista(Lista, '~w se usa en: ~w.~n', [NR],
                  'Ninguna mantencion usa ese repuesto.~n').

responder(Texto) :-
    buscar_repuesto(Texto, R),
    buscar_vehiculo(Texto, V),
    !,
    bonito(R, NR),
    (   compatible(R, V)
    ->  format('Si, ~w sirve para ~w.~n', [NR, V])
    ;   format('No, ~w no sirve para ~w.~n', [NR, V])
    ).

responder(Texto) :-
    contiene(Texto, "vehiculo"),
    buscar_repuesto(Texto, R),
    !,
    bonito(R, NR),
    findall(V, compatible(R, V), Lista),
    mostrar_lista(Lista, '~w: ~w.~n', [NR],
                  'Sin vehiculos registrados.~n').

responder(Texto) :-
    contiene_alguna(Texto, ["repuesto", "sistema"]),
    buscar_sistema(Texto, S),
    !,
    findall(R, pertenece(R, S), Lista),
    mostrar_lista(Lista, '~w: ~w.~n', [S],
                  'Sin repuestos registrados.~n').

responder(Texto) :-
    contiene(Texto, "repuesto"),
    buscar_vehiculo(Texto, V),
    !,
    findall(R, compatible(R, V), Lista),
    mostrar_lista(Lista, '~w: ~w.~n', [V],
                  'Sin repuestos registrados.~n').

responder(Texto) :-
    buscar_repuesto(Texto, R),
    !,
    pertenece(R, S),
    cambio_km(R, Km),
    bonito(R, NR),
    format('~w: sistema ~w, cada ~w km.~n', [NR, S, Km]).

% preguntas generales, como que vehiculos hay
responder(Texto) :-
    contiene(Texto, "todos"),
    contiene(Texto, "vehiculo"),
    !,
    findall(R, para_todos(R), Lista),
    mostrar_lista(Lista, 'Sirven para todos los vehiculos: ~w.~n', [],
                  'Sin repuestos registrados.~n').

responder(Texto) :-
    contiene(Texto, "mantencion"),
    !,
    findall(M, mantencion(M), Lista0),
    sort(Lista0, Lista),
    mostrar_lista(Lista, 'Mantenciones: ~w.~n', [], 'Sin mantenciones registradas.~n').

responder(Texto) :-
    contiene(Texto, "sistema"),
    !,
    findall(S, sistema(S), Lista),
    mostrar_lista(Lista, 'Sistemas: ~w.~n', [], 'Sin sistemas registrados.~n').

responder(Texto) :-
    contiene(Texto, "repuesto"),
    !,
    findall(R, repuesto(R), Lista),
    mostrar_lista(Lista, 'Repuestos: ~w.~n', [], 'Sin repuestos registrados.~n').

responder(Texto) :-
    contiene(Texto, "vehiculo"),
    !,
    findall(V, vehiculo(V), Lista),
    mostrar_lista(Lista, 'Vehiculos: ~w.~n', [], 'Sin vehiculos registrados.~n').

responder(Texto) :-
    contiene_alguna(Texto, ["ayuda", "ejemplo"]),
    !,
    writeln('Ejemplos:'),
    writeln('- Cada cuantos km se cambia el aceite?'),
    writeln('- Debo cambiar las bujias si tengo 35000 km?'),
    writeln('- Tengo un sedan con 30000 km, que debo cambiar?'),
    writeln('- Que repuestos necesita el cambio de aceite?'),
    writeln('- En que mantencion se usa el filtro de aire?'),
    writeln('- Sirve la bujia para un camion?'),
    writeln('- Para que vehiculos sirve el disco de freno?'),
    writeln('- Que repuestos tiene el sistema de frenos?'),
    writeln('- Que repuestos sirven para un suv?'),
    writeln('- A que sistema pertenece la bateria?').

responder(_) :-
    writeln('No entendi. Escribe "ayuda".').

mostrar_lista([], _, _, MensajeVacio) :-
    !,
    format(MensajeVacio, []).
mostrar_lista(Lista, Mensaje, Datos, _) :-
    lista_bonita(Lista, Texto),
    append(Datos, [Texto], Argumentos),
    format(Mensaje, Argumentos).

% parte cuatro para la pagina web
% responder una sola pregunta y terminar

responder_una :-
    current_prolog_flag(argv, Argv),
    quitar_programa(Argv, Args),
    atomic_list_concat(Args, ' ', Pregunta),
    limpiar(Pregunta, Texto),
    responder(Texto).

% sacar el nombre del programa si viene en la lista
quitar_programa([P|Resto], Resto) :-
    file_base_name(P, swipl),
    !.
quitar_programa(Args, Args).
