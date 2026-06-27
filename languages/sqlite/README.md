# PositionTape for SQLite

Status: Level 3 verified with the repo-local SHA-256 loadable extension.

SQLite does not provide parameterized stored functions in a plain `.sql` file,
so this implementation exposes the API as TEMP views backed by the
`position_tape_params` TEMP table.

The Level 3 hash APIs require loading the repo-local extension in
`languages/sqlite/extensions/sha256/`. It exposes exact `sha256(text)` over
SQLite UTF-8 TEXT bytes and does not use SQLite `sha3()`.

Load the views, set the required parameters, then query the corresponding view:

```sql
.load ./languages/sqlite/extensions/sha256/sha256_extension.dll sqlite3_sha256_init
.read languages/sqlite/src/position_tape.sql
INSERT INTO position_tape_params VALUES ('length', '120');
SELECT text FROM position_tape_generate;
```

## Build the SHA-256 extension

Probe the available tools from PowerShell:

```powershell
Get-Command gcc,clang,sqlite3 -ErrorAction SilentlyContinue | Select-Object Name,Source,Version
Get-Command C:\msys64\ucrt64\bin\gcc.exe -ErrorAction SilentlyContinue | Select-Object Name,Source,Version
Get-ChildItem -Path "C:\Users\alfon\AppData\Local\Programs\GNU Octave" -Recurse -Filter sqlite3ext.h -ErrorAction SilentlyContinue
```

Locally verified on Windows with GNU Octave's MinGW GCC 15.2.0, SQLite 3.51.2,
and the Octave-bundled SQLite extension header:

```powershell
$sqliteInclude = "C:\Users\alfon\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\include"
gcc -shared -O2 -Wall -Wextra -I $sqliteInclude `
  -o languages\sqlite\extensions\sha256\sha256_extension.dll `
  languages\sqlite\extensions\sha256\sha256_extension.c
```

MSYS2 UCRT64 GCC 16.1.0 is available locally, but this checkpoint found
`sqlite3ext.h` under the Octave include directory. Use the same include path if
the MSYS2 SQLite development headers are not installed:

```powershell
C:\msys64\ucrt64\bin\gcc.exe -shared -O2 -Wall -Wextra `
  -I "C:\Users\alfon\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\include" `
  -o languages\sqlite\extensions\sha256\sha256_extension.dll `
  languages\sqlite\extensions\sha256\sha256_extension.c
```

Load command:

```sql
.load ./languages/sqlite/extensions/sha256/sha256_extension.dll sqlite3_sha256_init
```

Run the local checks after building the DLL:

```powershell
Get-Content languages/sqlite/tests/position_tape_tests.sql | sqlite3
```

The generated `sha256_extension.dll` is a local build artifact and must not be
committed.
