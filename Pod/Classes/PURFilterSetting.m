//
//  PURFilterSetting.m
//  Puree
//
//  Created by tomohiro-moro on 10/24/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import "PURFilterSetting.h"

@implementation PURFilterSetting

- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern
{
    return [self initWithFilter:filterClass tagPattern:tagPattern settings:nil];
}

- (instancetype)initWithFilter:(Class)filterClass tagPattern:(NSString *)tagPattern settings:(nullable NSDictionary<NSString *, id> *)settings
{
    self = [super init];
    _filterClass = filterClass;
    _tagPattern = tagPattern;
    _settings = settings;

    return self;
}

@end
