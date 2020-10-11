%Definir un predicado sustitucionValida/1 que reciba una lista de pares
%[(V1,T1),(V2,T2),...,(Vn,Tn)] y determine si se trata de una sustitución
%valida en la que Vi son las variables y Tj son los terminos.
%En caso de que la lista suministrada no se trate de una sustitución valida,
%debera mostrarse por pantalla un mensaje que indique lo ocurrido.
%Podrá asumirse que la lista no contiene dos o más pares exactamente iguales.
%Podrá asumirse que los terminos ingresados son validos.
%Las unicas letras funcionales validas seran las constantes a,b,c,...,z sin incluir ñ
%=====================================================================================%


%Reviso que el parametro ingresado es una lista, 
%no es necesario de todas formas porque se asume lista formada correctamente
sustitucion_valida(X) :- \+is_list(X),write("ERROR: El parametro ingresado no es una lista.").
sustitucion_valida([]) :- true.
sustitucion_valida([(A,B)| R]) :- pertenece(A,R),imprimir_error.
sustitucion_valida([(A,B)| R]) :- \+pertenece(A,R),valido(A,B),sustitucion_valida(R).
pertenece(E,[(A,_) | T]) :- E == A.
pertenece(E,[(A,_) | T]) :- E \== A, pertenece(E,T).
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
chequear_args(A,1) :- arg(1,A,X),nonvar(X),caracter_valido(X). %Debo chequear si es var o nonvar
chequear_args(A,1) :- arg(1,A,X),var(X).
chequear_args(A,N) :- arg(N,A,X),nonvar(X),caracter_valido(X),B is (N-1),chequear_args(A,B).
chequear_args(A,N) :- arg(N,A,X),var(X),B is (N-1),chequear_args(A,B).


