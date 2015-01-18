//
//  YSKDB.m
//  YSKDB
//
//  Created by Yusuke Kita on 12/21/14.
//  Copyright (c) 2014 Yusuke Kita. All rights reserved.
//

#import <FMDB/FMDatabase.h>
#import "YSKDB.h"
#import "YSKConfig.h"
#import "FMDatabaseAdditions.h"

@implementation YSKDB

#pragma mark - Configuration

+ (void)databaseWithName:(NSString *)fileName secretKey:(NSString *)secretKey
{
    NSParameterAssert(fileName);
    NSAssert([self validateFileName:fileName], @"Database file name must be ***.sqlite or ***.db");

    // configure
    [YSKConfig setDatabaseFileName:fileName];
    [YSKConfig setDatabaseSecretKey:secretKey];

    // check if the db already exists
    NSString *filePath = [self databaseFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return;
    }

    // get default path for the db
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *defaultPath = [[bundle bundlePath] stringByAppendingPathComponent:[YSKConfig databaseFileName]];

    // encrypt the db
#if !defined(DEBUG) && !defined(ADHOC)
    const char *query = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", filePath, [YSKConfig databaseSecretKey]] UTF8String];
    sqlite3 *unencryptedDB;
    if (sqlite3_open([defaultPath UTF8String], &unencryptedDB) == SQLITE_OK) {
        sqlite3_exec(unencryptedDB, query, NULL, NULL, NULL);
        sqlite3_exec(unencryptedDB, "SELECT sqlcipher_export('encrypted');", NULL, NULL, NULL);
        sqlite3_exec(unencryptedDB, "DETACH DATABASE encrypted;", NULL, NULL, NULL);
        sqlite3_close(unencryptedDB);
    }
#endif

    // copy to document folder
    if (![fileManager copyItemAtPath:defaultPath
                              toPath:filePath
                               error:nil]) {
        // TODO
    }
}

+ (void)createDatabaseWithName:(NSString *)fileName secretKey:(NSString *)secretKey
{
    NSAssert(fileName.length > 0, @"Database file name cannot be nil");

    // configure
    if (![self validateFileName:fileName]) {
        fileName = [fileName stringByAppendingPathExtension:@"db"];
    }

    [YSKConfig setDatabaseFileName:fileName];
    [YSKConfig setDatabaseSecretKey:secretKey];


    // encrypt database
    FMDatabase *database = [self openWithKey];
    [database close];
}

+ (BOOL)validateFileName:(NSString *)fileName
{
    if (![fileName hasSuffix:@"sqlite"] &&
            ![fileName hasSuffix:@"db"]) {
        return NO;
    }
    return YES;
}

+ (NSString *)databaseFilePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:[YSKConfig databaseFileName]];
}

+ (FMDatabase *)openWithKey
{
    FMDatabase *database = [FMDatabase databaseWithPath:[self databaseFilePath]];
    [database open];
#if !defined(DEBUG) && !defined(ADHOC)
    [database setKey:[YSKConfig databaseSecretKey]];
#endif
    return database;
}

#pragma mark - SQLite operator

+ (NSArray *)executeSelectQuery:(NSString *)query
{
    NSParameterAssert(query);
    FMDatabase *database = [self openWithKey];
    FMResultSet *resultSet = [database executeQuery:query];

    NSMutableArray *results = [@[] mutableCopy];
    while ([resultSet next]) {
        [results addObject:[resultSet resultDictionary]];
    }
    [database close];

    return results;
}

+ (BOOL)executeCreateQuery:(NSString *)query
{
    NSParameterAssert(tableName);
    NSParameterAssert(params);

    FMDatabase *database = [self openWithKey];
    BOOL succeeded = [database executeUpdate:query];
    [database close];

    return succeeded;
}

+ (BOOL)executeInsertQuery:(NSString *)query params:(NSDictionary *)params
{
    NSParameterAssert(query);

    FMDatabase *database = [self openWithKey];
    BOOL succeeded = [database executeUpdate:query withArgumentsInArray:[params allValues]];
    [database close];
    return succeeded;
}

+ (BOOL)executeUpdateQuery:(NSString *)query params:(NSDictionary *)params
{
    NSParameterAssert(query);

    FMDatabase *database = [self openWithKey];
    BOOL succeeded = [database executeUpdate:query withParameterDictionary:params];
    [database close];
    return succeeded;
}

@end
