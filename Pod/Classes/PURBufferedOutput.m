//
//  PURBufferedOutput.m
//  Puree
//
//  Created by tomohiro-moro on 10/14/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import "PURBufferedOutput.h"
#import "PURLogStore.h"
#import "PURLog.h"

NSString * const PURBufferedOutputSettingsLogLimitKey = @"BufferedOutputLogLimit";
NSString * const PURBufferedOutputSettingsFlushIntervalKey = @"BufferedOutputFlushInterval";
NSString * const PURBufferedOutputSettingsMaxRetryCountKey = @"BufferedOutputMaxRetryCount";

NSUInteger PURBufferedOutputDefaultLogLimit = 5;
NSTimeInterval PURBufferedOutputDefaultFlushInterval = 10;
NSUInteger PURBufferedOutputDefaultMaxRetryCount = 3;

@implementation PURBufferedOutputChunk

- (instancetype)initWithLogs:(NSArray<PURLog *> *)logs
{
    self = [super init];
    _logs = logs;
    _retryCount = 0;

    return self;
}

@end

@interface PURBufferedOutput ()

@property (nonatomic) NSMutableArray<PURLog *> *buffer;
@property (nonatomic) NSUInteger logLimit;
@property (nonatomic) NSTimeInterval flushInterval;
@property (nonatomic) NSUInteger maxRetryCount;
@property (nonatomic) CFAbsoluteTime recentFlushTime;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSOperationQueue *writeChunkQueue;

@end

@implementation PURBufferedOutput

- (void)dealloc
{
    [self.timer invalidate];
}

- (void)setUpTimer
{
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(tick)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)configure:(NSDictionary *)settings
{
    [super configure:settings];

    id value;

    value = settings[PURBufferedOutputSettingsLogLimitKey];
    self.logLimit = value ? [value unsignedIntegerValue] : PURBufferedOutputDefaultLogLimit;

    value = settings[PURBufferedOutputSettingsFlushIntervalKey];
    self.flushInterval = value ? [value unsignedIntegerValue] : PURBufferedOutputDefaultFlushInterval;

    value = settings[PURBufferedOutputSettingsMaxRetryCountKey];
    self.maxRetryCount = value ? [value unsignedIntegerValue] : PURBufferedOutputDefaultMaxRetryCount;

    self.buffer = [NSMutableArray new];

    NSOperationQueue *writeChunkQueue = [[NSOperationQueue alloc] init];
    writeChunkQueue.maxConcurrentOperationCount = 1;
    self.writeChunkQueue = writeChunkQueue;
}

- (void)start
{
    [super start];

    [self reloadLogStore];
    [self flush];

    [self setUpTimer];
}

- (void)resume
{
    [super resume];

    [self reloadLogStore];
    [self flush];

    [self setUpTimer];
}

- (void)suspend
{
    [self.timer invalidate];

    [super suspend];
}

- (void)tick
{
    if ((CFAbsoluteTimeGetCurrent() - self.recentFlushTime) > self.flushInterval) {
        [self flush];
    }
}

- (void)reloadLogStore
{
    [self.buffer removeAllObjects];

    [self.logStore retrieveLogsForPattern:self.tagPattern
                                   output:self
                               completion:^(NSArray<PURLog *> *logs){
                                   [self.buffer addObjectsFromArray:logs];
                               }];
}

- (void)emitLog:(PURLog *)log
{
    [self.buffer addObject:log];
    [self.logStore addLog:log fromOutput:self];

    if ([self.buffer count] >= self.logLimit) {
        [self flush];
    }
}

- (void)flush
{
    self.recentFlushTime = CFAbsoluteTimeGetCurrent();

    if ([self.buffer count] == 0) {
        return;
    }

    NSUInteger logCount = MIN([self.buffer count], self.logLimit);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, logCount)];
    NSArray<PURLog *> *flushLogs = [self.buffer objectsAtIndexes:indexSet];
    [self.buffer removeObjectsAtIndexes:indexSet];

    PURBufferedOutputChunk *chunk = [[PURBufferedOutputChunk alloc] initWithLogs:flushLogs];
    [self.writeChunkQueue addOperationWithBlock:^{
        [self callWriteChunk:chunk];
    }];
}

- (void)callWriteChunk:(PURBufferedOutputChunk *)chunk
{
    [self writeChunk:chunk
          completion:^(BOOL success){
              if (success) {
                  [self.logStore removeLogs:chunk.logs fromOutput:self];
                  return;
              }

              chunk.retryCount++;
              if (chunk.retryCount <= self.maxRetryCount) {
                  int64_t delay = 2.0 * pow(2, chunk.retryCount - 1);
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [self.writeChunkQueue addOperationWithBlock:^{
                          [self callWriteChunk:chunk];
                      }];
                  });
              }
          }];
}

- (void)writeChunk:(PURBufferedOutputChunk *)chunk completion:(void (^)(BOOL))completion
{
    completion(YES);
}

@end
