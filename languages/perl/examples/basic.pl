use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../src";
use PositionTape qw(Generate GenerateMarkerComplete Validate);

my $exact = Generate(100);
my $marker_complete = GenerateMarkerComplete(1000);
my $validation = Validate($exact, 100);

print "$exact\n";
print length($marker_complete) . "\n";
print ($validation->{is_valid} ? "true" : "false") . "\n";
