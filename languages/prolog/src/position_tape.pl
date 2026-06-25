:- module(position_tape, [
    generate/2,
    generate_marker_complete/2,
    get_marker_complete_length/2,
    locate/2,
    validate/3,
    find_truncation_point/2,
    find_first_mismatch/3,
    hash_fragment/2,
    build_window_index/2,
    locate_by_hash/3
]).

:- use_module(library(crypto)).
:- use_module(library(pairs)).

default_search_length(100003).

generate(Length, Text) :-
    must_be(nonneg, Length),
    gen_codes(1, Length, Codes, []),
    string_codes(Text, Codes).

gen_codes(_, 0, Tail, Tail) :- !.
gen_codes(Cursor, Remaining, Codes, Tail) :-
    Cursor mod 10 =:= 0,
    !,
    MarkerValue is Cursor // 10,
    number_codes(MarkerValue, MarkerCodes),
    length(MarkerCodes, MarkerLength),
    take_at_most(Remaining, MarkerCodes, ChunkCodes),
    length(ChunkCodes, ChunkLength),
    append_dl(ChunkCodes, Codes, Next),
    NextCursor is Cursor + MarkerLength,
    NextRemaining is Remaining - ChunkLength,
    gen_codes(NextCursor, NextRemaining, Next, Tail).
gen_codes(Cursor, Remaining, [DigitCode|Rest], Tail) :-
    Digit is Cursor mod 10,
    DigitCode is 0'0 + Digit,
    NextCursor is Cursor + 1,
    NextRemaining is Remaining - 1,
    gen_codes(NextCursor, NextRemaining, Rest, Tail).

take_at_most(0, _, []) :- !.
take_at_most(_, [], []) :- !.
take_at_most(N, [Head|Rest], [Head|Taken]) :-
    N > 0,
    Next is N - 1,
    take_at_most(Next, Rest, Taken).

append_dl([], Tail, Tail).
append_dl([Head|Rest], [Head|Out], Tail) :-
    append_dl(Rest, Out, Tail).

get_marker_complete_length(Length, CompleteLength) :-
    must_be(nonneg, Length),
    marker_complete_cursor(1, Length, CompleteLength).

marker_complete_cursor(Cursor, Length, Length) :-
    Cursor > Length,
    !.
marker_complete_cursor(Cursor, Length, CompleteLength) :-
    Cursor mod 10 =:= 0,
    !,
    MarkerValue is Cursor // 10,
    number_codes(MarkerValue, MarkerCodes),
    length(MarkerCodes, MarkerLength),
    MarkerEnd is Cursor + MarkerLength - 1,
    (   Length < MarkerEnd
    ->  CompleteLength = MarkerEnd
    ;   NextCursor is Cursor + MarkerLength,
        marker_complete_cursor(NextCursor, Length, CompleteLength)
    ).
marker_complete_cursor(Cursor, Length, CompleteLength) :-
    NextCursor is Cursor + 1,
    marker_complete_cursor(NextCursor, Length, CompleteLength).

generate_marker_complete(Length, Text) :-
    get_marker_complete_length(Length, CompleteLength),
    generate(CompleteLength, Text).

find_first_mismatch(Expected, Received, Mismatch) :-
    string_chars(Expected, ExpectedChars),
    string_chars(Received, ReceivedChars),
    first_mismatch_chars(ExpectedChars, ReceivedChars, 1, Mismatch).

first_mismatch_chars([], [], _, none) :- !.
first_mismatch_chars([Expected|_], [], Position, mismatch(Position, Expected, none)) :- !.
first_mismatch_chars([], [Received|_], Position, mismatch(Position, none, Received)) :- !.
first_mismatch_chars([Expected|ExpectedRest], [Received|ReceivedRest], Position, Mismatch) :-
    (   Expected \= Received
    ->  Mismatch = mismatch(Position, Expected, Received)
    ;   NextPosition is Position + 1,
        first_mismatch_chars(ExpectedRest, ReceivedRest, NextPosition, Mismatch)
    ).

validate(ReceivedText, ExpectedLength, validation_result(IsValid, ExpectedLength, ReceivedLength, TruncationPoint, Mismatch)) :-
    generate(ExpectedLength, Expected),
    find_first_mismatch(Expected, ReceivedText, Mismatch),
    string_length(ReceivedText, ReceivedLength),
    (   Mismatch == none
    ->  IsValid = true,
        TruncationPoint = none
    ;   IsValid = false,
        (   ReceivedLength < ExpectedLength,
            sub_string(Expected, 0, ReceivedLength, _, ReceivedText)
        ->  TruncationPoint is ReceivedLength + 1
        ;   TruncationPoint = none
        )
    ).

find_truncation_point(ReceivedText, Position) :-
    string_length(ReceivedText, ReceivedLength),
    generate(ReceivedLength, Expected),
    find_first_mismatch(Expected, ReceivedText, Mismatch),
    (   Mismatch = mismatch(Position, _, _)
    ->  true
    ;   Position is ReceivedLength + 1
    ).

locate("", 1) :- !.
locate(Fragment, Position) :-
    default_search_length(SearchLength),
    generate(SearchLength, Tape),
    (   sub_string(Tape, Before, _, _, Fragment)
    ->  Position is Before + 1
    ;   Position = -1
    ).

hash_fragment(Fragment, Hash) :-
    crypto_data_hash(Fragment, Hash, [algorithm(sha256), encoding(utf8)]).

build_window_index(WindowSize, Index) :-
    must_be(positive_integer, WindowSize),
    default_search_length(SearchLength),
    WindowSize =< SearchLength,
    generate(SearchLength, Tape),
    LastOffset is SearchLength - WindowSize,
    findall(Hash-Position,
        (
            between(0, LastOffset, Offset),
            sub_string(Tape, Offset, WindowSize, _, Fragment),
            hash_fragment(Fragment, Hash),
            Position is Offset + 1
        ),
        Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Index).

locate_by_hash(FragmentHash, WindowSize, Positions) :-
    normalize_hash(FragmentHash, NormalizedHash),
    build_window_index(WindowSize, Index),
    (   member(NormalizedHash-Positions, Index)
    ->  true
    ;   Positions = []
    ).

normalize_hash(Hash, NormalizedHash) :-
    (   atom(Hash)
    ->  downcase_atom(Hash, NormalizedHash)
    ;   string(Hash)
    ->  string_lower(Hash, LowerString),
        atom_string(NormalizedHash, LowerString)
    ;   atom_string(HashAtom, Hash),
        downcase_atom(HashAtom, NormalizedHash)
    ).
