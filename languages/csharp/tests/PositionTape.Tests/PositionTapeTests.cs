using Xunit;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Tape = global::PositionTape.PositionTape;

namespace PositionTape.Tests;

public sealed class PositionTapeTests
{
    [Theory]
    [InlineData(0, "")]
    [InlineData(1, "1")]
    [InlineData(9, "123456789")]
    [InlineData(10, "1234567891")]
    [InlineData(11, "12345678911")]
    [InlineData(100, "1234567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891")]
    [InlineData(101, "12345678911234567892123456789312345678941234567895123456789612345678971234567898123456789912345678910")]
    public void GenerateReturnsExactKnownValues(int length, string expected)
    {
        Assert.Equal(expected, Tape.Generate(length));
    }

    [Fact]
    public void GenerateMatchesOfficialManifestFixtures()
    {
        var root = FindRepoRoot();
        var manifest = LoadManifest(root);

        foreach (var fixture in manifest.Fixtures)
        {
            var path = Path.Combine(root, "fixtures", fixture.File);
            var raw = File.ReadAllBytes(path);
            var text = Encoding.UTF8.GetString(raw);
            var generated = GenerateForFixture(fixture.File);

            Assert.Equal(fixture.Bytes, raw.Length);
            Assert.Equal(fixture.Sha256, Sha256Hex(raw));
            Assert.Equal(generated, text);
            Assert.Equal(generated.Length, raw.Length);
        }
    }

    [Fact]
    public void OfficialFixturesHaveNoBomOrTrailingNewline()
    {
        var root = FindRepoRoot();
        var manifest = LoadManifest(root);

        foreach (var fixture in manifest.Fixtures)
        {
            var raw = File.ReadAllBytes(Path.Combine(root, "fixtures", fixture.File));
            Assert.False(raw.AsSpan().StartsWith(new byte[] { 0xEF, 0xBB, 0xBF }));
            Assert.False(raw.AsSpan().EndsWith(new byte[] { 0x0A }));
            Assert.False(raw.AsSpan().EndsWith(new byte[] { 0x0D }));
        }
    }

    [Fact]
    public void RequiredBootstrapCasesArePresent()
    {
        var lengths = LoadManifest(FindRepoRoot())
            .Fixtures
            .Select(fixture => fixture.Bytes)
            .ToHashSet();

        foreach (var requiredLength in new[] { 0, 1, 9, 10, 99, 100, 101, 10_000, 10_003 })
        {
            Assert.Contains(requiredLength, lengths);
        }
    }

    [Theory]
    [InlineData(99, 99)]
    [InlineData(100, 101)]
    [InlineData(101, 101)]
    [InlineData(10_000, 10_003)]
    public void GenerateMarkerCompleteExtendsOnlyWhenMarkerIsCut(int requestedLength, int expectedLength)
    {
        Assert.Equal(expectedLength, Tape.GenerateMarkerComplete(requestedLength).Length);
    }

    [Fact]
    public void ValidateReportsValidAndTruncatedPayloads()
    {
        var valid = Tape.Validate(Tape.Generate(100), 100);
        Assert.True(valid.IsValid);
        Assert.Null(valid.TruncationPoint);
        Assert.Null(valid.FirstMismatch);

        var truncated = Tape.Validate(Tape.Generate(99), 100);
        Assert.False(truncated.IsValid);
        Assert.Equal(100, truncated.TruncationPoint);
        Assert.Equal(new global::PositionTape.Mismatch(100, '1', null), truncated.FirstMismatch);
    }

    [Fact]
    public void FindFirstMismatchUsesOneIndexedPositions()
    {
        Assert.Equal(new global::PositionTape.Mismatch(2, 'b', 'x'), Tape.FindFirstMismatch("abc", "axc"));
        Assert.Equal(new global::PositionTape.Mismatch(4, 'd', null), Tape.FindFirstMismatch("abcd", "abc"));
        Assert.Null(Tape.FindFirstMismatch("abc", "abc"));
    }

    [Fact]
    public void FindTruncationPointReturnsFirstNonMatchingPosition()
    {
        Assert.Equal(1, Tape.FindTruncationPoint(""));
        Assert.Equal(100, Tape.FindTruncationPoint(Tape.Generate(99)));
        Assert.Equal(3, Tape.FindTruncationPoint("12x45"));
    }

    [Fact]
    public void LocateReturnsFirstOneIndexedOccurrence()
    {
        var tape = Tape.Generate(10_000);
        var fragment = tape.Substring(9_950, 30);
        var expectedPosition = tape.IndexOf(fragment, StringComparison.Ordinal) + 1;

        Assert.True(expectedPosition > 0);
        Assert.Equal(expectedPosition, Tape.Locate(fragment));
        Assert.Equal(-1, Tape.Locate("not-a-position-tape-fragment"));
    }

    [Fact]
    public void HashWindowIndexLocatesKnownFragmentHash()
    {
        const int windowSize = 16;
        var tape = Tape.Generate(1_000);
        var fragment = tape.Substring(250, windowSize);
        var expectedPosition = tape.IndexOf(fragment, StringComparison.Ordinal) + 1;
        var hash = Tape.HashFragment(fragment);

        var index = Tape.BuildWindowIndex(windowSize);
        var positions = Tape.LocateByHash(hash, windowSize);

        Assert.True(index.ContainsKey(hash));
        Assert.Contains(expectedPosition, positions);
    }

    [Fact]
    public void NegativeLengthsAreRejected()
    {
        Assert.Throws<ArgumentOutOfRangeException>(() => Tape.Generate(-1));
        Assert.Throws<ArgumentOutOfRangeException>(() => Tape.GenerateMarkerComplete(-1));
    }

    private static string FindRepoRoot()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            if (File.Exists(Path.Combine(directory.FullName, "fixtures", "manifest.generated.json")))
            {
                return directory.FullName;
            }

            directory = directory.Parent;
        }

        throw new DirectoryNotFoundException("Could not locate repository root from test output directory.");
    }

    private static FixtureManifest LoadManifest(string root)
    {
        var path = Path.Combine(root, "fixtures", "manifest.generated.json");
        var json = File.ReadAllText(path, Encoding.UTF8);
        return JsonSerializer.Deserialize<FixtureManifest>(json) ?? new FixtureManifest();
    }

    private static string GenerateForFixture(string file)
    {
        const string markerSuffix = "_marker_complete.txt";
        if (file.EndsWith(markerSuffix, StringComparison.Ordinal))
        {
            var lengthText = file["position_tape_".Length..^markerSuffix.Length];
            return Tape.GenerateMarkerComplete(int.Parse(lengthText));
        }

        var exactLengthText = file["position_tape_".Length..^".txt".Length];
        return Tape.Generate(int.Parse(exactLengthText));
    }

    private static string Sha256Hex(byte[] data)
    {
        return Convert.ToHexString(SHA256.HashData(data)).ToLowerInvariant();
    }

    private sealed class FixtureManifest
    {
        [JsonPropertyName("fixtures")]
        public List<FixtureEntry> Fixtures { get; set; } = new();
    }

    private sealed class FixtureEntry
    {
        [JsonPropertyName("file")]
        public string File { get; set; } = string.Empty;

        [JsonPropertyName("bytes")]
        public int Bytes { get; set; }

        [JsonPropertyName("sha256")]
        public string Sha256 { get; set; } = string.Empty;
    }
}

