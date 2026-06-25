#import <Foundation/Foundation.h>
#import "../src/PositionTape.h"

static void PTAssert(BOOL condition, NSString *message) {
    if (!condition) {
        [NSException raise:@"PositionTapeTestFailure" format:@"%@", message];
    }
}

int main(void) {
    @autoreleasepool {
        PTAssert([[PositionTape Generate:0] isEqualToString:@""], @"zero length");
        PTAssert([[PositionTape Generate:11] isEqualToString:@"12345678911"], @"basic generation");
        PTAssert([PositionTape Generate:100].length == 100, @"exact length");
        PTAssert([PositionTape GenerateMarkerComplete:100].length == 101, @"marker complete 100");
        PTAssert([PositionTape GenerateMarkerComplete:10000].length == 10003, @"marker complete 10000");

        PTValidationResult *valid = [PositionTape Validate:[PositionTape Generate:250] expectedLength:250];
        PTAssert(valid.isValid, @"valid tape");

        PTValidationResult *truncated = [PositionTape Validate:[PositionTape Generate:40] expectedLength:50];
        PTAssert(!truncated.isValid, @"truncated invalid");
        PTAssert([truncated.truncationPoint integerValue] == 41, @"truncation point");

        PTMismatch *mismatch = [PositionTape FindFirstMismatch:[PositionTape Generate:20]
                                                      received:[[PositionTape Generate:19] stringByAppendingString:@"X"]];
        PTAssert(mismatch != nil && mismatch.position == 20, @"mismatch");

        NSLog(@"OK objective-c");
    }
    return 0;
}
