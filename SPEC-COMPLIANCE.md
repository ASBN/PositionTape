# SPEC-COMPLIANCE

Validation checkpoint: 2026-06-26 Level 3 continuation. This checkpoint reran
the portable fixture conformance runner and the C# conformance runner, and
locally verified updated R and Fortran Level 3 APIs. OCaml and MATLAB/Octave
were updated as Level 3 source implementations but remain pending local runtime
validation.

| Language | Level | Verified locally | Validation command | Current blocker | Generate / marker-complete fixture status |
|---|---:|---|---|---|---|
| Ada | 2 | No | `gnat --version`; intended `gnatmake languages/ada/tests/position_tape_tests.adb` | `gnat` is not on PATH | Not locally verified |
| Assembly | 1 | No | WSL/Linux: `nasm -v`; then `sh languages/assembly/tests/verify_position_tape_100.sh` | NASM is available on Windows, but the current program targets Linux x86-64 syscalls and still requires a Linux/WSL linker/runtime path for validation. | Not locally verified |
| C | 3 | Yes | `cmd /c "vcvars64.bat && cl /nologo /I languages\c\src languages\c\src\position_tape.c languages\c\tests\position_tape_tests.c /Fe:.\toolchain-c-position_tape_tests.exe && .\toolchain-c-position_tape_tests.exe"` | None for MSVC path | Exact `Generate(10000)` SHA verified; marker-complete boundary lengths verified |
| COBOL | 1 | No | `cobc -V` | `cobc` is not on PATH | Not locally verified |
| C++ | 3 | Yes | `cmake -S .\languages\cpp -B .\languages\cpp\build`; `cmake --build .\languages\cpp\build --config Release`; `ctest --test-dir .\languages\cpp\build --output-on-failure -C Release` | None | Exact `Generate(10000)` SHA verified; marker-complete boundary lengths verified |
| C# | 3 | Yes | `dotnet build .\languages\csharp\src\PositionTape\PositionTape.csproj --configuration Release`; `dotnet test .\languages\csharp\tests\PositionTape.Tests\PositionTape.Tests.csproj --configuration Release`; `dotnet run --project .\tools\conformance\csharp\PositionTape.Conformance\PositionTape.Conformance.csproj --configuration Release` | NuGet vulnerability index warning only; tests restored and passed | Official manifest fixtures verified, including marker-complete fixture |
| Dart | 3 | Yes | `$env:DART_SUPPRESS_ANALYTICS='true'; dart .\languages\dart\tests\position_tape_test.dart` | None | Official manifest fixtures verified, including marker-complete fixture |
| Delphi/Object Pascal | 2 | No | `fpc -iV` | `fpc` is not on PATH | Not locally verified |
| Fortran | 3 | Yes | `gfortran .\languages\fortran\src\position_tape.f90 .\languages\fortran\tests\position_tape_tests.f90 -o .\languages\fortran\tests\position_tape_tests.exe`; `.\languages\fortran\tests\position_tape_tests.exe` | None for gfortran plus installed Perl `Digest::SHA` | API generation, marker-complete boundaries, locate, and hash-window behavior verified; official fixture files not directly checked |
| Go | 3 | Yes | From `languages/go`: `go test ./...` | None in this checkpoint | Official manifest fixtures verified, including marker-complete fixture |
| Java | 3 | Yes | `javac -d .toolchain-logs\java .\languages\java\src\main\java\org\positiontape\*.java .\languages\java\tests\PositionTapeTest.java`; `java -cp .toolchain-logs\java PositionTapeTest` | None | API generation and marker-complete boundaries verified; official fixture files not directly checked |
| JavaScript | 3 | Yes | `node .\languages\javascript\tests\position-tape.test.js` | None | Official manifest fixtures verified, including marker-complete fixture |
| Julia | 3 | Yes | `julia .\languages\julia\tests\position_tape_tests.jl` | None | Official manifest fixtures verified, including marker-complete fixture |
| Kotlin | 3 | No | `kotlinc -version` | `kotlinc` is not on PATH | Not locally verified |
| Lua | 3 | Yes | `lua .\languages\lua\tests\position_tape_tests.lua` | None | Official manifest fixtures verified, including marker-complete fixture |
| MATLAB/Octave | 3 source | No | `octave --version`; `matlab -batch "run('languages/matlab-octave/tests/position_tape_tests.m')"` | Neither `octave` nor `matlab` is on PATH | Source updated for Level 3 APIs; not locally verified |
| Objective-C | 2 | No | `clang -fobjc-arc -framework Foundation .\languages\objective-c\src\PositionTape.m .\languages\objective-c\tests\PositionTapeTests.m` | Available Clang lacks a Foundation-capable Objective-C runtime and reports ARC unsupported on legacy runtime | Not locally verified |
| OCaml | 3 source | No | From repo root: `ocaml languages/ocaml/tests/position_tape_tests.ml` | `ocaml` is not currently on PATH | Source updated for Level 3 APIs; not locally verified in this checkpoint |
| Perl | 3 | No | `perl --version` | Not rerun in this checkpoint | Not locally verified in this checkpoint |
| PHP | 3 | No | `php --version` | `php` is not on PATH | Not locally verified |
| Prolog | 3 | Yes | From repo root: `swipl -q -s languages/prolog/tests/position_tape_tests.pl` | None for SWI-Prolog 10.0.2 direct test | API generation, marker-complete boundaries, locate, and hash-window behavior verified; official fixture files not directly checked |
| Python | 3 | Yes | `python -m unittest discover .\languages\python\tests` | None | Official manifest fixtures verified, including marker-complete fixture |
| R | 3 | Yes | `Rscript .\languages\r\tests\test_position_tape.R` | None for Rscript plus installed Perl `Digest::SHA`; full hash-window test took about 208 seconds | API generation, marker-complete boundaries, locate, and hash-window behavior verified; official fixture files not directly checked |
| Ruby | 3 | No | `ruby --version` | `ruby` is not on PATH | Not locally verified |
| Rust | 3 | No | From `languages/rust`: `cargo test` | Cargo/rustc are present, but local MSVC linking still fails with `LINK : fatal error LNK1104: no se puede abrir el archivo 'msvcrt.lib'`; treated as a local MSVC environment/toolchain blocker | Not locally verified |
| Scratch | 1 | No | Manual guide review only | No local headless Scratch runtime | Guide only; not executable fixture verification |
| SQLite | 2 | Yes | From repo root: `Get-Content languages/sqlite/tests/position_tape_tests.sql | sqlite3` | None for SQLite 3.53.2 direct test | API generation and marker-complete boundaries verified; official fixture files not directly checked |
| Standard ML | 3 | Yes | `Get-Content .\languages\standard-ml\tests\position_tape_tests.sml \| sml` | None | Exact `Generate(10000)` SHA verified; marker-complete boundary lengths verified |
| Swift | 3 | No | `swift --version`; intended `swift test --package-path languages\swift --cache-path .toolchain-cache\swiftpm` | Swift 6.3.2 crashes under the current Visual Studio 2026/18 environment with `unsupported toolset layout (VS2017+ required)`; treated as Swift-on-Windows toolchain incompatibility | Not locally verified |
| VB.NET | 3 | Yes | `dotnet run --project .\languages\vbnet\tests\PositionTape.Tests\PositionTape.Tests.vbproj --configuration Release` | None | Official manifest fixtures verified, including marker-complete fixture |
