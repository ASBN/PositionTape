# SPEC-COMPLIANCE

Validation checkpoint: 2026-06-27 GEN-PT-028 alpha status freeze.

This checkpoint is documentation-only. It freezes the current public alpha
classification after GEN-PT-024 through GEN-PT-027:

- SHA-256 provider policy and shared vectors are defined.
- SQLite Level 3 is verified only when the repo-local SHA-256 loadable
  extension is built and loaded.
- Ada and Delphi/Object Pascal Level 3 are verified with pure SHA-256.
- COBOL has a verified shared C SHA-256 binding probe, but remains Level 1.
- Assembly has a verified minimal Win64 NASM-to-C ABI probe, but remains
  Level 1.
- Objective-C remains source-only/blocked on the local Windows runtime setup.
- MATLAB/Octave remains Level 3 source-only because the hash-window test is
  too slow or unstable on the current Windows Octave path.
- Scratch remains a scaffold/guide only.

Level 3 hash behavior is governed by `docs/spec/hash-provider-policy.md` and
the shared vectors in `fixtures/sha256-vectors.json`. No SHA3 result is
substituted for SHA-256.

## Level 3 Verified

These implementations have locally verified Level 3 behavior without a
repo-local hybrid SHA-256 extension boundary.

| Language | Validation command | Notes |
|---|---|---|
| Ada | `gnatmake -Ilanguages/ada/src languages/ada/tests/position_tape_tests.adb`; `.\position_tape_tests.exe` | Pure Ada SHA-256 vectors and hash-window locate verified; official fixture files not directly checked. |
| C | `cmd /c "vcvars64.bat && cl /nologo /I languages\c\src languages\c\src\position_tape.c languages\c\tests\position_tape_tests.c /Fe:.\toolchain-c-position_tape_tests.exe && .\toolchain-c-position_tape_tests.exe"` | Exact `Generate(10000)` SHA and marker-complete boundaries verified. |
| C++ | `cmake -S .\languages\cpp -B .\languages\cpp\build`; `cmake --build .\languages\cpp\build --config Release`; `ctest --test-dir .\languages\cpp\build --output-on-failure -C Release` | Exact `Generate(10000)` SHA and marker-complete boundaries verified. |
| C# | `dotnet build .\languages\csharp\src\PositionTape\PositionTape.csproj --configuration Release`; `dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj --configuration Release`; `dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release` | Official manifest fixtures verified, including marker-complete fixture. |
| Dart | `$env:DART_SUPPRESS_ANALYTICS='true'; dart .\languages\dart\tests\position_tape_test.dart` | Official manifest fixtures verified, including marker-complete fixture. |
| Delphi/Object Pascal | `fpc -Fulanguages\delphi\src languages\delphi\tests\position_tape_tests.pas`; `languages\delphi\tests\position_tape_tests.exe` | Pure FPC-compatible SHA-256 vectors and hash-window locate verified; official fixture files not directly checked. |
| Fortran | `gfortran .\languages\fortran\src\position_tape.f90 .\languages\fortran\tests\position_tape_tests.f90 -o .\languages\fortran\tests\position_tape_tests.exe`; `.\languages\fortran\tests\position_tape_tests.exe` | API behavior and hash-window behavior verified; official fixture files not directly checked. |
| Go | From `languages/go`: `go test ./...` | Official manifest fixtures verified, including marker-complete fixture. |
| Java | `javac -d .toolchain-logs\java .\languages\java\src\main\java\org\positiontape\*.java .\languages\java\tests\PositionTapeTest.java`; `java -cp .toolchain-logs\java PositionTapeTest` | API behavior verified; official fixture files not directly checked. |
| JavaScript | `node .\languages\javascript\tests\position-tape.test.js` | Official manifest fixtures verified, including marker-complete fixture. |
| Julia | `julia .\languages\julia\tests\position_tape_tests.jl` | Official manifest fixtures verified, including marker-complete fixture. |
| Kotlin | `kotlinc .\languages\kotlin\src\PositionTape.kt .\languages\kotlin\tests\PositionTapeTest.kt -include-runtime -d <temp jar>`; `java -jar <temp jar>` | API behavior and hash-window behavior verified; official fixture files not directly checked. |
| Lua | `lua .\languages\lua\tests\position_tape_tests.lua` | Official manifest fixtures verified, including marker-complete fixture. |
| OCaml | `ocaml languages/ocaml/tests/position_tape_tests.ml` | API behavior and hash-window behavior verified; official fixture files not directly checked. |
| PHP | `php .\languages\php\tests\position_tape_test.php` | API behavior and hash-window behavior verified; official fixture files not directly checked. |
| Prolog | `swipl -q -s languages/prolog/tests/position_tape_tests.pl` | API behavior and hash-window behavior verified; official fixture files not directly checked. |
| Python | `python -m unittest discover .\languages\python\tests` | Official manifest fixtures verified, including marker-complete fixture. |
| R | `Rscript .\languages\r\tests\test_position_tape.R` | API behavior and hash-window behavior verified; official fixture files not directly checked. The full hash-window test took about 208 seconds. |
| Ruby | `ruby .\languages\ruby\tests\position_tape_test.rb` | API behavior and hash-window behavior verified; system-wide `gemrc` permission warning is unrelated. |
| Standard ML | `Get-Content .\languages\standard-ml\tests\position_tape_tests.sml \| sml` | Exact `Generate(10000)` SHA and marker-complete boundaries verified. |
| VB.NET | `dotnet run --project .\languages\vbnet\tests\PositionTape.Tests\PositionTape.Tests.vbproj --configuration Release` | Official manifest fixtures verified, including marker-complete fixture. |

