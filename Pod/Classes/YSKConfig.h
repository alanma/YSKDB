//
//  YSKConfig.h
//  YSKDB
//
//  Created by Yusuke Kita on 12/21/14.
//  Copyright (c) 2014 Yusuke Kita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKConfig : NSObject

+ (NSString *)databaseFileName;
+ (void)setDatabaseFileName:(NSString *)fileName;
+ (NSString *)databaseSecretKey;
+ (void)setDatabaseSecretKey:(NSString *)secretKey;

@end
