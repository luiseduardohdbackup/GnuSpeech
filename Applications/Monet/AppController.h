//
// $Id: AppController.h,v 1.22 2004/03/19 22:33:22 nygard Exp $
//

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================

	Object: AppController
	Purpose: Oversees the functioning of MONET

	Date: March 23, 1994

History:
	March 23, 1994
		Integrated into MONET.

===========================================================================*/

#import <Foundation/NSObject.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class NSMutableDictionary;
@class CategoryList, ParameterList, PhoneList, StringParser, SymbolList;
@class BrowserManager, DefaultMgr, EventListView, Inspector, IntonationScrollView, PrototypeManager, RuleManager, SpecialView, TransitionView;
@class MModel;
@class MDataEntryController, MPostureEditor;

@interface AppController : NSObject
{
    IBOutlet Inspector *inspectorController;
    IBOutlet NSPanel *infoPanel;

    NSMutableDictionary *namedObjects;

    MModel *model;

    IBOutlet BrowserManager *dataBrowser;
    IBOutlet RuleManager *ruleManager;
    IBOutlet PrototypeManager *prototypeManager;
    IBOutlet TransitionView *transitionBuilder;
    IBOutlet SpecialView *specialTransitionBuilder;
    IBOutlet StringParser *stringParser;
    IBOutlet EventListView *eventListView;
    IBOutlet IntonationScrollView *intonationView;

    IBOutlet DefaultMgr *defaultManager;

    /* Window pointers */
    IBOutlet NSWindow *transitionWindow;
    IBOutlet NSWindow *ruleManagerWindow;
    IBOutlet NSWindow *phonesWindow;
    IBOutlet NSWindow *ruleParserWindow;
    IBOutlet NSWindow *prototypeWindow;
    IBOutlet NSWindow *synthesisWindow;
    IBOutlet NSWindow *specialWindow;
    IBOutlet NSWindow *synthParmWindow;

    MDataEntryController *dataEntryController;
    MPostureEditor *postureEditor;
}

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)displayInfoPanel:(id)sender;
- (void)displayInspectorWindow:(id)sender;
- (Inspector *)inspector;

- (void)openFile:(id)sender;
- (void)importTRMData:(id)sender;
- (void)printData:(id)sender;


- (void)archiveToDisk:(id)sender;
- (void)readFromDisk:(id)sender;

- (void)savePrototypes:(id)sender;
- (void)loadPrototypes:(id)sender;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)removeObjectForKey:(id)key;

- (void)_disableUnconvertedClassLoading;

- (IBAction)showNewDataEntryWindow:(id)sender;
- (IBAction)showPostureEditor:(id)sender;

@end

/* Replace some obsolete NeXT functions */
#define NXNameObject(key, object, controller) \
  [[controller delegate] setObject:object forKey:key]

#define NXUnnameObject(key, controller) \
  [[controller delegate] removeObjectForKey:key]

#define NXGetNamedObject(key, controller) \
  [[controller delegate] objectForKey:key]

/* NeXT Streams */
#undef NXRead
#define NXRead(fp, buf, size) fread(buf, size, 1, fp)
