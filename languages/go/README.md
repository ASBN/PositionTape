# PositionTape for Go

Status: Level 3 implementation.

## API

- `Generate(length int) (string, error)`
- `GenerateMarkerComplete(length int) (string, error)`
- `Validate(receivedText string, expectedLength int) (ValidationResult, error)`
- `FindTruncationPoint(receivedText string) (int, error)`
- `FindFirstMismatch(expected string, received string) *Mismatch`
- `Locate(fragment string) (int, error)`
- `BuildWindowIndex(windowSize int) (map[string][]int, error)`
- `LocateByHash(fragmentHash string, windowSize int) ([]int, error)`
- `HashFragment(fragment string) string`

## Verify

```powershell
Push-Location languages/go
go test ./...
Pop-Location
```
