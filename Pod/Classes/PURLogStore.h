#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLog;
@class PUROutput;

typedef void(^PURLogStoreRetrieveCompletionBlock)(NSArray<PURLog *> *logs);

@interface PURLogStore : NSObject

+ (instancetype)defaultLogStore;
- (instancetype)initWithDatabasePath:(NSString *)databasePath;

- (BOOL)prepare;

- (void)retrieveLogsForOutput:(PUROutput *)output completion:(PURLogStoreRetrieveCompletionBlock)completion;
- (void)addLog:(PURLog *)log forOutput:(PUROutput *)output completion:(nullable dispatch_block_t)completion;
- (void)addLogs:(NSArray<PURLog *> *)logs forOutput:(PUROutput *)output completion:(nullable dispatch_block_t)completion;
- (void)removeLogs:(NSArray<PURLog *> *)logs forOutput:(PUROutput *)output completion:(nullable dispatch_block_t)completion;
- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
