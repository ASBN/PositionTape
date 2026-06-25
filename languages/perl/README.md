# PositionTape for perl

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```perl
use lib "src";
use PositionTape qw(Generate GenerateMarkerComplete Validate);

my $exact = Generate(10000);
my $marker_complete = GenerateMarkerComplete(10000);
my $validation = Validate($exact, 10000);
```

## Verify

```powershell
perl .\languages\perl\tests\position_tape_test.pl
```
