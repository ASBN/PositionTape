use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use FindBin qw($Bin);
use lib "$Bin/../src";
use PositionTape qw(
  Generate GenerateMarkerComplete Locate Validate FindTruncationPoint
  FindFirstMismatch BuildWindowIndex LocateByHash HashFragment
);

sub assert_equal {
    my ($expected, $actual, $message) = @_;
    die "$message: got <$actual>, want <$expected>\n" if !defined($expected) || !defined($actual) || $expected ne $actual;
}

assert_equal("", Generate(0), "Generate(0)");
assert_equal("1234567891", Generate(10), "Generate(10)");
assert_equal(101, length(GenerateMarkerComplete(100)), "GenerateMarkerComplete(100)");
assert_equal(10003, length(GenerateMarkerComplete(10000)), "GenerateMarkerComplete(10000)");

my $expected = Generate(50);
assert_equal(1, Validate($expected, 50)->{is_valid}, "valid result");
assert_equal(18, Validate(substr($expected, 0, 17), 50)->{truncation_point}, "truncation point");
assert_equal(4, FindTruncationPoint("123X"), "mismatch point");
assert_equal(13, FindFirstMismatch($expected, substr($expected, 0, 12) . "X" . substr($expected, 13))->{position}, "mismatch");

my $fragment = substr(Generate(80), 29, 12);
my $hash = HashFragment($fragment);
assert_equal(30, Locate($fragment), "Locate");
die "BuildWindowIndex missing position 30\n" unless grep { $_ == 30 } @{ BuildWindowIndex(length($fragment))->{$hash} };
die "LocateByHash missing position 30\n" unless grep { $_ == 30 } @{ LocateByHash(uc($hash), length($fragment)) };

open my $manifest_fh, "<:raw", "$Bin/../../../fixtures/manifest.generated.json" or die $!;
my $manifest = do { local $/; <$manifest_fh> };
while ($manifest =~ /"file":\s*"([^"]+)".*?"bytes":\s*(\d+).*?"sha256":\s*"([^"]+)"/gs) {
    my ($file, $bytes, $sha) = ($1, $2, $3);
    open my $fixture_fh, "<:raw", "$Bin/../../../fixtures/$file" or die $!;
    my $raw = do { local $/; <$fixture_fh> };
    assert_equal($bytes, length($raw), "$file bytes");
    assert_equal($sha, sha256_hex($raw), "$file sha256");
    die "$file has UTF-8 BOM\n" if substr($raw, 0, 3) eq "\xef\xbb\xbf";
    die "$file has trailing newline\n" if $raw =~ /[\r\n]\z/;
}

print "OK perl position_tape\n";
