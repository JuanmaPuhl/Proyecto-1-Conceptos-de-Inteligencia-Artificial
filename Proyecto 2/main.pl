:- dynamic ejemplo/3.
construirAD(InputFile,OutputFile):- 
                                    \+checkEmpty(InputFile), 
                                    consult(InputFile), 
                                    findall(X, ejemplo(_,_,X), L),
                                    length(L,S),
                                    S>0,
                                    sort(L,ListaFinal), 
                                    length(ListaFinal,_), 
                                    file_directory_name(InputFile, Directory),
                                    atom_concat(Directory,'/',DestinoAux),
                                    atom_concat(DestinoAux,OutputFile,Destino),
                                    open(Destino,write,Output),
                                    generarArbolDecisionShell(Output),
                                    write("Se construyo exitosamente el AD en el archivo "),
                                    writeln(Destino),
                                    retractall(ejemplo(_,_,_)),
                                    !.
construirAD(_,_):- write("Ocurrio un error.").
checkEmpty(File):-open(File,read,Str),isEmpty(Str).

/*obtenerListaValoresAtributosTotal(Resultado):-findall(X,(ejemplo(_,ListaAtributos,_),member((Attr,X),ListaAtributos)),ListaValoresAtributosTotal).*/
obtenerListaClasificacionesTotal(Resultado):-findall(X,ejemplo(_,_,(_,X)),ListaClasificacionesTotal),sort(ListaClasificacionesTotal,Resultado).


/*ACLARACION GENERAL: Siempre que se necesita trabajar con listas se agrega al predicado una listaIntermedia y otra listafinal
ListaIntermedia guarda el progreso, agregando los elementos. Una vez que se llega al caso base, se guarda la lista esa en listaFinal 
y de esta forma se evita la perdida de datos por el backtracking*/

/*
Tengo que hacer algun metodo para revisar cual es el predicado que mas veces aparece para el default
Debo recorrer la lista final, llamando a findall contando todos los ids que aparezcan con el nombre indicado en la lista. 
Para cada uno entonces debo guardar en una lista el par (Nombre,Cantidad) y una vez que termino entonces recorro y veo el mayor.
Sort creo que los ordena.
*/
buscarApariciones(ListaInput,ListaOutput):-findall(H, member((_,_,(decision,H)),ListaInput),ListaAux),sort(ListaAux,ListaAux2),buscarAparicionesAux(ListaInput,ListaAux2,[],ListaOutput).
buscarAparicionesAux(_,[],ListaIntermedia,ListaOutput):-append(_,ListaIntermedia,ListaOutput),!.
buscarAparicionesAux(ListaInput,[H|T],ListaIntermedia,ListaOutput) :-
                                    findall(ID,member((ID,_,(_,H)),ListaInput),ListaAux),
                                    length(ListaAux,Cantidad),
                                    append([(Cantidad,H)],ListaIntermedia,ListaNueva2),
                                    buscarAparicionesAux(ListaInput,T,ListaNueva2,ListaOutput).

calcularDefault(ListaEjemplos,Default):-buscarApariciones(ListaEjemplos,ListaOutput),buscarMayor(ListaOutput,Default).

/*
En la lista final tengo todo ordenado, sin repeticiones, y el primero es el que mas apariciones tiene
*/
buscarMayor(ListaOutput,Default):-sort(ListaOutput,ListaOrdenada),reverse(ListaOrdenada,ListaFinal),obtenerMayor(ListaFinal,Default).
obtenerMayor([(_,C)|_],Default):- Default = C.

