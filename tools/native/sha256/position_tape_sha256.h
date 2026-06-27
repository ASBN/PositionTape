#ifndef POSITION_TAPE_SHA256_H
#define POSITION_TAPE_SHA256_H

#include <stddef.h>

#if defined(_WIN32)
#define POSITION_TAPE_SHA256_EXPORT __declspec(dllexport)
#else
#define POSITION_TAPE_SHA256_EXPORT
#endif

/*
 * Computes SHA-256 over an exact UTF-8 byte sequence and writes lowercase
 * hexadecimal text. The caller owns output_hex and must provide at least
 * 65 bytes; the result is NUL-terminated for C callers.
 */
POSITION_TAPE_SHA256_EXPORT int position_tape_sha256_hex(
    const unsigned char *input,
    size_t length,
    char output_hex[65]);

/*
 * COBOL-friendly ABI wrapper.
 *
 * GnuCOBOL passes fixed text buffers by reference. This function hashes the
 * first *length bytes of input, writes exactly 64 lowercase hex characters to
 * output_hex, and writes a trailing NUL only when the caller provided a larger
 * C buffer. COBOL callers should declare output as PIC X(64).
 */
POSITION_TAPE_SHA256_EXPORT int position_tape_sha256_hex_cobol(
    const char *input,
    const int *length,
    char *output_hex);

#endif
