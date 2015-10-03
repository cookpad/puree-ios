//
//  PURFilter.h
//  Puree
//
//  Created by tomohiro-moro on 10/24/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLogger;
@class PURLogStore;
@class PURLog;

@interface PURFilter : NSObject

- (instancetype)initWithLogger:(PURLogger *)logger tagPattern:(nullable NSString *)tagPattern;
- (void)configure:(nullable NSDictionary *)settings NS_REQUIRES_SUPER;
- (NSArray<PURLog *> *)logsWithObject:(id)object tag:(NSString *)tag captured:(nullable NSString *)captured;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly) PURLogger *logger;
@property (nonatomic, readonly) PURLogStore *logStore;

@end

NS_ASSUME_NONNULL_END
