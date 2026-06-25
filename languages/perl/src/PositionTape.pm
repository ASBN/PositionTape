package PositionTape;

use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use Exporter qw(import);

our @EXPORT_OK = qw(
  Generate GenerateMarkerComplete GetMarkerCompleteLength Locate Validate
  FindTruncationPoint FindFirstMismatch BuildWindowIndex LocateByHash HashFragment
);

our $DEFAULT_SEARCH_LENGTH = 100003;
my %INDEX_CACHE;

sub _assert_non_negative {
    my ($length, $name) = @_;
    die "$name must be a non-negative integer" if $length !~ /^\d+$/;
}

sub Generate {
    my ($length) = @_;
    _assert_non_negative($length, "length");

    my $output = "";
    my $cursor = 1;
    while (length($output) < $length) {
        if ($cursor % 10 == 0) {
            my $marker = int($cursor / 10);
            my $remaining = $length - length($output);
            $output .= substr($marker, 0, $remaining);
            $cursor += length($marker);
        } else {
            $output .= $cursor % 10;
            $cursor += 1;
        }
    }

    return $output;
}

sub GetMarkerCompleteLength {
    my ($length) = @_;
    _assert_non_negative($length, "length");

    my $cursor = 1;
    while ($cursor <= $length) {
        if ($cursor % 10 == 0) {
            my $marker_length = length(int($cursor / 10));
            my $marker_end = $cursor + $marker_length - 1;
            return $marker_end if $length < $marker_end;
            $cursor += $marker_length;
        } else {
            $cursor += 1;
        }
    }

    return $length;
}

sub GenerateMarkerComplete {
    my ($length) = @_;
    return Generate(GetMarkerCompleteLength($length));
}

sub FindFirstMismatch {
    my ($expected, $received) = @_;
    my $shared_length = length($expected) < length($received) ? length($expected) : length($received);

    for my $index (0 .. $shared_length - 1) {
        my $expected_char = substr($expected, $index, 1);
        my $received_char = substr($received, $index, 1);
        return { position => $index + 1, expected => $expected_char, received => $received_char }
            if $expected_char ne $received_char;
    }

    return undef if length($expected) == length($received);

    my $position = $shared_length + 1;
    return {
        position => $position,
        expected => $position <= length($expected) ? substr($expected, $position - 1, 1) : undef,
        received => $position <= length($received) ? substr($received, $position - 1, 1) : undef,
    };
}

sub Validate {
    my ($received_text, $expected_length) = @_;
    my $expected = Generate($expected_length);
    my $mismatch = FindFirstMismatch($expected, $received_text);
    my $truncation_point;

    if (defined $mismatch && length($received_text) < $expected_length && index($expected, $received_text) == 0) {
        $truncation_point = length($received_text) + 1;
    }

    return {
        is_valid => !defined $mismatch,
        expected_length => $expected_length,
        received_length => length($received_text),
        truncation_point => $truncation_point,
        first_mismatch => $mismatch,
    };
}

sub FindTruncationPoint {
    my ($received_text) = @_;
    my $mismatch = FindFirstMismatch(Generate(length($received_text)), $received_text);
    return defined $mismatch ? $mismatch->{position} : length($received_text) + 1;
}

sub Locate {
    my ($fragment) = @_;
    return 1 if $fragment eq "";
    my $index = index(Generate($DEFAULT_SEARCH_LENGTH), $fragment);
    return $index < 0 ? -1 : $index + 1;
}

sub HashFragment {
    my ($fragment) = @_;
    return sha256_hex($fragment);
}

sub BuildWindowIndex {
    my ($window_size) = @_;
    die "windowSize must be positive" if $window_size !~ /^\d+$/ || $window_size <= 0;
    die "windowSize cannot exceed the default search length" if $window_size > $DEFAULT_SEARCH_LENGTH;

    my $tape = Generate($DEFAULT_SEARCH_LENGTH);
    my %index;
    for my $offset (0 .. length($tape) - $window_size) {
        my $hash = HashFragment(substr($tape, $offset, $window_size));
        push @{ $index{$hash} }, $offset + 1;
    }

    return \%index;
}

sub LocateByHash {
    my ($fragment_hash, $window_size) = @_;
    $fragment_hash =~ s/^\s+|\s+$//g;
    $fragment_hash = lc $fragment_hash;
    $INDEX_CACHE{$window_size} = BuildWindowIndex($window_size) unless exists $INDEX_CACHE{$window_size};
    return [ @{ $INDEX_CACHE{$window_size}{$fragment_hash} || [] } ];
}

1;
