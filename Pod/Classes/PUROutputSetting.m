#import "PUROutputSetting.h"

@implementation PUROutputSetting

- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern
{
    return [self initWithOutput:outputClass tagPattern:tagPattern settings:nil];
}

- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern settings:(nullable NSDictionary<NSString *, id> *)settings
{
    self = [super init];
    _outputClass = outputClass;
    _tagPattern = tagPattern;
    _settings = settings;

    return self;
}

@end
