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
assert_true
  (hash_fragment "" = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
  "sha256 empty";;
assert_true
  (hash_fragment "abc" = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
  "sha256 abc";;
let hash = hash_fragment fragment;;
let index = build_window_index (String.length fragment);;
assert_true (List.mem 30 (Hashtbl.find index hash)) "hash index";;
assert_true (List.mem 30 (locate_by_hash (String.uppercase_ascii hash) (String.length fragment))) "locate by hash";;

print_endline "OK ocaml";;
