import org.positiontape.PositionTape;
import org.positiontape.ValidationResult;

public final class PositionTapeTest {
    public static void main(String[] args) {
        assertEquals("", PositionTape.generate(0));
        assertEquals("1", PositionTape.generate(1));
        assertEquals("123456789", PositionTape.generate(9));
        assertEquals("1234567891", PositionTape.generate(10));
        assertEquals("12345678911", PositionTape.generate(11));
        assertEquals(99, PositionTape.generateMarkerComplete(99).length());
        assertEquals(101, PositionTape.generateMarkerComplete(100).length());
        assertEquals(101, PositionTape.generateMarkerComplete(101).length());
        assertEquals(10003, PositionTape.generateMarkerComplete(10000).length());

        ValidationResult valid = PositionTape.validate(PositionTape.generate(100), 100);
        if (!valid.isValid() || valid.firstMismatch() != null || valid.truncationPoint() != null) {
            throw new AssertionError("valid payload reported invalid");
        }

        ValidationResult truncated = PositionTape.validate(PositionTape.generate(99), 100);
        if (truncated.isValid() || truncated.truncationPoint() == null || truncated.truncationPoint() != 100) {
            throw new AssertionError("truncated payload did not report position 100");
        }

        assertEquals(3, PositionTape.findTruncationPoint("12x45"));
        if (PositionTape.findFirstMismatch("abc", "abc") != null) {
            throw new AssertionError("equal strings reported mismatch");
        }

        String fragment = PositionTape.generate(80).substring(29, 41);
        assertEquals(30, PositionTape.locate(fragment));
        String hash = PositionTape.hashFragment(fragment);
        if (!PositionTape.buildWindowIndex(fragment.length()).get(hash).contains(30)) {
            throw new AssertionError("BuildWindowIndex missing position 30");
        }
        if (!PositionTape.locateByHash(hash.toUpperCase(), fragment.length()).contains(30)) {
            throw new AssertionError("LocateByHash missing position 30");
        }

        assertEquals(PositionTape.generate(10), PositionTape.Generate(10));
        assertEquals(30, PositionTape.Locate(fragment));
    }

    private static void assertEquals(Object expected, Object actual) {
        if (!expected.equals(actual)) {
            throw new AssertionError("expected " + expected + " but got " + actual);
        }
    }
}
