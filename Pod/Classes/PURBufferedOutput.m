#import "PURBufferedOutput.h"
#import "PURLogStore.h"
#import "PURLog.h"
#import "PURBufferCollection.h"

NSString * const PURBufferedOutputSettingsLogLimitKey = @"BufferedOutputLogLimit";
NSString * const PURBufferedOutputSettingsFlushIntervalKey = @"BufferedOutputFlushInterval";
NSString * const PURBufferedOutputSettingsMaxRetryCountKey = @"BufferedOutputMaxRetryCount";

NSString * const PURBufferedOutputDidStartNotification = @"PURBufferedOutputDidStartNotification";
NSString * const PURBufferedOutputDidResumeNotification = @"PURBufferedOutputDidResumeNotification";
NSString * const PURBufferedOutputDidFlushNotification = @"PURBufferedOutputDidFlushNotification";
NSString * const PURBufferedOutputDidTryWriteChunkNotification = @"PURBufferedOutputDidTryWriteChunkNotification";
NSString * const PURBufferedOutputDidSuccessWriteChunkNotification = @"PURBufferedOutputDidSuccessWriteChunkNotification";
NSString * const PURBufferedOutputDidRetryWriteChunkNotification = @"PURBufferedOutputDidRetryWriteChunkNotification";

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

@property (nonatomic) PURBufferCollection *buffer;
@property (nonatomic) NSUInteger logLimit;
@property (nonatomic) NSTimeInterval flushInterval;
@property (nonatomic) NSUInteger maxRetryCount;
@property (nonatomic) CFAbsoluteTime recentFlushTime;
@property (nonatomic) NSTimer *timer;

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

- (void)configure:(NSDictionary<NSString *, id> *)settings
{
    [super configure:settings];

    id value;

    value = settings[PURBufferedOutputSettingsLogLimitKey];
    self.logLimit = value ? [value unsignedIntegerValue] : PURBufferedOutputDefaultLogLimit;

    value = settings[PURBufferedOutputSettingsFlushIntervalKey];
    self.flushInterval = value ? [value unsignedIntegerValue] : PURBufferedOutputDefaultFlushInterval;

    value = settings[PURBufferedOutputSettingsMaxRetryCountKey];
    self.maxRetryCount = value ? [value unsignedIntegerValue] : PURBufferedOutputDefaultMaxRetryCount;

    self.buffer = [PURBufferCollection new];
}

- (void)start
{
    [super start];

    [self.buffer removeAll];
    [self retrieveLogs:^(NSArray<PURLog *> * _Nonnull logs){
        [[NSNotificationCenter defaultCenter] postNotificationName:PURBufferedOutputDidStartNotification object:self];

        if (![self.timer isValid]) {
            return;
        }
        [self.buffer addLogs:logs];
        [self flush];
    }];

    [self setUpTimer];
}

- (void)resume
{
    [super resume];

    [self.buffer removeAll];
    [self retrieveLogs:^(NSArray<PURLog *> * _Nonnull logs){
        [[NSNotificationCenter defaultCenter] postNotificationName:PURBufferedOutputDidResumeNotification object:self];

        if (![self.timer isValid]) {
            return;
        }
        [self.buffer addLogs:logs];
        [self flush];
    }];

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

- (void)retrieveLogs:(PURLogStoreRetrieveCompletionBlock)completion
{
    [self.buffer removeAll];
    [self.logStore retrieveLogsForOutput:self
                              completion:completion];
}

- (void)emitLog:(PURLog *)log
{
    [self.buffer addLog:log];
    [self.logStore addLog:log forOutput:self completion:^{
        if ([self.buffer count] >= self.logLimit) {
            [self flush];
        }
    }];
}

- (void)flush
{
    self.recentFlushTime = CFAbsoluteTimeGetCurrent();

    if ([self.buffer count] == 0) {
        return;
    }

    NSUInteger logCount = MIN([self.buffer count], self.logLimit);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, logCount)];
    NSArray<PURLog *> *flushLogs = [self.buffer logsAtIndexSet:indexSet];
    [self.buffer removeAtIndexes:indexSet];

    PURBufferedOutputChunk *chunk = [[PURBufferedOutputChunk alloc] initWithLogs:flushLogs];
    [self callWriteChunk:chunk];

    [[NSNotificationCenter defaultCenter] postNotificationName:PURBufferedOutputDidFlushNotification object:self];
}

- (void)callWriteChunk:(PURBufferedOutputChunk *)chunk
{
    [self writeChunk:chunk
          completion:^(BOOL success){
              [[NSNotificationCenter defaultCenter] postNotificationName:PURBufferedOutputDidTryWriteChunkNotification object:self];

              if (success) {
                  [self.logStore removeLogs:chunk.logs forOutput:self completion:nil];

                  [[NSNotificationCenter defaultCenter] postNotificationName:PURBufferedOutputDidSuccessWriteChunkNotification object:self];
                  return;
              }

              chunk.retryCount++;
              if (chunk.retryCount <= self.maxRetryCount) {
                  int64_t delay = 2.0 * pow(2, chunk.retryCount - 1);
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [[NSNotificationCenter defaultCenter] postNotificationName:PURBufferedOutputDidRetryWriteChunkNotification object:self];

                      [self callWriteChunk:chunk];
                  });
              }
          }];
}

- (void)writeChunk:(PURBufferedOutputChunk *)chunk completion:(void (^)(BOOL))completion
{
    completion(YES);
}

@end
