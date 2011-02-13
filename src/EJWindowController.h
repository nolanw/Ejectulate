//
//  EJWindowController.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <AppKit/AppKit.h>


@class EJActionButton;
@class EJEjectableVolumesWatcher;


// The main Ejectulate window.
@interface EJWindowController : NSWindowController <NSWindowDelegate>
{
  NSTreeController *tree;
  NSOutlineView *outline;
  EJEjectableVolumesWatcher *volumesWatcher;
  NSButton *windowTitleAccessoryView;
  NSMenu *windowTitleAccessoryMenu;
}

// A tree-driven outline view whose content is the volumes watcher's volumes.
@property (assign, nonatomic) IBOutlet NSTreeController *tree;
@property (assign, nonatomic) IBOutlet NSOutlineView *outline;
@property (assign, nonatomic) IBOutlet EJEjectableVolumesWatcher*
                                                                 volumesWatcher;

// The action menu that sits on the window frame.
@property (assign, nonatomic) IBOutlet NSButton *windowTitleAccessoryView;
@property (assign, nonatomic) IBOutlet NSMenu *windowTitleAccessoryMenu;

// Whether there are any ejectable volumes.
@property (readonly, nonatomic) NSInteger tabViewIndex;

// Load and show the main window, ignoring other apps (since we run as an 
// agent).
- (void)showWindow;

// Close the window and hide the app so that whatever app previously had focus 
// once again has focus.
- (void)closeWindow;

// Action for the action menu button.
- (IBAction)showActionMenu:(id)sender;

// Hide Ejectulate window and show About window.
- (IBAction)showAboutPanel:(id)sender;

@end
