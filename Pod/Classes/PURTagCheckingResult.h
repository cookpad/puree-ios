//
//  PURTagCheckingResult.h
//  Puree
//
//  Created by tomohiro-moro on 10/28/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PURTagCheckingResult : NSObject

+ (instancetype)failureResult;
+ (instancetype)successResult;
+ (instancetype)successResultWithCapturedString:(NSString *)capturedString;

@property (nonatomic, readonly) BOOL matched;
@property (nonatomic, copy, readonly) NSString *capturedString;

@end
