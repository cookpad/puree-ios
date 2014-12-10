//
//  PUROutputSetting.h
//  Puree
//
//  Created by tomohiro-moro on 10/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUROutputSetting : NSObject

- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern;
- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern settings:(NSDictionary *)settings;

@property (nonatomic, readonly) Class outputClass;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly) NSDictionary *settings;

@end
