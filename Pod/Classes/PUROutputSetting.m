//
//  PUROutputSetting.m
//  Puree
//
//  Created by tomohiro-moro on 10/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import "PUROutputSetting.h"

@implementation PUROutputSetting

- (instancetype)init
{
    return nil;
}

- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern
{
    return [self initWithOutput:outputClass tagPattern:tagPattern settings:nil];
}

- (instancetype)initWithOutput:(Class)outputClass tagPattern:(NSString *)tagPattern settings:(NSDictionary *)settings
{
    self = [super init];
    if (self) {
        _outputClass = outputClass;
        _tagPattern = tagPattern;
        _settings = settings;
    }
    return self;
}

@end
