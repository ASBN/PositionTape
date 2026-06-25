package org.positiontape

import java.security.MessageDigest

const val DEFAULT_SEARCH_LENGTH: Int = 100_003

data class Mismatch(val position: Int, val expected: Char?, val received: Char?)

data class ValidationResult(
    val isValid: Boolean,
    val expectedLength: Int,
    val receivedLength: Int,
    val truncationPoint: Int?,
    val firstMismatch: Mismatch?,
)

object PositionTape {
    private val indexCache = mutableMapOf<Int, Map<String, List<Int>>>()

    @JvmStatic
    fun Generate(length: Int): String = generate(length)

    @JvmStatic
    fun generate(length: Int): String {
        require(length >= 0) { "length must be non-negative" }

        val output = StringBuilder(length)
        var cursor = 1
        while (output.length < length) {
            if (cursor % 10 == 0) {
                val marker = (cursor / 10).toString()
                val remaining = length - output.length
                output.append(marker.substring(0, minOf(marker.length, remaining)))
                cursor += marker.length
            } else {
                output.append(('0'.code + (cursor % 10)).toChar())
                cursor += 1
            }
        }

        return output.toString()
    }

    @JvmStatic
    fun GenerateMarkerComplete(length: Int): String = generateMarkerComplete(length)

    @JvmStatic
    fun generateMarkerComplete(length: Int): String = generate(getMarkerCompleteLength(length))

    @JvmStatic
    fun GetMarkerCompleteLength(length: Int): Int = getMarkerCompleteLength(length)

    @JvmStatic
    fun getMarkerCompleteLength(length: Int): Int {
        require(length >= 0) { "length must be non-negative" }

        var cursor = 1
        while (cursor <= length) {
            if (cursor % 10 == 0) {
                val markerLength = (cursor / 10).toString().length
                val markerEnd = cursor + markerLength - 1
                if (length < markerEnd) {
                    return markerEnd
                }
                cursor += markerLength
            } else {
                cursor += 1
            }
        }

        return length
    }

    @JvmStatic
    fun Locate(fragment: String): Int = locate(fragment)

    @JvmStatic
    fun locate(fragment: String): Int {
        if (fragment.isEmpty()) {
            return 1
        }
        val index = generate(DEFAULT_SEARCH_LENGTH).indexOf(fragment)
        return if (index < 0) -1 else index + 1
    }

    @JvmStatic
    fun Validate(receivedText: String, expectedLength: Int): ValidationResult = validate(receivedText, expectedLength)

    @JvmStatic
    fun validate(receivedText: String, expectedLength: Int): ValidationResult {
        val expected = generate(expectedLength)
        val mismatch = findFirstMismatch(expected, receivedText)
        val truncationPoint =
            if (mismatch != null && receivedText.length < expectedLength && expected.startsWith(receivedText)) {
                receivedText.length + 1
            } else {
                null
            }

        return ValidationResult(
            isValid = mismatch == null,
            expectedLength = expectedLength,
            receivedLength = receivedText.length,
            truncationPoint = truncationPoint,
            firstMismatch = mismatch,
        )
    }

    @JvmStatic
    fun FindTruncationPoint(receivedText: String): Int = findTruncationPoint(receivedText)

    @JvmStatic
    fun findTruncationPoint(receivedText: String): Int {
        val mismatch = findFirstMismatch(generate(receivedText.length), receivedText)
        return mismatch?.position ?: receivedText.length + 1
    }

    @JvmStatic
    fun FindFirstMismatch(expected: String, received: String): Mismatch? = findFirstMismatch(expected, received)

    @JvmStatic
    fun findFirstMismatch(expected: String, received: String): Mismatch? {
        val sharedLength = minOf(expected.length, received.length)
        for (index in 0 until sharedLength) {
            if (expected[index] != received[index]) {
                return Mismatch(index + 1, expected[index], received[index])
            }
        }
        if (expected.length == received.length) {
            return null
        }

        val position = sharedLength + 1
        return Mismatch(
            position,
            expected.getOrNull(position - 1),
            received.getOrNull(position - 1),
        )
    }

    @JvmStatic
    fun HashFragment(fragment: String): String = hashFragment(fragment)

    @JvmStatic
    fun hashFragment(fragment: String): String {
        val digest = MessageDigest.getInstance("SHA-256").digest(fragment.toByteArray(Charsets.UTF_8))
        return digest.joinToString("") { byte -> "%02x".format(byte.toInt() and 0xff) }
    }

    @JvmStatic
    fun BuildWindowIndex(windowSize: Int): Map<String, List<Int>> = buildWindowIndex(windowSize)

    @JvmStatic
    fun buildWindowIndex(windowSize: Int): Map<String, List<Int>> {
        require(windowSize > 0) { "windowSize must be positive" }
        require(windowSize <= DEFAULT_SEARCH_LENGTH) { "windowSize cannot exceed the default search length" }

        val tape = generate(DEFAULT_SEARCH_LENGTH)
        val index = linkedMapOf<String, MutableList<Int>>()
        for (offset in 0..(tape.length - windowSize)) {
            val hash = hashFragment(tape.substring(offset, offset + windowSize))
            index.getOrPut(hash) { mutableListOf() }.add(offset + 1)
        }
        return index.mapValues { it.value.toList() }
    }

    @JvmStatic
    fun LocateByHash(fragmentHash: String, windowSize: Int): List<Int> = locateByHash(fragmentHash, windowSize)

    @JvmStatic
    fun locateByHash(fragmentHash: String, windowSize: Int): List<Int> {
        val normalizedHash = fragmentHash.trim().lowercase()
        val index = indexCache.getOrPut(windowSize) { buildWindowIndex(windowSize) }
        return index[normalizedHash].orEmpty()
    }
}
