#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PUROutputSetting : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern;
- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern settings:(nullable NSDictionary<NSString *, id> *)settings;

@property (nonatomic, readonly) Class outputClass;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *settings;

@end

NS_ASSUME_NONNULL_END
