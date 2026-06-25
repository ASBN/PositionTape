using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace PositionTape;

/// <summary>Describes the first 1-indexed position where two texts differ.</summary>
/// <param name="Position">The 1-indexed mismatch position.</param>
/// <param name="Expected">The expected character, or null when the expected text ended first.</param>
/// <param name="Received">The received character, or null when the received text ended first.</param>
public sealed record Mismatch(int Position, char? Expected, char? Received);

/// <summary>Summarizes validation of received text against an expected PositionTape length.</summary>
/// <param name="IsValid">True when received text exactly equals the expected generated tape.</param>
/// <param name="ExpectedLength">The requested expected tape length.</param>
/// <param name="ReceivedLength">The received text length.</param>
/// <param name="TruncationPoint">The 1-indexed missing position when the received text is a valid truncated prefix.</param>
/// <param name="FirstMismatch">The first mismatch, including length-only mismatches.</param>
public sealed record ValidationResult(
    bool IsValid,
    int ExpectedLength,
    int ReceivedLength,
    int? TruncationPoint,
    Mismatch? FirstMismatch);

/// <summary>Reference implementation of the PositionTape diagnostic sequence.</summary>
public static class PositionTape
{
    /// <summary>Default number of generated characters searched by locate and hash-window helpers.</summary>
    public const int DefaultSearchLength = 100_003;

    private static readonly object IndexLock = new();
    private static readonly Dictionary<int, IReadOnlyDictionary<string, IReadOnlyList<int>>> IndexCache = new();

    /// <summary>Generates exactly <paramref name="length" /> characters of PositionTape.</summary>
    /// <param name="length">The exact number of characters to generate.</param>
    /// <returns>The generated tape text.</returns>
    public static string Generate(int length)
    {
        if (length < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(length), "length must be non-negative");
        }

        var builder = new StringBuilder(capacity: length);
        var cursor = 1;

        while (builder.Length < length)
        {
            if (cursor % 10 == 0)
            {
                var marker = (cursor / 10).ToString(CultureInfo.InvariantCulture);
                var remaining = length - builder.Length;
                builder.Append(marker, 0, Math.Min(marker.Length, remaining));
                cursor += marker.Length;
            }
            else
            {
                builder.Append((char)('0' + (cursor % 10)));
                cursor += 1;
            }
        }

