//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MMToneGroupType_Statement    = 0,
    MMToneGroupType_Exclamation  = 1,
    MMToneGroupType_Question     = 2,
    MMToneGroupType_Continuation = 3,
    MMToneGroupType_Semicolon    = 4,
} MMToneGroupType;

@interface MMToneGroup : NSObject

@property (assign) NSUInteger startFootIndex;
@property (assign) NSUInteger endFootIndex;
@property (assign) MMToneGroupType type;

@end

NSString *MMToneGroupTypeName(MMToneGroupType toneGroupType);
