#import <AppKit/NSScrollView.h>

/*===========================================================================

	Object: IntonationView
	Purpose: Highest View in the ScrollView Hierarchy.  This view has
		two sub views.  They are intonationView and
		intonationScaleView
		NOTE: IntonationView is the "docView" of this scrollview, so its
		instance variable is in the superclass.

	Author: Craig-Richard Taube-Schock
	Date: Nov. 1, 1993

History:
	Nov. 23, 1993.  Documentation Completed.

===========================================================================*/

@interface IntonationScrollView : NSScrollView
{
    id controller;
    id scaleView;
    id utterance;
    id smoothing;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)drawRect:(NSRect)rect;
- (void)tile;
- (void)print:(id)sender;

- scaleView;

- (void)saveIntonationContour:sender;
- (void)loadContour:sender;
- (void)loadContourAndUtterance:sender;

@end
