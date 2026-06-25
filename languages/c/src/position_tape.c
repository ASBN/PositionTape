#include "position_tape.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static uint32_t rotr(uint32_t value, int count) {
    return (value >> count) | (value << (32 - count));
}

static char *normalized_hash(const char *hash) {
    while (isspace((unsigned char)*hash)) {
        hash += 1;
    }
    size_t length = strlen(hash);
    while (length > 0 && isspace((unsigned char)hash[length - 1])) {
        length -= 1;
    }
    char *normalized = (char *)malloc(length + 1);
    if (normalized == NULL) {
        return NULL;
    }
    for (size_t index = 0; index < length; index += 1) {
        normalized[index] = (char)tolower((unsigned char)hash[index]);
    }
    normalized[length] = '\0';
    return normalized;
}

char *position_tape_generate(int length) {
    if (length < 0) {
        return NULL;
    }

    char *output = (char *)malloc((size_t)length + 1);
    if (output == NULL) {
        return NULL;
    }

    int cursor = 1;
    int written = 0;
    while (written < length) {
        if (cursor % 10 == 0) {
            char marker[32];
            int marker_length = snprintf(marker, sizeof(marker), "%d", cursor / 10);
            int remaining = length - written;
            int copy_length = marker_length < remaining ? marker_length : remaining;
            memcpy(output + written, marker, (size_t)copy_length);
            written += copy_length;
            cursor += marker_length;
        } else {
            output[written++] = (char)('0' + (cursor % 10));
            cursor += 1;
        }
    }

    output[written] = '\0';
    return output;
}

int position_tape_marker_complete_length(int length) {
    if (length < 0) {
        return -1;
    }

    int cursor = 1;
    while (cursor <= length) {
        if (cursor % 10 == 0) {
            char marker[32];
            int marker_length = snprintf(marker, sizeof(marker), "%d", cursor / 10);
            int marker_end = cursor + marker_length - 1;
            if (length < marker_end) {
                return marker_end;
            }
            cursor += marker_length;
        } else {
            cursor += 1;
        }
    }

    return length;
}

char *position_tape_generate_marker_complete(int length) {
    int adjusted = position_tape_marker_complete_length(length);
    return adjusted < 0 ? NULL : position_tape_generate(adjusted);
}

int position_tape_find_first_mismatch(const char *expected, const char *received, PositionTapeMismatch *mismatch) {
    size_t expected_length = strlen(expected);
    size_t received_length = strlen(received);
    size_t shared_length = expected_length < received_length ? expected_length : received_length;

    for (size_t index = 0; index < shared_length; index += 1) {
        if (expected[index] != received[index]) {
            if (mismatch != NULL) {
                mismatch->position = (int)index + 1;
                mismatch->expected = expected[index];
                mismatch->received = received[index];
                mismatch->has_expected = 1;
                mismatch->has_received = 1;
            }
            return 1;
        }
    }

    if (expected_length == received_length) {
        return 0;
    }

    if (mismatch != NULL) {
        size_t position = shared_length + 1;
        mismatch->position = (int)position;
        mismatch->has_expected = position <= expected_length;
        mismatch->has_received = position <= received_length;
        mismatch->expected = mismatch->has_expected ? expected[position - 1] : '\0';
        mismatch->received = mismatch->has_received ? received[position - 1] : '\0';
    }
    return 1;
}

PositionTapeValidationResult position_tape_validate(const char *received_text, int expected_length) {
    PositionTapeValidationResult result;
    memset(&result, 0, sizeof(result));
    result.expected_length = expected_length;
    result.received_length = (int)strlen(received_text);

    char *expected = position_tape_generate(expected_length);
    if (expected == NULL) {
        return result;
    }

    result.has_first_mismatch = position_tape_find_first_mismatch(expected, received_text, &result.first_mismatch);
    result.is_valid = !result.has_first_mismatch;
    if (result.has_first_mismatch && result.received_length < expected_length && strncmp(expected, received_text, strlen(received_text)) == 0) {
        result.has_truncation_point = 1;
        result.truncation_point = result.received_length + 1;
    }

    free(expected);
    return result;
}

int position_tape_find_truncation_point(const char *received_text) {
    char *expected = position_tape_generate((int)strlen(received_text));
    if (expected == NULL) {
        return -1;
    }

    PositionTapeMismatch mismatch;
    int has_mismatch = position_tape_find_first_mismatch(expected, received_text, &mismatch);
    free(expected);
    return has_mismatch ? mismatch.position : (int)strlen(received_text) + 1;
}

int position_tape_locate(const char *fragment) {
    if (fragment[0] == '\0') {
        return 1;
    }

    char *haystack = position_tape_generate(POSITION_TAPE_DEFAULT_SEARCH_LENGTH);
    if (haystack == NULL) {
        return -1;
    }
    char *found = strstr(haystack, fragment);
    int result = found == NULL ? -1 : (int)(found - haystack) + 1;
    free(haystack);
    return result;
}

