//
//  PURLoggerConfiguration.m
//  Puree
//
//  Created by tomohiro-moro on 10/9/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import "PURLoggerConfiguration.h"
#import "PURLogStore.h"

@implementation PURLoggerConfiguration

+ (instancetype)defaultConfiguration
{
    PURLoggerConfiguration *configuration = [PURLoggerConfiguration new];
    configuration.logStore = [PURLogStore defaultLogStore];
    configuration.filterSettings = @[];
    configuration.outputSettings = @[];

    return configuration;
}

@end
