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
/*
En la lista final tengo todo ordenado, sin repeticiones, y el primero es el que mas apariciones tiene
*/
buscarMayor(ListaOutput,Default):-sort(ListaOutput,ListaOrdenada),reverse(ListaOrdenada,ListaFinal),obtenerMayor(ListaFinal,Default).
obtenerMayor([(A,(B,C))|T],Default):- Default = C.

/*
Ahora tengo que generar el arbol de decision
ALGORITMO:

    generarArbolDecision(ejemplos,atributos,default)
        si ejemplos esta vacio
            retornar default
        sino
            si todos los ejemplos tienen la misma clasificacion
                retornar clasificacion
            sino
                best = elegirAtributo(atributos,ejemplos)
                arbol = arbol con raiz best
                para cada Vi de best hacer
                    ejemplos = {elementos de examples con best = Vi}
                    subArbol = generarArbolDecision(ejemplos,atributos-best,majority_values(ejemplosI))
                    añadir una rama a arbol con etiqueta Vi y subarbol subArbol
                fin
        retornar arbol
*/

generarArbolDecisionShell(Default) :- 
                                    findall((ID,Atributos,Clasificacion),ejemplo(ID,Atributos,Clasificacion),ListaEjemplos),
                                    findall(Atributos,ejemplo(1,Atributos,_),ListaAtributos),
                                    nth0(0,ListaAtributos,Lista),
                                    recuperarAtributosShell(Lista,ListaFinalAtributos),
                                    nl,
                                    writeln(ListaFinalAtributos),
                                    generarArbolDecision(ListaEjemplos,ListaFinalAtributos,Default).
generarArbolDecision(ListaEjemplos,ListaAtributos,Default):-length(ListaEjemplos,Size),Size==0,writeln(Default).
generarArbolDecision([(ID,Atributos,(_,Calificacion))|T],ListaAtributos,Default):-verificarIgualesShell([(Id,Atributos,(_,Calificacion))|T]),writeln(Calificacion).
generarArbolDecision(ListaEjemplos,ListaAtributos,Default):-writeln("Caso General"),auxiliar(ListaAtributos,ListaEjemplos,ListaFinal),write("\n\n\nResultado:\n"),writeln(ListaFinal),!.


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
searchAttribute([Attr|Tail],ListaEjemplos,ListaIntermedia,ListaFinal):-findall((Attr,Valor,Calificacion),(member((ID,L,(_,Calificacion)),ListaEjemplos),member((Attr,Valor),L)),ListaNueva),
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