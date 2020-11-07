construirAD(InputFile,OutputFile):-not(checkEmpty(InputFile)),leer(InputFile).
checkEmpty(File):-open(File,read,Str),isEmpty(Str).
ejemplo(A):-write("HELLO, "),write(A),write(".\n").

isEmpty(Str):-at_end_of_stream(Str).

leer(InputFile) :-
    open(InputFile, read, Str),
    read_file(Str,Lines),
    close(Str),!.

read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
    \+ at_end_of_stream(Stream),
    read(Stream,X),
    call(X),
    read_file(Stream,L).