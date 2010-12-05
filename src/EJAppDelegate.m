//
//  EJAppDelegate.m
//  Ejectulate
//
//  Created by Nolan Waite on 10-12-02.
//  Copyright 2010 Nolan Waite. All rights reserved.
//

#import "EJAppDelegate.h"
#import "EJWindowController.h"
#import "NWLoginItems.h"


@interface EJAppDelegate ()

@property (nonatomic, retain) EJEjectKeyWatcher *ejectKeyWatcher;
@property (nonatomic, retain) EJWindowController *windowController;

@end


@implementation EJAppDelegate

@synthesize ejectKeyWatcher;
@synthesize windowController;

#if 0
#pragma mark -
#pragma mark NSObject
#endif

+ (void)initialize
{
  [[NSUserDefaults standardUserDefaults] registerDefaults:$dict(
    @"StartOnLogin", @"NO")];
}

#if 0
#pragma mark -
#pragma mark NSApplicationDelegate
#endif

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
  self.windowController = [[[EJWindowController alloc] initWithWindowNibName:
                                                    @"MainWindow"] autorelease];
  
  // Handle the user toggling option to start Ejectulate on login.
  NSUserDefaultsController *defaults;
  defaults = [NSUserDefaultsController sharedUserDefaultsController];
  [defaults addObserverForKeyPath:@"values.StartsOnLogin"
                          options:0
                             task:^(id obj, NSDictionary *change)
    {
      // For some reason the change dictionary refuses to set a useful value 
      // for new, so here we just get it ourselves.
      NSNumber *startOnLogin = [obj valueForKeyPath:@"values.StartsOnLogin"];
      if ([startOnLogin boolValue])
        [NWLoginItems addBundleToSessionLoginItems:nil];
      else
        [NWLoginItems removeBundleFromSessionLoginItems:nil];
    }];
  self.ejectKeyWatcher = [EJEjectKeyWatcher watcher];
  self.ejectKeyWatcher.delegate = self;
}

#if 0
#pragma mark -
#pragma mark EJEjectKeyWatcherDelegate
#endif

- (void)ejectWasPressed
{
  if ([self.windowController.window isKeyWindow])
    [self.windowController closeWindow];
  else
  {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.windowController showWindow];
  }
}

@end
