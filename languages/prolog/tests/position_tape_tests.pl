:- working_directory(RepoRoot, RepoRoot),
   directory_file_path(RepoRoot, 'languages/prolog/src/position_tape.pl', SourcePath),
   use_module(SourcePath).

:- initialization(main, main).

assert_true(Condition, Message) :-
    (   call(Condition)
    ->  true
    ;   format(user_error, 'FAIL: ~w~n', [Message]),
        halt(1)
    ).

main :-
    generate(0, Empty),
    assert_true(Empty == "", 'zero length'),
    generate(11, Basic),
    assert_true(Basic == "12345678911", 'basic generation'),
    generate(100, ExactBoundary),
    string_length(ExactBoundary, ExactBoundaryLength),
    assert_true(ExactBoundaryLength =:= 100, 'exact boundary'),
    generate_marker_complete(100, Complete100),
    string_length(Complete100, Complete100Length),
    assert_true(Complete100Length =:= 101, 'marker complete 100'),
    generate_marker_complete(10000, Complete10000),
    string_length(Complete10000, Complete10000Length),
    assert_true(Complete10000Length =:= 10003, 'marker complete 10000'),
    generate(250, ValidTape),
    validate(ValidTape, 250, validation_result(true, 250, 250, none, none)),
    generate(40, TruncatedTape),
    validate(TruncatedTape, 50, validation_result(false, 50, 40, 41, _)),
    generate(60, Expected60),
    sub_string(Expected60, 0, 19, _, Prefix),
    sub_string(Expected60, 20, _, 0, SuffixTail),
    string_concat(Prefix, "X", MutatedPrefix),
    string_concat(MutatedPrefix, SuffixTail, Mutated),
    find_first_mismatch(Expected60, Mutated, mismatch(20, _, 'X')),
    generate(75, Tape75),
    find_truncation_point(Tape75, 76),
    generate(80, Tape80),
    sub_string(Tape80, 29, 12, _, Fragment),
    locate(Fragment, 30),
    generate(600, Tape600),
    sub_string(Tape600, 198, 16, _, HashFragment),
    hash_fragment(HashFragment, Hash),
    locate_by_hash(Hash, 16, Positions),
    assert_true(member(199, Positions), 'locate by hash'),
    writeln('OK prolog'),
    halt(0).
