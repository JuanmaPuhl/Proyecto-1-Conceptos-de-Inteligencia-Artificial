:- dynamic ejemplo/2.
construirAD(InputFile,OutputFile):- 
                                    \+checkEmpty(InputFile), 
                                    consult(InputFile), 
                                    findall(X, ejemplo(_,X), L),
                                    sort(L,ListaFinal), 
                                    length(ListaFinal,Size), 
                                    write(Size),
                                    write(ListaFinal),
                                    buscarDefault(ListaFinal,Default).
checkEmpty(File):-open(File,read,Str),isEmpty(Str).
/*
Tengo que hacer algun metodo para revisar cual es el predicado que mas veces aparece para el default
Debo recorrer la lista final, llamando a findall contando todos los ids que aparezcan con el nombre indicado en la lista. 
Para cada uno entonces debo guardar en una lista el par (Nombre,Cantidad) y una vez que termino entonces recorro y veo el mayor.
Sort creo que los ordena.
*/

buscarDefault(ListaInput, Default):-buscarApariciones(ListaInput,ListaOutput),write(ListaOutput),buscarMayor(ListaOutput,Default).
buscarApariciones(ListaInput,ListaOutput):-buscarAparicionesAux(ListaInput,[],ListaOutput).
buscarAparicionesAux([],ListaIntermedia,ListaOutput):-append(ListaNueva,ListaIntermedia,ListaOutput),!.
buscarAparicionesAux([H|T],ListaIntermedia,ListaOutput) :-
                                                        findall(ID, ejemplo(ID,H),ListaAux),
                                                        length(ListaAux,Cantidad),ListaNueva=[(H,Cantidad)],
                                                        append(ListaIntermedia,ListaNueva,ListaNueva2),
                                                        buscarAparicionesAux(T,ListaNueva2,ListaOutput).
buscarMayor(ListaOutput,Default):-sort(ListaOutput,ListaOrdenada),write(ListaOrdenada).


isEmpty(Str):-at_end_of_stream(Str).

leer(InputFile) :- open(InputFile, read, Str), read_file(Str,Lines), close(Str),!.

read_file(Stream,[]) :- at_end_of_stream(Stream).

read_file(Stream,[X|L]) :- \+ at_end_of_stream(Stream), read(Stream,X), call(X), read_file(Stream,L).