# PositionTape Conformance Tools

This folder contains repository-local conformance helpers.

## Python Fixture Runner

```bash
python tools/conformance/run_conformance.py
```

The Python runner validates every entry in `fixtures/manifest.generated.json` against the canonical reference generator, byte length, SHA-256, UTF-8 BOM absence, and no trailing newline.

## SHA-256 Vector Runner

```bash
python tools/conformance/verify_sha256_vectors.py
```

The vector runner validates `fixtures/sha256-vectors.json` with Python
`hashlib.sha256` so Level 3 providers share the same UTF-8 hash evidence.

## C# No-Package Runner

```bash
dotnet run --project tools/conformance/csharp/PositionTape.Conformance/PositionTape.Conformance.csproj --configuration Release
```

The C# runner references the core library directly and uses only the .NET SDK. It exists so restricted environments can verify the C# implementation without restoring xUnit packages from NuGet.
