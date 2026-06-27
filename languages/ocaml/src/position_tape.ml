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

type hash_window_index = (string, int list) Hashtbl.t

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

let run_perl_sha script args =
  let script_file = Filename.temp_file "position-tape-" ".pl" in
  let channel = open_out script_file in
  output_string channel script;
  close_out channel;
  let command =
    String.concat " "
      ("perl" :: Filename.quote script_file :: List.map Filename.quote args)
  in
  let status = Sys.command command in
  Sys.remove script_file;
  if status <> 0 then failwith "Perl Digest::SHA command failed"

let hash_fragment fragment =
  let input_file = Filename.temp_file "position-tape-fragment-" ".txt" in
  let output_file = Filename.temp_file "position-tape-hash-" ".txt" in
  let input_channel = open_out_bin input_file in
  output_string input_channel fragment;
  close_out input_channel;
  let script =
    String.concat "\n"
      [
        "use Digest::SHA qw(sha256_hex);";
        "my ($input, $output) = @ARGV;";
        "open my $in, '<:raw', $input or die $!;";
        "local $/;";
        "my $fragment = <$in>;";
        "open my $out, '>:raw', $output or die $!;";
        "print $out sha256_hex($fragment);";
      ]
  in
  run_perl_sha script [ input_file; output_file ];
  let output_channel = open_in output_file in
  let hash = input_line output_channel |> String.lowercase_ascii in
  close_in output_channel;
  Sys.remove input_file;
  Sys.remove output_file;
  hash

let build_window_index window_size =
  if window_size <= 0 then invalid_arg "window_size must be positive";
  if window_size > default_search_length then
    invalid_arg "window_size cannot exceed default search length";
  let tape = generate default_search_length in
  let input_file = Filename.temp_file "position-tape-search-" ".txt" in
  let output_file = Filename.temp_file "position-tape-index-" ".txt" in
  let input_channel = open_out_bin input_file in
  output_string input_channel tape;
  close_out input_channel;
  let script =
    String.concat "\n"
      [
        "use Digest::SHA qw(sha256_hex);";
        "my ($window_size, $input, $output) = @ARGV;";
        "open my $in, '<:raw', $input or die $!;";
        "local $/;";
        "my $tape = <$in>;";
        "open my $out, '>:raw', $output or die $!;";
        "my $last = length($tape) - $window_size;";
        "for (my $offset = 0; $offset <= $last; $offset++) {";
        "  print $out sha256_hex(substr($tape, $offset, $window_size)), qq(\\t), $offset + 1, qq(\\n);";
        "}";
      ]
  in
  run_perl_sha script [ string_of_int window_size; input_file; output_file ];
  let index : hash_window_index = Hashtbl.create default_search_length in
  let output_channel = open_in output_file in
  (try
     while true do
       let line = input_line output_channel in
       let separator = String.index line '\t' in
       let hash = String.sub line 0 separator |> String.lowercase_ascii in
       let position =
         String.sub line (separator + 1) (String.length line - separator - 1)
         |> int_of_string
       in
       let existing =
         match Hashtbl.find_opt index hash with Some positions -> positions | None -> []
       in
       Hashtbl.replace index hash (position :: existing)
     done
   with End_of_file -> ());
  close_in output_channel;
  Hashtbl.iter (fun hash positions -> Hashtbl.replace index hash (List.rev positions)) index;
  Sys.remove input_file;
  Sys.remove output_file;
  index

let locate_by_hash fragment_hash window_size =
  let index = build_window_index window_size in
  let hash = String.trim fragment_hash |> String.lowercase_ascii in
  match Hashtbl.find_opt index hash with Some positions -> positions | None -> []

let generateMarkerComplete = generate_marker_complete
let findFirstMismatch = find_first_mismatch
let findTruncationPoint = find_truncation_point
let buildWindowIndex = build_window_index
let locateByHash = locate_by_hash
