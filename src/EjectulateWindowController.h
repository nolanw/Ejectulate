//
//  EjectulateWindowController.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <AppKit/AppKit.h>

@class EJEjectableVolumesWatcher;


@interface EjectulateWindowController : NSWindowController <NSWindowDelegate>
{
  NSTreeController *tree;
  NSOutlineView *outline;
  EJEjectableVolumesWatcher *volumesWatcher;
}

@property (assign) IBOutlet NSTreeController *tree;
@property (assign) IBOutlet NSOutlineView *outline;
@property (assign) IBOutlet EJEjectableVolumesWatcher *volumesWatcher;
@property (readonly) NSInteger tabViewIndex;

@end
