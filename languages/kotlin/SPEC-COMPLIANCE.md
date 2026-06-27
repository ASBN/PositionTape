# SPEC-COMPLIANCE — kotlin

- Language: Kotlin/JVM
- Runtime/compiler: not available in this local environment
- Conformance level: 3 source implementation
- Generate: implemented
- GenerateMarkerComplete: implemented
- Validate: implemented
- Locate: implemented with a default 100,003-character search window
- Hash index: implemented with SHA-256 fixed-size windows using JVM standard `MessageDigest`
- Logger integration: not implemented
- Known limitations: local `kotlinc` is missing, so Kotlin tests were not executed in this environment
- Verified locally: `kotlinc .\languages\kotlin\src\PositionTape.kt .\languages\kotlin\tests\PositionTapeTest.kt -include-runtime -d <temp jar>` then `java -jar <temp jar>`.
- Fixture SHA-256 verified: covered by `languages/kotlin/tests/PositionTapeTest.kt`.
