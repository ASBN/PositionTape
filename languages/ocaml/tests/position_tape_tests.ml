#directory "languages/ocaml/src";;
#use "position_tape.ml";;

let assert_true condition message =
  if not condition then (prerr_endline ("FAIL: " ^ message); exit 1)
;;

assert_true (generate 0 = "") "zero length";;
assert_true (generate 11 = "12345678911") "basic generation";;
assert_true (String.length (generate 100) = 100) "exact boundary";;
assert_true (String.length (generate_marker_complete 100) = 101) "marker complete 100";;
assert_true (String.length (generate_marker_complete 10000) = 10003) "marker complete 10000";;

let valid = validate (generate 250) 250;;
assert_true valid.is_valid "valid tape";;

let truncated = validate (generate 40) 50;;
assert_true (not truncated.is_valid) "truncated invalid";;
assert_true (truncated.truncation_point = Some 41) "truncation point";;

let mutated = Bytes.of_string (generate 60);;
Bytes.set mutated 19 'X';;
let mismatch = find_first_mismatch (generate 60) (Bytes.to_string mutated);;
assert_true ((Option.get mismatch).position = 20) "first mismatch";;

assert_true (find_truncation_point (generate 75) = 76) "find truncation";;
let fragment = String.sub (generate 80) 29 12;;
assert_true (locate fragment = 30) "locate fragment";;

print_endline "OK ocaml";;
