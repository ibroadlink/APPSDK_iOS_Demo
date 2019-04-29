
#import "BLSThreadSafeArray.h"


#define BLSINIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_arr) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;


#define BLSLOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);


@implementation BLSThreadSafeArray {
    NSMutableArray *_arr;  //Subclass a class cluster...
    dispatch_semaphore_t _lock;
}

#pragma mark - init

- (instancetype)init {
    BLSINIT(_arr = [[NSMutableArray alloc] init]);
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    BLSINIT(_arr = [[NSMutableArray alloc] initWithCapacity:numItems]);
}

- (instancetype)initWithArray:(NSArray *)array {
    BLSINIT(_arr = [[NSMutableArray alloc] initWithArray:array]);
}

- (instancetype)initWithObjects:(const id[])objects count:(NSUInteger)cnt {
    BLSINIT(_arr = [[NSMutableArray alloc] initWithObjects:objects count:cnt]);
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    BLSINIT(_arr = [[NSMutableArray alloc] initWithContentsOfFile:path]);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    BLSINIT(_arr = [[NSMutableArray alloc] initWithContentsOfURL:url]);
}

#pragma mark - method

- (NSUInteger)count {
    BLSLOCK(NSUInteger count = _arr.count); return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    BLSLOCK(id obj = [_arr objectAtIndex:index]); return obj;
}

- (NSArray *)arrayByAddingObject:(id)anObject {
    BLSLOCK(NSArray * arr = [_arr arrayByAddingObject:anObject]); return arr;
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    BLSLOCK(NSArray * arr = [_arr arrayByAddingObjectsFromArray:otherArray]); return arr;
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    BLSLOCK(NSString * str = [_arr componentsJoinedByString:separator]); return str;
}

- (BOOL)containsObject:(id)anObject {
    BLSLOCK(BOOL c = [_arr containsObject:anObject]); return c;
}

- (NSString *)description {
    BLSLOCK(NSString * d = _arr.description); return d;
}

