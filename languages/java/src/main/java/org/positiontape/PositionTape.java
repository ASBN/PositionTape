package org.positiontape;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public final class PositionTape {
    public static final int DEFAULT_SEARCH_LENGTH = 100_003;

    private static final Map<Integer, Map<String, List<Integer>>> INDEX_CACHE = new HashMap<>();

    private PositionTape() {
    }

    public static String Generate(int length) {
        return generate(length);
    }

    public static String generate(int length) {
        if (length < 0) {
            throw new IllegalArgumentException("length must be non-negative");
        }

        StringBuilder builder = new StringBuilder(length);
        int cursor = 1;
        while (builder.length() < length) {
            if (cursor % 10 == 0) {
                String marker = Integer.toString(cursor / 10);
                int remaining = length - builder.length();
                builder.append(marker, 0, Math.min(marker.length(), remaining));
                cursor += marker.length();
            } else {
                builder.append((char) ('0' + (cursor % 10)));
                cursor += 1;
            }
        }

        return builder.toString();
    }

    public static String GenerateMarkerComplete(int length) {
        return generateMarkerComplete(length);
    }

    public static String generateMarkerComplete(int length) {
        return generate(markerCompleteLength(length));
    }

    public static int GetMarkerCompleteLength(int length) {
        return markerCompleteLength(length);
    }

    public static int markerCompleteLength(int length) {
        if (length < 0) {
            throw new IllegalArgumentException("length must be non-negative");
        }

        int cursor = 1;
        while (cursor <= length) {
            if (cursor % 10 == 0) {
                int markerLength = Integer.toString(cursor / 10).length();
                int markerEnd = cursor + markerLength - 1;
                if (length < markerEnd) {
                    return markerEnd;
                }
                cursor += markerLength;
            } else {
                cursor += 1;
            }
        }

        return length;
    }

    public static ValidationResult validate(String receivedText, int expectedLength) {
        if (receivedText == null) {
            throw new NullPointerException("receivedText");
        }

        String expected = generate(expectedLength);
        Mismatch mismatch = findFirstMismatch(expected, receivedText);
        Integer truncationPoint = null;
        if (mismatch != null && receivedText.length() < expectedLength && expected.startsWith(receivedText)) {
            truncationPoint = receivedText.length() + 1;
        }

        return new ValidationResult(
                mismatch == null,
                expectedLength,
                receivedText.length(),
                truncationPoint,
                mismatch);
    }

    public static ValidationResult Validate(String receivedText, int expectedLength) {
        return validate(receivedText, expectedLength);
    }

    public static int findTruncationPoint(String receivedText) {
        if (receivedText == null) {
            throw new NullPointerException("receivedText");
        }

        Mismatch mismatch = findFirstMismatch(generate(receivedText.length()), receivedText);
        return mismatch == null ? receivedText.length() + 1 : mismatch.position();
    }

    public static int FindTruncationPoint(String receivedText) {
        return findTruncationPoint(receivedText);
    }

    public static Mismatch findFirstMismatch(String expected, String received) {
        if (expected == null) {
            throw new NullPointerException("expected");
        }
        if (received == null) {
            throw new NullPointerException("received");
        }

        int sharedLength = Math.min(expected.length(), received.length());
        for (int index = 0; index < sharedLength; index += 1) {
            if (expected.charAt(index) != received.charAt(index)) {
                return new Mismatch(index + 1, expected.charAt(index), received.charAt(index));
            }
        }

        if (expected.length() == received.length()) {
            return null;
        }

        int position = sharedLength + 1;
        Character expectedCharacter = position <= expected.length() ? expected.charAt(position - 1) : null;
        Character receivedCharacter = position <= received.length() ? received.charAt(position - 1) : null;
        return new Mismatch(position, expectedCharacter, receivedCharacter);
    }

    public static Mismatch FindFirstMismatch(String expected, String received) {
        return findFirstMismatch(expected, received);
    }

    public static int locate(String fragment) {
        if (fragment == null) {
            throw new NullPointerException("fragment");
        }
        if (fragment.isEmpty()) {
            return 1;
        }

        int index = generate(DEFAULT_SEARCH_LENGTH).indexOf(fragment);
        return index < 0 ? -1 : index + 1;
    }

    public static int Locate(String fragment) {
        return locate(fragment);
    }

    public static Map<String, List<Integer>> buildWindowIndex(int windowSize) {
        if (windowSize <= 0) {
            throw new IllegalArgumentException("windowSize must be positive");
        }
        if (windowSize > DEFAULT_SEARCH_LENGTH) {
            throw new IllegalArgumentException("windowSize cannot exceed the default search length");
        }

        String tape = generate(DEFAULT_SEARCH_LENGTH);
        Map<String, List<Integer>> index = new LinkedHashMap<>();
        for (int offset = 0; offset <= tape.length() - windowSize; offset += 1) {
            String hash = hashFragment(tape.substring(offset, offset + windowSize));
            index.computeIfAbsent(hash, ignored -> new ArrayList<>()).add(offset + 1);
        }
        return index;
    }

    public static Map<String, List<Integer>> BuildWindowIndex(int windowSize) {
        return buildWindowIndex(windowSize);
    }

    public static List<Integer> locateByHash(String fragmentHash, int windowSize) {
        if (fragmentHash == null) {
            throw new NullPointerException("fragmentHash");
        }
        String normalizedHash = fragmentHash.trim().toLowerCase(Locale.ROOT);
        Map<String, List<Integer>> index;
        synchronized (INDEX_CACHE) {
            index = INDEX_CACHE.computeIfAbsent(windowSize, PositionTape::buildWindowIndex);
        }
        List<Integer> positions = index.get(normalizedHash);
        return positions == null ? List.of() : Collections.unmodifiableList(new ArrayList<>(positions));
    }

    public static List<Integer> LocateByHash(String fragmentHash, int windowSize) {
        return locateByHash(fragmentHash, windowSize);
    }

    public static String hashFragment(String fragment) {
        if (fragment == null) {
            throw new NullPointerException("fragment");
        }
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(fragment.getBytes(StandardCharsets.UTF_8));
            StringBuilder builder = new StringBuilder(digest.length * 2);
            for (byte value : digest) {
                builder.append(String.format("%02x", value & 0xff));
            }
            return builder.toString();
        } catch (NoSuchAlgorithmException error) {
            throw new IllegalStateException("SHA-256 is unavailable", error);
        }
    }

    public static String HashFragment(String fragment) {
        return hashFragment(fragment);
    }
}
