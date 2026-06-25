:- use_module('../src/position_tape').

:- initialization(main, main).

main :-
    generate(120, Tape),
    writeln(Tape),
    locate("9910", Position),
    writeln(Position).
