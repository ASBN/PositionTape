# PositionTape for Swift

Status: Level 3 implementation.

This package exposes the required PositionTape API through the `PositionTape`
enum:

- `Generate(_:)`
- `GenerateMarkerComplete(_:)`
- `Locate(_:)`
- `Validate(_:_:)`
- `FindTruncationPoint(_:)`
- `FindFirstMismatch(_:_:)`
- `BuildWindowIndex(_:)`
- `LocateByHash(_:_:)`

Run the local checks with:

```powershell
swift run PositionTapeTests
```