## Level 3 Verified With Extension/Hybrid Provider

| Language | Validation command | Notes |
|---|---|---|
| SQLite | Build: `gcc -shared -O2 -Wall -Wextra -I "C:\Users\alfon\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\include" -o languages\sqlite\extensions\sha256\sha256_extension.dll languages\sqlite\extensions\sha256\sha256_extension.c`; test: `Get-Content languages/sqlite/tests/position_tape_tests.sql \| sqlite3` | Level 3 only when the repo-local `sha256(text)` extension is built and loaded. The generated DLL is a local artifact and must not be committed. SQLite SHA3 is not a substitute. |

## Level 3 Source-Only

These folders contain Level 3 source/API intent, but the current local
checkpoint did not complete full runtime validation.

| Language | Validation command | Current blocker |
|---|---|---|
| MATLAB/Octave | `octave-cli --no-gui --quiet languages/matlab-octave/tests/position_tape_tests.m`; focused pre-index probe with `octave-cli --no-gui --quiet --eval ...` | Octave 11.3.0 is on PATH, but the full test hangs/slows in `BuildWindowIndex(length(fragment))` / `LocateByHash`. The pre-index probe printed `OK octave pre-index` before Octave timed out on exit. |
| Perl | `perl --version`; intended `perl .\languages\perl\tests\position_tape_test.pl` | Not rerun in this checkpoint. |
| Rust | From `languages/rust`: `cargo test` | Cargo/rustc are present, but local MSVC linking still fails with `LINK : fatal error LNK1104: no se puede abrir el archivo 'msvcrt.lib'`. |
| Swift | `swift --version`; intended `swift test --package-path languages\swift --cache-path .toolchain-cache\swiftpm` | Swift 6.3.2 crashes under the current Visual Studio 2026/18 environment with `unsupported toolset layout (VS2017+ required)`. |

## Level 2 Verified

No Level 2-only implementation is locally verified in this checkpoint. Current
verified implementations are either Level 3, Level 3 with the SQLite extension,
or Level 1/scaffold probes.

## Level 2 Source-Only / Blocked

| Language | Validation command | Current blocker |
|---|---|---|
| Objective-C | Intended macOS command: `clang -fobjc-arc -framework Foundation languages/objective-c/src/PositionTape.m languages/objective-c/tests/PositionTapeTests.m -o languages/objective-c/tests/PositionTapeTests`; `languages/objective-c/tests/PositionTapeTests` | Source implements Level 2 APIs, but local Windows validation is blocked. Available Clang lacks a Foundation-capable modern Objective-C runtime, reports ARC unsupported on legacy runtime, and cannot find standard C headers for no-Foundation shared-C-provider probes. |

## Level 1/Scaffold

| Language | Validation command | Current status |
|---|---|---|
| Assembly | Linux/WSL intended: `sh languages/assembly/tests/verify_position_tape_100.sh`; local probes: `nasm -f elf64 languages/assembly/src/position_tape.asm -o <temp object>` and a temporary Win64 NASM function linked through a C harness | Level 1 generator source only. The checked-in program targets Linux syscalls. GEN-PT-027 proved a future Win64 callable-object direction, not PositionTape Level 3. |
| COBOL | With `COB_CONFIG_DIR`, `CPATH`, and `LIBRARY_PATH` set to MSYS2 UCRT64 paths: `cobc -free -x -o <temp exe> languages/cobol/tests/position_tape_tests.cob`; `<temp exe>`; `cobc -free -x -I tools/native/sha256 -o <temp exe> languages/cobol/tests/sha256_hybrid_tests.cob tools/native/sha256/position_tape_sha256.c`; `<temp exe>` | Level 1 generator verified plus shared C SHA-256 binding vectors. Full diagnostics, direct locate, and hash-window APIs are not implemented. |
| Scratch | Manual guide review only | Text guide/scaffold only. No `.sb3` project or headless verification runtime exists in this alpha. |

## Blocked/Deferred

| Language | Reason |
|---|---|
| Objective-C | Deferred for local Windows runtime/toolchain setup despite Level 2 source. |
| MATLAB/Octave | Deferred for performance/stability of `BuildWindowIndex` / `LocateByHash` despite Level 3 source. |
| Perl | Deferred until test command is rerun in a clean local or CI checkpoint. |
| Rust | Deferred on local MSVC linker library discovery. |
| Swift | Deferred on Swift-on-Windows toolset compatibility. |
| Assembly | Deferred until a callable API and exact SHA-256 hash-window path exist. |
| COBOL | Deferred until full diagnostics, direct locate, and exact SHA-256 hash-window APIs exist. |
| Scratch | Deferred until a concrete executable Scratch project and verification path exist. |
