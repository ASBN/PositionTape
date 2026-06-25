#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Mismatch {
    pub position: usize,
    pub expected: Option<char>,
    pub received: Option<char>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ValidationResult {
    pub is_valid: bool,
    pub expected_length: usize,
    pub received_length: usize,
    pub truncation_point: Option<usize>,
    pub first_mismatch: Option<Mismatch>,
}

pub const DEFAULT_SEARCH_LENGTH: usize = 100_003;

pub fn generate(length: usize) -> String {
    let mut output = String::with_capacity(length);
    let mut cursor = 1usize;

    while output.len() < length {
        if cursor % 10 == 0 {
            let marker = (cursor / 10).to_string();
            let remaining = length - output.len();
            output.push_str(&marker[..marker.len().min(remaining)]);
            cursor += marker.len();
        } else {
            let digit = char::from(b'0' + (cursor % 10) as u8);
            output.push(digit);
            cursor += 1;
        }
    }

    output
}

pub fn generate_marker_complete(length: usize) -> String {
    generate(marker_complete_length(length))
}

pub fn marker_complete_length(length: usize) -> usize {
    let mut cursor = 1usize;
    while cursor <= length {
        if cursor % 10 == 0 {
            let marker_length = (cursor / 10).to_string().len();
            let marker_end = cursor + marker_length - 1;
            if length < marker_end {
                return marker_end;
            }
            cursor += marker_length;
        } else {
            cursor += 1;
        }
    }

    length
}

pub fn validate(received_text: &str, expected_length: usize) -> ValidationResult {
    let expected = generate(expected_length);
    let mismatch = find_first_mismatch(&expected, received_text);
    let truncation_point =
        if mismatch.is_some() && received_text.len() < expected_length && expected.starts_with(received_text) {
            Some(received_text.len() + 1)
        } else {
            None
        };

    ValidationResult {
        is_valid: mismatch.is_none(),
        expected_length,
        received_length: received_text.len(),
        truncation_point,
        first_mismatch: mismatch,
    }
}

pub fn find_truncation_point(received_text: &str) -> usize {
    let expected_prefix = generate(received_text.len());
    find_first_mismatch(&expected_prefix, received_text)
        .map(|mismatch| mismatch.position)
        .unwrap_or(received_text.len() + 1)
}

pub fn find_first_mismatch(expected: &str, received: &str) -> Option<Mismatch> {
    let expected_bytes = expected.as_bytes();
    let received_bytes = received.as_bytes();
    let shared_length = expected_bytes.len().min(received_bytes.len());

    for index in 0..shared_length {
        if expected_bytes[index] != received_bytes[index] {
            return Some(Mismatch {
                position: index + 1,
                expected: Some(expected_bytes[index] as char),
                received: Some(received_bytes[index] as char),
            });
        }
    }

    if expected_bytes.len() == received_bytes.len() {
        return None;
    }

    let position = shared_length + 1;
    Some(Mismatch {
        position,
        expected: expected_bytes.get(position - 1).map(|byte| *byte as char),
        received: received_bytes.get(position - 1).map(|byte| *byte as char),
    })
}

pub fn locate(fragment: &str) -> isize {
    if fragment.is_empty() {
        return 1;
    }

    generate(DEFAULT_SEARCH_LENGTH)
        .find(fragment)
        .map(|index| index as isize + 1)
        .unwrap_or(-1)
}

