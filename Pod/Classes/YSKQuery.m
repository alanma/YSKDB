//
// Created by Yusuke Kita on 1/17/15.
//

#import <YSKDB/YSKDB.h>
#import "YSKQuery.h"

NSString * const YSKDBTypeNameInteger = @"INTEGER";
NSString * const YSKDBTypeNameReal = @"REAL";
NSString * const YSKDBTypeNameText = @"TEXT";
NSString * const YSKDBTypeNameBlob = @"BLOB";
NSString * const YSKDBTypeNameNull = @"NULL";

NSString * const YSKDBFieldNameCreatedAt = @"created_at";
NSString * const YSKDBFieldNameUpdatedAt = @"updated_at";

@interface YSKQuery ()

@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSMutableArray *wherePredicates;
@property (nonatomic, strong) NSMutableArray *ascendingOrderPredicates;
@property (nonatomic, strong) NSMutableArray *descendingOrderPredicates;

@end

@implementation YSKQuery

+ (instancetype)queryWithTableName:(NSString *)tableName
{
    YSKQuery *query = [self sharedInstance];
    query.tableName = tableName;
    query.predicate = nil;
    query.wherePredicates = [@[] mutableCopy];
    query.ascendingOrderPredicates = [@[] mutableCopy];
    query.descendingOrderPredicates = [@[] mutableCopy];
    return query;
}

+ (instancetype)queryWithTableName:(NSString *)tableName predicate:(NSPredicate *)predicate
{
    YSKQuery *query = [self sharedInstance];
    query.tableName = tableName;
    query.predicate = predicate;
    query.wherePredicates = [@[] mutableCopy];
    query.ascendingOrderPredicates = [@[] mutableCopy];
    query.descendingOrderPredicates = [@[] mutableCopy];
    return query;
}

+ (instancetype)sharedInstance
{
    static YSKQuery *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

#pragma mark - Predicate

- (void)whereKey:(NSString *)key equalTo:(id)object
{
    NSParameterAssert(object);
    NSString *operator = @"=";
    [self addWherePredicateWithKey:key
                          operator:operator
                            object:object];
}

- (void)whereKey:(NSString *)key notEqualTo:(id)object
{
    NSParameterAssert(object);
    NSString *operator = @"!=";
    [self addWherePredicateWithKey:key
                          operator:operator
                            object:object];
}

- (void)whereKey:(NSString *)key greaterThan:(NSNumber *)number
{
    NSParameterAssert(number && [number isKindOfClass:[NSNumber class]]);

    NSString *operator = @">";
    [self addWherePredicateWithKey:key
                          operator:operator
                            object:number];
}

- (void)whereKey:(NSString *)key greaterThanOrEqualTo:(NSNumber *)number
{
    NSParameterAssert(number && [number isKindOfClass:[NSNumber class]]);

    NSString *operator = @">=";
    [self addWherePredicateWithKey:key
                          operator:operator
                            object:number];
}

- (void)whereKey:(NSString *)key lessThan:(NSNumber *)number
{
    NSParameterAssert(number && [number isKindOfClass:[NSNumber class]]);

    NSString *operator = @"<";
    [self addWherePredicateWithKey:key
                          operator:operator
                            object:number];
}

- (void)whereKey:(NSString *)key lessThanOrEqualTo:(NSNumber *)number
{
    NSParameterAssert(number && [number isKindOfClass:[NSNumber class]]);

    NSString *operator = @"<=";
    [self addWherePredicateWithKey:key
                          operator:operator
                            object:number];
}

- (void)whereKey:(NSString *)key containedIn:(NSArray *)objects
{
    NSParameterAssert(objects);

    NSString *operator = @"IN";
    [self addWherePredicateWithKey:key
                          operator:operator
                           objects:objects];
}

- (void)whereKey:(NSString *)key notContainedIn:(NSArray *)objects
{
    NSParameterAssert(objects);

    NSString *operator = @"NOT IN";
    [self addWherePredicateWithKey:key
                          operator:operator
                           objects:objects];
}

- (void)whereKey:(NSString *)key hasPrefix:(NSString *)prefix
{
    NSString *operator = @"LIKE";
    NSString *predicate = [NSString stringWithFormat:@"%@ %@ '%@%%'", key, operator, prefix];
    [self.wherePredicates addObject:predicate];
}

- (void)whereKey:(NSString *)key hasSuffix:(NSString *)suffix;
{
    NSString *operator = @"LIKE";
    NSString *predicate = [NSString stringWithFormat:@"%@ %@ '%%%@'", key, operator, suffix];
    [self.wherePredicates addObject:predicate];
}

- (void)orderByAscending:(NSString *)key
{
    self.ascendingOrderPredicates = [@[] mutableCopy];
    [self.ascendingOrderPredicates addObject:key];
}

- (void)orderByDescending:(NSString *)key
{
    self.descendingOrderPredicates = [@[] mutableCopy];
    [self.descendingOrderPredicates addObject:key];
}

- (void)addAscendingOrder:(NSString *)key
{
    [self.ascendingOrderPredicates addObject:key];
}

- (void)addDescendingOrder:(NSString *)key
{
    [self.descendingOrderPredicates addObject:key];
}

#pragma mark - SQL execute

- (NSInteger)countObjects
{
    NSString *countKey = @"count(*)";
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@", countKey, self.tableName];

    NSArray *results = [YSKDB executeSelectQuery:query];
    NSDictionary *countInfo = [results firstObject];
    return [countInfo[countKey] integerValue];
}

- (NSDictionary *)getObject;
{
    NSString *baseQuery = [NSString stringWithFormat:@"SELECT * FROM %@", self.tableName];
    NSString *query = [self stringByAppendingWherePredicates:baseQuery];

    NSArray *results = [YSKDB executeSelectQuery:query];
    if ([results count] == 0) {
        return @{};
    }

    return [results firstObject];
}

- (NSDictionary *)getObjectWithID:(NSNumber *)ID
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", self.tableName];
    query = [query stringByAppendingFormat:@" WHERE id = %@", ID];

    NSArray *results = [YSKDB executeSelectQuery:query];
    if ([results count] == 0) {
        return @{};
    }

    return [results firstObject];
}

