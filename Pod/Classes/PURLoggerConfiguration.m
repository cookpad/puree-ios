#import "PURLoggerConfiguration.h"
#import "PURLogStore.h"

@implementation PURLoggerConfiguration

+ (instancetype)defaultConfiguration
{
    PURLoggerConfiguration *configuration = [PURLoggerConfiguration new];
    configuration.logStore = [PURLogStore defaultLogStore];
    configuration.filterSettings = @[];
    configuration.outputSettings = @[];

    return configuration;
}

@end
