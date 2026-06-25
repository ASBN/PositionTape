import org.positiontape.PositionTape
import java.io.File
import java.security.MessageDigest

private fun requireEqual(expected: Any?, actual: Any?, message: String) {
    if (expected != actual) {
        throw IllegalStateException("$message: got $actual, want $expected")
    }
}

fun main() {
    requireEqual("", PositionTape.Generate(0), "Generate(0)")
    requireEqual("1234567891", PositionTape.Generate(10), "Generate(10)")
    requireEqual("12345678911234567892", PositionTape.Generate(20), "Generate(20)")
    requireEqual(100, PositionTape.Generate(100).length, "Generate(100) length")

    requireEqual(PositionTape.Generate(99), PositionTape.GenerateMarkerComplete(99), "marker complete 99")
    requireEqual(PositionTape.Generate(101), PositionTape.GenerateMarkerComplete(100), "marker complete 100")
    requireEqual(1002, PositionTape.GenerateMarkerComplete(1000).length, "marker complete 1000")
    requireEqual(10003, PositionTape.GenerateMarkerComplete(10000).length, "marker complete 10000")

    val expected = PositionTape.Generate(50)
    require(PositionTape.Validate(expected, 50).isValid) { "valid result" }
    requireEqual(18, PositionTape.Validate(expected.substring(0, 17), 50).truncationPoint, "truncation point")
    requireEqual(4, PositionTape.FindTruncationPoint("123X"), "mismatch point")
    requireEqual(13, PositionTape.FindFirstMismatch(expected, expected.substring(0, 12) + "X" + expected.substring(13))!!.position, "mismatch")

    val fragment = PositionTape.Generate(80).substring(29, 41)
    val hash = PositionTape.HashFragment(fragment)
    requireEqual(30, PositionTape.Locate(fragment), "locate")
    require(PositionTape.BuildWindowIndex(fragment.length)[hash]!!.contains(30)) { "hash index" }
    require(PositionTape.LocateByHash(hash.uppercase(), fragment.length).contains(30)) { "locate by hash" }

    val root = generateSequence(File(".").absoluteFile) { it.parentFile }
        .first { File(it, "fixtures/manifest.generated.json").exists() }
    val manifest = File(root, "fixtures/manifest.generated.json").readText()
    val pattern = Regex(""""file":\s*"([^"]+)".*?"bytes":\s*(\d+).*?"sha256":\s*"([^"]+)"""", RegexOption.DOT_MATCHES_ALL)
    for (match in pattern.findAll(manifest)) {
        val file = match.groupValues[1]
        val bytes = match.groupValues[2].toInt()
        val sha = match.groupValues[3]
        val raw = File(root, "fixtures/$file").readBytes()
        requireEqual(bytes, raw.size, "$file bytes")
        val actualSha = MessageDigest.getInstance("SHA-256").digest(raw).joinToString("") { "%02x".format(it.toInt() and 0xff) }
        requireEqual(sha, actualSha, "$file sha256")
        require(!(raw.size >= 3 && raw[0] == 0xef.toByte() && raw[1] == 0xbb.toByte() && raw[2] == 0xbf.toByte())) { "$file BOM" }
        require(raw.isEmpty() || (raw.last() != '\n'.code.toByte() && raw.last() != '\r'.code.toByte())) { "$file newline" }
    }

    println("OK kotlin position_tape")
}
