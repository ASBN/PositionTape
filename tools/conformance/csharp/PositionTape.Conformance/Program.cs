using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Tape = PositionTape.PositionTape;

var root = FindRepoRoot();
var manifest = LoadManifest(root);

foreach (var fixture in manifest.Fixtures)
{
    VerifyFixture(root, fixture);
}

VerifyApiBehavior();
Console.WriteLine("OK csharp conformance");

static void VerifyFixture(string root, FixtureEntry fixture)
{
    var path = Path.Combine(root, "fixtures", fixture.File);
    var raw = File.ReadAllBytes(path);
    var text = Encoding.UTF8.GetString(raw);
    var expected = GenerateForFixture(fixture.File);
    var sha = Sha256Hex(raw);

    Assert(raw.Length == fixture.Bytes, $"Length mismatch for {fixture.File}: {raw.Length} != {fixture.Bytes}");
    Assert(sha == fixture.Sha256, $"SHA mismatch for {fixture.File}: {sha} != {fixture.Sha256}");
    Assert(!StartsWith(raw, [0xEF, 0xBB, 0xBF]), $"Fixture has UTF-8 BOM: {fixture.File}");
    Assert(!EndsWith(raw, 0x0A), $"Fixture has trailing LF: {fixture.File}");
    Assert(!EndsWith(raw, 0x0D), $"Fixture has trailing CR: {fixture.File}");
    Assert(text == expected, $"Generated content mismatch for {fixture.File}");

    if (fixture.First50 is not null)
    {
        Assert(expected[..Math.Min(50, expected.Length)] == fixture.First50, $"first_50 mismatch for {fixture.File}");
    }

    if (fixture.Last50 is not null)
    {
        var last = expected.Length <= 50 ? expected : expected[^50..];
        Assert(last == fixture.Last50, $"last_50 mismatch for {fixture.File}");
    }

    Console.WriteLine($"OK {fixture.File} {sha}");
}

static void VerifyApiBehavior()
{
    Assert(Tape.Generate(0) == string.Empty, "Generate(0) mismatch");
    Assert(Tape.Generate(10) == "1234567891", "Generate(10) mismatch");
    Assert(Tape.Generate(101).EndsWith("10", StringComparison.Ordinal), "Generate(101) should complete marker 10");
    Assert(Tape.GenerateMarkerComplete(99).Length == 99, "Marker-complete 99 length mismatch");
    Assert(Tape.GenerateMarkerComplete(100).Length == 101, "Marker-complete 100 length mismatch");
    Assert(Tape.GenerateMarkerComplete(10_000).Length == 10_003, "Marker-complete 10000 length mismatch");

    var exact = Tape.Generate(10_000);
    Assert(Sha256Hex(Encoding.UTF8.GetBytes(exact)) == "9ee39196c3dd959c14600095c165c237d0b4a7639237cf2bb1bfbee6f3321f5c", "Generate(10000) SHA mismatch");

    var markerComplete = Tape.GenerateMarkerComplete(10_000);
    Assert(Sha256Hex(Encoding.UTF8.GetBytes(markerComplete)) == "848ec54bb7cecafa86c9e5db6b8b7551e70e63aeec357054bbae4c0b698362c6", "GenerateMarkerComplete(10000) SHA mismatch");

    var truncated = Tape.Validate(Tape.Generate(99), 100);
    Assert(!truncated.IsValid, "Truncated payload should not validate");
    Assert(truncated.TruncationPoint == 100, "Truncation point mismatch");
    Assert(truncated.FirstMismatch == new PositionTape.Mismatch(100, '1', null), "Truncation mismatch details mismatch");

    var mismatch = Tape.FindFirstMismatch("abc", "axc");
    Assert(mismatch == new PositionTape.Mismatch(2, 'b', 'x'), "First mismatch details mismatch");
    Assert(Tape.FindTruncationPoint("12x45") == 3, "FindTruncationPoint mismatch position incorrect");

    var fragment = exact.Substring(9_950, 30);
    Assert(Tape.Locate(fragment) > 0, "Locate failed for known fragment");

    const int windowSize = 16;
    var indexedFragment = exact.Substring(250, windowSize);
    var positions = Tape.LocateByHash(Tape.HashFragment(indexedFragment), windowSize);
    Assert(positions.Count > 0, "LocateByHash failed for known fragment hash");
}

static string GenerateForFixture(string file)
{
    const string prefix = "position_tape_";
    const string markerSuffix = "_marker_complete.txt";
    const string exactSuffix = ".txt";

    if (file.EndsWith(markerSuffix, StringComparison.Ordinal))
    {
        var lengthText = file[prefix.Length..^markerSuffix.Length];
        return Tape.GenerateMarkerComplete(int.Parse(lengthText));
    }

    if (file.EndsWith(exactSuffix, StringComparison.Ordinal))
    {
        var lengthText = file[prefix.Length..^exactSuffix.Length];
        return Tape.Generate(int.Parse(lengthText));
    }

    throw new InvalidOperationException($"Unsupported fixture file name: {file}");
}

static FixtureManifest LoadManifest(string root)
{
    var path = Path.Combine(root, "fixtures", "manifest.generated.json");
    var json = File.ReadAllText(path, Encoding.UTF8);
    return JsonSerializer.Deserialize<FixtureManifest>(json) ?? throw new InvalidOperationException("Could not parse fixture manifest.");
}

static string FindRepoRoot()
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

    throw new DirectoryNotFoundException("Could not locate repository root from conformance runner output directory.");
}

static string Sha256Hex(byte[] data)
{
    return Convert.ToHexString(SHA256.HashData(data)).ToLowerInvariant();
}

static bool StartsWith(byte[] raw, byte[] prefix)
{
    return raw.AsSpan().StartsWith(prefix);
}

static bool EndsWith(byte[] raw, byte value)
{
    return raw.Length > 0 && raw[^1] == value;
}

static void Assert(bool condition, string message)
{
    if (!condition)
    {
        throw new InvalidOperationException(message);
    }
}

internal sealed class FixtureManifest
{
    [JsonPropertyName("fixtures")]
    public List<FixtureEntry> Fixtures { get; set; } = new();
}

internal sealed class FixtureEntry
{
    [JsonPropertyName("file")]
    public string File { get; set; } = string.Empty;

    [JsonPropertyName("bytes")]
    public int Bytes { get; set; }

    [JsonPropertyName("sha256")]
    public string Sha256 { get; set; } = string.Empty;

    [JsonPropertyName("first_50")]
    public string? First50 { get; set; }

    [JsonPropertyName("last_50")]
    public string? Last50 { get; set; }
}
