# SPEC-COMPLIANCE — ruby

- Language: Ruby
- Runtime/compiler: not available in this local environment
- Conformance level: 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with SHA-256 fixed-size windows using Ruby standard `digest`
- Logger integration: not implemented
- Known limitations: local `ruby` is missing, so Ruby tests were not executed in this environment
- Fixture SHA-256 verified: covered by `languages/ruby/tests/position_tape_test.rb`, not locally executed
