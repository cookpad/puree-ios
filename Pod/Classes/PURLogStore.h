//
//  PURLogStore.h
//  Puree
//
//  Created by tomohiro-moro on 10/7/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PURLog;
@class PUROutput;

typedef void(^PURLogStoreRetrieveCompletionBlock)(NSArray *logs);

@interface PURLogStore : NSObject

+ (instancetype)defaultLogStore;
- (instancetype)initWithDatabasePath:(NSString *)databasePath;

- (BOOL)prepare;

- (void)retrieveLogsForPattern:(NSString *)pattern output:(PUROutput *)output completion:(PURLogStoreRetrieveCompletionBlock)completion;
- (void)addLog:(PURLog *)log fromOutput:(PUROutput *)output;
- (void)addLogs:(NSArray *)logs fromOutput:(PUROutput *)output;
- (void)removeLogs:(NSArray *)logs fromOutput:(PUROutput *)output;
- (void)clearAll;

@end
