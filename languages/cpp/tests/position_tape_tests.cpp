#include "position_tape.hpp"

#include <cstdlib>
#include <algorithm>
#include <iostream>
#include <stdexcept>
#include <string>

namespace {

void require(bool condition, const std::string& message) {
    if (!condition) {
        throw std::runtime_error(message);
    }
}

void require_equal(const std::string& expected, const std::string& actual, const std::string& message) {
    if (expected != actual) {
        throw std::runtime_error(message + ": expected " + expected + " got " + actual);
    }
}

} // namespace

int main() {
    using namespace position_tape;

    try {
        require_equal("", generate(0), "Generate(0)");
        require_equal("1", generate(1), "Generate(1)");
        require_equal("123456789", generate(9), "Generate(9)");
        require_equal("1234567891", generate(10), "Generate(10)");
        require_equal("12345678911", generate(11), "Generate(11)");
        require_equal(
            "1234567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891",
            generate(100),
            "Generate(100)");

        require(generate_marker_complete(99).size() == 99, "marker-complete 99");
        require(generate_marker_complete(100).size() == 101, "marker-complete 100");
        require(generate_marker_complete(101).size() == 101, "marker-complete 101");
        require(generate_marker_complete(10000).size() == 10003, "marker-complete 10000");

        auto valid = validate(generate(100), 100);
        require(valid.is_valid, "valid payload");
        require(!valid.first_mismatch.has_value(), "valid mismatch");
        require(!valid.truncation_point.has_value(), "valid truncation");

        auto truncated = validate(generate(99), 100);
        require(!truncated.is_valid, "truncated invalid");
        require(truncated.truncation_point == 100, "truncated point");
        require(find_truncation_point("12x45") == 3, "mutation point");
        require(!find_first_mismatch("abc", "abc").has_value(), "equal mismatch");

        std::string source = generate(80);
        std::string fragment = source.substr(29, 12);
        require(locate(fragment) == 30, "locate");
        std::string hash = hash_fragment(fragment);
        auto index = build_window_index(static_cast<int>(fragment.size()));
        require(std::find(index[hash].begin(), index[hash].end(), 30) != index[hash].end(), "hash index");
        auto positions = locate_by_hash(hash, static_cast<int>(fragment.size()));
        require(std::find(positions.begin(), positions.end(), 30) != positions.end(), "locate by hash");
        require(
            hash_fragment(generate(10000)) == "9ee39196c3dd959c14600095c165c237d0b4a7639237cf2bb1bfbee6f3321f5c",
            "sha256 fixture");

        bool rejected = false;
        try {
            (void)generate(-1);
        } catch (const std::invalid_argument&) {
            rejected = true;
        }
        require(rejected, "negative length");

        std::cout << "OK cpp Level 3" << std::endl;
        return EXIT_SUCCESS;
    } catch (const std::exception& ex) {
        std::cerr << ex.what() << std::endl;
        return EXIT_FAILURE;
    }
}
