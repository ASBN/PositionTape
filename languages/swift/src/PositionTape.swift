import CryptoKit
import Foundation

public let DefaultSearchLength = 100_003

public struct Mismatch: Equatable {
    public let position: Int
    public let expected: Character?
    public let received: Character?
}

public struct ValidationResult: Equatable {
    public let isValid: Bool
    public let expectedLength: Int
    public let receivedLength: Int
    public let truncationPoint: Int?
    public let firstMismatch: Mismatch?
}

public enum PositionTape {
    private static var indexCache: [Int: [String: [Int]]] = [:]

    public static func Generate(_ length: Int) -> String {
        precondition(length >= 0, "length must be non-negative")

        var output = ""
        output.reserveCapacity(length)
        var cursor = 1

        while output.count < length {
            if cursor % 10 == 0 {
                let marker = String(cursor / 10)
                let remaining = length - output.count
                output += String(marker.prefix(remaining))
                cursor += marker.count
            } else {
                output += String(cursor % 10)
                cursor += 1
            }
        }

        return output
    }

    public static func GetMarkerCompleteLength(_ length: Int) -> Int {
        precondition(length >= 0, "length must be non-negative")

        var cursor = 1
        while cursor <= length {
            if cursor % 10 == 0 {
                let markerLength = String(cursor / 10).count
                let markerEnd = cursor + markerLength - 1
                if length < markerEnd {
                    return markerEnd
                }
                cursor += markerLength
            } else {
                cursor += 1
            }
        }

        return length
    }

    public static func GenerateMarkerComplete(_ length: Int) -> String {
        Generate(GetMarkerCompleteLength(length))
    }

    public static func Locate(_ fragment: String) -> Int {
        if fragment.isEmpty {
            return 1
        }

        let tape = Generate(DefaultSearchLength)
        guard let range = tape.range(of: fragment) else {
            return -1
        }
        return tape.distance(from: tape.startIndex, to: range.lowerBound) + 1
    }

    public static func FindFirstMismatch(_ expected: String, _ received: String) -> Mismatch? {
        let expectedChars = Array(expected)
        let receivedChars = Array(received)
        let sharedLength = min(expectedChars.count, receivedChars.count)

        for index in 0..<sharedLength {
            if expectedChars[index] != receivedChars[index] {
                return Mismatch(position: index + 1, expected: expectedChars[index], received: receivedChars[index])
            }
        }

        if expectedChars.count == receivedChars.count {
            return nil
        }

        let position = sharedLength + 1
        let expectedChar = position <= expectedChars.count ? expectedChars[position - 1] : nil
        let receivedChar = position <= receivedChars.count ? receivedChars[position - 1] : nil
        return Mismatch(position: position, expected: expectedChar, received: receivedChar)
    }

    public static func Validate(_ receivedText: String, _ expectedLength: Int) -> ValidationResult {
        let expected = Generate(expectedLength)
        let mismatch = FindFirstMismatch(expected, receivedText)
        let truncationPoint =
            mismatch != nil && receivedText.count < expectedLength && expected.hasPrefix(receivedText)
            ? receivedText.count + 1
            : nil

        return ValidationResult(
            isValid: mismatch == nil,
            expectedLength: expectedLength,
            receivedLength: receivedText.count,
            truncationPoint: truncationPoint,
            firstMismatch: mismatch
        )
    }

    public static func FindTruncationPoint(_ receivedText: String) -> Int {
        FindFirstMismatch(Generate(receivedText.count), receivedText)?.position ?? receivedText.count + 1
    }

    public static func HashFragment(_ fragment: String) -> String {
        let digest = SHA256.hash(data: Data(fragment.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func BuildWindowIndex(_ windowSize: Int) -> [String: [Int]] {
        precondition(windowSize > 0, "windowSize must be positive")
        precondition(windowSize <= DefaultSearchLength, "windowSize cannot exceed the default search length")

        let tape = Array(Generate(DefaultSearchLength))
        var index: [String: [Int]] = [:]
        for offset in 0...(tape.count - windowSize) {
            let fragment = String(tape[offset..<(offset + windowSize)])
            index[HashFragment(fragment), default: []].append(offset + 1)
        }
        return index
    }

    public static func LocateByHash(_ fragmentHash: String, _ windowSize: Int) -> [Int] {
        let normalizedHash = fragmentHash.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if indexCache[windowSize] == nil {
            indexCache[windowSize] = BuildWindowIndex(windowSize)
        }
        return indexCache[windowSize]?[normalizedHash] ?? []
    }
}
