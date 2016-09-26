#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PURLog;
@class PUROutput;

typedef void(^PURLogStoreRetrieveCompletionBlock)(NSArray<PURLog *> *logs);

@interface PURLogStore : NSObject

+ (instancetype)defaultLogStore;
- (instancetype)initWithDatabasePath:(NSString *)databasePath;

- (BOOL)prepare;

- (void)retrieveLogsForPattern:(NSString *)pattern output:(PUROutput *)output completion:(PURLogStoreRetrieveCompletionBlock)completion;
- (void)addLog:(PURLog *)log fromOutput:(PUROutput *)output completion:(nullable dispatch_block_t)completion;
- (void)addLogs:(NSArray<PURLog *> *)logs fromOutput:(PUROutput *)output completion:(nullable dispatch_block_t)completion;
- (void)removeLogs:(NSArray<PURLog *> *)logs fromOutput:(PUROutput *)output completion:(nullable dispatch_block_t)completion;
- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
