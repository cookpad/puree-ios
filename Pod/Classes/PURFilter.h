//
//  PURFilter.h
//  Puree
//
//  Created by tomohiro-moro on 10/24/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PURLogger;
@class PURLogStore;
@class PURLog;

@interface PURFilter : NSObject

- (instancetype)initWithLogger:(PURLogger *)logger tagPattern:(NSString *)tagPattern;
- (void)configure:(NSDictionary *)settings NS_REQUIRES_SUPER;
- (NSArray *)logsWithObject:(id)object tag:(NSString *)tag captured:(NSString *)captured;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly) PURLogger *logger;
@property (nonatomic, readonly) PURLogStore *logStore;

@end
