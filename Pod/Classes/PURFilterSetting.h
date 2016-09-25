#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PURFilterSetting : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern;
- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern settings:(nullable NSDictionary<NSString *, id> *)settings;

@property (nonatomic, readonly) Class filterClass;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, id> *settings;

@end

NS_ASSUME_NONNULL_END
