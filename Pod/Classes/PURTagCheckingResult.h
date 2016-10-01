#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PURTagCheckingResult : NSObject

+ (instancetype)failureResult;
+ (instancetype)successResult;
+ (instancetype)successResultWithCapturedString:(nullable NSString *)capturedString;

@property (nonatomic, readonly) BOOL matched;
@property (nonatomic, copy, readonly, nullable) NSString *capturedString;

@end

NS_ASSUME_NONNULL_END
