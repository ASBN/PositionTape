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
swift test --package-path languages\swift --cache-path .toolchain-cache\swiftpm
```

Current local blocker: Swift 6.3.2 on this Windows machine crashes before
package tests under the installed Visual Studio 2026/18 toolset layout.
