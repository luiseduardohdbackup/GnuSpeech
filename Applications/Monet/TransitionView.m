#import "TransitionView.h"

#import <AppKit/AppKit.h>
#import "AppController.h"
#import "FormulaExpression.h"
#import "Inspector.h"
#import "MonetList.h"
#import "NamedList.h"
#import "Phone.h"
#import "Point.h"
#import "PointInspector.h"
#import "ProtoEquation.h"
#import "PrototypeManager.h"
#import "ProtoTemplate.h"
#import "Slope.h"
#import "SlopeRatio.h"
#import "Target.h"
#import "TargetList.h"

@implementation TransitionView

/*===========================================================================

	Method: initFrame
	Purpose: To initialize the frame

===========================================================================*/

static NSImage *_dotMarker = nil;
static NSImage *_squareMarker = nil;
static NSImage *_triangleMarker = nil;
static NSImage *_selectionBox = nil;

+ (void)initialize;
{
    NSBundle *mainBundle;
    NSString *path;

    mainBundle = [NSBundle mainBundle];
    path = [mainBundle pathForResource:@"dotMarker" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _dotMarker = [[NSImage alloc] initWithContentsOfFile:path];

    path = [mainBundle pathForResource:@"squareMarker" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _squareMarker = [[NSImage alloc] initWithContentsOfFile:path];

    path = [mainBundle pathForResource:@"triangleMarker" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _triangleMarker = [[NSImage alloc] initWithContentsOfFile:path];

    path = [mainBundle pathForResource:@"selectionBox" ofType:@"tiff"];
    NSLog(@"path: %@", path);
    _selectionBox = [[NSImage alloc] initWithContentsOfFile:path];
}

- (id)initWithFrame:(NSRect)frameRect;
{
    if ([super initWithFrame:frameRect] == nil)
        return nil;

    cache = 100000;
    [self allocateGState];
    totalFrame = NSMakeRect(0.0, 0.0, 700.0, 380.0);

    timesFont = [[NSFont fontWithName:@"Times-Roman" size:12] retain];
    currentTemplate = nil;

    dummyPhoneList = [[MonetList alloc] initWithCapacity:4];
    displayPoints = [[MonetList alloc] initWithCapacity:12];
    displaySlopes = [[MonetList alloc] initWithCapacity:12];
    selectedPoints = [[MonetList alloc] initWithCapacity:4];

    boxRect = NSZeroRect;

    [self setNeedsDisplay:YES];

    return self;
}

- (void)dealloc;
{
    [timesFont release];
    [dummyPhoneList release];
    [displayPoints release];
    [displaySlopes release];
    [selectedPoints release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    SymbolList *symbols;
    ParameterList *mainParameterList, *mainMetaParameterList;
    Phone *aPhone;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    symbols = NXGetNamedObject(@"mainSymbolList", NSApp);
    mainParameterList = NXGetNamedObject(@"mainParameterList", NSApp);
    mainMetaParameterList = NXGetNamedObject(@"mainMetaParameterList", NSApp);

    aPhone = [[Phone alloc] initWithSymbol:@"dummy" parameters:mainParameterList metaParameters:mainMetaParameterList symbols:symbols];
    [(Target *)[[aPhone symbolList] objectAtIndex:0] setValue:100.0]; // Rule Duration
    [(Target *)[[aPhone symbolList] objectAtIndex:1] setValue:33.3333]; // Beat Location
    [(Target *)[[aPhone symbolList] objectAtIndex:2] setValue:33.3333]; // Mark 1
    [(Target *)[[aPhone symbolList] objectAtIndex:3] setValue:33.3333]; // Mark 2
    [dummyPhoneList addObject:aPhone];
    [dummyPhoneList addObject:aPhone];
    [dummyPhoneList addObject:aPhone];
    [dummyPhoneList addObject:aPhone];
    [aPhone release];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    return YES;
}

- (void)drawRect:(NSRect)rect;
{
    [self clearView];
    [self drawGrid];
    [self drawEquations];
    [self drawPhones];
    [self drawTransition];
    [self drawSlopes];

    NSLog(@"%s, boxRect: %@", _cmd, NSStringFromRect(boxRect));
    if (boxRect.size.width != 0 && boxRect.size.height != 0) {
        [[NSColor purpleColor] set];
        NSFrameRect(boxRect);
    }
}

- (void)clearView;
{
    NSDrawWhiteBezel([self bounds], [self bounds]);
}

- (void)drawGrid;
{
    int i;
    float temp = ([self bounds].size.height - 100.0) / 14.0;
    NSBezierPath *bezierPath;

    [[NSColor lightGrayColor] set];
    NSRectFill(NSMakeRect(51.0, 51.0, [self bounds].size.width - 102.0, (temp*2) - 2.0));
    NSRectFill(NSMakeRect(51.0, [self bounds].size.height - 50.0 - (temp*2), [self bounds].size.width - 102.0, (temp*2) - 1.0));

    /* Grayed out (unused) data spaces should be placed here */

    [[NSColor blackColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath moveToPoint:NSMakePoint(50.0, 50.0)];
    [bezierPath lineToPoint:NSMakePoint(50.0, [self bounds].size.height - 50.0)];
    [bezierPath lineToPoint:NSMakePoint([self bounds].size.width - 50.0, [self bounds].size.height - 50.0)];
    [bezierPath lineToPoint:NSMakePoint([self bounds].size.width - 50.0, 50.0)];
    [bezierPath lineToPoint:NSMakePoint(50.0, 50.0)];
    [bezierPath stroke];
    [bezierPath release];

    [timesFont set];
    [[NSColor blackColor] set];

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:1];

    for (i = 1; i < 14; i++) {
        NSString *label;

        [bezierPath moveToPoint:NSMakePoint(50.0, (float)i*temp + 50.0)];
        [bezierPath lineToPoint:NSMakePoint([self bounds].size.width - 50.0,  (float)i*temp + 50.0)];

        label = [NSString stringWithFormat:@"%4d%%", (i-2)*10];
        [label drawAtPoint:NSMakePoint(16.0, (float)i*temp + 45.0) withAttributes:nil];
        [label drawAtPoint:NSMakePoint([self bounds].size.width - 47.0, (float)i*temp + 45.0) withAttributes:nil];
    }
    [bezierPath stroke];
    [bezierPath release];
}

// These are the proto equations
- (void)drawEquations;
{
    int i, j;
    double symbols[5], time;
    MonetList *equationList = [NXGetNamedObject(@"prototypeManager", NSApp) equationList];
    NamedList *namedList;
    ProtoEquation *equation;
    float timeScale = ([self bounds].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    int type;
    NSBezierPath *bezierPath;

    cache++;

    if (currentTemplate)
        type = [currentTemplate type];
    else
        type = DIPHONE;

    for (i = 0; i < 5; i++) {
        symbols[i] = [[displayParameters cellAtIndex:i] doubleValue];
        NSLog(@"%s, symbols[%d] = %g", _cmd, i, symbols[i]);
    }

    [[NSColor darkGrayColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    for (i = 0; i < [equationList count]; i++) {
        namedList = [equationList objectAtIndex:i];
        //NSLog(@"named list: %@, count: %d", [namedList name], [namedList count]);
        for (j = 0; j < [namedList count]; j++) {
            equation = [namedList objectAtIndex:j];
            if ([[equation expression] maxPhone] <= type) {
                time = [equation evaluate:symbols phones:dummyPhoneList andCacheWith:cache];
                //NSLog(@"\t%@", [equation name]);
                //NSLog(@"\t\ttime = %f", time);
                //NSLog(@"equation name: %@, formula: %@, time: %f", [equation name], [[equation expression] expressionString], time);
                [bezierPath moveToPoint:NSMakePoint(50.0 + (timeScale*(float)time), 49.0)];
                [bezierPath lineToPoint:NSMakePoint(50.0 + (timeScale*(float)time), 40.0)];
            }
        }
    }

    [bezierPath stroke];
    [bezierPath release];
}

- (void)drawPhones;
{
    NSRect rect = NSMakeRect(0, 0, 8, 8);
    NSPoint myPoint;
    float timeScale;
    float currentTimePoint;
    int type;
    NSBezierPath *bezierPath;

    if (currentTemplate)
        type = [currentTemplate type];
    else
        type = DIPHONE;

    [[NSColor blackColor] set];
    [[NSColor redColor] set];
    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];

    timeScale = ([self bounds].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    myPoint.y = [self bounds].size.height - 47.0;

    switch (type) {
      case TETRAPHONE:
          currentTimePoint = (timeScale * [[displayParameters cellAtIndex:4] floatValue]);
          [bezierPath moveToPoint:NSMakePoint(50.0 + currentTimePoint, 50.0)];
          [bezierPath lineToPoint:NSMakePoint(50.0 + currentTimePoint, [self bounds].size.height - 50.0)];
          myPoint.x = currentTimePoint+47.0;
          [_squareMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];

      case TRIPHONE:
          currentTimePoint = (timeScale * [[displayParameters cellAtIndex:3] floatValue]);
          [bezierPath moveToPoint:NSMakePoint(50.0 + currentTimePoint, 50.0)];
          [bezierPath lineToPoint:NSMakePoint(50.0 + currentTimePoint, [self bounds].size.height - 50.0)];
          myPoint.x = currentTimePoint+47.0;
          [_triangleMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];

      case DIPHONE:
          currentTimePoint = (timeScale * [[displayParameters cellAtIndex:2] floatValue]);
          [bezierPath moveToPoint:NSMakePoint(50.0 + currentTimePoint, 50.0)];
          [bezierPath lineToPoint:NSMakePoint(50.0 + currentTimePoint, [self bounds].size.height - 50.0)];
          myPoint.x = currentTimePoint+47.0;
          [_dotMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
    }

    [bezierPath stroke];
    [bezierPath release];
}

- (void)drawTransition;
{
    int i;
    GSMPoint *currentPoint;
    double symbols[5];
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};
    NSRect rect = {{0.0, 0.0}, {10.0, 10.0}};
    NSPoint myPoint;
    float timeScale, yScale, y;
    float eventTime;
    GSMPoint *tempPoint;
    NSBezierPath *bezierPath;

    if (currentTemplate == nil)
        return;

    [displayPoints removeAllObjects];
    [displaySlopes removeAllObjects];

    for (i = 0; i < 5; i++)
        symbols[i] = [[displayParameters cellAtIndex:i] doubleValue];

    timeScale = ([self bounds].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    yScale = ([self bounds].size.height - 100.0)/14.0;

    cache++;

    for (i = 0; i < [[currentTemplate points] count]; i++) {
        currentPoint = [[currentTemplate points] objectAtIndex:i];
        [currentPoint calculatePoints:symbols tempos:tempos phones:dummyPhoneList andCacheWith:cache toDisplay:displayPoints];

        if ([currentPoint isKindOfClass:[SlopeRatio class]])
            [(SlopeRatio *)currentPoint displaySlopesInList:displaySlopes];
    }

    bezierPath = [[NSBezierPath alloc] init];
    [bezierPath setLineWidth:2];
    [bezierPath moveToPoint:NSMakePoint(50.0, 50.0 + (yScale*2.0))];

// TODO (2004-03-02): With the bezier path change, we may want to do the compositing after we draw the path.
    for (i = 0; i < [displayPoints count]; i++) {
        currentPoint = [displayPoints objectAtIndex:i];
        y = (float)[currentPoint value];
        if ([currentPoint expression] == nil)
            eventTime = [currentPoint freeTime];
        else
            eventTime = [[currentPoint expression] cacheValue];
        myPoint.x = timeScale * eventTime + 47.0;
        myPoint.y = (47.0 + (yScale*2.0))+ (y*yScale/10.0);
        [bezierPath lineToPoint:NSMakePoint(myPoint.x+3.0, myPoint.y+3.0)];
        switch ([currentPoint type]) {
          case TETRAPHONE:
              [_squareMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
              break;
          case TRIPHONE:
              [_triangleMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
              break;
          case DIPHONE:
              [_dotMarker compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
              break;
        }

        if (i != [displayPoints count] - 1) {
            if ([currentPoint type] == [(GSMPoint *)[displayPoints objectAtIndex:i+1] type])
                [bezierPath moveToPoint:NSMakePoint(myPoint.x+3.0, myPoint.y+3.0)];
            else
                [bezierPath moveToPoint:NSMakePoint(myPoint.x+3.0, 50.0+(yScale*2.0))];
        }
        else
            [bezierPath moveToPoint:NSMakePoint(myPoint.x+3.0, myPoint.y+3.0)];
    }
    [bezierPath lineToPoint:NSMakePoint([self bounds].size.width-50.0, [self bounds].size.height - 50.0 - (2.0*yScale))];
    [[NSColor greenColor] set];
    [bezierPath stroke];
    [bezierPath release];

//    for (i = 0; i < [displaySlopes count]; i++) {
//        currentSlope = [displaySlopes objectAtIndex:i];
//        slopeRect.origin.x = [currentSlope displayTime]*timeScale+32.0;
//        slopeRect.origin.y = 100.0;
//        slopeRect.size.height = 20.0;
//        slopeRect.size.width = 30.0;
//        NXDrawButton(&slopeRect, &bounds);
//    }

    if ([selectedPoints count]) {
        for(i = 0; i < [selectedPoints count]; i++) {
            tempPoint = [selectedPoints objectAtIndex:i];
            y = (float)[tempPoint value];
            if ([tempPoint expression] == nil)
                eventTime = [tempPoint freeTime];
            else
                eventTime = [[tempPoint expression] cacheValue];
            myPoint.x = timeScale * eventTime + 45.0;
            myPoint.y = (45.0 + (yScale*2.0))+ (y*yScale/10.0);

            //NSLog(@"Selectoion; x: %f y:%f", myPoint.x, myPoint.y);

            [_selectionBox compositeToPoint:myPoint fromRect:rect operation:NSCompositeSourceOver];
        }
    }
}

- (void)drawSlopes;
{
    int i, j;
    double start, end;
    NSRect rect = {{0.0, 10.0}, {100.0, 20.0}};
    SlopeRatio *currentPoint;
    MonetList *slopes, *points;
    float timeScale = ([self bounds].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];

    for (i = 0; i < [[currentTemplate points] count]; i++) {
        currentPoint = [[currentTemplate points] objectAtIndex:i];
        if ([currentPoint isKindOfClass:[SlopeRatio class]]) {
            start = ([currentPoint startTime]*(double)timeScale)+50.0;
            end = ([currentPoint endTime]*(double)timeScale)+50.0;
            NSLog(@"Slope  %f -> %f", start, end);
            rect.origin.x = (float) start;
            rect.size.width = (float) (end-start);
            NSDrawButton(rect, [self bounds]);

            slopes = [currentPoint slopes];
            points = [currentPoint points];
            for (j = 0; j < [slopes count]; j++) {
                NSString *str;

                str = [NSString stringWithFormat:@"%.1f", [[slopes objectAtIndex:j] slope]];
                NSLog(@"Buffer = %@", str);

                [[NSColor blackColor] set];
                [[NSColor blueColor] set];
                [str drawAtPoint:NSMakePoint(([[(GSMPoint *)[points objectAtIndex:j] expression] cacheValue])*timeScale + 55.0, 16) withAttributes:nil];
            }
        }
    }
}

#define MOVE_MASK NSLeftMouseUpMask|NSLeftMouseDraggedMask

// TODO (2004-03-10): Replace with mouseDragged: and mouseUp: methods

- (void)mouseDown:(NSEvent *)theEvent;
{
    int i;
    float row, row1, row2;
    float column, column1, column2;
    float distance, distance1;
    float timeScale = ([self bounds].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    float yScale = ([self bounds].size.height - 100.0)/14.0;
    float tempValue, startTime, endTime;
    double symbols[5];
    NSPoint mouseDownLocation = [theEvent locationInWindow];
    NSPoint origin = NSZeroPoint;
    NSEvent *newEvent;
    NSImage *tempImage;
    Slope *tempSlope = nil;
    GSMPoint *tempPoint;
    NSPoint loc;

    NSLog(@" > %s", _cmd);

    for (i = 0; i < 5; i++)
        symbols[i] = [[displayParameters cellAtIndex:i] doubleValue];

    /* Get information about the original location of the mouse event */
    mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];

    column = mouseDownLocation.x - 50.0;
    row = mouseDownLocation.y - 50.0;

    tempSlope = [self clickSlopeMarker:row:column:&startTime:&endTime];

    /* Single click mouse events */
    if ([theEvent clickCount] == 1) {
        if (tempSlope) {
            [self getSlopeInput:tempSlope:startTime:endTime];
            NSLog(@"<  %s (1)", _cmd);
            return;
        }

        [[self window] setAcceptsMouseMovedEvents:YES];
        [selectedPoints removeAllObjects];
        newEvent = [NSApp nextEventMatchingMask:NSAnyEventMask
                          untilDate:[NSDate distantFuture]
                          inMode:NSEventTrackingRunLoopMode
                          dequeue:YES];

        NSLog(@"event type: %d", [newEvent type]);
        if ([newEvent type] == NSLeftMouseUp) {
            cache++;
            distance = 100.0;
            for (i = 0; i < [displayPoints count]; i++) {
                tempPoint = [displayPoints objectAtIndex:i];
                if ([tempPoint expression] == nil)
                    column1 = (float)[tempPoint freeTime];
                else
                    column1 = (float)[[tempPoint expression] evaluate:symbols phones:dummyPhoneList andCacheWith:cache];

                column1 *= timeScale;
                row1 = (float) ((yScale*2.0)+ ([tempPoint value] *yScale/10.0));
                row1 -= row;
                column1 -=column;
                distance1 = (row1*row1)+(column1*column1);

                if (distance1 < distance) {
                    [selectedPoints removeAllObjects];
                    [selectedPoints addObject:tempPoint];
                }
            }
        } else {
            /* Draw current state of the view for compositing. */
            tempImage = [[NSImage alloc] initWithSize:[self bounds].size];
            [tempImage lockFocus];
            [self clearView];
            [self drawGrid];
            [self drawEquations];
            [self drawPhones];
            [self drawTransition];
            [self drawSlopes];
            [tempImage unlockFocus];

            /* Draw in current View */
#ifdef PORTING
            [self lockFocus];
#endif
            //PSsetinstance(TRUE);
            loc = [newEvent locationInWindow];
            while (1) {
                // TODO (2004-03-10): Limit the events that we match
                newEvent = [NSApp nextEventMatchingMask:NSAnyEventMask
                                  untilDate:[NSDate distantFuture]
                                  inMode:NSEventTrackingRunLoopMode
                                  dequeue:YES];
                NSLog(@"event type: %d", [newEvent type]);
                //PSnewinstance();
                loc = [self convertPoint:loc fromView:nil];
                if ([newEvent type] == NSLeftMouseUp)
                    break;
                boxRect.origin.x = 50.0 + column;
                boxRect.origin.y = 50.0 + row;
                boxRect.size.width = loc.x - boxRect.origin.x;
                boxRect.size.height = loc.y - boxRect.origin.y;
                boxRect.size.width = 20;
                boxRect.size.height = 10;
                [self setNeedsDisplay:YES];
                [self display];
#if 0
                [tempImage compositeToPoint:origin fromRect:[self bounds] operation:NSCompositeSourceOver];
                [[NSColor darkGrayColor] set];
                {
                    NSBezierPath *bezierPath;

                    bezierPath = [[NSBezierPath alloc] init];
                    [bezierPath moveToPoint:NSMakePoint(50.0+column, 50.0+row)];
                    [bezierPath lineToPoint:NSMakePoint(50.0+column, loc.y)];
                    [bezierPath lineToPoint:NSMakePoint(loc.x, loc.y)];
                    [bezierPath lineToPoint:NSMakePoint(loc.x, 50.0+row)];
                    [bezierPath lineToPoint:NSMakePoint(50.0+column, 50.0+row)];
                    [bezierPath stroke];
                    [bezierPath release];
                }
#endif
                [[self window] flushWindow];
            }
            //PSsetinstance(FALSE);
            loc.y -= 50.0;
            loc.x -= 50.0;
            if (row < loc.y)
                row1 = loc.y;
            else {
                row1 = row;
                row = loc.y;
            }

            if (column < loc.x)
                column1 = loc.x;
            else {
                column1 = column;
                column = loc.x;
            }
            for (i = 0; i < [displayPoints count]; i++) {
                tempPoint = [displayPoints objectAtIndex:i];
                if ([tempPoint expression] == nil)
                    column2 = (float) [tempPoint freeTime];
                else
                    column2 = (float) [[tempPoint expression] evaluate:symbols phones:dummyPhoneList andCacheWith:cache];
                column2 *= timeScale;

                row2 = (float) ((yScale*2.0)+ ([tempPoint value] *yScale/10.0));

                if ((row2 < row1) && (row2 > row))
                    if ((column2 < column1) && (column2 > column))
                        [selectedPoints addObject:tempPoint];
            }

#ifdef PORTING
            [self unlockFocus];
#endif
            [tempImage release];
        }

        [[controller inspector] inspectPoints:selectedPoints];
        [self display];
    }

    /* Double Click mouse events */
    if ([theEvent clickCount] == 2) {
        tempPoint = [[GSMPoint alloc] init];
        [tempPoint setFreeTime:column/timeScale];
        tempValue = (row - (2.0*yScale))/([self bounds].size.height - 100.0 - (4*yScale)) * 100.0;

        //NSLog(@"NewPoint Time: %f  value: %f", [tempPoint freeTime], [tempPoint value]);
        [tempPoint setValue:tempValue];
        if ([currentTemplate insertPoint:tempPoint]) {
            [selectedPoints removeAllObjects];
            [selectedPoints addObject:tempPoint];
        }

        [tempPoint release];

        [[controller inspector] inspectPoints:selectedPoints];
        [self display];
    }

    NSLog(@"<  %s", _cmd);
}

#define RETURNKEY 42

- getSlopeInput:aSlopeRatio:(float)startTime:(float)endTime;
{
    int next = 0;
    float timeScale = ([self bounds].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    NSEvent *newEvent;
    NSRect displayRect;
    char buffer[8];
    int bufferIndex = 0;
    float tempSlope;

    bzero(buffer, 8);
    [self lockFocus];

    {
        [timesFont set];
        [[NSColor blackColor] set];
        displayRect.origin.x = startTime*timeScale+51.0;
        displayRect.origin.y = 11.0;
        displayRect.size.width = (endTime-startTime)*timeScale;
        displayRect.size.height = 18.0;
        while (1) {
            NSDrawWhiteBezel(displayRect, [self bounds]);
            PSmoveto(displayRect.origin.x+3, displayRect.origin.y+4);
            [[NSColor blackColor] set];
            PSshow(buffer);
            [[self window] flushWindow];
            newEvent = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES];

            if ([newEvent type] == NSLeftMouseDown) {
                if (bufferIndex > 0) {
                    tempSlope = (float)atof(buffer);
                    [aSlopeRatio setSlope:tempSlope];
                }
                break;
            }

            if ([newEvent type] == NSKeyDown) {
                unichar ch;

                ch = [[newEvent characters] characterAtIndex:0];

                if (next == 0) {
                    switch (ch)
                    {
                      case 46:
                      case 48:
                      case 49:
                      case 50:
                      case 51:
                      case 52:
                      case 53:
                      case 54:
                      case 55:
                      case 56:
                      case 57:
                          if (bufferIndex >= 7)
                              NSBeep();
                          else
                              buffer[bufferIndex++] = (char)ch;
                          break;

                      case 3:
                      case 13:
                          tempSlope = (float)atof(buffer);
                          [aSlopeRatio setSlope:tempSlope];
                          break;
                      case 127:
                          if (bufferIndex <= 0)
                              NSBeep();
                          else
                              buffer[--bufferIndex] = '\000';
                          break;

                      default:
                          NSBeep();
                          break;
                    }

                    NSLog(@"CharCode = %d", ch);
                }

                next = 1;
            }
            if ([newEvent type] == NSKeyUp)
                next = 0;
            // TODO (2004-03-02): This is questionable, we're not sure it's a key event.
            if (([[newEvent characters] characterAtIndex:0] == 3) || ([[newEvent characters] characterAtIndex:0] == 13))
                break;
        }
        [self unlockFocus];

        [self display];
    }

    return self;
}

- clickSlopeMarker:(float)row:(float)column:(float *)startTime:(float *)endTime;
{
    MonetList *pointList;
    SlopeRatio *currentPoint;
    float timeScale = ([self bounds].size.width - 100.0) / [[displayParameters cellAtIndex:0] floatValue];
    float tempTime;
    float time1, time2;
    int i, j;

    if ( (row > -21.0) || (row < -39.0))
        return nil;

    tempTime = column/timeScale;

    NSLog(@"ClickSlopeMarker Row: %f  Col: %f  time = %f", row, column, tempTime);

    for (i = 0; i < [[currentTemplate points] count]; i++) {
        currentPoint = [[currentTemplate points] objectAtIndex:i];
        if ([currentPoint isKindOfClass:[SlopeRatio class]]) {
            if ((tempTime < [currentPoint endTime]) && (tempTime > [currentPoint startTime])) {
                pointList = [currentPoint points];
                time1 = [[pointList objectAtIndex:0] getTime];
                for (j = 1; j < [pointList count]; j++) {
                    time2 = [[pointList objectAtIndex:j] getTime];
                    if ((tempTime < time2) && (tempTime > time1)) {
                        *startTime = time1;
                        *endTime = time2;
                        return [[currentPoint slopes] objectAtIndex:j-1];
                    }

                    time1 = time2;
                }
            }
        }
    }

    return nil;
}

#ifdef PORTING
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent;
{
    NSLog(@"%d", [theEvent keyCode]);
    return YES;
}
#endif

- (void)delete:(id)sender;
{
    int i;
    GSMPoint *tempPoint;

    if ((currentTemplate == nil) || (![selectedPoints count])) {
        NSBeep();
        return;
    }

    for (i = 0; i < [selectedPoints count]; i++) {
        tempPoint = [selectedPoints objectAtIndex:i];
        if ([[currentTemplate points] indexOfObject:tempPoint]) {
            [[currentTemplate points] removeObject:tempPoint];
        }
    }

    [[controller inspector] cleanInspectorWindow];
    [selectedPoints removeAllObjects];

    [self display];
}


- (void)groupInSlopeRatio:sender;
{
    int i, index;
    int type;
    MonetList *tempPoints, *newPoints;
    SlopeRatio *tempSlopeRatio;

    if ([selectedPoints count] < 3) {
        NSBeep();
        return;
    }

    type = [(GSMPoint *)[selectedPoints objectAtIndex:0] type];
    for (i = 1; i < [selectedPoints count]; i++) {
        if (type != [(GSMPoint *)[selectedPoints objectAtIndex:i] type]) {
            NSBeep();
            return;
        }
    }

    tempPoints = [currentTemplate points];

    index = [tempPoints indexOfObject:[selectedPoints objectAtIndex:0]];
    for (i = 0; i < [selectedPoints count]; i++)
        [tempPoints removeObject:[selectedPoints objectAtIndex:i]];

    tempSlopeRatio = [[SlopeRatio alloc] init];
    newPoints = [tempSlopeRatio points];
    for (i = 0; i < [selectedPoints count]; i++)
        [newPoints addObject:[selectedPoints objectAtIndex:i]];
    [tempSlopeRatio updateSlopes];

    [tempPoints insertObject:tempSlopeRatio atIndex:index];
    [tempSlopeRatio release];

    [self display];
}

//
// Publicly used API
//

- (void)setTransition:newTransition;
{
    [selectedPoints removeAllObjects];
    currentTemplate = newTransition;

    switch ([currentTemplate type]) {
      case DIPHONE:
          [[displayParameters cellAtIndex:0] setDoubleValue:100];
          [[displayParameters cellAtIndex:1] setDoubleValue:33];
          [[displayParameters cellAtIndex:2] setDoubleValue:100];
          [[displayParameters cellAtIndex:3] setStringValue:@"--"];
          [[displayParameters cellAtIndex:4] setStringValue:@"--"];
          break;
      case TRIPHONE:
          [[displayParameters cellAtIndex:0] setDoubleValue:200];
          [[displayParameters cellAtIndex:1] setDoubleValue:33];
          [[displayParameters cellAtIndex:2] setDoubleValue:100];
          [[displayParameters cellAtIndex:3] setDoubleValue:200];
          [[displayParameters cellAtIndex:4] setStringValue:@"--"];
          break;
      case TETRAPHONE:
          [[displayParameters cellAtIndex:0] setDoubleValue:300];
          [[displayParameters cellAtIndex:1] setDoubleValue:33];
          [[displayParameters cellAtIndex:2] setDoubleValue:100];
          [[displayParameters cellAtIndex:3] setDoubleValue:200];
          [[displayParameters cellAtIndex:4] setDoubleValue:300];
          break;
    }

    [self display];
}

- (void)showWindow:(int)otherWindow;
{
    [[self window] orderWindow:NSWindowBelow relativeTo:otherWindow];
}

@end
