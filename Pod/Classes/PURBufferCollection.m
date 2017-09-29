//
//  PURBufferCollection.m
//  Pods
//
//  Created by atsushi.sakai on 2017/09/29.
//
//

#import "PURBufferCollection.h"
#import "PURLog.h"

@interface PURBufferCollection()

@property (nonatomic) NSMutableArray<PURLog *> *buffer;

@end

@implementation PURBufferCollection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.buffer = [NSMutableArray new];
    }
    return self;
}

- (NSUInteger)count
{
    @synchronized (self) {
        return [self.buffer count];
    }
}

- (void)addLog:(PURLog *)log
{
    @synchronized (self) {
        [self.buffer addObject:log];
    }
}

- (void)addLogs:(NSArray<PURLog *> *)logs
{
    @synchronized (self) {
        [self.buffer addObjectsFromArray:logs];
    }
}

- (void)removeAtIndexes:(NSIndexSet *)indexSet
{
    @synchronized (self) {
        [self.buffer removeObjectsAtIndexes:indexSet];
    }
}

- (void)removeAll
{
    @synchronized (self) {
        [self.buffer removeAllObjects];
    }
}

- (NSArray<PURLog *> *)logsAtIndexSet:(NSIndexSet *)indexSet
{
    @synchronized (self) {
        return [self.buffer objectsAtIndexes:indexSet];
    }
}

@end
