import org.positiontape.PositionTape

fun main() {
    val exact = PositionTape.Generate(100)
    val markerComplete = PositionTape.GenerateMarkerComplete(1000)
    val validation = PositionTape.Validate(exact, 100)

    println(exact)
    println(markerComplete.length)
    println(validation.isValid)
}
