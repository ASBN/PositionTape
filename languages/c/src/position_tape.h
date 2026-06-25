#ifndef POSITION_TAPE_H
#define POSITION_TAPE_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

#define POSITION_TAPE_DEFAULT_SEARCH_LENGTH 100003

typedef struct {
    int position;
    char expected;
    char received;
    int has_expected;
    int has_received;
} PositionTapeMismatch;

typedef struct {
    int is_valid;
    int expected_length;
    int received_length;
    int truncation_point;
    int has_truncation_point;
    PositionTapeMismatch first_mismatch;
    int has_first_mismatch;
} PositionTapeValidationResult;

typedef struct {
    char *hash;
    int *positions;
    size_t position_count;
} PositionTapeHashEntry;

typedef struct {
    PositionTapeHashEntry *entries;
    size_t entry_count;
} PositionTapeHashIndex;

char *position_tape_generate(int length);
char *position_tape_generate_marker_complete(int length);
int position_tape_marker_complete_length(int length);
int position_tape_locate(const char *fragment);
PositionTapeValidationResult position_tape_validate(const char *received_text, int expected_length);
int position_tape_find_truncation_point(const char *received_text);
int position_tape_find_first_mismatch(const char *expected, const char *received, PositionTapeMismatch *mismatch);
char *position_tape_hash_fragment(const char *fragment);
PositionTapeHashIndex position_tape_build_window_index(int window_size);
int *position_tape_locate_by_hash(const char *fragment_hash, int window_size, size_t *position_count);
void position_tape_free_hash_index(PositionTapeHashIndex *index);

#ifdef __cplusplus
}
#endif

#endif
