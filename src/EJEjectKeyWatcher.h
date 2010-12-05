//
//  EJEjectKeyWatcher.h
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-04.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol EJEjectKeyWatcherDelegate;


// Sends delegate a message when the eject key is pressed (unmodified).
@interface EJEjectKeyWatcher : NSObject
{
  id <EJEjectKeyWatcherDelegate> delegate;
  CFMachPortRef eventTap;
}

// The delegate is sent -ejectWasPressed, if implemented, when the eject key 
// is pressed unmodified.
@property (assign, nonatomic) id <EJEjectKeyWatcherDelegate> delegate;

// Returns autoreleased instance using default initializer.
+ (id)watcher;

@end


@protocol EJEjectKeyWatcherDelegate <NSObject>

@optional
- (void)ejectWasPressed;

@end
