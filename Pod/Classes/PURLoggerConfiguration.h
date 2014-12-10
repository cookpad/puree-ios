//
//  PURLoggerConfiguration.h
//  Puree
//
//  Created by tomohiro-moro on 10/9/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PURLogStore;

@interface PURLoggerConfiguration : NSObject

+ (instancetype)defaultConfiguration;

@property (nonatomic) PURLogStore *logStore;
@property (nonatomic) NSArray *filterSettings;
@property (nonatomic) NSArray *outputSettings;

@end
