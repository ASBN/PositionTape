import '../src/position_tape.dart' as pt;

void main() {
  final exact = pt.Generate(100);
  final markerComplete = pt.GenerateMarkerComplete(1000);
  final validation = pt.Validate(exact, 100);

  print(exact);
  print(markerComplete.length);
  print(validation.isValid);
}
