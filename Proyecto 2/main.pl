:- dynamic ejemplo/3.
construirAD(InputFile,OutputFile):- 
                                    \+checkEmpty(InputFile), 
                                    consult(InputFile), 
                                    findall(X, ejemplo(_,_,X), L),
                                    length(L,S),
                                    S>0,
                                    sort(L,ListaFinal), 
                                    length(ListaFinal,Size), 
                                    buscarDefault(ListaFinal,Default),!.
construirAD(InputFile,OutputFile):- write("Ocurrio un error.").
checkEmpty(File):-open(File,read,Str),isEmpty(Str).
/*
Tengo que hacer algun metodo para revisar cual es el predicado que mas veces aparece para el default
Debo recorrer la lista final, llamando a findall contando todos los ids que aparezcan con el nombre indicado en la lista. 
Para cada uno entonces debo guardar en una lista el par (Nombre,Cantidad) y una vez que termino entonces recorro y veo el mayor.
Sort creo que los ordena.
*/
buscarDefault(ListaInput, Default):-buscarApariciones(ListaInput,ListaOutput),buscarMayor(ListaOutput,Default),write(Default),generarArbolDecisionShell(Default).
buscarApariciones(ListaInput,ListaOutput):-buscarAparicionesAux(ListaInput,[],ListaOutput).
buscarAparicionesAux([],ListaIntermedia,ListaOutput):-append(ListaNueva,ListaIntermedia,ListaOutput),!.
buscarAparicionesAux([H|T],ListaIntermedia,ListaOutput) :-
                                                        findall(ID, ejemplo(ID,_,H),ListaAux),
                                                        length(ListaAux,Cantidad),ListaNueva=[(Cantidad,H)],
                                                        append(ListaIntermedia,ListaNueva,ListaNueva2),
                                                        buscarAparicionesAux(T,ListaNueva2,ListaOutput).

calcularDefault(ListaEjemplos,Default):-buscarApariciones(ListaEjemplos,ListaOutput),buscarMayor(ListaOutput,Default).

/*
En la lista final tengo todo ordenado, sin repeticiones, y el primero es el que mas apariciones tiene
*/
buscarMayor(ListaOutput,Default):-sort(ListaOutput,ListaOrdenada),reverse(ListaOrdenada,ListaFinal),obtenerMayor(ListaFinal,Default).
obtenerMayor([(A,(B,C))|T],Default):- Default = C.