- (NSArray *)findObjects;
{
    NSString *query = [self constructSelectQueryWithRandom:NO];

    NSArray *results = [YSKDB executeSelectQuery:query];
    return results;
}

- (NSArray *)findRandomObjects;
{
    NSString *query = [self constructSelectQueryWithRandom:YES];

    NSArray *results = [YSKDB executeSelectQuery:query];
    return results;
}

- (BOOL)createTable:(NSDictionary *)params
{
    NSString *query = [self constructCreateQueryWithParams:params];

    return [YSKDB executeCreateQuery:query];
}

- (BOOL)insertObjects:(NSDictionary *)params
{
    NSString *query = [self constructInsertQueryWithParams:params];
    NSLog(@"query:%@", query);

    return [YSKDB executeInsertQuery:query params:params];
}

- (BOOL)updateObjects:(NSDictionary *)params
{
    NSString *query = [self constructUpdateQueryWithParams:params];
    NSLog(@"query:%@", query);

    return [YSKDB executeUpdateQuery:query params:params];
}

#pragma mark - Predicate operator

- (void)addWherePredicateWithKey:(NSString *)whereKey operator:(NSString *)operator object:(id)object
{
    NSString *predicate;
    if ([object isKindOfClass:[NSNumber class]]) {
        predicate = [NSString stringWithFormat:@"%@ %@ %@", whereKey, operator, object];
    } else {
        predicate = [NSString stringWithFormat:@"%@ %@ '%@'", whereKey, operator, object];
    }
    [self.wherePredicates addObject:predicate];
}

- (void)addWherePredicateWithKey:(NSString *)key operator:(NSString *)operator objects:(NSArray *)objects
{
    NSMutableArray *objectStrings = [@[] mutableCopy];
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if ([object isKindOfClass:[NSNumber class]]) {
            [objectStrings addObject:[NSString stringWithFormat:@"%@", object]];
        } else {
            [objectStrings addObject:[NSString stringWithFormat:@"'%@'", object]];
        }
    }];

    NSString *predicate;
    predicate = [NSString stringWithFormat:@"%@ %@ (%@)", key, operator, [objectStrings componentsJoinedByString:@", "]];
    [self.wherePredicates addObject:predicate];
}

