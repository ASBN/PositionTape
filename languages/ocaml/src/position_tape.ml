let default_search_length = 100_003

type mismatch = {
  position : int;
  expected : char option;
  received : char option;
}

type validation_result = {
  is_valid : bool;
  expected_length : int;
  received_length : int;
  truncation_point : int option;
  first_mismatch : mismatch option;
}

let generate length =
  if length < 0 then invalid_arg "length must be non-negative";
  let buffer = Buffer.create length in
  let rec loop cursor =
    if Buffer.length buffer < length then
      if cursor mod 10 = 0 then
        let marker = string_of_int (cursor / 10) in
        let remaining = length - Buffer.length buffer in
        let chunk_length = min (String.length marker) remaining in
        Buffer.add_substring buffer marker 0 chunk_length;
        loop (cursor + String.length marker)
      else (
        Buffer.add_char buffer (Char.chr (Char.code '0' + (cursor mod 10)));
        loop (cursor + 1))
  in
  loop 1;
  Buffer.contents buffer

let get_marker_complete_length length =
  if length < 0 then invalid_arg "length must be non-negative";
  let rec loop cursor =
    if cursor > length then length
    else if cursor mod 10 = 0 then
      let marker_length = String.length (string_of_int (cursor / 10)) in
      let marker_end = cursor + marker_length - 1 in
      if length < marker_end then marker_end else loop (cursor + marker_length)
    else loop (cursor + 1)
  in
  loop 1

let generate_marker_complete length = generate (get_marker_complete_length length)

let find_first_mismatch expected received =
  let expected_length = String.length expected in
  let received_length = String.length received in
  let shared_length = min expected_length received_length in
  let rec scan index =
    if index >= shared_length then None
    else if expected.[index] <> received.[index] then
      Some { position = index + 1; expected = Some expected.[index]; received = Some received.[index] }
    else scan (index + 1)
  in
  match scan 0 with
  | Some mismatch -> Some mismatch
  | None when expected_length = received_length -> None
  | None ->
      let position = shared_length + 1 in
      let expected_char = if position <= expected_length then Some expected.[position - 1] else None in
      let received_char = if position <= received_length then Some received.[position - 1] else None in
      Some { position; expected = expected_char; received = received_char }

let validate received_text expected_length =
  let expected = generate expected_length in
  let mismatch = find_first_mismatch expected received_text in
  let truncation_point =
    match mismatch with
    | Some _ when String.length received_text < expected_length
      && String.starts_with ~prefix:received_text expected ->
        Some (String.length received_text + 1)
    | _ -> None
  in
  {
    is_valid = Option.is_none mismatch;
    expected_length;
    received_length = String.length received_text;
    truncation_point;
    first_mismatch = mismatch;
  }

let find_truncation_point received_text =
  match find_first_mismatch (generate (String.length received_text)) received_text with
  | None -> String.length received_text + 1
  | Some mismatch -> mismatch.position

let locate fragment =
  if fragment = "" then 1
  else
    let tape = generate default_search_length in
    let fragment_length = String.length fragment in
    let rec scan offset =
      if offset + fragment_length > String.length tape then -1
      else if String.sub tape offset fragment_length = fragment then offset + 1
      else scan (offset + 1)
    in
    scan 0

let generateMarkerComplete = generate_marker_complete
let findFirstMismatch = find_first_mismatch
let findTruncationPoint = find_truncation_point
