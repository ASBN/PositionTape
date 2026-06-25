package org.positiontape;

public record ValidationResult(
        boolean isValid,
        int expectedLength,
        int receivedLength,
        Integer truncationPoint,
        Mismatch firstMismatch) {
}
