//
//  PURFilterSetting.h
//  Puree
//
//  Created by tomohiro-moro on 10/24/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PURFilterSetting : NSObject

- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern;
- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern settings:(NSDictionary *)settings;

@property (nonatomic, readonly) Class filterClass;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly) NSDictionary *settings;

@end
