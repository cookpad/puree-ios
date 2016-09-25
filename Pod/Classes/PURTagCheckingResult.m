#import "PURTagCheckingResult.h"

@interface PURTagCheckingResult ()

@property (nonatomic) BOOL matched;
@property (nonatomic, copy, nullable) NSString *capturedString;

@end

@implementation PURTagCheckingResult

+ (instancetype)failureResult
{
    PURTagCheckingResult *result = [PURTagCheckingResult new];
    result.matched = NO;

    return result;
}

+ (instancetype)successResult
{
    return [self successResultWithCapturedString:nil];
}

+ (instancetype)successResultWithCapturedString:(NSString *)capturedString
{
    PURTagCheckingResult *result = [PURTagCheckingResult new];
    result.matched = YES;
    result.capturedString = capturedString;

    return result;
}

@end
