//
//  PURBufferCollection.h
//  Pods
//
//  Created by atsushi.sakai on 2017/09/29.
//
//

#import <Foundation/Foundation.h>
#import "PURLog.h"

@interface PURBufferCollection : NSObject

- (NSUInteger)count;
- (void)addLog:(PURLog *)log;
- (void)addLogs:(NSArray<PURLog *> *)logs;
- (void)removeAtIndexes:(NSIndexSet *)indexSet;
- (void)removeAll;
- (NSArray<PURLog *> *)logsAtIndexSet:(NSIndexSet *)indexSet;

@end
