/* MonetList - Base list class for all MONET list classes
 *
 * Written: Adam Fedor <fedor@gnu.org>
 * Date: Dec, 2002
 */

#import "MonetList.h"

#import <Foundation/Foundation.h>

@implementation MonetList

- (id)init;
{
    return [self initWithCapacity:2];
}

- (id)initWithCapacity:(unsigned)numItems;
{
    if ([super init] == nil)
        return nil;

    ilist = [[NSMutableArray alloc] initWithCapacity:numItems];

    return self;
}

- (void)dealloc;
{
    [ilist release];
    [super dealloc];
}

- (unsigned)count;
{
    return [ilist count];
}

- (unsigned)indexOfObject:(id)anObject;
{
    return [ilist indexOfObject:anObject];
}

- (id)lastObject;
{
    return [ilist lastObject];
}

- (id)objectAtIndex:(unsigned)index;
{
    return [ilist objectAtIndex:index];
}

- (void)makeObjectsPerform:(SEL)aSelector;
{
    [ilist makeObjectsPerformSelector:aSelector];
}


- (void)addObject:(id)anObject;
{
    [ilist addObject:anObject];
}

- (void)insertObject:(id)anObject atIndex:(unsigned)index;
{
    [ilist insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(unsigned)index;
{
    [ilist removeObjectAtIndex:index];
}

- (void)removeObject:(id)anObject;
{
    [ilist removeObject:anObject];
}

- (void)replaceObjectAtIndex:(unsigned)index
                  withObject:(id)anObject;
{
    [ilist replaceObjectAtIndex:index withObject:anObject];
}


- (void)removeAllObjects;
{
    [ilist removeAllObjects];
}

- (void)removeLastObject;
{
    [ilist removeLastObject];
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:ilist];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int count;

    NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    count = 0;
    [aDecoder decodeValueOfObjCType:@encode(int) at:&count];
    NSLog(@"count: %d", count);

    if (count > 0) {
        id *array;

        array = malloc(count * sizeof(id *));
        if (array == NULL) {
            NSLog(@"malloc()'ing %d id *'s failed.", count);
        } else {
            [aDecoder decodeArrayOfObjCType:@encode(id) count:count at:array];
            NSLog(@"After decode array.");
        }
    }


    //ilist = [[aDecoder decodeObject] retain];
    NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end
