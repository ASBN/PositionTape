use "languages/standard-ml/src/position_tape.sml";

fun require condition message =
  if condition then () else raise Fail message;

fun requireEqual expected actual message =
  require (expected = actual) (message ^ ": got " ^ actual ^ ", want " ^ expected);

val _ = requireEqual "" (PositionTape.generate 0) "Generate(0)";
val _ = requireEqual "1234567891" (PositionTape.generate 10) "Generate(10)";
val _ = requireEqual "12345678911234567892" (PositionTape.generate 20) "Generate(20)";
val _ = require (String.size (PositionTape.generate 100) = 100) "Generate(100) length";

val _ = require (PositionTape.generateMarkerComplete 99 = PositionTape.generate 99) "marker complete 99";
val _ = require (PositionTape.generateMarkerComplete 100 = PositionTape.generate 101) "marker complete 100";
val _ = require (String.size (PositionTape.generateMarkerComplete 1000) = 1002) "marker complete 1000";
val _ = require (String.size (PositionTape.generateMarkerComplete 10000) = 10003) "marker complete 10000";

val expected = PositionTape.generate 50;
val PositionTape.ValidationResult { is_valid, ... } = PositionTape.validate (expected, 50);
val _ = require is_valid "valid result";
val PositionTape.ValidationResult { truncation_point, ... } = PositionTape.validate (String.substring (expected, 0, 17), 50);
val _ = require (truncation_point = SOME 18) "truncation point";
val _ = require (PositionTape.findTruncationPoint "123X" = 4) "mismatch point";

val fragment = String.substring (PositionTape.generate 80, 29, 12);
val hash = PositionTape.hashFragment fragment;
val _ = require (PositionTape.locate fragment = 30) "locate";
val _ = require (List.exists (fn position => position = 30) (PositionTape.locateByHash (String.map Char.toUpper hash, String.size fragment))) "locate by hash";
val _ = require (PositionTape.hashFragment (PositionTape.generate 10000) = "9ee39196c3dd959c14600095c165c237d0b4a7639237cf2bb1bfbee6f3321f5c") "sha256 fixture";

val _ = print "OK standard-ml position_tape\n";
