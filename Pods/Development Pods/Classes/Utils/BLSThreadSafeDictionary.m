//
//  YYThreadSafeDictionary.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 14/10/21.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "BLSThreadSafeDictionary.h"


#define BLSINIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_dic) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;


#define BLSLOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);


@implementation BLSThreadSafeDictionary {
    NSMutableDictionary *_dic;  //Subclass a class cluster...
    dispatch_semaphore_t _lock;
}

#pragma mark - init

- (instancetype)init {
    BLSINIT(_dic = [[NSMutableDictionary alloc] init]);
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    BLSINIT(_dic =  [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys]);
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    BLSINIT(_dic = [[NSMutableDictionary alloc] initWithCapacity:capacity]);
}

- (instancetype)initWithObjects:(const id[])objects forKeys:(const id <NSCopying>[])keys count:(NSUInteger)cnt {
    BLSINIT(_dic = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    BLSINIT(_dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    BLSINIT(_dic = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:flag]);
}


#pragma mark - method

- (NSUInteger)count {
    BLSLOCK(NSUInteger c = _dic.count); return c;
}

- (id)objectForKey:(id)aKey {
    BLSLOCK(id o = [_dic objectForKey:aKey]); return o;
}

- (NSEnumerator *)keyEnumerator {
    BLSLOCK(NSEnumerator * e = [_dic keyEnumerator]); return e;
}

- (NSArray *)allKeys {
    BLSLOCK(NSArray * a = [_dic allKeys]); return a;
}

- (NSArray *)allKeysForObject:(id)anObject {
    BLSLOCK(NSArray * a = [_dic allKeysForObject:anObject]); return a;
}

- (NSArray *)allValues {
    BLSLOCK(NSArray * a = [_dic allValues]); return a;
}

- (NSString *)description {
    BLSLOCK(NSString * d = [_dic description]); return d;
}

- (NSString *)descriptionInStringsFileFormat {
    BLSLOCK(NSString * d = [_dic descriptionInStringsFileFormat]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale {
    BLSLOCK(NSString * d = [_dic descriptionWithLocale:locale]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    BLSLOCK(NSString * d = [_dic descriptionWithLocale:locale indent:level]); return d;
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary {
    if (otherDictionary == self) return YES;
    
    if ([otherDictionary isKindOfClass:BLSThreadSafeDictionary.class]) {
        BLSThreadSafeDictionary *other = (id)otherDictionary;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_dic isEqual:other->_dic];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (NSEnumerator *)objectEnumerator {
    BLSLOCK(NSEnumerator * e = [_dic objectEnumerator]); return e;
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {
    BLSLOCK(NSArray * a = [_dic objectsForKeys:keys notFoundMarker:marker]); return a;
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
    BLSLOCK(NSArray * a = [_dic keysSortedByValueUsingSelector:comparator]); return a;
}

- (void)getObjects:(id __unsafe_unretained[])objects andKeys:(id __unsafe_unretained[])keys {
    BLSLOCK([_dic getObjects:objects andKeys:keys]);
}

- (id)objectForKeyedSubscript:(id)key {
    BLSLOCK(id o = [_dic objectForKeyedSubscript:key]); return o;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    BLSLOCK([_dic enumerateKeysAndObjectsUsingBlock:block]);
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    BLSLOCK([_dic enumerateKeysAndObjectsWithOptions:opts usingBlock:block]);
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr {
    BLSLOCK(NSArray * a = [_dic keysSortedByValueUsingComparator:cmptr]); return a;
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    BLSLOCK(NSArray * a = [_dic keysSortedByValueWithOptions:opts usingComparator:cmptr]); return a;
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {
    BLSLOCK(NSSet * a = [_dic keysOfEntriesPassingTest:predicate]); return a;
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {
    BLSLOCK(NSSet * a = [_dic keysOfEntriesWithOptions:opts passingTest:predicate]); return a;
}

#pragma mark - mutable

- (void)removeObjectForKey:(id)aKey {
    BLSLOCK([_dic removeObjectForKey:aKey]);
}

- (void)setObject:(id)anObject forKey:(id <NSCopying> )aKey {
    BLSLOCK([_dic setObject:anObject forKey:aKey]);
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    BLSLOCK([_dic addEntriesFromDictionary:otherDictionary]);
}

- (void)removeAllObjects {
    BLSLOCK([_dic removeAllObjects]);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    BLSLOCK([_dic removeObjectsForKeys:keyArray]);
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    BLSLOCK([_dic setDictionary:otherDictionary]);
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying> )key {
    BLSLOCK([_dic setObject:obj forKeyedSubscript:key]);
}

#pragma mark - protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    BLSLOCK(id copiedDictionary = [[self.class allocWithZone:zone] initWithDictionary:_dic]);
    return copiedDictionary;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    BLSLOCK(NSUInteger count = [_dic countByEnumeratingWithState:state objects:stackbuf count:len]);
    return count;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    
    if ([object isKindOfClass:BLSThreadSafeDictionary.class]) {
        BLSThreadSafeDictionary *other = object;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_dic isEqual:other->_dic];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (NSUInteger)hash {
    BLSLOCK(NSUInteger hash = [_dic hash]);
    return hash;
}

@end
