//
//  PUROutputSetting.h
//  Puree
//
//  Created by tomohiro-moro on 10/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

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
