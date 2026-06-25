package positiontape

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"
)

const DefaultSearchLength = 100003

var indexCache = map[int]map[string][]int{}

type Mismatch struct {
	Position int
	Expected *rune
	Received *rune
}

type ValidationResult struct {
	IsValid         bool
	ExpectedLength  int
	ReceivedLength  int
	TruncationPoint *int
	FirstMismatch   *Mismatch
}

func Generate(length int) (string, error) {
	if length < 0 {
		return "", fmt.Errorf("length must be non-negative")
	}

	output := make([]byte, 0, length)
	cursor := 1
	for len(output) < length {
		if cursor%10 == 0 {
			marker := []byte(fmt.Sprintf("%d", cursor/10))
			remaining := length - len(output)
			if len(marker) > remaining {
				marker = marker[:remaining]
			}
			output = append(output, marker...)
			cursor += len(fmt.Sprintf("%d", cursor/10))
		} else {
			output = append(output, byte('0'+cursor%10))
			cursor++
		}
	}

	return string(output), nil
}

func GenerateMarkerComplete(length int) (string, error) {
	adjusted, err := MarkerCompleteLength(length)
	if err != nil {
		return "", err
	}
	return Generate(adjusted)
}

func MarkerCompleteLength(length int) (int, error) {
	if length < 0 {
		return 0, fmt.Errorf("length must be non-negative")
	}

	cursor := 1
	for cursor <= length {
		if cursor%10 == 0 {
			markerLength := len(fmt.Sprintf("%d", cursor/10))
			markerEnd := cursor + markerLength - 1
			if length < markerEnd {
				return markerEnd, nil
			}
			cursor += markerLength
		} else {
			cursor++
		}
	}

	return length, nil
}

func Validate(receivedText string, expectedLength int) (ValidationResult, error) {
	expected, err := Generate(expectedLength)
	if err != nil {
		return ValidationResult{}, err
	}

	mismatch := FindFirstMismatch(expected, receivedText)
	result := ValidationResult{
		IsValid:        mismatch == nil,
		ExpectedLength: expectedLength,
		ReceivedLength: len(receivedText),
		FirstMismatch:  mismatch,
	}

	if mismatch != nil && len(receivedText) < expectedLength && hasPrefix(expected, receivedText) {
		point := len(receivedText) + 1
		result.TruncationPoint = &point
	}

	return result, nil
}

func FindTruncationPoint(receivedText string) (int, error) {
	expectedPrefix, err := Generate(len(receivedText))
	if err != nil {
		return 0, err
	}
	mismatch := FindFirstMismatch(expectedPrefix, receivedText)
	if mismatch != nil {
		return mismatch.Position, nil
	}
	return len(receivedText) + 1, nil
}

func FindFirstMismatch(expected string, received string) *Mismatch {
	sharedLength := len(expected)
	if len(received) < sharedLength {
		sharedLength = len(received)
	}

	for index := 0; index < sharedLength; index++ {
		if expected[index] != received[index] {
			expectedRune := rune(expected[index])
			receivedRune := rune(received[index])
			return &Mismatch{Position: index + 1, Expected: &expectedRune, Received: &receivedRune}
		}
	}

	if len(expected) == len(received) {
		return nil
	}

	position := sharedLength + 1
	var expectedRune *rune
	var receivedRune *rune
	if position <= len(expected) {
		value := rune(expected[position-1])
		expectedRune = &value
	}
	if position <= len(received) {
		value := rune(received[position-1])
		receivedRune = &value
	}
	return &Mismatch{Position: position, Expected: expectedRune, Received: receivedRune}
}

func Locate(fragment string) (int, error) {
	if fragment == "" {
		return 1, nil
	}

	haystack, err := Generate(DefaultSearchLength)
	if err != nil {
		return 0, err
	}

	index := strings.Index(haystack, fragment)
	if index < 0 {
		return -1, nil
	}
	return index + 1, nil
}

func HashFragment(fragment string) string {
	sum := sha256.Sum256([]byte(fragment))
	return hex.EncodeToString(sum[:])
}

func BuildWindowIndex(windowSize int) (map[string][]int, error) {
	if windowSize <= 0 {
		return nil, fmt.Errorf("windowSize must be positive")
	}
	if windowSize > DefaultSearchLength {
		return nil, fmt.Errorf("windowSize cannot exceed the default search length")
	}

	tape, err := Generate(DefaultSearchLength)
	if err != nil {
		return nil, err
	}

	index := make(map[string][]int)
	for offset := 0; offset <= len(tape)-windowSize; offset++ {
		hash := HashFragment(tape[offset : offset+windowSize])
		index[hash] = append(index[hash], offset+1)
	}
	return index, nil
}

func LocateByHash(fragmentHash string, windowSize int) ([]int, error) {
	normalizedHash := strings.ToLower(strings.TrimSpace(fragmentHash))
	index, ok := indexCache[windowSize]
	if !ok {
		var err error
		index, err = BuildWindowIndex(windowSize)
		if err != nil {
			return nil, err
		}
		indexCache[windowSize] = index
	}

	positions := index[normalizedHash]
	copied := make([]int, len(positions))
	copy(copied, positions)
	return copied, nil
}

func hasPrefix(text string, prefix string) bool {
	return len(prefix) <= len(text) && text[:len(prefix)] == prefix
}
