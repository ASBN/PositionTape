# PositionTape for kotlin

Status: Level 3 implementation.

Target conformance level: 3.

## Usage

```kotlin
import org.positiontape.PositionTape

val exact = PositionTape.Generate(10000)
val markerComplete = PositionTape.GenerateMarkerComplete(10000)
val validation = PositionTape.Validate(exact, 10000)
```

## Verify

```powershell
kotlinc .\languages\kotlin\src\PositionTape.kt .\languages\kotlin\tests\PositionTapeTest.kt -include-runtime -d .\languages\kotlin\position-tape-tests.jar
java -jar .\languages\kotlin\position-tape-tests.jar
```
