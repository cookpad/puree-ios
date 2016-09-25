#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLoggerConfiguration;
@class PURLogStore;
@class PURTagCheckingResult;

@interface PURLogger : NSObject

+ (PURTagCheckingResult *)matchesTag:(NSString *)tag pattern:(NSString *)pattern NS_SWIFT_NAME(matches(tag:pattern:));

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfiguration:(PURLoggerConfiguration *)configuration;
- (void)postLog:(id)object tag:(NSString *)sourceTag;
- (void)shutdown;

- (PURLogStore *)logStore;
- (NSDate *)currentDate;

@end

NS_ASSUME_NONNULL_END
