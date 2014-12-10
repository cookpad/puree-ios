//
//  PURLog.h
//  Puree
//
//  Created by tomohiro-moro on 10/7/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PURLog : NSObject <NSCoding>

- (instancetype)initWithTag:(NSString *)tag date:(NSDate *)date userInfo:(NSDictionary *)userInfo;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *tag;
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSDictionary *userInfo;

@end
