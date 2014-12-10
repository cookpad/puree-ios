//
//  PURTagCheckingResult.m
//  Puree
//
//  Created by tomohiro-moro on 10/28/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import "PURTagCheckingResult.h"

@interface PURTagCheckingResult ()

@property (nonatomic) BOOL matched;
@property (nonatomic, copy) NSString *capturedString;

@end

@implementation PURTagCheckingResult

+ (instancetype)failureResult
{
    PURTagCheckingResult *result = [PURTagCheckingResult new];
    result.matched = NO;

    return result;
}

+ (instancetype)successResult
{
    return [self successResultWithCapturedString:nil];
}

+ (instancetype)successResultWithCapturedString:(NSString *)capturedString
{
    PURTagCheckingResult *result = [PURTagCheckingResult new];
    result.matched = YES;
    result.capturedString = capturedString;

    return result;
}

@end
