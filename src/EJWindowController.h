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


@interface EJWindowController : NSWindowController <NSWindowDelegate>
{
  NSTreeController *tree;
  NSOutlineView *outline;
  EJEjectableVolumesWatcher *volumesWatcher;
  NSButton *windowTitleAccessoryView;
  NSMenu *windowTitleAccessoryMenu;
}

@property (assign) IBOutlet NSTreeController *tree;
@property (assign) IBOutlet NSOutlineView *outline;
@property (assign) IBOutlet EJEjectableVolumesWatcher *volumesWatcher;
@property (assign) IBOutlet NSButton *windowTitleAccessoryView;
@property (assign) IBOutlet NSMenu *windowTitleAccessoryMenu;
@property (readonly) NSInteger tabViewIndex;

- (void)showWindow;
- (void)closeWindow;

- (IBAction)showActionMenu:(id)sender;

@end
