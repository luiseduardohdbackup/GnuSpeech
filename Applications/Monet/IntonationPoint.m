#import "IntonationPoint.h"

#import <Foundation/Foundation.h>
#import "EventList.h"
#import "MyController.h"

@implementation IntonationPoint

- (id)init;
{
    if ([super init] == nil)
        return nil;

    semitone = 0.0;
    offsetTime = 0.0;
    slope = 0.0;
    ruleIndex = 0;
    eventList = nil;

    return self;
}

- (id)initWithEventList:(EventList *)aList;
{
    if ([self init] == nil)
        return nil;

    eventList = [aList retain];

    return self;
}

- (void)dealloc;
{
    [eventList release];

    [super dealloc];
}

- (EventList *)eventList;
{
    return eventList;
}

- (void)setEventList:(EventList *)aList;
{
    if (aList == eventList)
        return;

    [eventList release];
    eventList = [aList retain];
}

- (double)semitone;
{
    return semitone;
}

- (void)setSemitone:(double)newValue;
{
    semitone = newValue;
}

- (double)offsetTime;
{
    return offsetTime;
}

- (void)setOffsetTime:(double)newValue;
{
    offsetTime = newValue;
}

- (double)slope;
{
    return slope;
}

- (void)setSlope:(double)newValue;
{
    slope = newValue;
}

- (int)ruleIndex;
{
    return ruleIndex;
}

- (void)setRuleIndex:(int)newIndex;
{
    ruleIndex = newIndex;
}

- (double)absoluteTime;
{
    double time;

    time = [eventList getBeatAtIndex:ruleIndex];
    return time+offsetTime;
}

- (double)beatTime;
{
    return [eventList getBeatAtIndex: ruleIndex];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    [aDecoder decodeValuesOfObjCTypes:"dddi", &semitone, &offsetTime, &slope, &ruleIndex];
    eventList = NXGetNamedObject(@"mainEventList", NSApp);

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeValuesOfObjCTypes:"dddi", &semitone, &offsetTime, &slope, &ruleIndex];
}

#ifdef NeXT
- read:(NXTypedStream *)stream;
{
    NXReadTypes(stream, "dddi", &semitone, &offsetTime, &slope, &ruleIndex);
    eventList = NXGetNamedObject(@"mainEventList", NSApp);

    return self;
}
#endif
@end