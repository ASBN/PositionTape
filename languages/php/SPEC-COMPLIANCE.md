# SPEC-COMPLIANCE — php

- Language: PHP
- Runtime/compiler: not available in this local environment
- Conformance level: 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with SHA-256 fixed-size windows using PHP standard `hash`
- Logger integration: not implemented
- Known limitations: local `php` is missing, so PHP tests were not executed in this environment
- Verified locally: `php .\languages\php\tests\position_tape_test.php`.
- Fixture SHA-256 verified: covered by `languages/php/tests/position_tape_test.php`.
