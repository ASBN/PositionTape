package org.positiontape;

public record Mismatch(int position, Character expected, Character received) {
}
