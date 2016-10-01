#import "PURFilter.h"
#import "PURLogger.h"
#import "PURLog.h"

@implementation PURFilter

- (instancetype)initWithLogger:(PURLogger *)logger tagPattern:(NSString *)tagPattern
{
    self = [super init];
    _identifier = [NSUUID UUID].UUIDString;
    _tagPattern = tagPattern;
    _logger = logger;

    return self;
}

- (PURLogStore *)logStore
{
    return self.logger.logStore;
}

- (void)configure:(NSDictionary<NSString *, id> *)settings
{

}

- (NSArray<PURLog *> *)logsWithObject:(id)object tag:(NSString *)tag captured:(NSString *)captured
{
    if (![object isKindOfClass:[NSDictionary class]]) {
        return @[];
    }

    NSDate *currentDate = [self.logger currentDate];
    return @[[[PURLog alloc] initWithTag:tag date:currentDate userInfo:object]];
}

@end
