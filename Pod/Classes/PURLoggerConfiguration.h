#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLogStore;
@class PURFilterSetting;
@class PUROutputSetting;

@interface PURLoggerConfiguration : NSObject

+ (instancetype)defaultConfiguration;

@property (nonatomic) PURLogStore *logStore;
@property (nonatomic) NSArray<PURFilterSetting *> *filterSettings;
@property (nonatomic) NSArray<PUROutputSetting *> *outputSettings;

@end

NS_ASSUME_NONNULL_END
