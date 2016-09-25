#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLogger;
@class PURLogStore;
@class PURLog;

@interface PURFilter : NSObject

- (instancetype)initWithLogger:(PURLogger *)logger tagPattern:(nullable NSString *)tagPattern;
- (void)configure:(NSDictionary<NSString *, id> *)settings NS_REQUIRES_SUPER NS_SWIFT_NAME(configure(settings:));
- (NSArray<PURLog *> *)logsWithObject:(id)object tag:(NSString *)tag captured:(nullable NSString *)captured NS_SWIFT_NAME(logs(object:tag:captured:));

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly) PURLogger *logger;
@property (nonatomic, readonly) PURLogStore *logStore;

@end

NS_ASSUME_NONNULL_END
