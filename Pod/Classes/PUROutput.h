//
//  PUROutput.h
//  Puree
//
//  Created by tomohiro-moro on 10/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLogger;
@class PURLogStore;
@class PURLog;

@interface PUROutput : NSObject

- (instancetype)initWithLogger:(PURLogger *)logger tagPattern:(NSString *)tagPattern;
- (void)configure:(NSDictionary<NSString *, id> *)settings NS_REQUIRES_SUPER;
- (void)start NS_REQUIRES_SUPER;
- (void)resume NS_REQUIRES_SUPER;
- (void)suspend NS_REQUIRES_SUPER;
- (void)emitLog:(PURLog *)log;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *tagPattern;
@property (nonatomic, readonly) PURLogger *logger;
@property (nonatomic, readonly) PURLogStore *logStore;

@end

NS_ASSUME_NONNULL_END
