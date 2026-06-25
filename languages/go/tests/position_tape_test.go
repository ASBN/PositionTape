package tests

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"

	pt "github.com/positiontape/positiontape/languages/go/src/positiontape"
)

type manifest struct {
	Fixtures []fixture `json:"fixtures"`
}

type fixture struct {
	File   string `json:"file"`
	Bytes  int    `json:"bytes"`
	Sha256 string `json:"sha256"`
}

func TestGenerateKnownValues(t *testing.T) {
	cases := map[int]string{
		0:   "",
		1:   "1",
		9:   "123456789",
		10:  "1234567891",
		11:  "12345678911",
		99:  "123456789112345678921234567893123456789412345678951234567896123456789712345678981234567899123456789",
		100: "1234567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891",
		101: "12345678911234567892123456789312345678941234567895123456789612345678971234567898123456789912345678910",
	}

	for length, expected := range cases {
		actual, err := pt.Generate(length)
		if err != nil {
			t.Fatalf("Generate(%d) returned error: %v", length, err)
		}
		if actual != expected {
			t.Fatalf("Generate(%d) = %q, want %q", length, actual, expected)
		}
	}
}

func TestGenerateMatchesOfficialManifestFixtures(t *testing.T) {
	root := repoRoot(t)
	manifestBytes, err := os.ReadFile(filepath.Join(root, "fixtures", "manifest.generated.json"))
	if err != nil {
		t.Fatal(err)
	}

	var data manifest
	if err := json.Unmarshal(manifestBytes, &data); err != nil {
		t.Fatal(err)
	}

	for _, entry := range data.Fixtures {
		raw, err := os.ReadFile(filepath.Join(root, "fixtures", entry.File))
		if err != nil {
			t.Fatal(err)
		}
		if len(raw) != entry.Bytes {
			t.Fatalf("%s length = %d, want %d", entry.File, len(raw), entry.Bytes)
		}
		sum := sha256.Sum256(raw)
		if hex.EncodeToString(sum[:]) != entry.Sha256 {
			t.Fatalf("%s sha mismatch", entry.File)
		}
		if len(raw) >= 3 && raw[0] == 0xef && raw[1] == 0xbb && raw[2] == 0xbf {
			t.Fatalf("%s has UTF-8 BOM", entry.File)
		}
		if len(raw) > 0 && (raw[len(raw)-1] == '\n' || raw[len(raw)-1] == '\r') {
			t.Fatalf("%s has trailing newline", entry.File)
		}

		generated := generateForFixture(t, entry.File)
		if string(raw) != generated {
			t.Fatalf("%s generated content mismatch", entry.File)
		}
	}
}

func TestGenerateMarkerComplete(t *testing.T) {
	cases := map[int]int{99: 99, 100: 101, 101: 101, 10000: 10003}
	for requested, expectedLength := range cases {
		actual, err := pt.GenerateMarkerComplete(requested)
		if err != nil {
			t.Fatal(err)
		}
		if len(actual) != expectedLength {
			t.Fatalf("GenerateMarkerComplete(%d) length = %d, want %d", requested, len(actual), expectedLength)
		}
	}
}

func TestValidationDiagnostics(t *testing.T) {
	exact, _ := pt.Generate(100)
	valid, err := pt.Validate(exact, 100)
	if err != nil {
		t.Fatal(err)
	}
	if !valid.IsValid || valid.FirstMismatch != nil || valid.TruncationPoint != nil {
		t.Fatalf("valid result was not valid: %+v", valid)
	}

	truncatedText, _ := pt.Generate(99)
	truncated, err := pt.Validate(truncatedText, 100)
	if err != nil {
		t.Fatal(err)
	}
	if truncated.IsValid || truncated.TruncationPoint == nil || *truncated.TruncationPoint != 100 {
		t.Fatalf("truncated result did not report position 100: %+v", truncated)
	}

	point, err := pt.FindTruncationPoint("12x45")
	if err != nil {
		t.Fatal(err)
	}
	if point != 3 {
		t.Fatalf("FindTruncationPoint = %d, want 3", point)
	}
}

func TestLocateAndHashIndex(t *testing.T) {
	source, err := pt.Generate(80)
	if err != nil {
		t.Fatal(err)
	}
	fragment := source[29:41]

	position, err := pt.Locate(fragment)
	if err != nil {
		t.Fatal(err)
	}
	if position != 30 {
		t.Fatalf("Locate = %d, want 30", position)
	}

	hash := pt.HashFragment(fragment)
	index, err := pt.BuildWindowIndex(len(fragment))
	if err != nil {
		t.Fatal(err)
	}
	if !contains(index[hash], 30) {
		t.Fatalf("BuildWindowIndex missing position 30")
	}

	positions, err := pt.LocateByHash(strings.ToUpper(hash), len(fragment))
	if err != nil {
		t.Fatal(err)
	}
	if !contains(positions, 30) {
		t.Fatalf("LocateByHash missing position 30")
	}
}

func TestNegativeLengthRejected(t *testing.T) {
	if _, err := pt.Generate(-1); err == nil {
		t.Fatal("Generate(-1) did not fail")
	}
	if _, err := pt.GenerateMarkerComplete(-1); err == nil {
		t.Fatal("GenerateMarkerComplete(-1) did not fail")
	}
}

func generateForFixture(t *testing.T, file string) string {
	t.Helper()
	const prefix = "position_tape_"
	if strings.HasSuffix(file, "_marker_complete.txt") {
		text := strings.TrimSuffix(strings.TrimPrefix(file, prefix), "_marker_complete.txt")
		length, err := strconv.Atoi(text)
		if err != nil {
			t.Fatal(err)
		}
		generated, err := pt.GenerateMarkerComplete(length)
		if err != nil {
			t.Fatal(err)
		}
		return generated
	}

	text := strings.TrimSuffix(strings.TrimPrefix(file, prefix), ".txt")
	length, err := strconv.Atoi(text)
	if err != nil {
		t.Fatal(err)
	}
	generated, err := pt.Generate(length)
	if err != nil {
		t.Fatal(err)
	}
	return generated
}

func repoRoot(t *testing.T) string {
	t.Helper()
	dir, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	for {
		if _, err := os.Stat(filepath.Join(dir, "fixtures", "manifest.generated.json")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			t.Fatal("could not find repository root")
		}
		dir = parent
	}
}

func contains(values []int, expected int) bool {
	for _, value := range values {
		if value == expected {
			return true
		}
	}
	return false
}
