//
//  EjectulateAppDelegate.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EJOutlineView.h"


@interface EjectulateAppDelegate : NSObject <NSApplicationDelegate, 
                                             EJOutlineViewDelegate>
{
  NSWindow *window;
  NSMutableArray *volumes;
  EJOutlineView *outlineView;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSMutableArray *volumes;
@property (assign) IBOutlet EJOutlineView *outlineView;

@end