pub fn hash_fragment(fragment: &str) -> String {
    let mut message = fragment.as_bytes().to_vec();
    let bit_length = (message.len() as u64) * 8;
    message.push(0x80);
    while message.len() % 64 != 56 {
        message.push(0);
    }
    message.extend_from_slice(&bit_length.to_be_bytes());

    let mut h = [
        0x6a09e667u32, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    ];
    const K: [u32; 64] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ];

    for chunk in message.chunks(64) {
        let mut w = [0u32; 64];
        for index in 0..16 {
            let start = index * 4;
            w[index] = u32::from_be_bytes([chunk[start], chunk[start + 1], chunk[start + 2], chunk[start + 3]]);
        }
        for index in 16..64 {
            let s0 = w[index - 15].rotate_right(7) ^ w[index - 15].rotate_right(18) ^ (w[index - 15] >> 3);
            let s1 = w[index - 2].rotate_right(17) ^ w[index - 2].rotate_right(19) ^ (w[index - 2] >> 10);
            w[index] = w[index - 16].wrapping_add(s0).wrapping_add(w[index - 7]).wrapping_add(s1);
        }

        let (mut a, mut b, mut c, mut d, mut e, mut f, mut g, mut hh) =
            (h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]);
        for index in 0..64 {
            let s1 = e.rotate_right(6) ^ e.rotate_right(11) ^ e.rotate_right(25);
            let ch = (e & f) ^ ((!e) & g);
            let temp1 = hh.wrapping_add(s1).wrapping_add(ch).wrapping_add(K[index]).wrapping_add(w[index]);
            let s0 = a.rotate_right(2) ^ a.rotate_right(13) ^ a.rotate_right(22);
            let maj = (a & b) ^ (a & c) ^ (b & c);
            let temp2 = s0.wrapping_add(maj);
            hh = g;
            g = f;
            f = e;
            e = d.wrapping_add(temp1);
            d = c;
            c = b;
            b = a;
            a = temp1.wrapping_add(temp2);
        }

        h[0] = h[0].wrapping_add(a);
        h[1] = h[1].wrapping_add(b);
        h[2] = h[2].wrapping_add(c);
        h[3] = h[3].wrapping_add(d);
        h[4] = h[4].wrapping_add(e);
        h[5] = h[5].wrapping_add(f);
        h[6] = h[6].wrapping_add(g);
        h[7] = h[7].wrapping_add(hh);
    }

    h.iter().map(|value| format!("{value:08x}")).collect()
}

pub fn build_window_index(window_size: usize) -> std::collections::HashMap<String, Vec<usize>> {
    assert!(window_size > 0, "windowSize must be positive");
    assert!(window_size <= DEFAULT_SEARCH_LENGTH, "windowSize cannot exceed the default search length");

    let tape = generate(DEFAULT_SEARCH_LENGTH);
    let mut index = std::collections::HashMap::<String, Vec<usize>>::new();
    for offset in 0..=(tape.len() - window_size) {
        let hash = hash_fragment(&tape[offset..offset + window_size]);
        index.entry(hash).or_default().push(offset + 1);
    }
    index
}

pub fn locate_by_hash(fragment_hash: &str, window_size: usize) -> Vec<usize> {
    let normalized_hash = fragment_hash.trim().to_ascii_lowercase();
    build_window_index(window_size)
        .remove(&normalized_hash)
        .unwrap_or_default()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn generate_known_values() {
        assert_eq!("", generate(0));
        assert_eq!("1", generate(1));
        assert_eq!("123456789", generate(9));
        assert_eq!("1234567891", generate(10));
        assert_eq!("12345678911", generate(11));
        assert_eq!("1234567891123456789212345678931234567894123456789512345678961234567897123456789812345678991234567891", generate(100));
        assert_eq!("12345678911234567892123456789312345678941234567895123456789612345678971234567898123456789912345678910", generate(101));
    }

    #[test]
    fn marker_complete_extends_only_when_cutting_marker() {
        assert_eq!(99, generate_marker_complete(99).len());
        assert_eq!(101, generate_marker_complete(100).len());
        assert_eq!(101, generate_marker_complete(101).len());
        assert_eq!(10003, generate_marker_complete(10000).len());
    }

    #[test]
    fn validation_diagnostics() {
        let valid = validate(&generate(100), 100);
        assert!(valid.is_valid);
        assert_eq!(None, valid.truncation_point);
        assert_eq!(None, valid.first_mismatch);

        let truncated = validate(&generate(99), 100);
        assert!(!truncated.is_valid);
        assert_eq!(Some(100), truncated.truncation_point);
        assert_eq!(
            Some(Mismatch {
                position: 100,
                expected: Some('1'),
                received: None,
            }),
            truncated.first_mismatch
        );

        assert_eq!(3, find_truncation_point("12x45"));
    }

    #[test]
    fn locate_and_hash_index() {
        let source = generate(80);
        let fragment = &source[29..41];

        assert_eq!(30, locate(fragment));
        let hash = hash_fragment(fragment);
        assert!(build_window_index(fragment.len())[&hash].contains(&30));
        assert!(locate_by_hash(&hash.to_uppercase(), fragment.len()).contains(&30));
        assert_eq!(
            "9ee39196c3dd959c14600095c165c237d0b4a7639237cf2bb1bfbee6f3321f5c",
            hash_fragment(&generate(10000))
        );
    }
}