- (NSString *)stringByAppendingWherePredicates:(NSString *)query
{
    if (self.predicate) {
        query = [query stringByAppendingFormat:@" WHERE %@", self.predicate.predicateFormat];
    } else if ([self.wherePredicates count] > 0) {
        query = [query stringByAppendingFormat:@" WHERE %@", [self.wherePredicates componentsJoinedByString:@" AND "]];
    }

    return query;
}

- (NSString *)stringByAppendingOrderPredicates:(NSString *)query
{
    if ([self.ascendingOrderPredicates count] > 0 &&
            [self.descendingOrderPredicates count] > 0) {
        query = [query stringByAppendingFormat:@" ORDER BY %@ DESC, %@", [self.descendingOrderPredicates componentsJoinedByString:@" DESC, "], [self.ascendingOrderPredicates componentsJoinedByString:@" ASC, "]];
    } else if ([self.ascendingOrderPredicates count] == 0 &&
            [self.descendingOrderPredicates count] > 0) {
        query = [query stringByAppendingFormat:@" ORDER BY %@ DESC", [self.descendingOrderPredicates componentsJoinedByString:@" DESC, "]];
    } else if ([self.ascendingOrderPredicates count] > 0 &&
            [self.descendingOrderPredicates count] == 0) {
        query = [query stringByAppendingFormat:@" ORDER BY %@ ASC", [self.ascendingOrderPredicates componentsJoinedByString:@" ASC, "]];
    }

    return query;
}

- (NSString *)stringByAppendingLimitAndOffsetPredicate:(NSString *)query
{
    if (self.limit > 0) {
        query = [query stringByAppendingFormat:@" LIMIT %d", self.limit];
    }

    if (self.skip > 0) {
        query = [query stringByAppendingFormat:@" OFFSET %d", self.skip];
    }
    return query;
}

#pragma mark - Query constructor

- (NSString *)constructSelectQueryWithRandom:(BOOL)isRandom
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", self.tableName];

    query = [self stringByAppendingWherePredicates:query];
    if (isRandom) {
        query = [query stringByAppendingString:@" ORDER BY RANDOM()"];
    } else {
        query = [self stringByAppendingOrderPredicates:query];
    }
    query = [self stringByAppendingLimitAndOffsetPredicate:query];

    return query;
}

- (NSString *)constructInsertQueryWithParams:(NSDictionary *)params
{
    NSArray *keys = [params allKeys];
    NSMutableDictionary *values = [@{} mutableCopy];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        [values setObject:@"?" forKey:@(idx)];
    }];

    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", self.tableName, [keys componentsJoinedByString:@", "], [[values allValues] componentsJoinedByString:@", "]];
    return query;
}

- (NSString *)constructUpdateQueryWithParams:(NSDictionary *)params
{
    NSMutableArray *values = [@[] mutableCopy];
    [[params allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *predicate = [NSString stringWithFormat:@"%@ = :%@", key, key];
        [values addObject:predicate];
    }];

    NSString *query = [self stringByAppendingWherePredicates:[NSString stringWithFormat:@"UPDATE %@ SET %@", self.tableName, [values componentsJoinedByString:@", "]]];
    return query;
}

- (NSString *)constructCreateQueryWithParams:(NSDictionary *)params
{
    NSMutableArray *values = [@[] mutableCopy];
    [values addObject:[NSString stringWithFormat:@"id INTEGER PRIMARY KEY AUTOINCREMENT"]];

    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *type, BOOL *stop) {
        NSAssert([self isSupportedType:type], @"Type:%@ is not supported", type);
        [values addObject:[NSString stringWithFormat:@"%@ %@", key, type]];
    }];

    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", self.tableName, [values componentsJoinedByString:@", "]];
    return query;
}

- (BOOL)isSupportedType:(NSString *)type
{
    if ([type isEqualToString:YSKDBTypeNameNull] ||
            [type isEqualToString:YSKDBTypeNameInteger] ||
            [type isEqualToString:YSKDBTypeNameReal] ||
            [type isEqualToString:YSKDBTypeNameText] ||
            [type isEqualToString:YSKDBTypeNameBlob]) {
        return YES;
    }
    return NO;
}

@end