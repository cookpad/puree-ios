//
//  PURFilterSetting.h
//  Puree
//
//  Created by tomohiro-moro on 10/24/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PURFilterSetting : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern;
- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern settings:(nullable NSDictionary *)settings;

@property (nonatomic, readonly) Class filterClass;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly, nullable) NSDictionary *settings;

@end

NS_ASSUME_NONNULL_END
