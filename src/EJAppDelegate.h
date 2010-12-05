//
//  EJAppDelegate.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EJEjectKeyWatcher.h"


@class EJWindowController;


@interface EJAppDelegate : NSObject <NSApplicationDelegate, 
                                     EJEjectKeyWatcherDelegate>
{
  EJWindowController *windowController;
  EJEjectKeyWatcher *ejectKeyWatcher;
}

@end
