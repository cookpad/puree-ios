#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLogger;
@class PURLogStore;
@class PURLog;

@interface PUROutput : NSObject

- (instancetype)initWithLogger:(PURLogger *)logger tagPattern:(NSString *)tagPattern;
- (void)configure:(NSDictionary<NSString *, id> *)settings NS_REQUIRES_SUPER NS_SWIFT_NAME(configure(settings:));
- (void)start NS_REQUIRES_SUPER;
- (void)resume NS_REQUIRES_SUPER;
- (void)suspend NS_REQUIRES_SUPER;
- (void)emitLog:(PURLog *)log NS_SWIFT_NAME(emit(log:));

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly) PURLogger *logger;
@property (nonatomic, readonly) PURLogStore *logStore;

@end

NS_ASSUME_NONNULL_END
