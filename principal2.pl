sustitucionValida(X) :- \+is_list(X),write("El parametro ingresado no es una lista.").
sustitucionValida([]) :- true.
%Busco repeticiones de variable para cumplir la primera regla de sustitucion
sustitucionValida([(A,_)|T]) :- buscarRepeticion(A,T),imprimirError,true.
%Si se cumple la primer regla voy a revisar la segunda
sustitucionValida([(A,_)|T]) :- \+buscarRepeticion(A,T),\+cumplirSegundaRegla(A,T),imprimirError,true.
%Tengo que chequear la segunda regla con la lista invertida tambien, para evitar errores del tipo [(A,X),(X,b)]
%Si se cumplen las dos entonces puedo avanzar
sustitucionValida([(A,_)|T]) :- \+buscarRepeticion(A,T),cumplirSegundaRegla(A,T),true,!.

buscarRepeticion(A,L) :- pertenece(A,L).
pertenece(_,[]) :- false.
pertenece(E,[(A,_) | _]) :- E == A.
pertenece(E,[(A,_) | T]) :- E \== A, pertenece(E,T).

cumplirSegundaRegla(_,[]) :- true.
cumplirSegundaRegla(E,[(_,B)|T]) :- var(B),chequearArgumento(E,B,0),cumplirSegundaRegla(E,T).
cumplirSegundaRegla(E,[(_,B)|T]) :- nonvar(B),functor(B,_,W),chequearArgumento(E,B,W),cumplirSegundaRegla(E,T).
chequearArgumento(E,B,0) :- E\==B.
chequearArgumento(E,B,W) :- W>0,arg(W,B,X),var(X),X\==E,Q is W-1,chequearArgumento(E,B,Q).
chequearArgumento(E,B,W) :- W>0,arg(W,B,X),nonvar(X),functor(X,_,Cantidad),Cantidad==0,X\==E,Q is W-1,chequearArgumento(E,B,Q).
chequearArgumento(E,B,W) :- W>0,arg(W,B,X),nonvar(X),functor(X,_,Cantidad),Cantidad\==0,chequearArgumento(E,X,Cantidad),X\==E,Q is W-1,chequearArgumento(E,B,Q).
imprimirError :- write("La sustitucion ingresada no es valida").


%Ahora tengo que sustituir y ver si unifican
unificadosPorSustitucion(_,B) :- \+sustitucionValida(B),write("La sustitucion ingresada no es valida"),true,!.
unificadosPorSustitucion(A,B) :- L = A,sustitucionValida(B),sustituir(L,B),estaUnificado(L),nth0(0,L,Elemento),write("Es posible unificar la lista de terminos con la sustitucion dada.\n"),write("El termino resultante de aplicar la sustitucion es: "),write(Elemento),true,!. %Ahora tengo que iniciar la sustitucion
unificadosPorSustitucion(A,B) :- sustitucionValida(B),sustituir(A,B),\+estaUnificado(A),write("No es posible unificar la lista de terminos con la sustitucion dada."),true,!.
sustituir(_,[]) :- true.
sustituir(L, [(A1,B1) | T1]) :- pertenece_functor(A1,B1,L),sustituir(L,T1). %Buscar en la cadena 1 si esta la variable




pertenece_functor(_,_,[]) :- true,!.
pertenece_functor(E,V,[F | T]) :-   functor(F,Q,W),W\==0,nonvar(Q),chequear_sustituir_args(F,W,E,V),pertenece_functor(E,V,T).
chequear_sustituir_args(F,1,_,_) :- arg(1,F,X),nonvar(X).
chequear_sustituir_args(F,1,E,V) :- arg(1,F,X),var(X),X == E, X =V. 
chequear_sustituir_args(F,1,E,_) :- arg(1,F,X),var(X),X \== E.
chequear_sustituir_args(F,W,E,V) :- W>1,arg(W,F,X),nonvar(X),H is W - 1,chequear_sustituir_args(F,H,E,V). 
chequear_sustituir_args(F,W,E,V) :- W>1,arg(W,F,X),var(X),X \== E,H is W - 1,chequear_sustituir_args(F,H,E,V).
chequear_sustituir_args(F,W,E,V) :- W>1,arg(W,F,X),var(X),X == E, H is W - 1, X =V,chequear_sustituir_args(F,H,E,V).

estaUnificado([H|T]) :- revisar(H,T).
revisar(_,[]) :- true.
revisar(H,[H1 | T]) :- H == H1, revisar(H1,T).