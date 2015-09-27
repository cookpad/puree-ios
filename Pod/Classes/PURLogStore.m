//
//  PURLogStore.m
//  Puree
//
//  Created by tomohiro-moro on 10/7/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

#import <YapDatabase/YapDatabase.h>
#import "PURLogStore.h"
#import "PURLog.h"
#import "PUROutput.h"

static NSString * const LogDatabaseDirectory = @"com.cookpad.PureeData.default";
static NSString * const LogDatabaseFileName = @"logs.db";

static NSString * const LogDataCollectionNamePrefix = @"log_";
static NSString * const SystemDataCollectionNamePrefix = @"system_";

static NSString * const LogMetadataKeyOutput = @"_MetadataOutput";

static NSMutableDictionary *__databases;

@interface PURLogStore ()

@property (nonatomic) NSString *databasePath;
@property (nonatomic) YapDatabase *database;
@property (nonatomic) YapDatabaseConnection *databaseConnection;

@end

NSString *PURLogStoreCollectionNameForPattern(NSString *pattern)
{
    return [LogDataCollectionNamePrefix stringByAppendingString:pattern];
}

NSDictionary *PURLogStoreMetadataForLog(PURLog *log, PUROutput *output)
{
    return @{
             LogMetadataKeyOutput: NSStringFromClass([output class]),
             };
}

NSString *PURLogKey(PUROutput *output, PURLog *log)
{
    return [[NSStringFromClass([output class]) stringByAppendingString:@"_"] stringByAppendingString:log.identifier];
}

@implementation PURLogStore

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __databases = [NSMutableDictionary new];
    });
}

+ (instancetype)defaultLogStore
{
    return [[self alloc] initWithDatabasePath:[self defaultDatabasePath]];
}

- (instancetype)initWithDatabasePath:(NSString *)databasePath
{
    self = [super init];
    if (self) {
        _databasePath = databasePath;
    }
    return self;
}

- (BOOL)prepare
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *databaseDirectory = [self.databasePath stringByDeletingLastPathComponent];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:databaseDirectory isDirectory:&isDirectory]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:databaseDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        if (error) {
            return NO;
        }
    } else if (!isDirectory) {
        return NO;
    }

    YapDatabase *database = __databases[self.databasePath];
    if (!database) {
        database = [[YapDatabase alloc] initWithPath:self.databasePath];
        __databases[self.databasePath] = database;
    }
    self.database = database;
    self.databaseConnection = [self.database newConnection];

    return self.database && self.databaseConnection;
}

+ (NSString *)defaultDatabasePath
{
    NSArray *libraryCachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *libraryCacheDirectoryPath = libraryCachePaths.firstObject;
    NSString *filePath = [LogDatabaseDirectory stringByAppendingPathComponent:LogDatabaseFileName];
    NSString *databasePath = [libraryCacheDirectoryPath stringByAppendingPathComponent:filePath];

    return databasePath;
}

- (void)retrieveLogsForPattern:(NSString *)pattern output:(PUROutput *)output completion:(PURLogStoreRetrieveCompletionBlock)completion;
{
    NSAssert(self.databaseConnection, @"Database connection is not available");

    [self.databaseConnection readWithBlock:^(YapDatabaseReadTransaction *transaction){
        NSMutableArray *logs = [NSMutableArray new];
        NSString *keyPrefix = [NSStringFromClass([output class]) stringByAppendingString:@"_"];
        [transaction enumerateRowsInCollection:PURLogStoreCollectionNameForPattern(output.tagPattern)
                                    usingBlock:^(NSString *key, PURLog *log, id metadata, BOOL *stop){
                                        [logs addObject:log];
                                    }
                                    withFilter:^BOOL(NSString *key){
                                        return [key hasPrefix:keyPrefix];
                                    }];
        completion(logs);
    }];
}

- (void)addLog:(PURLog *)log fromOutput:(PUROutput *)output
{
    NSAssert(self.databaseConnection, @"Database connection is not available");

    if (![log isKindOfClass:[PURLog class]]) {
        return;
    }

    [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction){
        NSString *collectionName = PURLogStoreCollectionNameForPattern(output.tagPattern);
        [transaction setObject:log forKey:PURLogKey(output, log) inCollection:collectionName];
    }];
}

- (void)addLogs:(NSArray *)logs fromOutput:(PUROutput *)output
{
    NSAssert(self.databaseConnection, @"Database connection is not available");

    [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction){
        NSString *collectionName = PURLogStoreCollectionNameForPattern(output.tagPattern);
        for (PURLog *log in logs) {
            if (![log isKindOfClass:[PURLog class]]) {
                continue;
            }
            [transaction setObject:log forKey:PURLogKey(output, log) inCollection:collectionName];
        }
    }];
}

- (void)removeLogs:(NSArray *)logs fromOutput:(PUROutput *)output
{
    NSAssert(self.databaseConnection, @"Database connection is not available");

    [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction){
        NSString *collectionName = PURLogStoreCollectionNameForPattern(output.tagPattern);
        for (PURLog *log in logs) {
            if (![log isKindOfClass:[PURLog class]]) {
                continue;
            }
            [transaction removeObjectForKey:PURLogKey(output, log) inCollection:collectionName];
        }
    }];
}

- (void)clearAll
{
    NSAssert(self.databaseConnection, @"Database connection is not available");

    [self.databaseConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction){
        [transaction removeAllObjectsInAllCollections];
    }];
}

@end
