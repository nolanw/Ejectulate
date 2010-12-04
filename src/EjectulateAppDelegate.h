//
//  EjectulateAppDelegate.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EjectulateWindowController;


@interface EjectulateAppDelegate : NSObject <NSApplicationDelegate>
{
  EjectulateWindowController *windowController;
}

@end
