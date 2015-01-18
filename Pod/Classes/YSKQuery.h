//
// Created by Yusuke Kita on 1/17/15.
//

#import <Foundation/Foundation.h>

extern NSString * const YSKDBTypeNameInteger;
extern NSString * const YSKDBTypeNameReal;
extern NSString * const YSKDBTypeNameText;
extern NSString * const YSKDBTypeNameBlob;
extern NSString * const YSKDBTypeNameNull;

typedef NS_ENUM(NSInteger , YSKDBAutoDateUpdateType) {
    YSKDBAutoDateUpdateTypeNone,
    YSKDBAutoDateUpdateTypeNSDate,
    YSKDBAutoDateUpdateTypeNSString,
    YSKDBAutoDateUpdateTypeFloat
};

@interface YSKQuery : NSObject

@property (nonatomic) NSInteger limit;
@property (nonatomic) NSInteger skip;
@property (nonatomic) enum YSKDBAutoDateUpdateType dateUpdateType;

+ (instancetype)queryWithTableName:(NSString *)tableName;
+ (instancetype)queryWithTableName:(NSString *)tableName predicate:(NSPredicate *)predicate;

- (void)whereKey:(NSString *)key equalTo:(id)object;
- (void)whereKey:(NSString *)key notEqualTo:(id)object;
- (void)whereKey:(NSString *)key greaterThan:(NSNumber *)number;
- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(NSNumber *)number;
- (void)whereKey:(NSString *)key lessThan:(NSNumber *)number;
- (void)whereKey:(NSString *)key lessThanOrEqualTo:(NSNumber *)number;
- (void)whereKey:(NSString *)key containedIn:(NSArray *)objects;
- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)objects;
- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix;
- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix;

- (void)orderByAscending:(NSString *)key;
- (void)orderByDescending:(NSString *)key;
- (void)addAscendingOrder:(NSString *)key;
- (void)addDescendingOrder:(NSString *)key;

- (void)upToDateKey:(NSString *)key;
- (void)upToDateKeys:(NSArray *)keys;

- (NSInteger)countObjects;
- (NSDictionary *)getObject;
- (NSDictionary *)getObjectWithID:(NSNumber *)ID;
- (NSArray *)findObjects;
- (NSArray *)findRandomObjects;
- (BOOL)insertObjects:(NSDictionary *)params;
- (BOOL)updateObjects:(NSDictionary *)params;

@end