obtenerValoresDeAtributos([],_,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
obtenerValoresDeAtributos([Attr|T],ListaEjemplos,ListaIntermedia,ListaFinal):-
                                    findall(Value,(member((_,ListaAtributos,_),ListaEjemplos),member((Attr,Value),ListaAtributos)),ListaValores),
                                    sort(ListaValores,ListaSinRepetir),
                                    append([(Attr,ListaSinRepetir)],ListaIntermedia,ListaNueva),
                                    obtenerValoresDeAtributos(T,ListaEjemplos,ListaNueva,ListaFinal).

/*Predicado principal para generar el arbol*/
generarArbolDecisionShell(Output) :-
                                    findall((ID,Atributos,Clasificacion),ejemplo(ID,Atributos,Clasificacion),ListaEjemplos),
                                    calcularDefault(ListaEjemplos,Default),
                                    findall(Atributos,ejemplo(1,Atributos,_),ListaAtributos),
                                    nth0(0,ListaAtributos,Lista),
                                    recuperarAtributosShell(Lista,ListaFinalAtributos),
                                    obtenerValoresDeAtributos(ListaFinalAtributos,ListaEjemplos,[],ListaValoresAtributos),
                                    write(Output,"digraph AD{\n"),
                                    write(Output,"node [shape = box]\n"),
                                    generarArbolDecision(ListaEjemplos,ListaFinalAtributos,Default,ListaValoresAtributos,0,0,[],_,Output),
                                    write(Output,"}\n"),
                                    close(Output).
/*Predicado del algoritmo, tiene los argumentos clave, como ListaEjemplos con los casos de prueba,
ListaAtributos, con los atributos a revisar, Default con el valor por defecto de la mayoria
Además se agregaron: 
    ListaValores que contiene todos los posibles valores de todos los atributos
    Father, el padre del nodo que estoy mirando. Se usa para poder escribir en DOT
    FatherValue, la etiqueta del arco entre el padre y el actual
    ListaLabels y Lista2 son utilizados para mantener los identificadores ya ingresados
        de forma que no se termine generando un grafo en lugar de un arbol
    Output, la referencia al archivo de salida*/  

/*La lista de ejemplos está vacia*/                              
generarArbolDecision([],_,Default,_,Father,FatherValue,ListaLabels,Lista2,Output):-
                                    escribirDOT(Default,Father,FatherValue,Listalabels,Lista2,Output).
/*La lista de atributos está vacia*/
generarArbolDecision(ListaEjemplos,[],_,_,Father,FatherValue,ListaLabels,Lista2,Output):-
                                    calcularDefault(ListaEjemplos,Resultado),
                                    escribirDOT(Resultado,Father,FatherValue,ListaLabels,Lista2,Output).
/*Todos tienen el mismo valor de clasificacion*/                                
generarArbolDecision([(ID,Atributos,(_,Calificacion))|T],_,_,_,Father,FatherValue,ListaLabels,Lista2,Output):-
                                    verificarIgualesShell([(ID,Atributos,(_,Calificacion))|T]),
                                    escribirDOT(Calificacion,Father,FatherValue,ListaLabels,Lista2,Output).
/*Caso general*/
generarArbolDecision(ListaEjemplos,ListaAtributos,_,ListaValores,Father,FatherValue,ListaLabels,Lista2,Output):-
                                    auxiliar(ListaAtributos,ListaEjemplos,ListaFinal),
                                    obtenerListaClasificacionesTotal(ListaResultadoClasificaciones),
                                    calcularMejorAtributo(ListaFinal,ListaAtributos,ListaResultadoClasificaciones,[],ListaNueva),
                                    sumarAtributos(ListaAtributos,ListaNueva,[],ListaSumas),
                                    length(ListaSumas,Size),
                                    Size>0,
                                    Q is Size-1,
                                    nth0(Q,ListaSumas,(_,Best)),
                                    escribirDOT(Best,Father,FatherValue,ListaLabels,ListaLoca,Output),
                                    seguirEjecucionShell(Best,ListaValores,ListaEjemplos,ListaAtributos,ListaLoca,ListaNuevisima,Output),
                                    Lista2 = ListaNuevisima,
                                    !.
/*Predicado para escribir en el archivo los nodos y los arcos (Si no es el primero)*/
escribirDOT(Best,Father,ValueFather,ListaLabels,ListaLoca,Output):-
                                    Father\==0,
                                    ValueFather\==0,
                                    append([Best],ListaLabels,ListaNueva),
                                    findall(a,member(Best,ListaNueva),ListaApariciones),
                                    length(ListaApariciones,CantidadApariciones),
                                    write(Output,Best),
                                    write(Output,CantidadApariciones),
                                    write(Output," [label="),
                                    write(Output,Best),
                                    write(Output,"]\n"),   
                                    findall(b,member(Father,ListaLabels),ListaAparicionesFather),
                                    length(ListaAparicionesFather,CantidadAparicionesFather),
                                    ListaLoca = ListaNueva,
                                    write(Output,Father),
                                    write(Output,CantidadAparicionesFather),
                                    write(Output," -> "),
                                    write(Output,Best),
                                    write(Output,CantidadApariciones),
                                    write(Output,"[label = "),
                                    write(Output,ValueFather),
                                    write(Output,"]\n").
/*Predicado para escribir en el archivo los nodos y los arcos (Si es el primero)*/   
escribirDOT(Best,_,_,ListaLabels,ListaLoca,Output):-
                                    append([Best],ListaLabels,ListaNueva),
                                    findall(a,member(Best,ListaNueva),ListaApariciones),
                                    length(ListaApariciones,CantidadApariciones),
                                    write(Output,Best),
                                    write(Output,CantidadApariciones),
                                    write(Output," [label="),
                                    write(Output,Best),
                                    write(Output,"]\n"),   
                                    ListaLoca = ListaNueva.        
/*Predicados auxiliares que crean recursivamente el arbol de decision*/                                 
seguirEjecucionShell(Best,ListaValores,ListaEjemplos,ListaAtributos,ListaLabels,ListaFinal,Output):-
                                    findall(Value,(member((Best,ListaValoresBest),ListaValores),member(Value,ListaValoresBest)),ListaValoresABuscar),
                                    seguirEjecucion(Best,ListaValoresABuscar,ListaEjemplos,ListaAtributos,ListaValores,ListaLabels,ListaFinal,Output).
seguirEjecucion(_,[],_,_,_,ListaLabels,ListaFinal,_):-ListaFinal = ListaLabels.
seguirEjecucion(Best,[Valor|T],ListaEjemplos,ListaAtributos,ListaValoresCompleta,ListaLabels,ListaFinal,Output):-
                                    findall((Id,ListaAtributosEjemplos,Calificacion),(member((Id,ListaAtributosEjemplos,Calificacion),ListaEjemplos),member((Best,Valor),ListaAtributosEjemplos)),ListaNuevosEjemplos),
                                    delete(ListaAtributos,Best,ListaAtributosSinBest),
                                    calcularDefault(ListaNuevosEjemplos,Default),
                                    /*Creo subarbol para el primer valor del atributo*/
                                    generarArbolDecision(ListaNuevosEjemplos,ListaAtributosSinBest,Default,ListaValoresCompleta,Best,Valor,ListaLabels,Lista2,Output),
                                    /*Creo subarbol para los valores restantes del atributo*/
                                    seguirEjecucion(Best,T,ListaEjemplos,ListaAtributos,ListaValoresCompleta,Lista2,ListaFinal,Output).
/*Predicados para sumar las diferencias de cada atributo y llegar a una respuesta sobre el mejor*/
sumarAtributos([],_,ListaIntermedia,ListaSuma):-sort(ListaIntermedia,ListaNueva),ListaSuma = ListaNueva.
sumarAtributos([Attr|T],ListaObtenida,ListaIntermedia,ListaSuma):-
                                    /*Hallar las cantidades de los pares cuyos atributo es el que estoy mirando*/
                                    findall(Cantidad,member((Cantidad,Attr),ListaObtenida),ListaNueva),
                                    sumar(Attr,ListaNueva,0,ListaIntermedia,ListaNuevita),
                                    sumarAtributos(T,ListaObtenida,ListaNuevita,ListaSuma).
sumar(Attr,[],Suma,ListaIntermedia,ListaNueva):-append([(Suma,Attr)],ListaIntermedia,ListaNueva).
sumar(Attr,[Cantidad|T],Suma,ListaIntermedia,ListaNueva):-
                                    Q is Suma+Cantidad,
                                    sumar(Attr,T,Q,ListaIntermedia,ListaNueva).
/*Estos predicados estan para recuperar la lista de atributos. Basicamente se recibe la lista de atributos y valores y se cicla hasta llegar al ultimo
guardando mientras en una lista de retorno todos los atributos encontrados*/
recuperarAtributosShell(ListaAtributos,ListaFinal):-recuperarAtributos(ListaAtributos,_,ListaFinal).
recuperarAtributos([],ListaIntermedia,ListaFinal):- ListaFinal = ListaIntermedia.
recuperarAtributos([(Atributo,_)|T],ListaIntermedia,ListaFinal):- ListaAux=[Atributo],append(ListaIntermedia,ListaAux,ListaNueva),recuperarAtributos(T,ListaNueva,ListaFinal).
/*
Este predicado se encarga de generar las tablas para cada atributo, lo almacena en una lista con el siguiente formato:
[(Atributo1,[(total,valor1,cantTotal1),(total,valor2,cantTotal2),...,(total,valorq,cantTotalq),(calificacion1, valor1, cantidad11),(calificacion1,valor2,cantidad12),...,(calificacion2,valor1,cantidad21),...,(calificacionn,valorm,cantidadnm)],...,(Atributox,[...])]
Se opto por esta forma porque es bastante comoda, sin necesidad de entrar en tantos niveles de anidamiento de listas.
*/
auxiliar(ListaAtributos,ListaEjemplos,ListaFinal):-searchAttribute(ListaAtributos,ListaEjemplos,[],ListaFinal).
searchAttribute([],_,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
searchAttribute([Attr|Tail],ListaEjemplos,ListaIntermedia,ListaFinal):-
                                    findall((Attr,Valor,Calificacion),(member((_,L,(_,Calificacion)),ListaEjemplos),member((Attr,Valor),L)),ListaNueva),
                                    findall(Clasificacion,member((_,_,(_,Clasificacion)),ListaEjemplos),ListaClasificacion),
                                    sort(ListaClasificacion,ListaClasificacionSinRepetidos),
                                    append([(Attr,ListaCantidades)],ListaIntermedia,ListaTemplate),
                                    findall(Value,member((_,Value,_),ListaNueva),ListaValores),
                                    sort(ListaValores,ListaValoresSinRepetidos),
                                    buscarTotal(ListaValoresSinRepetidos,ListaNueva,[],ListaIncompleta),
                                    buscarTotalAtributosPorClasificacion(ListaClasificacionSinRepetidos,Attr,ListaNueva,ListaValoresSinRepetidos,ListaIncompleta,ListaCantidades),
                                    searchAttribute(Tail,ListaEjemplos,ListaTemplate,ListaFinal).
/*Busca para cada clasificacion, la cantidad de ejemplos que hayan por cada tipo de valor*/                
buscarTotalAtributosPorClasificacion([],_,_,_,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
buscarTotalAtributosPorClasificacion([Clasificacion|T],Attr,Lista,ListaValores,ListaIntermedia,ListaFinal):-
                                    buscarParcial(Clasificacion,ListaValores,Attr,Lista,ListaIntermedia,ListaMedio),
                                    buscarTotalAtributosPorClasificacion(T,Attr,Lista,ListaValores,ListaMedio,ListaFinal).
/*Busca para cada valor, la cantidad total de ejemplos*/
buscarTotal([],_,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
buscarTotal([Valor|T],Lista,ListaIntermedia,ListaFinal):-
                                    findall(Valor,member((_,Valor,_),Lista),ListaNueva),
                                    length(ListaNueva,Size),
                                    append([(total,Valor,Size)],ListaIntermedia,ListaTotal),
                                    buscarTotal(T,Lista,ListaTotal,ListaFinal).
/*Metodo auxiliar para buscar la cantidad parcial de ejemplos con determinado tipo y determinada calificacion*/
buscarParcial(_,[],_,_,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
buscarParcial(Clasificacion,[Valor|T],Attr,Lista,ListaIntermedia,ListaFinal):-
                                    findall(Valor,member((Attr,Valor,Clasificacion),Lista),ListaEncontrada),
                                    length(ListaEncontrada,Size),
                                    append([(Clasificacion,Valor,Size)],ListaIntermedia,ListaIncompleta),
                                    buscarParcial(Clasificacion,T,Attr,Lista,ListaIncompleta,ListaFinal).

/*Predicados para calcular el mejor atributo dada la lista de datos, clasificacion y atributo*/
calcularMejorAtributo(_,[],_,ListaIntermedia,ListaFinal):-
                                    sort(ListaIntermedia,ListaNueva),
                                    ListaFinal = ListaNueva.
calcularMejorAtributo(ListaDatos,[Attr|T],ListaClasificacion,ListaIntermedia,ListaFinal):-
                                    calcularAux1(ListaDatos,Attr,ListaClasificacion,ListaIntermedia,ListaNueva),
                                    calcularMejorAtributo(ListaDatos,T,ListaClasificacion,ListaNueva,ListaFinal).
calcularAux1(_,_,[],ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
calcularAux1(ListaDatos,Attr,[Clasificacion|T],ListaIntermedia,ListaFinal):-
                                    /*Tengo que obtener la lista de valores*/
                                    findall(Value,(member((Attr,ListaCantidades),ListaDatos),member((Clasificacion,Value,_),ListaCantidades)),ListaValores),
                                    sort(ListaValores,ListaValores2),
                                    /*Ahora tengo que buscar para cada uno de los valores*/
                                    calcularAux2(ListaDatos,Attr,Clasificacion,ListaValores2,ListaIntermedia,ListaNueva),
                                    calcularAux1(ListaDatos,Attr,T,ListaNueva,ListaFinal).
calcularAux2(_,_,_,[],ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
calcularAux2(ListaDatos,Attr,Clasificacion,[Valor|T],ListaIntermedia,ListaFinal):-
                                    /*Tengo que obtener el total para ese valor*/
                                    findall(Cantidad,(member((Attr,ListaCantidades),ListaDatos),member((total,Valor,Cantidad),ListaCantidades)),ListaTotal),
                                    nth0(0,ListaTotal,Total),
                                    /*Ahora tengo que obtener la cantidad*/
                                    findall(Cantidad,(member((Attr,ListaCantidades),ListaDatos),member((Clasificacion,Valor,Cantidad),ListaCantidades)),ListaCantidad),
                                    nth0(0,ListaCantidad,Cantidad),
                                    procesar(Attr,Total,Cantidad,ListaIntermedia,ListaNueva),
                                    calcularAux2(ListaDatos,Attr,Clasificacion,T,ListaNueva,ListaFinal).
/*Predicados para procesar los puntajes de las tablas obtenidas para cada atributo*/
procesar(Attr,Total,Cantidad,ListaIntermedia,ListaFinal):-Total == Cantidad, append([(Cantidad,Attr)],ListaIntermedia,ListaFinal).
procesar(_,_,_,ListaIntermedia,ListaFinal):-ListaFinal = ListaIntermedia.
/*Utilidades*/
/*Chequear si un archivo esta vacio*/
isEmpty(Str):-at_end_of_stream(Str).
/*Leer un archivo*/
leer(InputFile) :- open(InputFile, read, Str), read_file(Str,_), close(Str),!.
/*Auxiliar para leer un archivo*/
read_file(Stream,[]) :- at_end_of_stream(Stream).
read_file(Stream,[X|L]) :- \+ at_end_of_stream(Stream), read(Stream,X), call(X), read_file(Stream,L).
/*Verificar si todos los ejemplos del conjunto de pruebas tienen la misma clasificacion*/
verificarIgualesShell([(_,_,(_,E))|T]):-verificarIguales(T,E).
verificarIguales([],_).
verificarIguales([(_,_,(_,Calificacion))|T],E):-Calificacion==E,verificarIguales(T,E).
/*Reemplazar elementos de una lista por algun otro*/
replaceP(_, _, [], []).
replaceP(O, R, [O|T], [R|T2]) :- replaceP(O, R, T, T2).
replaceP(O, R, [H|T], [H|T2]) :- dif(H,O), replaceP(O, R, T, T2).