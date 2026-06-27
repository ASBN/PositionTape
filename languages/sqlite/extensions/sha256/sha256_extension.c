#include <sqlite3ext.h>
SQLITE_EXTENSION_INIT1

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#define POSITION_TAPE_EXPORT __declspec(dllexport)
#else
#define POSITION_TAPE_EXPORT
#endif

static uint32_t position_tape_rotr32(uint32_t value, int count) {
    return (value >> count) | (value << (32 - count));
}

/**
 * Computes SHA-256 for the exact input byte sequence.
 *
 * The SQLite wrapper passes `sqlite3_value_text` bytes, which SQLite exposes as
 * UTF-8 for TEXT values. The returned digest is binary and deterministic; the
 * SQL function converts it to lowercase hexadecimal.
 */
static int position_tape_sha256_bytes(const unsigned char *input, size_t length, unsigned char digest[32]) {
    static const uint32_t k[64] = {
        0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u, 0x3956c25bu, 0x59f111f1u, 0x923f82a4u,
        0xab1c5ed5u, 0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u, 0x72be5d74u, 0x80deb1feu,
        0x9bdc06a7u, 0xc19bf174u, 0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu, 0x2de92c6fu,
        0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau, 0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u,
        0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u, 0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu,
        0x53380d13u, 0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u, 0xa2bfe8a1u, 0xa81a664bu,
        0xc24b8b70u, 0xc76c51a3u, 0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u, 0x19a4c116u,
        0x1e376c08u, 0x2748774cu, 0x34b0bcb5u, 0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
        0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u, 0x90befffau, 0xa4506cebu, 0xbef9a3f7u,
        0xc67178f2u};
    uint32_t h[8] = {
        0x6a09e667u, 0xbb67ae85u, 0x3c6ef372u, 0xa54ff53au,
        0x510e527fu, 0x9b05688cu, 0x1f83d9abu, 0x5be0cd19u};

    if (length > ((SIZE_MAX - 9u) / 64u) * 64u) {
        return 0;
    }

    uint64_t bit_length = (uint64_t)length * 8u;
    size_t padded_length = length + 1u;
    while (padded_length % 64u != 56u) {
        padded_length += 1u;
    }
    padded_length += 8u;

    unsigned char *message = (unsigned char *)calloc(padded_length, 1u);
    if (message == NULL) {
        return 0;
    }

    if (length > 0u) {
        memcpy(message, input, length);
    }
    message[length] = 0x80u;
    for (int shift = 56, index = 0; shift >= 0; shift -= 8, index += 1) {
        message[padded_length - 8u + (size_t)index] = (unsigned char)((bit_length >> shift) & 0xffu);
    }

    for (size_t chunk = 0u; chunk < padded_length; chunk += 64u) {
        uint32_t w[64] = {0u};
        for (int index = 0; index < 16; index += 1) {
            size_t start = chunk + (size_t)index * 4u;
            w[index] = ((uint32_t)message[start] << 24) |
                       ((uint32_t)message[start + 1u] << 16) |
                       ((uint32_t)message[start + 2u] << 8) |
                       (uint32_t)message[start + 3u];
        }
        for (int index = 16; index < 64; index += 1) {
            uint32_t s0 = position_tape_rotr32(w[index - 15], 7) ^
                          position_tape_rotr32(w[index - 15], 18) ^
                          (w[index - 15] >> 3);
            uint32_t s1 = position_tape_rotr32(w[index - 2], 17) ^
                          position_tape_rotr32(w[index - 2], 19) ^
                          (w[index - 2] >> 10);
            w[index] = w[index - 16] + s0 + w[index - 7] + s1;
        }

        uint32_t a = h[0];
        uint32_t b = h[1];
        uint32_t c = h[2];
        uint32_t d = h[3];
        uint32_t e = h[4];
        uint32_t f = h[5];
        uint32_t g = h[6];
        uint32_t hh = h[7];

        for (int index = 0; index < 64; index += 1) {
            uint32_t s1 = position_tape_rotr32(e, 6) ^ position_tape_rotr32(e, 11) ^ position_tape_rotr32(e, 25);
            uint32_t ch = (e & f) ^ ((~e) & g);
            uint32_t temp1 = hh + s1 + ch + k[index] + w[index];
            uint32_t s0 = position_tape_rotr32(a, 2) ^ position_tape_rotr32(a, 13) ^ position_tape_rotr32(a, 22);
            uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
            uint32_t temp2 = s0 + maj;
            hh = g;
            g = f;
            f = e;
            e = d + temp1;
            d = c;
            c = b;
            b = a;
            a = temp1 + temp2;
        }

        h[0] += a;
        h[1] += b;
        h[2] += c;
        h[3] += d;
        h[4] += e;
        h[5] += f;
        h[6] += g;
        h[7] += hh;
    }

    free(message);
    for (int word = 0; word < 8; word += 1) {
        digest[(size_t)word * 4u] = (unsigned char)((h[word] >> 24) & 0xffu);
        digest[(size_t)word * 4u + 1u] = (unsigned char)((h[word] >> 16) & 0xffu);
        digest[(size_t)word * 4u + 2u] = (unsigned char)((h[word] >> 8) & 0xffu);
        digest[(size_t)word * 4u + 3u] = (unsigned char)(h[word] & 0xffu);
    }
    return 1;
}

/**
 * SQLite scalar function `sha256(text)`.
 *
 * NULL input returns NULL. Non-NULL input is converted by SQLite to UTF-8 TEXT,
 * hashed over its exact byte sequence, and returned as lowercase 64-character
 * hexadecimal text.
 */
static void position_tape_sqlite_sha256(sqlite3_context *context, int argc, sqlite3_value **argv) {
    static const char hex_digits[] = "0123456789abcdef";
    unsigned char digest[32];
    char output[65];

    (void)argc;
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }

    const unsigned char *text = sqlite3_value_text(argv[0]);
    int byte_count = sqlite3_value_bytes(argv[0]);
    if (text == NULL || byte_count < 0) {
        sqlite3_result_error_nomem(context);
        return;
    }

    if (!position_tape_sha256_bytes(text, (size_t)byte_count, digest)) {
        sqlite3_result_error_nomem(context);
        return;
    }

    for (int index = 0; index < 32; index += 1) {
        output[index * 2] = hex_digits[digest[index] >> 4];
        output[index * 2 + 1] = hex_digits[digest[index] & 0x0f];
    }
    output[64] = '\0';
    sqlite3_result_text(context, output, 64, SQLITE_TRANSIENT);
}

static int position_tape_register_sha256(sqlite3 *db) {
    return sqlite3_create_function(
        db,
        "sha256",
        1,
        SQLITE_UTF8 | SQLITE_DETERMINISTIC | SQLITE_INNOCUOUS,
        NULL,
        position_tape_sqlite_sha256,
        NULL,
        NULL);
}

POSITION_TAPE_EXPORT int sqlite3_sha256_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
    SQLITE_EXTENSION_INIT2(pApi);
    (void)pzErrMsg;
    return position_tape_register_sha256(db);
}

POSITION_TAPE_EXPORT int sqlite3_sha256extension_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
    SQLITE_EXTENSION_INIT2(pApi);
    (void)pzErrMsg;
    return position_tape_register_sha256(db);
}

POSITION_TAPE_EXPORT int sqlite3_extension_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
    SQLITE_EXTENSION_INIT2(pApi);
    (void)pzErrMsg;
    return position_tape_register_sha256(db);
}
