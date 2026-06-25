# SPEC-COMPLIANCE — perl

- Language: Perl
- Runtime/compiler: not available in this local environment
- Conformance level: 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with SHA-256 fixed-size windows using Perl standard `Digest::SHA`
- Logger integration: not implemented
- Known limitations: local `perl` is missing, so Perl tests were not executed in this environment
- Fixture SHA-256 verified: covered by `languages/perl/tests/position_tape_test.pl`, not locally executed
