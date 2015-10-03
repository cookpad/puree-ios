//
//  PURLoggerConfiguration.h
//  Puree
//
//  Created by tomohiro-moro on 10/9/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLogStore;
@class PURFilterSetting;
@class PUROutputSetting;

@interface PURLoggerConfiguration : NSObject

+ (instancetype)defaultConfiguration;

@property (nonatomic) PURLogStore *logStore;
@property (nonatomic) NSArray<PURFilterSetting *> *filterSettings;
@property (nonatomic) NSArray<PUROutputSetting *> *outputSettings;

@end

NS_ASSUME_NONNULL_END
