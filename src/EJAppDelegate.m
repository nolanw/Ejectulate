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


// Observed when pressing eject key. Unsure of portabiility.
#define kEJEjectKeyCode 14
// This magic layout of data1 thanks to Rogue Amoeba.
// http://www.rogueamoeba.com/utm/archives/MediaKeys.m
#define EJIsMediaKeyEvent(e) ([e type] == NSSystemDefined && [e subtype] == 8)
#define EJMediaKeyCodeWithNSEvent(e) (([e data1] & 0xFFFF0000) >> 16)
#define EJMediaKeyStateWithNSEvent(e) \
        (((([e data1] & 0x0000FFFF) & 0xFF00) >> 8) == 0xA)


@interface EJAppDelegate ()

@property (nonatomic, retain) EJWindowController *windowController;

- (void)ejectWasPressed;
- (void)listenForEject;

@end


@implementation EJAppDelegate

@synthesize windowController;

#if 0
#pragma mark -
#pragma mark API
#endif

- (void)ejectWasPressed
{
  if ([self.windowController.window isKeyWindow])
    [self.windowController.window performClose:self];
  else
  {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    // Send on next run loop iteration so a crash doesn't happen in the event 
    // tap callback.
    [self.windowController performSelector:@selector(showWindow:)
                                withObject:self
                                afterDelay:0];
  }
}

// Thanks to Kevin Gessner's post on CocoaDev for the code in the following 
// function and its following method.
// http://www.cocoabuilder.com/archive/cocoa/222356-play-pause-rew-ff-keys.html
static CGEventRef KeyDownCallback(CGEventTapProxy proxy, 
                                  CGEventType type,
                                  CGEventRef event,
                                  void *refcon)
{
  if (type != NX_SYSDEFINED)
    return event;
  NSEvent *e = [NSEvent eventWithCGEvent:event];
  // NSSystemDefined subtype 8 is a media key.
  if (EJIsMediaKeyEvent(e))
  {
		if (EJMediaKeyCodeWithNSEvent(e) == kEJEjectKeyCode)
		{
		  if (!EJMediaKeyStateWithNSEvent(e))
        [(EJAppDelegate *)refcon ejectWasPressed];
      return NULL;
    }
  }
  return event;
}

- (void)listenForEject
{
  CFMachPortRef eventTap = CGEventTapCreate(kCGSessionEventTap, 
                                            kCGHeadInsertEventTap,
                                            0,
                                            CGEventMaskBit(NX_SYSDEFINED),
                                            KeyDownCallback,
                                            self);
  if (!eventTap)
  {
    NSLog(@"%@ no tap; universal access?", NSStringFromSelector(_cmd));
    return;
  }
  CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(
                                              kCFAllocatorDefault, eventTap, 0);
  CFRunLoopAddSource(CFRunLoopGetCurrent(),
                     runLoopSource,
                     kCFRunLoopCommonModes);
  CGEventTapEnable(eventTap, true);
}

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
  [self listenForEject];
  
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
}

@end
