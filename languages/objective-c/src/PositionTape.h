#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PTMismatch : NSObject
@property(nonatomic, assign) NSInteger position;
@property(nonatomic, nullable, copy) NSString *expected;
@property(nonatomic, nullable, copy) NSString *received;
+ (nullable instancetype)mismatchAtPosition:(NSInteger)position
                                   expected:(nullable NSString *)expected
                                   received:(nullable NSString *)received;
@end

@interface PTValidationResult : NSObject
@property(nonatomic, assign) BOOL isValid;
@property(nonatomic, assign) NSInteger expectedLength;
@property(nonatomic, assign) NSInteger receivedLength;
@property(nonatomic, nullable, strong) NSNumber *truncationPoint;
@property(nonatomic, nullable, strong) PTMismatch *firstMismatch;
@end

@interface PositionTape : NSObject
+ (NSString *)Generate:(NSInteger)length;
+ (NSInteger)GetMarkerCompleteLength:(NSInteger)length;
+ (NSString *)GenerateMarkerComplete:(NSInteger)length;
+ (nullable PTMismatch *)FindFirstMismatch:(NSString *)expected received:(NSString *)received;
+ (NSInteger)FindTruncationPoint:(NSString *)receivedText;
+ (PTValidationResult *)Validate:(NSString *)receivedText expectedLength:(NSInteger)expectedLength;
@end

NS_ASSUME_NONNULL_END
