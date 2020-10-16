sustitucionValida(X) :- \+is_list(X),write("ERROR: El parametro ingresado no es una lista.").
sustitucionValida([]) :- true.
%Busco repeticiones de variable para cumplir la primera regla de sustitucion
sustitucionValida([(A,B)|T]) :- buscarRepeticion(A,T),imprimirError.
%Si se cumple la primer regla voy a revisar la segunda
sustitucionValida([(A,B)|T]) :- \+buscarRepeticion(A,T),\+cumplirSegundaRegla(A,T),imprimirError.
%Tengo que chequear la segunda regla con la lista invertida tambien, para evitar errores del tipo [(A,X),(X,b)]
%Si se cumplen las dos entonces puedo avanzar
sustitucionValida([(A,B)|T]) :- \+buscarRepeticion(A,T),cumplirSegundaRegla(A,T),write("Todo legal, todo correcto.").

buscarRepeticion(A,L) :- pertenece(A,L).
pertenece(E,[]) :- false.
pertenece(E,[(A,_) | T]) :- E == A.
pertenece(E,[(A,_) | T]) :- E \== A, pertenece(E,T).

cumplirSegundaRegla(E,[]) :- true.
cumplirSegundaRegla(E,[(A,B)|T]) :- var(B),chequearArgumento(E,B,0),cumplirSegundaRegla(E,T).
cumplirSegundaRegla(E,[(A,B)|T]) :- nonvar(B),functor(B,Q,W),chequearArgumento(E,B,W),cumplirSegundaRegla(E,T).
chequearArgumento(E,B,0) :- E\==B.
chequearArgumento(E,B,W) :- W>0,arg(W,B,X),var(X),X\==E,Q is W-1,chequearArgumento(E,B,Q).
chequearArgumento(E,B,W) :- W>0,arg(W,B,X),nonvar(X),functor(X,Nombre,Cantidad),Cantidad==0,X\==E,Q is W-1,chequearArgumento(E,B,Q).
chequearArgumento(E,B,W) :- W>0,arg(W,B,X),nonvar(X),functor(X,Nombre,Cantidad),Cantidad\==0,chequearArgumento(E,X,Cantidad),X\==E,Q is W-1,chequearArgumento(E,B,Q).
imprimirError :- write("ERROR: La sustitucion ingresada no es valida").