//
//  YSKConfig.m
//  YSKDB
//
//  Created by Yusuke Kita on 12/21/14.
//  Copyright (c) 2014 Yusuke Kita. All rights reserved.
//

#import "YSKConfig.h"

static NSString *YKDatabaseFileName;
static NSString *YKDatabaseSecretKey;

@implementation YSKConfig

+ (NSString *)databaseFileName
{
    return YKDatabaseFileName;
}

+ (void)setDatabaseFileName:(NSString *)fileName
{
    YKDatabaseFileName = fileName;
}

+ (NSString *)databaseSecretKey
{
    return YKDatabaseSecretKey;
}

+ (void)setDatabaseSecretKey:(NSString *)secretKey
{
    YKDatabaseSecretKey = secretKey;
}

@end
