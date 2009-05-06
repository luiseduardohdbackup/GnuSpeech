////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Dalmazio Brisinda
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MMTextToPhone.h
//  Monet
//
//  Created by Dalmazio on 05/01/09.
//
//  Version: 0.9.5
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@class GSPronunciationDictionary;

@interface MMTextToPhone : NSObject {
    GSPronunciationDictionary * pronunciationDictionary;
}

- (id) init;
- (void) dealloc;

- (void) _createDBMFileIfNecessary;

- (NSString *) phoneForText:(NSString *)text;

- (void) loadMainDictionary;

@end