- (NSString *)descriptionWithLocale:(id)locale {
    BLSLOCK(NSString * d = [_arr descriptionWithLocale:locale]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    BLSLOCK(NSString * d = [_arr descriptionWithLocale:locale indent:level]); return d;
}

- (id)firstObjectCommonWithArray:(NSArray *)otherArray {
    BLSLOCK(id o = [_arr firstObjectCommonWithArray:otherArray]); return o;
}

- (void)getObjects:(id __unsafe_unretained[])objects range:(NSRange)range {
    BLSLOCK([_arr getObjects:objects range:range]);
}

- (NSUInteger)indexOfObject:(id)anObject {
    BLSLOCK(NSUInteger i = [_arr indexOfObject:anObject]); return i;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    BLSLOCK(NSUInteger i = [_arr indexOfObject:anObject inRange:range]); return i;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
    BLSLOCK(NSUInteger i = [_arr indexOfObjectIdenticalTo:anObject]); return i;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    BLSLOCK(NSUInteger i = [_arr indexOfObjectIdenticalTo:anObject inRange:range]); return i;
}

- (id)firstObject {
    BLSLOCK(id o = _arr.firstObject); return o;
}

- (id)lastObject {
    BLSLOCK(id o = _arr.lastObject); return o;
}

- (NSEnumerator *)objectEnumerator {
    BLSLOCK(NSEnumerator * e = [_arr objectEnumerator]); return e;
}

- (NSEnumerator *)reverseObjectEnumerator {
    BLSLOCK(NSEnumerator * e = [_arr reverseObjectEnumerator]); return e;
}

- (NSData *)sortedArrayHint {
    BLSLOCK(NSData * d = [_arr sortedArrayHint]); return d;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context {
    BLSLOCK(NSArray * arr = [_arr sortedArrayUsingFunction:comparator context:context]) return arr;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint {
    BLSLOCK(NSArray * arr = [_arr sortedArrayUsingFunction:comparator context:context hint:hint]); return arr;
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    BLSLOCK(NSArray * arr = [_arr sortedArrayUsingSelector:comparator]); return arr;
}

- (NSArray *)subarrayWithRange:(NSRange)range {
    BLSLOCK(NSArray * arr = [_arr subarrayWithRange:range]) return arr;
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    BLSLOCK([_arr makeObjectsPerformSelector:aSelector]);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    BLSLOCK([_arr makeObjectsPerformSelector:aSelector withObject:argument]);
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    BLSLOCK(NSArray * arr = [_arr objectsAtIndexes:indexes]); return arr;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    BLSLOCK(id o = [_arr objectAtIndexedSubscript:idx]); return o;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    BLSLOCK([_arr enumerateObjectsUsingBlock:block]);
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    BLSLOCK([_arr enumerateObjectsWithOptions:opts usingBlock:block]);
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    BLSLOCK([_arr enumerateObjectsAtIndexes:s options:opts usingBlock:block]);
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    BLSLOCK(NSUInteger i = [_arr indexOfObjectPassingTest:predicate]); return i;
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    BLSLOCK(NSUInteger i = [_arr indexOfObjectWithOptions:opts passingTest:predicate]); return i;
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    BLSLOCK(NSUInteger i = [_arr indexOfObjectAtIndexes:s options:opts passingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    BLSLOCK(NSIndexSet * i = [_arr indexesOfObjectsPassingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    BLSLOCK(NSIndexSet * i = [_arr indexesOfObjectsWithOptions:opts passingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    BLSLOCK(NSIndexSet * i = [_arr indexesOfObjectsAtIndexes:s options:opts passingTest:predicate]); return i;
}

- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr {
    BLSLOCK(NSArray * a = [_arr sortedArrayUsingComparator:cmptr]); return a;
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    BLSLOCK(NSArray * a = [_arr sortedArrayWithOptions:opts usingComparator:cmptr]); return a;
}

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp {
    BLSLOCK(NSUInteger i = [_arr indexOfObject:obj inSortedRange:r options:opts usingComparator:cmp]); return i;
}

#pragma mark - mutable

- (void)addObject:(id)anObject {
    BLSLOCK([_arr addObject:anObject]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    BLSLOCK([_arr insertObject:anObject atIndex:index]);
}

- (void)removeLastObject {
    BLSLOCK([_arr removeLastObject]);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    BLSLOCK([_arr removeObjectAtIndex:index]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    BLSLOCK([_arr replaceObjectAtIndex:index withObject:anObject]);
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    BLSLOCK([_arr addObjectsFromArray:otherArray]);
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    BLSLOCK([_arr exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2]);
}

- (void)removeAllObjects {
    BLSLOCK([_arr removeAllObjects]);
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
    BLSLOCK([_arr removeObject:anObject inRange:range]);
}

- (void)removeObject:(id)anObject {
    BLSLOCK([_arr removeObject:anObject]);
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    BLSLOCK([_arr removeObjectIdenticalTo:anObject inRange:range]);
}

- (void)removeObjectIdenticalTo:(id)anObject {
    BLSLOCK([_arr removeObjectIdenticalTo:anObject]);
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    BLSLOCK([_arr removeObjectsInArray:otherArray]);
}

- (void)removeObjectsInRange:(NSRange)range {
    BLSLOCK([_arr removeObjectsInRange:range]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    BLSLOCK([_arr replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    BLSLOCK([_arr replaceObjectsInRange:range withObjectsFromArray:otherArray]);
}

- (void)setArray:(NSArray *)otherArray {
    BLSLOCK([_arr setArray:otherArray]);
}

- (void)sortUsingFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context {
    BLSLOCK([_arr sortUsingFunction:compare context:context]);
}

- (void)sortUsingSelector:(SEL)comparator {
    BLSLOCK([_arr sortUsingSelector:comparator]);
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    BLSLOCK([_arr insertObjects:objects atIndexes:indexes]);
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    BLSLOCK([_arr removeObjectsAtIndexes:indexes]);
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    BLSLOCK([_arr replaceObjectsAtIndexes:indexes withObjects:objects]);
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    BLSLOCK([_arr setObject:obj atIndexedSubscript:idx]);
}

- (void)sortUsingComparator:(NSComparator)cmptr {
    BLSLOCK([_arr sortUsingComparator:cmptr]);
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    BLSLOCK([_arr sortWithOptions:opts usingComparator:cmptr]);
}

- (BOOL)isEqualToArray:(NSArray *)otherArray {
    if (otherArray == self) return YES;
    if ([otherArray isKindOfClass:BLSThreadSafeArray.class]) {
        BLSThreadSafeArray *other = (id)otherArray;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_arr isEqualToArray:other->_arr];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

#pragma mark - protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    BLSLOCK(id copiedDictionary = [[self.class allocWithZone:zone] initWithArray:_arr]);
    return copiedDictionary;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    BLSLOCK(NSUInteger count = [_arr countByEnumeratingWithState:state objects:stackbuf count:len]);
    return count;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    
    if ([object isKindOfClass:BLSThreadSafeArray.class]) {
        BLSThreadSafeArray *other = object;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_arr isEqual:other->_arr];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (NSUInteger)hash {
    BLSLOCK(NSUInteger hash = [_arr hash]);
    return hash;
}

@end