char *position_tape_hash_fragment(const char *fragment) {
    static const uint32_t k[64] = {
        0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u, 0x3956c25bu, 0x59f111f1u, 0x923f82a4u, 0xab1c5ed5u,
        0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u, 0x72be5d74u, 0x80deb1feu, 0x9bdc06a7u, 0xc19bf174u,
        0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu, 0x2de92c6fu, 0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau,
        0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u, 0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u,
        0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu, 0x53380d13u, 0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u,
        0xa2bfe8a1u, 0xa81a664bu, 0xc24b8b70u, 0xc76c51a3u, 0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u,
        0x19a4c116u, 0x1e376c08u, 0x2748774cu, 0x34b0bcb5u, 0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
        0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u, 0x90befffau, 0xa4506cebu, 0xbef9a3f7u, 0xc67178f2u};
    uint32_t h[8] = {0x6a09e667u, 0xbb67ae85u, 0x3c6ef372u, 0xa54ff53au, 0x510e527fu, 0x9b05688cu, 0x1f83d9abu, 0x5be0cd19u};

    size_t length = strlen(fragment);
    uint64_t bit_length = (uint64_t)length * 8u;
    size_t padded_length = length + 1;
    while (padded_length % 64u != 56u) {
        padded_length += 1;
    }
    padded_length += 8;

    uint8_t *message = (uint8_t *)calloc(padded_length, 1);
    if (message == NULL) {
        return NULL;
    }
    memcpy(message, fragment, length);
    message[length] = 0x80u;
    for (int shift = 56, index = 0; shift >= 0; shift -= 8, index += 1) {
        message[padded_length - 8 + (size_t)index] = (uint8_t)((bit_length >> shift) & 0xffu);
    }

    for (size_t chunk = 0; chunk < padded_length; chunk += 64) {
        uint32_t w[64] = {0};
        for (int index = 0; index < 16; index += 1) {
            size_t start = chunk + (size_t)index * 4u;
            w[index] = ((uint32_t)message[start] << 24) | ((uint32_t)message[start + 1] << 16) | ((uint32_t)message[start + 2] << 8) | (uint32_t)message[start + 3];
        }
        for (int index = 16; index < 64; index += 1) {
            uint32_t s0 = rotr(w[index - 15], 7) ^ rotr(w[index - 15], 18) ^ (w[index - 15] >> 3);
            uint32_t s1 = rotr(w[index - 2], 17) ^ rotr(w[index - 2], 19) ^ (w[index - 2] >> 10);
            w[index] = w[index - 16] + s0 + w[index - 7] + s1;
        }

        uint32_t a = h[0], b = h[1], c = h[2], d = h[3], e = h[4], f = h[5], g = h[6], hh = h[7];
        for (int index = 0; index < 64; index += 1) {
            uint32_t s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
            uint32_t ch = (e & f) ^ ((~e) & g);
            uint32_t temp1 = hh + s1 + ch + k[index] + w[index];
            uint32_t s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
            uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
            uint32_t temp2 = s0 + maj;
            hh = g; g = f; f = e; e = d + temp1; d = c; c = b; b = a; a = temp1 + temp2;
        }
        h[0] += a; h[1] += b; h[2] += c; h[3] += d; h[4] += e; h[5] += f; h[6] += g; h[7] += hh;
    }

    free(message);
    char *hex = (char *)malloc(65);
    if (hex == NULL) {
        return NULL;
    }
    snprintf(hex, 65, "%08x%08x%08x%08x%08x%08x%08x%08x", h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]);
    return hex;
}

PositionTapeHashIndex position_tape_build_window_index(int window_size) {
    PositionTapeHashIndex result;
    result.entries = NULL;
    result.entry_count = 0;
    if (window_size <= 0 || window_size > POSITION_TAPE_DEFAULT_SEARCH_LENGTH) {
        return result;
    }

    char *tape = position_tape_generate(POSITION_TAPE_DEFAULT_SEARCH_LENGTH);
    if (tape == NULL) {
        return result;
    }

    for (int offset = 0; offset <= POSITION_TAPE_DEFAULT_SEARCH_LENGTH - window_size; offset += 1) {
        char *window = (char *)malloc((size_t)window_size + 1);
        memcpy(window, tape + offset, (size_t)window_size);
        window[window_size] = '\0';
        char *hash = position_tape_hash_fragment(window);
        free(window);

        size_t found = result.entry_count;
        for (size_t index = 0; index < result.entry_count; index += 1) {
            if (strcmp(result.entries[index].hash, hash) == 0) {
                found = index;
                break;
            }
        }
        if (found == result.entry_count) {
            result.entries = (PositionTapeHashEntry *)realloc(result.entries, sizeof(PositionTapeHashEntry) * (result.entry_count + 1));
            result.entries[found].hash = hash;
            result.entries[found].positions = NULL;
            result.entries[found].position_count = 0;
            result.entry_count += 1;
        } else {
            free(hash);
        }
        PositionTapeHashEntry *entry = &result.entries[found];
        entry->positions = (int *)realloc(entry->positions, sizeof(int) * (entry->position_count + 1));
        entry->positions[entry->position_count++] = offset + 1;
    }

    free(tape);
    return result;
}

int *position_tape_locate_by_hash(const char *fragment_hash, int window_size, size_t *position_count) {
    *position_count = 0;
    char *normalized = normalized_hash(fragment_hash);
    if (normalized == NULL) {
        return NULL;
    }
    PositionTapeHashIndex index = position_tape_build_window_index(window_size);
    for (size_t entry = 0; entry < index.entry_count; entry += 1) {
        if (strcmp(index.entries[entry].hash, normalized) == 0) {
            int *positions = (int *)malloc(sizeof(int) * index.entries[entry].position_count);
            memcpy(positions, index.entries[entry].positions, sizeof(int) * index.entries[entry].position_count);
            *position_count = index.entries[entry].position_count;
            free(normalized);
            position_tape_free_hash_index(&index);
            return positions;
        }
    }
    free(normalized);
    position_tape_free_hash_index(&index);
    return NULL;
}

void position_tape_free_hash_index(PositionTapeHashIndex *index) {
    if (index == NULL) {
        return;
    }
    for (size_t entry = 0; entry < index->entry_count; entry += 1) {
        free(index->entries[entry].hash);
        free(index->entries[entry].positions);
    }
    free(index->entries);
    index->entries = NULL;
    index->entry_count = 0;
}
