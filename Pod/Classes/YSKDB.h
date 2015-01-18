//
//  YSKDB.h
//  YSKDB
//
//  Created by Yusuke Kita on 12/21/14.
//  Copyright (c) 2014 Yusuke Kita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKDB : NSObject

+ (void)databaseWithName:(NSString *)fileName secretKey:(NSString *)secretKey;
+ (void)createDatabaseWithName:(NSString *)fileName secretKey:(NSString *)secretKey;

+ (NSArray *)executeSelectQuery:(NSString *)query;
+ (BOOL)executeCreateQuery:(NSString *)query;
+ (BOOL)executeInsertQuery:(NSString *)query params:(NSDictionary *)params;
+ (BOOL)executeUpdateQuery:(NSString *)query params:(NSDictionary *)params;

@end
