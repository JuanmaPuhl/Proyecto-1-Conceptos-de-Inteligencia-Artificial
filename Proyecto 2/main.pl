:- dynamic ejemplo/2.
construirAD(InputFile,OutputFile):- \+checkEmpty(InputFile), consult(InputFile), findall(X, ejemplo(_,X), L), length(L,Size), write(Size),write(L).

checkEmpty(File):-open(File,read,Str),isEmpty(Str).




isEmpty(Str):-at_end_of_stream(Str).

leer(InputFile) :- open(InputFile, read, Str), read_file(Str,Lines), close(Str),!.

read_file(Stream,[]) :- at_end_of_stream(Stream).

read_file(Stream,[X|L]) :- \+ at_end_of_stream(Stream), read(Stream,X), call(X), read_file(Stream,L).