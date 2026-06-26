# PositionTape for Java

Status: Level 3 implementation.

## API

- `PositionTape.generate(int length)`
- `PositionTape.generateMarkerComplete(int length)`
- `PositionTape.validate(String receivedText, int expectedLength)`
- `PositionTape.findTruncationPoint(String receivedText)`
- `PositionTape.findFirstMismatch(String expected, String received)`
- `PositionTape.locate(String fragment)`
- `PositionTape.buildWindowIndex(int windowSize)`
- `PositionTape.locateByHash(String fragmentHash, int windowSize)`
- `PositionTape.hashFragment(String fragment)`

PascalCase wrappers are also exposed for the required cross-language API names.

## Verify

```powershell
javac -d .toolchain-logs\java .\languages\java\src\main\java\org\positiontape\*.java .\languages\java\tests\PositionTapeTest.java
java -cp .toolchain-logs\java PositionTapeTest
```
