# SQLite SHA-256 extension

This folder contains a repo-local SQLite loadable extension for PositionTape
Level 3 hash-window checks. It exposes:

```sql
sha256(text)
```

`sha256` returns lowercase 64-character SHA-256 hex for the exact UTF-8 bytes of
the input text. `NULL` input returns `NULL`. SHA3 is not used.

## Windows PowerShell build

The locally verified path uses GNU Octave's bundled MinGW GCC and SQLite
headers:

```powershell
$sqliteInclude = "C:\Users\alfon\AppData\Local\Programs\GNU Octave\Octave-11.3.0\mingw64\include"
gcc -shared -O2 -Wall -Wextra -I $sqliteInclude `
  -o languages\sqlite\extensions\sha256\sha256_extension.dll `
  languages\sqlite\extensions\sha256\sha256_extension.c
```

Equivalent MSYS2 UCRT64 GCC command, when its SQLite headers are installed:

```powershell
C:\msys64\ucrt64\bin\gcc.exe -shared -O2 -Wall -Wextra `
  -I C:\msys64\ucrt64\include `
  -o languages\sqlite\extensions\sha256\sha256_extension.dll `
  languages\sqlite\extensions\sha256\sha256_extension.c
```

Load explicitly with the exported entry point:

```sql
.load ./languages/sqlite/extensions/sha256/sha256_extension.dll sqlite3_sha256_init
SELECT sha256('abc');
```

Do not commit the generated `.dll`, `.o`, `.obj`, `.exe`, or local diagnostics.
