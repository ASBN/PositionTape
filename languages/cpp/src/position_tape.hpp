#pragma once

#include <algorithm>
#include <array>
#include <cctype>
#include <cstdint>
#include <iomanip>
#include <optional>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

namespace position_tape {

inline constexpr int default_search_length = 100003;

struct Mismatch {
    int position;
    std::optional<char> expected;
    std::optional<char> received;

    friend bool operator==(const Mismatch& left, const Mismatch& right) {
        return left.position == right.position
            && left.expected == right.expected
            && left.received == right.received;
    }
};

struct ValidationResult {
    bool is_valid;
    int expected_length;
    int received_length;
    std::optional<int> truncation_point;
    std::optional<Mismatch> first_mismatch;
};

inline std::string generate(int length) {
    if (length < 0) {
        throw std::invalid_argument("length must be non-negative");
    }

    std::string output;
    output.reserve(static_cast<std::size_t>(length));
    int cursor = 1;
    while (static_cast<int>(output.size()) < length) {
        if (cursor % 10 == 0) {
            std::string marker = std::to_string(cursor / 10);
            int remaining = length - static_cast<int>(output.size());
            output.append(marker, 0, static_cast<std::size_t>(std::min<int>(marker.size(), remaining)));
            cursor += static_cast<int>(marker.size());
        } else {
            output.push_back(static_cast<char>('0' + (cursor % 10)));
            cursor += 1;
        }
    }

    return output;
}

inline int marker_complete_length(int length) {
    if (length < 0) {
        throw std::invalid_argument("length must be non-negative");
    }

    int cursor = 1;
    while (cursor <= length) {
        if (cursor % 10 == 0) {
            int marker_length = static_cast<int>(std::to_string(cursor / 10).size());
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

inline std::string generate_marker_complete(int length) {
    return generate(marker_complete_length(length));
}

inline std::optional<Mismatch> find_first_mismatch(const std::string& expected, const std::string& received) {
    std::size_t shared_length = std::min(expected.size(), received.size());
    for (std::size_t index = 0; index < shared_length; index += 1) {
        if (expected[index] != received[index]) {
            return Mismatch{static_cast<int>(index + 1), expected[index], received[index]};
        }
    }

    if (expected.size() == received.size()) {
        return std::nullopt;
    }

    std::size_t position = shared_length + 1;
    std::optional<char> expected_char;
    std::optional<char> received_char;
    if (position <= expected.size()) {
        expected_char = expected[position - 1];
    }
    if (position <= received.size()) {
        received_char = received[position - 1];
    }

    return Mismatch{static_cast<int>(position), expected_char, received_char};
}

inline int find_truncation_point(const std::string& received_text) {
    auto mismatch = find_first_mismatch(generate(static_cast<int>(received_text.size())), received_text);
    return mismatch ? mismatch->position : static_cast<int>(received_text.size()) + 1;
}

inline ValidationResult validate(const std::string& received_text, int expected_length) {
    std::string expected = generate(expected_length);
    auto mismatch = find_first_mismatch(expected, received_text);
    std::optional<int> truncation_point;
    if (mismatch
        && static_cast<int>(received_text.size()) < expected_length
        && expected.rfind(received_text, 0) == 0) {
        truncation_point = static_cast<int>(received_text.size()) + 1;
    }

    return ValidationResult{
        !mismatch.has_value(),
        expected_length,
        static_cast<int>(received_text.size()),
        truncation_point,
        mismatch};
}

inline int locate(const std::string& fragment) {
    if (fragment.empty()) {
        return 1;
    }

    std::string haystack = generate(default_search_length);
    auto index = haystack.find(fragment);
    return index == std::string::npos ? -1 : static_cast<int>(index) + 1;
}

inline std::uint32_t rotr(std::uint32_t value, int count) {
    return (value >> count) | (value << (32 - count));
}

inline std::string hash_fragment(const std::string& fragment) {
    std::vector<std::uint8_t> message(fragment.begin(), fragment.end());
    std::uint64_t bit_length = static_cast<std::uint64_t>(message.size()) * 8u;
    message.push_back(0x80u);
    while (message.size() % 64u != 56u) {
        message.push_back(0u);
    }
    for (int shift = 56; shift >= 0; shift -= 8) {
        message.push_back(static_cast<std::uint8_t>((bit_length >> shift) & 0xffu));
    }

    std::array<std::uint32_t, 8> h{
        0x6a09e667u, 0xbb67ae85u, 0x3c6ef372u, 0xa54ff53au,
        0x510e527fu, 0x9b05688cu, 0x1f83d9abu, 0x5be0cd19u};
    constexpr std::array<std::uint32_t, 64> k{
        0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u, 0x3956c25bu, 0x59f111f1u, 0x923f82a4u, 0xab1c5ed5u,
        0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u, 0x72be5d74u, 0x80deb1feu, 0x9bdc06a7u, 0xc19bf174u,
        0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu, 0x2de92c6fu, 0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau,
        0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u, 0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u,
        0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu, 0x53380d13u, 0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u,
        0xa2bfe8a1u, 0xa81a664bu, 0xc24b8b70u, 0xc76c51a3u, 0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u,
        0x19a4c116u, 0x1e376c08u, 0x2748774cu, 0x34b0bcb5u, 0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
        0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u, 0x90befffau, 0xa4506cebu, 0xbef9a3f7u, 0xc67178f2u};

    for (std::size_t chunk_start = 0; chunk_start < message.size(); chunk_start += 64) {
        std::array<std::uint32_t, 64> w{};
        for (std::size_t index = 0; index < 16; index += 1) {
            std::size_t start = chunk_start + index * 4;
            w[index] = (static_cast<std::uint32_t>(message[start]) << 24)
                | (static_cast<std::uint32_t>(message[start + 1]) << 16)
                | (static_cast<std::uint32_t>(message[start + 2]) << 8)
                | static_cast<std::uint32_t>(message[start + 3]);
        }
        for (std::size_t index = 16; index < 64; index += 1) {
            std::uint32_t s0 = rotr(w[index - 15], 7) ^ rotr(w[index - 15], 18) ^ (w[index - 15] >> 3);
            std::uint32_t s1 = rotr(w[index - 2], 17) ^ rotr(w[index - 2], 19) ^ (w[index - 2] >> 10);
            w[index] = w[index - 16] + s0 + w[index - 7] + s1;
        }

        std::uint32_t a = h[0], b = h[1], c = h[2], d = h[3];
        std::uint32_t e = h[4], f = h[5], g = h[6], hh = h[7];
        for (std::size_t index = 0; index < 64; index += 1) {
            std::uint32_t s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
            std::uint32_t ch = (e & f) ^ ((~e) & g);
            std::uint32_t temp1 = hh + s1 + ch + k[index] + w[index];
            std::uint32_t s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
            std::uint32_t maj = (a & b) ^ (a & c) ^ (b & c);
            std::uint32_t temp2 = s0 + maj;
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

    std::ostringstream output;
    output << std::hex << std::setfill('0');
    for (std::uint32_t value : h) {
        output << std::setw(8) << value;
    }
    return output.str();
}

inline std::unordered_map<std::string, std::vector<int>> build_window_index(int window_size) {
    if (window_size <= 0) {
        throw std::invalid_argument("windowSize must be positive");
    }
    if (window_size > default_search_length) {
        throw std::invalid_argument("windowSize cannot exceed the default search length");
    }

    std::string tape = generate(default_search_length);
    std::unordered_map<std::string, std::vector<int>> index;
    for (int offset = 0; offset <= static_cast<int>(tape.size()) - window_size; offset += 1) {
        auto hash = hash_fragment(tape.substr(static_cast<std::size_t>(offset), static_cast<std::size_t>(window_size)));
        index[hash].push_back(offset + 1);
    }
    return index;
}

inline std::vector<int> locate_by_hash(const std::string& fragment_hash, int window_size) {
    std::string normalized = fragment_hash;
    std::transform(normalized.begin(), normalized.end(), normalized.begin(), [](unsigned char value) {
        return static_cast<char>(std::tolower(value));
    });
    normalized.erase(normalized.begin(), std::find_if(normalized.begin(), normalized.end(), [](unsigned char value) {
        return !std::isspace(value);
    }));
    normalized.erase(std::find_if(normalized.rbegin(), normalized.rend(), [](unsigned char value) {
        return !std::isspace(value);
    }).base(), normalized.end());

    auto index = build_window_index(window_size);
    auto found = index.find(normalized);
    return found == index.end() ? std::vector<int>{} : found->second;
}

} // namespace position_tape