obtenerValoresDeAtributos([],ListaEjemplos,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
obtenerValoresDeAtributos([Attr|T],ListaEjemplos,ListaIntermedia,ListaFinal):-
                                findall(Value,(member((ID,ListaAtributos,Calificacion),ListaEjemplos),member((Attr,Value),ListaAtributos)),ListaValores),
                                sort(ListaValores,ListaSinRepetir),
                                append([(Attr,ListaSinRepetir)],ListaIntermedia,ListaNueva),
                                obtenerValoresDeAtributos(T,ListaEjemplos,ListaNueva,ListaFinal).
generarArbolDecisionShell(Default) :-
                                    findall((ID,Atributos,Clasificacion),ejemplo(ID,Atributos,Clasificacion),ListaEjemplos),
                                    findall(Atributos,ejemplo(1,Atributos,_),ListaAtributos),
                                    nth0(0,ListaAtributos,Lista),
                                    recuperarAtributosShell(Lista,ListaFinalAtributos),
                                    nl,
                                    obtenerValoresDeAtributos(ListaFinalAtributos,ListaEjemplos,[],ListaValoresAtributos),
                                    generarArbolDecision(ListaEjemplos,ListaFinalAtributos,Default,ListaValoresAtributos,0,0,[],Lista2).
generarArbolDecision(ListaEjemplos,ListaAtributos,Default,ListaValores,Father,FatherValue,ListaLabels,Lista2):-length(ListaEjemplos,Size),Size==0,escribirDOT(Default,Father,FatherValue,Listalabels,Lista2).
generarArbolDecision(ListaEjemplos,[],Default,ListaValores,Father,FatherValue,ListaLabels,Lista2):-calcularDefault(ListaEjemplos,Resultado),escribirDOT(Resultado,Father,FatherValue,ListaLabels,Lista2).
generarArbolDecision([(ID,Atributos,(_,Calificacion))|T],ListaAtributos,Default,ListaValores,Father,FatherValue,ListaLabels,Lista2):-verificarIgualesShell([(ID,Atributos,(_,Calificacion))|T]),escribirDOT(Calificacion,Father,FatherValue,ListaLabels,Lista2).
generarArbolDecision(ListaEjemplos,ListaAtributos,Default,ListaValores,Father,FatherValue,ListaLabels,Lista2):-
                                                auxiliar(ListaAtributos,ListaEjemplos,ListaFinal),
                                                calcularMejorAtributo(ListaFinal,ListaAtributos,[inkjet,laser],[],ListaNueva),
                                                sumarAtributos(ListaAtributos,ListaNueva,[],ListaSumas),
                                                length(ListaSumas,Size),
                                                Size>0,
                                                Q is Size-1,
                                                nth0(Q,ListaSumas,(Cant,Best)),
                                                escribirDOT(Best,Father,FatherValue,ListaLabels,ListaLoca),
                                                seguirEjecucionShell(Best,ListaValores,ListaEjemplos,ListaAtributos,ListaLoca,ListaNuevisima),
                                                Lista2 = ListaNuevisima,
                                                !.
escribirDOT(Best,Father,ValueFather,ListaLabels,ListaLoca):-
                                    append([Best],ListaLabels,ListaNueva),
                                    findall(a,member(Best,ListaNueva),ListaApariciones),
                                    length(ListaApariciones,CantidadApariciones),
                                    write(Best),write(CantidadApariciones),write(" [label="),write(Best),write("]\n"),
                                    Father\==0,
                                    ValueFather\==0,
                                    findall(b,member(Father,ListaLabels),ListaAparicionesFather),
                                    length(ListaAparicionesFather,CantidadAparicionesFather),
                                    ListaLoca = ListaNueva,
                                    write(Father),write(CantidadAparicionesFather),write(" -> "),write(Best),write(CantidadApariciones),write("[label = "),write(ValueFather),write("]\n").   
escribirDOT(Best,Father,ValueFather,ListaLabels,ListaLoca):-append([Best],ListaLabels,ListaNueva),ListaLoca = ListaNueva.                                         
seguirEjecucionShell(Best,ListaValores,ListaEjemplos,ListaAtributos,ListaLabels,ListaFinal):-
    findall(Value,(member((Best,ListaValoresBest),ListaValores),member(Value,ListaValoresBest)),ListaValoresABuscar),
    seguirEjecucion(Best,ListaValoresABuscar,ListaEjemplos,ListaAtributos,ListaValores,ListaLabels,ListaFinal).
seguirEjecucion(Best,[],ListaEjemplos,ListaAtributos,ListaValoresCompleta,ListaLabels,ListaFinal):-ListaFinal = ListaLabels.
seguirEjecucion(Best,[Valor|T],ListaEjemplos,ListaAtributos,ListaValoresCompleta,ListaLabels,ListaFinal):-
    findall((Id,ListaAtributosEjemplos,Calificacion),(member((Id,ListaAtributosEjemplos,Calificacion),ListaEjemplos),member((Best,Valor),ListaAtributosEjemplos)),ListaNuevosEjemplos),
    delete(ListaAtributos,Best,ListaAtributosSinBest),
    calcularDefault(ListaNuevosEjemplos,Default),
    generarArbolDecision(ListaNuevosEjemplos,ListaAtributosSinBest,Default,ListaValoresCompleta,Best,Valor,ListaLabels,Lista2),
    seguirEjecucion(Best,T,ListaEjemplos,ListaAtributos,ListaValoresCompleta,Lista2,ListaFinal).
seguirEjecucion(Best,[Valor|T],ListaEjemplos,ListaAtributos,ListaValoresCompleta,ListaLabels).
sumarAtributos([],ListaObtenida,ListaIntermedia,ListaSuma):-sort(ListaIntermedia,ListaNueva),ListaSuma = ListaNueva.
sumarAtributos([Attr|T],ListaObtenida,ListaIntermedia,ListaSuma):-
    /*Hallar las cantidades de los pares cuyos atributo es el que estoy mirando*/
    findall(Cantidad,member((Cantidad,Attr),ListaObtenida),ListaNueva),
    sumar(Attr,ListaNueva,0,ListaIntermedia,ListaNuevita),
    sumarAtributos(T,ListaObtenida,ListaNuevita,ListaSuma).
sumar(Attr,[],Suma,ListaIntermedia,ListaNueva):-
    append([(Suma,Attr)],ListaIntermedia,ListaNueva).
sumar(Attr,[Cantidad|T],Suma,ListaIntermedia,ListaNueva):-
    Q is Suma+Cantidad,
    sumar(Attr,T,Q,ListaIntermedia,ListaNueva).
/*Estos metodos estan para recuperar la lista de atributos. Basicamente se recibe la lista de atributos y valores y se cicla hasta llegar al ultimo
guardando mientras en una lista de retorno todos los atributos encontrados*/
recuperarAtributosShell(ListaAtributos,ListaFinal):-recuperarAtributos(ListaAtributos,_,ListaFinal).
recuperarAtributos([],ListaIntermedia,ListaFinal):- ListaFinal = ListaIntermedia.
recuperarAtributos([(Atributo,Valor)|T],ListaIntermedia,ListaFinal):- ListaAux=[Atributo],append(ListaIntermedia,ListaAux,ListaNueva),recuperarAtributos(T,ListaNueva,ListaFinal).

/*
Esto se encarga de generar las tablas para cada atributo, lo almacena en una lista con el siguiente formato:
[(Atributo1,[(total,valor1,cantTotal1),(total,valor2,cantTotal2),...,(total,valorq,cantTotalq),(calificacion1, valor1, cantidad11),(calificacion1,valor2,cantidad12),...,(calificacion2,valor1,cantidad21),...,(calificacionn,valorm,cantidadnm)],...,(Atributox,[...])]
Se opto por esta forma porque es bastante comoda, sin necesidad de entrar en tantos niveles de anidamiento de listas.
*/
auxiliar(ListaAtributos,ListaEjemplos,ListaFinal):-searchAttribute(ListaAtributos,ListaEjemplos,[],ListaFinal).
searchAttribute([],ListaEjemplos,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
searchAttribute([Attr|Tail],ListaEjemplos,ListaIntermedia,ListaFinal):-
                    findall((Attr,Valor,Calificacion),(member((ID,L,(_,Calificacion)),ListaEjemplos),member((Attr,Valor),L)),ListaNueva),
                    findall(Clasificacion,member((_,_,(_,Clasificacion)),ListaEjemplos),ListaClasificacion),
                    sort(ListaClasificacion,ListaClasificacionSinRepetidos),
                    append([(Attr,ListaCantidades)],ListaIntermedia,ListaTemplate),
                    findall(Value,member((_,Value,_),ListaNueva),ListaValores),
                    sort(ListaValores,ListaValoresSinRepetidos),
                    buscarTotal(ListaValoresSinRepetidos,ListaNueva,[],ListaIncompleta),
                    buscarTotalAtributosPorClasificacion(ListaClasificacionSinRepetidos,Attr,ListaNueva,ListaValoresSinRepetidos,ListaIncompleta,ListaCantidades),
                    searchAttribute(Tail,ListaEjemplos,ListaTemplate,ListaFinal).
/*Busca para cada clasificacion, la cantidad de ejemplos que hayan por cada tipo de valor*/                
buscarTotalAtributosPorClasificacion([],Attr,Lista,ListaValores,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
buscarTotalAtributosPorClasificacion([Clasificacion|T],Attr,Lista,ListaValores,ListaIntermedia,ListaFinal):-
                                                                    buscarParcial(Clasificacion,ListaValores,Attr,Lista,ListaIntermedia,ListaMedio),
                                                                    buscarTotalAtributosPorClasificacion(T,Attr,Lista,ListaValores,ListaMedio,ListaFinal).
/*Busca para cada valor, la cantidad total de ejemplos*/
buscarTotal([],Lista,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
buscarTotal([Valor|T],Lista,ListaIntermedia,ListaFinal):-
                            findall(Valor,member((_,Valor,_),Lista),ListaNueva),
                            length(ListaNueva,Size),
                            append([(total,Valor,Size)],ListaIntermedia,ListaTotal),
                            buscarTotal(T,Lista,ListaTotal,ListaFinal).
/*Metodo auxiliar para buscar la cantidad parcial de ejemplos con determinado tipo y determinada calificacion*/
buscarParcial(Clasificacion,[],Attr,Lista,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
buscarParcial(Clasificacion,[Valor|T],Attr,Lista,ListaIntermedia,ListaFinal):-
                            findall(Valor,member((Attr,Valor,Clasificacion),Lista),ListaEncontrada),
                            length(ListaEncontrada,Size),
                            append([(Clasificacion,Valor,Size)],ListaIntermedia,ListaIncompleta),
                            buscarParcial(Clasificacion,T,Attr,Lista,ListaIncompleta,ListaFinal).

/*Al final me guarda el que mejor clasifica*/
calcularMejorAtributo(ListaDatos,[],ListaClasificacion,ListaIntermedia,ListaFinal):-
                                                    sort(ListaIntermedia,ListaNueva),
                                                    ListaFinal = ListaNueva.
calcularMejorAtributo(ListaDatos,[Attr|T],ListaClasificacion,ListaIntermedia,ListaFinal):-
                                                    calcularAux1(ListaDatos,Attr,ListaClasificacion,ListaIntermedia,ListaNueva),
                                                    calcularMejorAtributo(ListaDatos,T,ListaClasificacion,ListaNueva,ListaFinal).
calcularAux1(ListaDatos,Attr,[],ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
calcularAux1(ListaDatos,Attr,[Clasificacion|T],ListaIntermedia,ListaFinal):-
    /*Tengo que obtener la lista de valores*/
    findall(Value,(member((Attr,ListaCantidades),ListaDatos),member((Clasificacion,Value,Cantidad),ListaCantidades)),ListaValores),
    sort(ListaValores,ListaValores2),
    /*Ahora tengo que buscar para cada uno de los valores*/
    calcularAux2(ListaDatos,Attr,Clasificacion,ListaValores2,ListaIntermedia,ListaNueva),
    calcularAux1(ListaDatos,Attr,T,ListaNueva,ListaFinal).

calcularAux2(ListaDatos,Attr,Clasificacion,[],ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
calcularAux2(ListaDatos,Attr,Clasificacion,[Valor|T],ListaIntermedia,ListaFinal):-
    /*Tengo que obtener el total para ese valor*/
    findall(Cantidad,(member((Attr,ListaCantidades),ListaDatos),member((total,Valor,Cantidad),ListaCantidades)),ListaTotal),
    nth0(0,ListaTotal,Total),
    /*Ahora tengo que obtener la cantidad*/
    findall(Cantidad,(member((Attr,ListaCantidades),ListaDatos),member((Clasificacion,Valor,Cantidad),ListaCantidades)),ListaCantidad),
    nth0(0,ListaCantidad,Cantidad),
    procesar(Attr,Total,Cantidad,ListaIntermedia,ListaNueva),
    calcularAux2(ListaDatos,Attr,Clasificacion,T,ListaNueva,ListaFinal).
procesar(Attr,Total,Cantidad,ListaIntermedia,ListaFinal):-Total == Cantidad, append([(Cantidad,Attr)],ListaIntermedia,ListaFinal).
procesar(Attr,Total,Cantidad,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
/*Utilidades*/
isEmpty(Str):-at_end_of_stream(Str).
leer(InputFile) :- open(InputFile, read, Str), read_file(Str,Lines), close(Str),!.
read_file(Stream,[]) :- at_end_of_stream(Stream).
read_file(Stream,[X|L]) :- \+ at_end_of_stream(Stream), read(Stream,X), call(X), read_file(Stream,L).
verificarIgualesShell([(_,_,(_,E))|T]):-verificarIguales(T,E).
verificarIguales([],E).
verificarIguales([(_,_,(_,Calificacion))|T],E):-Calificacion==E,verificarIguales(T,E).
replaceP(_, _, [], []).
replaceP(O, R, [O|T], [R|T2]) :- replaceP(O, R, T, T2).
replaceP(O, R, [H|T], [H|T2]) :- dif(H,O), replaceP(O, R, T, T2).