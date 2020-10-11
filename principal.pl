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
sustitucion_valida(X) :- \+is_list(X),write("ERROR: El parametro ingresado no es una lista."),false.
sustitucion_valida([]) :- true.
sustitucion_valida([(A,B)| R]) :- pertenece(A,R),imprimir_error.
sustitucion_valida([(A,B)| R]) :- \+pertenece(A,R),valido(A,B),sustitucion_valida(R).
pertenece(E,[(A,_) | T]) :- E == A.
pertenece(E,[(A,_) | T]) :- E \== A, pertenece(E,T).
valido(A,_) :- nonvar(A),imprimir_error.
valido(_,B) :- \+caracter_valido(B),imprimir_error.
valido(A,B) :- var(A),caracter_valido(B). %Esto es para el caso simple [(A,b),(C,d),...,(N,n)]
imprimir_error :- write("ERROR: La sustitucion ingresada no es valida"),false.
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
caracter_valido(A) :- functor(A,B,N),caracter_valido(B).