        return builder.ToString();
    }

    /// <summary>Generates tape extended only as needed to complete the marker crossing <paramref name="length" />.</summary>
    /// <param name="length">The requested boundary length.</param>
    /// <returns>Generated tape with any boundary-crossing marker completed.</returns>
    public static string GenerateMarkerComplete(int length)
    {
        return Generate(GetMarkerCompleteLength(length));
    }

    /// <summary>Finds the first 1-indexed occurrence of a fragment in the default search window.</summary>
    /// <param name="fragment">The fragment to locate.</param>
    /// <returns>The 1-indexed position, or -1 when not found.</returns>
    public static int Locate(string fragment)
    {
        ArgumentNullException.ThrowIfNull(fragment);

        if (fragment.Length == 0)
        {
            return 1;
        }

        var haystack = Generate(DefaultSearchLength);
        var index = haystack.IndexOf(fragment, StringComparison.Ordinal);
        return index < 0 ? -1 : index + 1;
    }

    /// <summary>Validates received text against the exact tape for an expected length.</summary>
    /// <param name="receivedText">The text captured from a pipeline.</param>
    /// <param name="expectedLength">The expected exact tape length.</param>
    /// <returns>Validation details including truncation and mismatch diagnostics.</returns>
    public static ValidationResult Validate(string receivedText, int expectedLength)
    {
        ArgumentNullException.ThrowIfNull(receivedText);

        var expected = Generate(expectedLength);
        var mismatch = FindFirstMismatch(expected, receivedText);
        var isValid = mismatch is null;
        int? truncationPoint = null;

        if (!isValid
            && receivedText.Length < expectedLength
            && expected.StartsWith(receivedText, StringComparison.Ordinal))
        {
            truncationPoint = receivedText.Length + 1;
        }

        return new ValidationResult(
            isValid,
            expectedLength,
            receivedText.Length,
            truncationPoint,
            mismatch);
    }

    /// <summary>Returns the first 1-indexed position where received text stops matching the canonical tape prefix.</summary>
    /// <param name="receivedText">The captured text to inspect.</param>
    /// <returns>The first mismatch position, or the next position after a valid prefix.</returns>
    public static int FindTruncationPoint(string receivedText)
    {
        ArgumentNullException.ThrowIfNull(receivedText);

        var expectedPrefix = Generate(receivedText.Length);
        var mismatch = FindFirstMismatch(expectedPrefix, receivedText);
        return mismatch?.Position ?? receivedText.Length + 1;
    }

    /// <summary>Finds the first 1-indexed mismatch between expected and received text.</summary>
    /// <param name="expected">The expected text.</param>
    /// <param name="received">The received text.</param>
    /// <returns>Mismatch details, or null when the texts are equal.</returns>
    public static Mismatch? FindFirstMismatch(string expected, string received)
    {
        ArgumentNullException.ThrowIfNull(expected);
        ArgumentNullException.ThrowIfNull(received);

        var sharedLength = Math.Min(expected.Length, received.Length);
        for (var index = 0; index < sharedLength; index += 1)
        {
            if (expected[index] != received[index])
            {
                return new Mismatch(index + 1, expected[index], received[index]);
            }
        }

        if (expected.Length == received.Length)
        {
            return null;
        }

        var position = sharedLength + 1;
        char? expectedCharacter = position <= expected.Length ? expected[position - 1] : null;
        char? receivedCharacter = position <= received.Length ? received[position - 1] : null;
        return new Mismatch(position, expectedCharacter, receivedCharacter);
    }

    /// <summary>Builds a SHA-256 hash index of fixed-size windows in the default search window.</summary>
    /// <param name="windowSize">The fixed fragment size to index.</param>
    /// <returns>A map from lowercase SHA-256 hash to 1-indexed positions.</returns>
    public static IReadOnlyDictionary<string, IReadOnlyList<int>> BuildWindowIndex(int windowSize)
    {
        if (windowSize <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(windowSize), "windowSize must be positive");
        }

        if (windowSize > DefaultSearchLength)
        {
            throw new ArgumentOutOfRangeException(nameof(windowSize), "windowSize cannot exceed the default search length");
        }

        var tape = Generate(DefaultSearchLength);
        var mutableIndex = new Dictionary<string, List<int>>(StringComparer.OrdinalIgnoreCase);

        for (var index = 0; index <= tape.Length - windowSize; index += 1)
        {
            var window = tape.Substring(index, windowSize);
            var hash = HashFragment(window);

            if (!mutableIndex.TryGetValue(hash, out var positions))
            {
                positions = new List<int>();
                mutableIndex.Add(hash, positions);
            }

            positions.Add(index + 1);
        }

        return mutableIndex.ToDictionary(
            pair => pair.Key,
            pair => (IReadOnlyList<int>)pair.Value.AsReadOnly(),
            StringComparer.OrdinalIgnoreCase);
    }

    /// <summary>Finds positions whose fixed-size window hash matches <paramref name="fragmentHash" />.</summary>
    /// <param name="fragmentHash">A lowercase or uppercase SHA-256 hex hash.</param>
    /// <param name="windowSize">The fixed fragment size used to build the index.</param>
    /// <returns>All matching 1-indexed positions in the default search window.</returns>
    public static IReadOnlyList<int> LocateByHash(string fragmentHash, int windowSize)
    {
        ArgumentNullException.ThrowIfNull(fragmentHash);

        var normalizedHash = fragmentHash.Trim().ToLowerInvariant();
        var index = GetCachedWindowIndex(windowSize);
        return index.TryGetValue(normalizedHash, out var positions) ? positions : Array.Empty<int>();
    }

    /// <summary>Computes a lowercase SHA-256 hex hash for a tape fragment.</summary>
    /// <param name="fragment">The fragment to hash as UTF-8.</param>
    /// <returns>Lowercase SHA-256 hex.</returns>
    public static string HashFragment(string fragment)
    {
        ArgumentNullException.ThrowIfNull(fragment);

        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(fragment));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }

    /// <summary>Returns the length needed to complete any marker crossing the requested boundary.</summary>
    /// <param name="length">The requested boundary length.</param>
    /// <returns>The exact requested length or the minimal marker-complete extension.</returns>
    public static int GetMarkerCompleteLength(int length)
    {
        if (length < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(length), "length must be non-negative");
        }

        var cursor = 1;
        while (cursor <= length)
        {
            if (cursor % 10 == 0)
            {
                var markerLength = (cursor / 10).ToString(CultureInfo.InvariantCulture).Length;
                var markerEnd = cursor + markerLength - 1;
                if (length < markerEnd)
                {
                    return markerEnd;
                }

                cursor += markerLength;
            }
            else
            {
                cursor += 1;
            }
        }

        return length;
    }

    private static IReadOnlyDictionary<string, IReadOnlyList<int>> GetCachedWindowIndex(int windowSize)
    {
        lock (IndexLock)
        {
            if (!IndexCache.TryGetValue(windowSize, out var index))
            {
                index = BuildWindowIndex(windowSize);
                IndexCache.Add(windowSize, index);
            }

            return index;
        }
    }
}
