use "languages/standard-ml/src/position_tape.sml";

val exact = PositionTape.generate 100;
val markerComplete = PositionTape.generateMarkerComplete 1000;
val validation = PositionTape.validate (exact, 100);

val _ = print (exact ^ "\n");
val _ = print (Int.toString (String.size markerComplete) ^ "\n");
val PositionTape.ValidationResult { is_valid, ... } = validation;
val _ = print (Bool.toString is_valid ^ "\n");
