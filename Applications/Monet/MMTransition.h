#import <Foundation/NSObject.h>

@class MonetList, MMEquation, MMPoint, NamedList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

#define DIPHONE 2
#define TRIPHONE 3
#define TETRAPHONE 4

@interface MMTransition : NSObject
{
    NamedList *nonretained_group;

    NSString *name;
    NSString *comment;
    int type;
    MonetList *points; // Of MMSlopeRatios (or maybe something else - MMPoints?)
}

- (id)init;
- (id)initWithName:(NSString *)newName;
- (void)dealloc;

- (NamedList *)group;
- (void)setGroup:(NamedList *)newGroup;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (MonetList *)points;
- (void)setPoints:(MonetList *)newList;

- (BOOL)isTimeInSlopeRatio:(double)aTime;
- (void)insertPoint:(MMPoint *)aPoint;

- (int)type;
- (void)setType:(int)type;

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)transitionPath;

- (id)initWithXMLAttributes:(NSDictionary *)attributes;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
