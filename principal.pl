%======================================================================================================%
%===========================================INCISO 1===================================================%
%======================================================================================================%

%Definir un predicado sustitucionValida/1 que reciba una lista de pares
%[(V1,T1),(V2,T2),...,(Vn,Tn)] y determine si se trata de una sustitución
%valida en la que Vi son las variables y Tj son los terminos.
%En caso de que la lista suministrada no se trate de una sustitución valida,
%debera mostrarse por pantalla un mensaje que indique lo ocurrido.
%Podrá asumirse que la lista no contiene dos o más pares exactamente iguales.
%Podrá asumirse que los terminos ingresados son validos.
%Las unicas letras funcionales validas seran las constantes a,b,c,...,z sin incluir ñ

%Reviso que el parametro ingresado es una lista, 
%no es necesario de todas formas porque se asume lista formada correctamente

/*
    Falta el chequeo de la segunda regla de sustitucion valida
    para cualquier i,j Xi no puede estar en Tj, esto significa que si sustituyo X en alguna transformacion,
    no puedo usarla como termino.
*/

sustitucion_valida(X) :- \+is_list(X),write("ERROR: El parametro ingresado no es una lista.").
sustitucion_valida([]) :- true.
sustitucion_valida([(A,B)| R]) :- pertenece(A,R),imprimir_error.
sustitucion_valida([(A,B)| R]) :- \+pertenece(A,R),valido(A,B),sustitucion_valida(R).
pertenece(E,[(A,_) | T]) :- E == A.
pertenece(E,[(A,_) | T]) :- E \== A, pertenece(E,T).
/*
segunda_regla(E,[(_,B) | T]) :- var(B),E == B.
segunda_regla(E,[(_,B) | T]) :- E \== B, chequear_segunda(E,B).
segunda_regla(E,[(_,B) | T]) :- E \== B,\+chequear_segunda(E,B), segunda_regla(E,T).
*/

valido(A,_) :- nonvar(A),imprimir_error.
valido(_,B) :- nonvar(B),\+caracter_valido(B),imprimir_error.
valido(_,B) :- var(B).
valido(A,B) :- var(A),nonvar(B),caracter_valido(B). %Esto es para el caso simple [(A,b),(C,d),...,(N,n)]
valido(A,B) :- var(A),var(B).
imprimir_error :- write("ERROR: La sustitucion ingresada no es valida").
%se admite cualquier valor para B, debo hacer que chequee los valores correctos
%Tengo que ver para el caso en el que el valor es una funcion
caracter_valido(A) :- A == a.
caracter_valido(A) :- A == b.
caracter_valido(A) :- A == c.
caracter_valido(A) :- A == d.
caracter_valido(A) :- A == e.
caracter_valido(A) :- A == f.
caracter_valido(A) :- A == g.
caracter_valido(A) :- A == h.
caracter_valido(A) :- A == i.
caracter_valido(A) :- A == j.
caracter_valido(A) :- A == k.
caracter_valido(A) :- A == l.
caracter_valido(A) :- A == m.
caracter_valido(A) :- A == n.
caracter_valido(A) :- A == o.
caracter_valido(A) :- A == p.
caracter_valido(A) :- A == q.
caracter_valido(A) :- A == r.
caracter_valido(A) :- A == s.
caracter_valido(A) :- A == t.
caracter_valido(A) :- A == u.
caracter_valido(A) :- A == v.
caracter_valido(A) :- A == w.
caracter_valido(A) :- A == x.
caracter_valido(A) :- A == y.
caracter_valido(A) :- A == z.
%Esta parte hay que cambiarla, porque el functor no tiene que ser obligatoriamente de dos argumentos.
%Ademas hay que revisar que cada uno de los argumentos sean terminos validos
caracter_valido(A) :- functor(A,B,N),\+N is 0,nonvar(B),caracter_valido(B),chequear_args(A,N).
chequear_args(A,1) :- write("Entre 1"),arg(1,A,X),nonvar(X),caracter_valido(X). %Debo chequear si es var o nonvar
chequear_args(A,1) :- write("Entre 1"),arg(1,A,X),nonvar(X),\+caracter_valido(X). %Debo chequear si es var o nonvar
chequear_args(A,1) :- arg(1,A,X),var(X).
chequear_args(A,N) :- write("Entre 2"),arg(N,A,X),nonvar(X),caracter_valido(X),B is (N-1),chequear_args(A,B).
chequear_args(A,N) :- arg(N,A,X),var(X),B is (N-1),chequear_args(A,B).


