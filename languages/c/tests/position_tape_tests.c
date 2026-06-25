#include "../src/position_tape.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void require(int condition, const char *message) {
    if (!condition) {
        fprintf(stderr, "%s\n", message);
        exit(1);
    }
}

int main(void) {
    char *exact = position_tape_generate(10);
    require(strcmp(exact, "1234567891") == 0, "Generate(10)");
    free(exact);

    char *complete = position_tape_generate_marker_complete(100);
    require((int)strlen(complete) == 101, "GenerateMarkerComplete(100)");
    free(complete);

    exact = position_tape_generate(50);
    PositionTapeValidationResult valid = position_tape_validate(exact, 50);
    require(valid.is_valid, "valid result");
    PositionTapeValidationResult truncated = position_tape_validate("12345678911234567", 50);
    require(truncated.has_truncation_point && truncated.truncation_point == 18, "truncation point");
    require(position_tape_find_truncation_point("123X") == 4, "mismatch point");
    free(exact);

    char *source = position_tape_generate(80);
    char fragment[13];
    memcpy(fragment, source + 29, 12);
    fragment[12] = '\0';
    require(position_tape_locate(fragment) == 30, "locate");
    char *hash = position_tape_hash_fragment(fragment);
    PositionTapeHashIndex index = position_tape_build_window_index(12);
    int found = 0;
    for (size_t entry = 0; entry < index.entry_count; entry += 1) {
        if (strcmp(index.entries[entry].hash, hash) == 0) {
            for (size_t position = 0; position < index.entries[entry].position_count; position += 1) {
                found = found || index.entries[entry].positions[position] == 30;
            }
        }
    }
    require(found, "hash index");
    size_t position_count = 0;
    int *positions = position_tape_locate_by_hash(hash, 12, &position_count);
    found = 0;
    for (size_t index_position = 0; index_position < position_count; index_position += 1) {
        found = found || positions[index_position] == 30;
    }
    require(found, "locate by hash");
    free(positions);
    free(hash);
    position_tape_free_hash_index(&index);
    free(source);

    exact = position_tape_generate(10000);
    hash = position_tape_hash_fragment(exact);
    require(strcmp(hash, "9ee39196c3dd959c14600095c165c237d0b4a7639237cf2bb1bfbee6f3321f5c") == 0, "sha256 fixture");
    free(hash);
    free(exact);

    printf("OK c position_tape\n");
    return 0;
}
