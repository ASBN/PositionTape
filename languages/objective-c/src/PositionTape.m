#import "PositionTape.h"

@implementation PTMismatch
+ (nullable instancetype)mismatchAtPosition:(NSInteger)position
                                   expected:(nullable NSString *)expected
                                   received:(nullable NSString *)received {
    PTMismatch *mismatch = [[PTMismatch alloc] init];
    mismatch.position = position;
    mismatch.expected = expected;
    mismatch.received = received;
    return mismatch;
}
@end

@implementation PTValidationResult
@end

@implementation PositionTape

+ (NSString *)Generate:(NSInteger)length {
    if (length < 0) {
        [NSException raise:NSInvalidArgumentException format:@"length must be non-negative"];
    }

    NSMutableString *output = [NSMutableString stringWithCapacity:(NSUInteger)length];
    NSInteger cursor = 1;
    while ((NSInteger)output.length < length) {
        if (cursor % 10 == 0) {
            NSString *marker = [NSString stringWithFormat:@"%ld", (long)(cursor / 10)];
            NSInteger remaining = length - (NSInteger)output.length;
            NSInteger chunkLength = MIN((NSInteger)marker.length, remaining);
            [output appendString:[marker substringToIndex:(NSUInteger)chunkLength]];
            cursor += marker.length;
        } else {
            [output appendFormat:@"%ld", (long)(cursor % 10)];
            cursor += 1;
        }
    }
    return [output copy];
}

+ (NSInteger)GetMarkerCompleteLength:(NSInteger)length {
    if (length < 0) {
        [NSException raise:NSInvalidArgumentException format:@"length must be non-negative"];
    }

    NSInteger cursor = 1;
    while (cursor <= length) {
        if (cursor % 10 == 0) {
            NSInteger markerLength = [NSString stringWithFormat:@"%ld", (long)(cursor / 10)].length;
            NSInteger markerEnd = cursor + markerLength - 1;
            if (length < markerEnd) {
                return markerEnd;
            }
            cursor += markerLength;
        } else {
            cursor += 1;
        }
    }
    return length;
}

+ (NSString *)GenerateMarkerComplete:(NSInteger)length {
    return [self Generate:[self GetMarkerCompleteLength:length]];
}

+ (nullable PTMismatch *)FindFirstMismatch:(NSString *)expected received:(NSString *)received {
    NSInteger sharedLength = MIN((NSInteger)expected.length, (NSInteger)received.length);
    for (NSInteger index = 0; index < sharedLength; index += 1) {
        unichar expectedChar = [expected characterAtIndex:(NSUInteger)index];
        unichar receivedChar = [received characterAtIndex:(NSUInteger)index];
        if (expectedChar != receivedChar) {
            return [PTMismatch mismatchAtPosition:index + 1
                                        expected:[NSString stringWithCharacters:&expectedChar length:1]
                                        received:[NSString stringWithCharacters:&receivedChar length:1]];
        }
    }

    if (expected.length == received.length) {
        return nil;
    }

    NSInteger position = sharedLength + 1;
    NSString *expectedValue = nil;
    NSString *receivedValue = nil;
    if (position <= (NSInteger)expected.length) {
        unichar value = [expected characterAtIndex:(NSUInteger)(position - 1)];
        expectedValue = [NSString stringWithCharacters:&value length:1];
    }
    if (position <= (NSInteger)received.length) {
        unichar value = [received characterAtIndex:(NSUInteger)(position - 1)];
        receivedValue = [NSString stringWithCharacters:&value length:1];
    }
    return [PTMismatch mismatchAtPosition:position expected:expectedValue received:receivedValue];
}

+ (NSInteger)FindTruncationPoint:(NSString *)receivedText {
    PTMismatch *mismatch = [self FindFirstMismatch:[self Generate:(NSInteger)receivedText.length]
                                          received:receivedText];
    return mismatch == nil ? (NSInteger)receivedText.length + 1 : mismatch.position;
}

+ (PTValidationResult *)Validate:(NSString *)receivedText expectedLength:(NSInteger)expectedLength {
    NSString *expected = [self Generate:expectedLength];
    PTValidationResult *result = [[PTValidationResult alloc] init];
    result.firstMismatch = [self FindFirstMismatch:expected received:receivedText];
    result.isValid = result.firstMismatch == nil;
    result.expectedLength = expectedLength;
    result.receivedLength = receivedText.length;

    if (result.firstMismatch != nil && (NSInteger)receivedText.length < expectedLength &&
        [expected hasPrefix:receivedText]) {
        result.truncationPoint = @((NSInteger)receivedText.length + 1);
    }
    return result;
}

@end