%Recibe una lista y la recorre de adelante para atras y de atras para adelante buscando repeticiones de terminos.
prueba_loca(A) :- sustitucion_valida(A),reverse(A,X,[]),sustitucion_valida(X).
reverse([],Z,Z).
reverse([H|T],Z,Acc) :- reverse(T,Z,[H|Acc]).

%Ahora tengo que verificar recursivamente que se cumpla la segunda propiedad.
chequear_segunda(E,B) :- functor(B,C,N),N\==0,nonvar(C),chequear_args_segunda(E,B,N).
chequear_args_segunda(E,B,1) :- arg(1,B,X),\+chequear_segunda(E,X),E\==X.
chequear_args_segunda(E,B,N) :- arg(N,B,X),\+chequear_segunda(E,X),E\==X,Q is N-1,chequear_args_segunda(E,B,Q).





%======================================================================================================%
%===========================================INCISO 2===================================================%
%======================================================================================================%

%Definir un predicado unificadosPorSustitucion/2 que reciba una lista no vacia de terminos y una
%lista con el formato de una sustitucion y realice lo siguiente:
% -En caso de que la sustitucion ingresada no sea valida, debera mostrarse el correspondiente mensaje de error
% -En caso que la sustitucion ingresada sea valida y todos los terminos de la lista puedan ser 
%   unificados utilizando la sustitucion dada, imprimir por pantalla el termino resultante.
% -En caso que la sustitucion ingresada sea valida pero no sea posible unificar todos los terminos de la lista
%   debera mostrarse por pantalla un mensaje que indique lo ocurrido

unificadosPorSustitucion(A,B) :- \+sustitucion_valida(B),write("ERROR: La sustitucion ingresada no es valida").
unificadosPorSustitucion(A,B) :- sustitucion_valida(B),sustituir(A,B),write(A). %Ahora tengo que iniciar la sustitucion
sustituir(L,[]) :- true.
sustituir(L, [(A1,B1) | T1]) :- pertenece_functor(A1,B1,L),sustituir(L,T1). %Buscar en la cadena 1 si esta la variable
pertenece_sustituir(E,V,[],ListaNueva) :- write("ERROR: La variable no pertenece").
pertenece_sustituir(E,V,[(A,B)|T],ListaNueva) :- E == A, B is V.
pertenece_sustituir(E,V,[(A,B)|T],ListaNueva) :- E\== A, pertenece_sustituir(E,V,T,ListaNueva).

pertenece_functor(E,V,[]) :- true.
pertenece_functor(E,V,[F | T]) :-   functor(F,Q,W),W\==0,nonvar(Q),caracter_valido(Q),chequear_sustituir_args(F,W,E,V),pertenece_functor(E,V,T).
chequear_sustituir_args(F,1,E,V) :- arg(1,F,X),nonvar(X).
chequear_sustituir_args(F,1,E,V) :- arg(1,F,X),var(X),X == E, X =V. 
chequear_sustituir_args(F,1,E,V) :- arg(1,F,X),var(X),X \== E.
chequear_sustituir_args(F,W,E,V) :- arg(W,F,X),nonvar(X),H is W - 1,chequear_sustituir_args(F,H,E,V). 
chequear_sustituir_args(F,W,E,V) :- arg(W,F,X),var(X),X \== E,H is W - 1,chequear_sustituir_args(F,H,E,V).
chequear_sustituir_args(F,W,E,V) :- arg(W,F,X),var(X),X == E, H is W - 1, X =V,chequear_sustituir_args(F,H,E,V).

imprimirLista([]) :- nl.
imprimirLista([H | T]) :- write(H),imprimirLista(T).


prueba(T,L,NuevaLista):-append(T,['('],T), append(T,L,NuevaLista).
add(L,[]):- true.
add(L, Lista,ListaNueva):- append([L],[Lista], ListaNueva).


pruebaNueva(L) :- sus(L),write(L).
sus([P|T]):- P = e.