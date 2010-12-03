//
//  EjectulateWindowController.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface EjectulateWindowController : NSWindowController <NSWindowDelegate>
{
  NSTreeController *tree;
  NSOutlineView *outline;
  NSMutableArray *volumes;
}

@property (assign) IBOutlet NSTreeController *tree;
@property (assign) IBOutlet NSOutlineView *outline;
@property (readonly, retain) NSMutableArray *volumes;

@end
