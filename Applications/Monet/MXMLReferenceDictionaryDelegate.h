//
// $Id$
//

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MXMLReferenceDictionaryDelegate : NSObject
{
    NSString *childElementName;
    NSString *keyAttributeName;
    NSString *referenceAttributeName;
    id delegate;
    SEL addObjectsSelector;
    NSMutableDictionary *objects;
}

- (id)initWithChildElementName:(NSString *)anElementName keyAttributeName:(NSString *)aKeyAttribute referenceAttributeName:(NSString *)aReferenceAttribute
                      delegate:(id)aDelegate addObjectsSelector:(SEL)aSelector;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
