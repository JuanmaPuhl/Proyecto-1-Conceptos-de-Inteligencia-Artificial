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
sustitucion_valida([(A,B)| R]) :- valido(A,B),sustitucion_valida(R).
valido(A,_) :- nonvar(A),write("ERROR: La sustitucion ingresada no es valida"),false.
valido(_,B) :- var(B),write("ERROR: La sustitucion ingresada no es valida"),false.
valido(A,B) :- var(A),nonvar(B). %Esto es para el caso simple [(A,b),(C,d),...,(N,n)]
%se admite cualquier valor para B, debo hacer que chequee los valores correctos
%Tengo que ver para el caso en el que el valor es una funcion


