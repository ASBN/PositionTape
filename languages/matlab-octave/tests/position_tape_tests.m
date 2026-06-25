addpath('languages/matlab-octave/src');

assert(strcmp(Generate(0), ''));
assert(strcmp(Generate(11), '12345678911'));
assert(length(Generate(100)) == 100);
assert(length(GenerateMarkerComplete(100)) == 101);
assert(length(GenerateMarkerComplete(10000)) == 10003);

valid = Validate(Generate(250), 250);
assert(valid.isValid);

truncated = Validate(Generate(40), 50);
assert(~truncated.isValid);
assert(truncated.truncationPoint == 41);

mutated = Generate(60);
mutated(20) = 'X';
mismatch = FindFirstMismatch(Generate(60), mutated);
assert(mismatch.position == 20);

assert(FindTruncationPoint(Generate(75)) == 76);
generated80 = Generate(80);
fragment = generated80(30:41);
assert(Locate(fragment) == 30);

disp('OK matlab-octave');
